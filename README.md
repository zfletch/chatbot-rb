chatbot-rb
==========

Simple ruby chatbot

Description
-----------

At different times, I've had to write chatbots for XMPP/Jabber and IRC and
re-implimented basically the same thing twice. I decided to combine
the code and create one chatbot with multiple back ends that basically
works the same regardless of which back end is being used.

Supported protocols
-------------------

Right now only XMPP/Jabber is supported through the ruby gem xmpp4r.

Required gems
-------------

 - xmpp4r
 - eventmachine

