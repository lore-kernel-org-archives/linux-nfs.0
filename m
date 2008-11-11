From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] rpc.gssd: Don't supply the KDC with unsupported encryption
 types
Date: Tue, 11 Nov 2008 15:05:10 -0500
Message-ID: <4919E576.6050301@RedHat.com>
References: <4919B57C.6050104@RedHat.com> <4d569c330811111033p70264b87r2463e8cb68b985e9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50319 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751192AbYKKUHH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Nov 2008 15:07:07 -0500
In-Reply-To: <4d569c330811111033p70264b87r2463e8cb68b985e9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Kevin Coffman wrote:
> Hi Steve,
> 
> This patch shouldn't be necessary.
> 
> When you say "registers with the KDC", I assume that you mean gets a
> TGT.  
I'm not sure what a TGT is... but what I talking about is the AS-REQ and AS-REP
(output from wireshark):

Kerberos AS-REQ (from rpc.gssd)
    Pvno: 5
    MSG Type: AS-REQ (10)
    KDC_REQ_BODY
        Padding: 0
        KDCOptions: 40000010 (Forwardable, Renewable OK)
        Client Name (Principal): nfs/HOST.DOMAINNAME
        Realm: REALM
        Server Name (Unknown): krbtgt/REALM
        from: 2008-11-11 12:56:53 (UTC)
        till: 2008-11-12 12:56:53 (UTC)
        Nonce: 1226408213
        Encryption Types: aes256-cts-hmac-sha1-96 aes128-cts-hmac-sha1-96 des3-cbc-sha1 rc4-hmac des-cbc-crc des-cbc-md5 des-cbc-md4 rsa-sha1-cms rsa-md5-cms des-ede3-cbc-env rc2-cbc-env rsa-env

Kerberos AS-REP (From a linux KDC)
    Pvno: 5
    MSG Type: AS-REP (11)
    padata: PA-ENCTYPE-INFO2
    Client Realm: REALM
    Client Name (Principal): nfs/HOST.home.DOMAINNAME 
    Ticket
    enc-part des-cbc-crc

So my point is what if the KDC returns something other that 'des-cbc-crc' in the
AS-REP since in the AS-REQ we says we support all those encryption types.

Again this is still all theory since still don't have a functionally 
non-linux KDC but I'm working on it...

steved.

