class Email
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :subject, :type => String  
  field :body, :type => String
  field :from_name, :type => String  
  field :from_email, :type => String
  field :from_postcode, :type => String
  
  belongs_to :decision
  
  validates_presence_of :subject, :body, :from_name, :from_email, :from_postcode, :decision
        
  def self.admin_fields
    {
      :subject => :text,
      :body => :text_area,
      :from_name => :text,
      :from_email => :email,
      :from_postcode => :text
    }
  end
  
  def self.human_attribute_name(attr, options={})  
    {
      :from_name => 'Your name',
      :from_email => 'Your email address',
      :from_postcode => 'Your postcode',
    }[attr.to_sym] || super  
  end   
  
  def body_with_additions
    "Dear #{decision.representative.address_as || decision.representative.name},\n\n#{body}\n\nYours sincerely,\n\n#{from_name}\n#{from_postcode}"
  end
  
  after_create :send_email
  def send_email
    mail = Mail.new
    mail.to = decision.representative.email
    mail.from = from_email
    mail.bcc = from_email
    mail.subject = subject
    mail.body = body_with_additions
    mail.deliver 
  end
    
end
