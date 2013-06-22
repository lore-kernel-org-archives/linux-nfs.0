Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:49611 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab3FVPW5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Jun 2013 11:22:57 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: NFS clientaddr, kerberos
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1371913167.28295.8.camel@freed.purpleidea.com>
Date: Sat, 22 Jun 2013 11:22:52 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <E910FB58-8E56-4E96-A197-B25084B135BD@oracle.com>
References: <1371913167.28295.8.camel@freed.purpleidea.com>
To: James <purpleidea@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 22, 2013, at 10:59 AM, James <purpleidea@gmail.com> wrote:

> Dear NFS experts, I have a few questions:
> 
> 1) Concerning the NFSv4 clientaddr option, I'm curious about the
> technical details of why the server needs a callback address, and what
> to do if the client isn't directly routable? (eg: behind NAT) I am
> thinking of the situation with *many* clients.

If a callback path is not available, the server will not grant delegations to the client.  Delegation is simply a performance optimization.  Normal operation can proceed.

> Also, what ports need to be open on the client? Does it need to respond
> to "NEW" traffic, or only "ESTABLISHED" or ?

Typically the client will choose a port at random.  The client's callback address and port are provided to the server by the NFSv4 SETCLIENTID operation.

The server tests the provided callback arguments with a CB_NULL request (and a new TCP connection) either at mount time or when a client application first opens a file on that server.  If the arguments do not result in a successful CB_NULL, the server simply disables delegation for that client.

You can fix the port the client uses, if you have a firewall in place and want to leave an open port.  A kernel command-line parameter is used on the client:

        nfs.callback_tcpport=
                        [NFS] set the TCP port on which the NFSv4 callback
                        channel should listen.

Although, these days, it may be a per-namespace thing.  A quick browse of the documentation wasn't revealing.

> 2) In /etc/exports, for an NFSv4 export, you often see docs suggesting:
> sec=sys,krb5,krb5i,krb5p OR the same but without the 'sys' part. If you
> instead do 'sec=krb5p' will this *force* clients to use full encryption
> and authentication, and deny those who try to mount without sec=krb5p ?
> In particular, if a client tries to mount with sec=krb5i, what should
> happen? For some reason I haven't seen anyone just use 'sec=krb5p' and I
> wanted to know what was up.

If you specify "sec=krb5p" for an export, clients can mount that export only using sec=krb5p.  Thus a mount command that specifies sec=krb5i should fail with EACCES.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




