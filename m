From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] rpc.gssd: Don't supply the KDC with unsupported encryption
 types
Date: Tue, 25 Nov 2008 09:50:55 -0500
Message-ID: <492C10CF.7040902@RedHat.com>
References: <4919B57C.6050104@RedHat.com>	 <4d569c330811111033p70264b87r2463e8cb68b985e9@mail.gmail.com>	 <4919E576.6050301@RedHat.com> <4d569c330811111301r5948b77rd6125ffc0b950d88@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56803 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379AbYKYOxI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2008 09:53:08 -0500
In-Reply-To: <4d569c330811111301r5948b77rd6125ffc0b950d88-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kevin Coffman wrote:
> The AS-REQ (Authentication Service) is a request for a TGT (aka,
> Ticket-Granting-Ticket).  This is a ticket issued by the KDC to a
> principal after verifying her identity (by verifying her password).
> This ticket is good for a period of time, allowing that principal to
> get tickets for other services, such as NFS, without having to use her
> password for every request.  (Her password doesn't even go to the KDC
> for the AS-REQ.  It is used to generate a key locally, which is used
> to encrypt something locally, which is sent in the AS-REQ.)
> 
> This is the exchange your patch is limiting to only DES.  That is unnecessary.
> 
> The tickets for other services (like NFS) (aka Service Tickets) are
> obtained using a TGS-REQ (Ticket Granting Service).  The TGT returned
> in the AS-REP is used to form the TGS request -- to verify it is still
> the same principal.  This is where the code in gssd currently limits
> the encryption types that can be negotiated.  We only want limit the
> encryption types for the session key in the NFS Service Ticket, not
> for all the service tickets obtained using that TGT.  That is also why
> we DO NOT want to have
> 
> default_tkt_enctypes = des-cbc-crc    # Don't do this!
> default_tgs_enctypes = des-cbc-crc    # Don't do this!
> 
> in the /etc/krb5.conf file.  Those limit all negotiations to only using DES.
> 
> 
> Also, it shouldn't matter if the KDC is a Linux KDC or a Solaris KDC.
> Modern versions of both KDCs support many encryption types besides
> DES.  (As you can see above.)
> 
> Now the Solaris NFS client and server can handle more encryption types
> than Linux at the moment.  That is why it is important to limit the
> encryption types to only DES when creating the keytab entry for the
> nfs/<hostname>@REALM principal for Linux machines.  That gives the KDC
> the information it needs to only issue a Service Ticket with only a
> DES session key to a Solaris NFS client when it is going to talk to a
> Linux NFS server.
> 
> Hopefully this clears up a little without raising too many more questions!
It did... thanks!

It turns out there was bug in krb5-libs... Image that! 8-)

steved.

