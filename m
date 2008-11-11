From: "Kevin Coffman" <kwc@umich.edu>
Subject: Re: [PATCH] rpc.gssd: Don't supply the KDC with unsupported encryption types
Date: Tue, 11 Nov 2008 16:01:01 -0500
Message-ID: <4d569c330811111301r5948b77rd6125ffc0b950d88@mail.gmail.com>
References: <4919B57C.6050104@RedHat.com>
	 <4d569c330811111033p70264b87r2463e8cb68b985e9@mail.gmail.com>
	 <4919E576.6050301@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Steve Dickson" <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:32118 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbYKKVBD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Nov 2008 16:01:03 -0500
Received: by an-out-0708.google.com with SMTP id d40so62799and.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 Nov 2008 13:01:01 -0800 (PST)
In-Reply-To: <4919E576.6050301-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 11, 2008 at 3:05 PM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
> Kevin Coffman wrote:
>> Hi Steve,
>>
>> This patch shouldn't be necessary.
>>
>> When you say "registers with the KDC", I assume that you mean gets a
>> TGT.
> I'm not sure what a TGT is... but what I talking about is the AS-REQ and AS-REP
> (output from wireshark):
>
> Kerberos AS-REQ (from rpc.gssd)
>    Pvno: 5
>    MSG Type: AS-REQ (10)
>    KDC_REQ_BODY
>        Padding: 0
>        KDCOptions: 40000010 (Forwardable, Renewable OK)
>        Client Name (Principal): nfs/HOST.DOMAINNAME
>        Realm: REALM
>        Server Name (Unknown): krbtgt/REALM
>        from: 2008-11-11 12:56:53 (UTC)
>        till: 2008-11-12 12:56:53 (UTC)
>        Nonce: 1226408213
>        Encryption Types: aes256-cts-hmac-sha1-96 aes128-cts-hmac-sha1-96 des3-cbc-sha1 rc4-hmac des-cbc-crc des-cbc-md5 des-cbc-md4 rsa-sha1-cms rsa-md5-cms des-ede3-cbc-env rc2-cbc-env rsa-env
>
> Kerberos AS-REP (From a linux KDC)
>    Pvno: 5
>    MSG Type: AS-REP (11)
>    padata: PA-ENCTYPE-INFO2
>    Client Realm: REALM
>    Client Name (Principal): nfs/HOST.home.DOMAINNAME
>    Ticket
>    enc-part des-cbc-crc
>
> So my point is what if the KDC returns something other that 'des-cbc-crc' in the
> AS-REP since in the AS-REQ we says we support all those encryption types.
>
> Again this is still all theory since still don't have a functionally
> non-linux KDC but I'm working on it...
>
> steved.

The AS-REQ (Authentication Service) is a request for a TGT (aka,
Ticket-Granting-Ticket).  This is a ticket issued by the KDC to a
principal after verifying her identity (by verifying her password).
This ticket is good for a period of time, allowing that principal to
get tickets for other services, such as NFS, without having to use her
password for every request.  (Her password doesn't even go to the KDC
for the AS-REQ.  It is used to generate a key locally, which is used
to encrypt something locally, which is sent in the AS-REQ.)

This is the exchange your patch is limiting to only DES.  That is unnecessary.

The tickets for other services (like NFS) (aka Service Tickets) are
obtained using a TGS-REQ (Ticket Granting Service).  The TGT returned
in the AS-REP is used to form the TGS request -- to verify it is still
the same principal.  This is where the code in gssd currently limits
the encryption types that can be negotiated.  We only want limit the
encryption types for the session key in the NFS Service Ticket, not
for all the service tickets obtained using that TGT.  That is also why
we DO NOT want to have

default_tkt_enctypes = des-cbc-crc    # Don't do this!
default_tgs_enctypes = des-cbc-crc    # Don't do this!

in the /etc/krb5.conf file.  Those limit all negotiations to only using DES.


Also, it shouldn't matter if the KDC is a Linux KDC or a Solaris KDC.
Modern versions of both KDCs support many encryption types besides
DES.  (As you can see above.)

Now the Solaris NFS client and server can handle more encryption types
than Linux at the moment.  That is why it is important to limit the
encryption types to only DES when creating the keytab entry for the
nfs/<hostname>@REALM principal for Linux machines.  That gives the KDC
the information it needs to only issue a Service Ticket with only a
DES session key to a Solaris NFS client when it is going to talk to a
Linux NFS server.

Hopefully this clears up a little without raising too many more questions!

K.C.
