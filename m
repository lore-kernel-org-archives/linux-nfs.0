Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:39611 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751535Ab3FVSmb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Jun 2013 14:42:31 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: James <purpleidea@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS clientaddr, kerberos
Date: Sat, 22 Jun 2013 18:42:29 +0000
Message-ID: <1371926549.9337.7.camel@leira.trondhjem.org>
References: <1371913167.28295.8.camel@freed.purpleidea.com>
	 <E910FB58-8E56-4E96-A197-B25084B135BD@oracle.com>
In-Reply-To: <E910FB58-8E56-4E96-A197-B25084B135BD@oracle.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2013-06-22 at 11:22 -0400, Chuck Lever wrote:
> On Jun 22, 2013, at 10:59 AM, James <purpleidea@gmail.com> wrote:
> 
> > Dear NFS experts, I have a few questions:
> > 
> > 1) Concerning the NFSv4 clientaddr option, I'm curious about the
> > technical details of why the server needs a callback address, and what
> > to do if the client isn't directly routable? (eg: behind NAT) I am
> > thinking of the situation with *many* clients.
> 
> If a callback path is not available, the server will not grant delegations to the client.  Delegation is simply a performance optimization.  Normal operation can proceed.
> 
> > Also, what ports need to be open on the client? Does it need to respond
> > to "NEW" traffic, or only "ESTABLISHED" or ?
> 
> Typically the client will choose a port at random.  The client's callback address and port are provided to the server by the NFSv4 SETCLIENTID operation.
> 
> The server tests the provided callback arguments with a CB_NULL request (and a new TCP connection) either at mount time or when a client application first opens a file on that server.  If the arguments do not result in a successful CB_NULL, the server simply disables delegation for that client.
> 
> You can fix the port the client uses, if you have a firewall in place and want to leave an open port.  A kernel command-line parameter is used on the client:
> 
>         nfs.callback_tcpport=
>                         [NFS] set the TCP port on which the NFSv4 callback
>                         channel should listen.
> 
> Although, these days, it may be a per-namespace thing.  A quick browse of the documentation wasn't revealing.

Kernel parameters cannot be per-namespace; containers don't boot a
separate kernel.

Note that if you have compiled nfs as a module, you will want to do
something along the lines of:

	echo "options nfs callback_tcpport=<port>" >>/etc/modprobe.d/options-local.conf

Also note that this requirement is for NFSv4 only. NFSv4.1 callbacks use
the same connection as the outgoing RPC calls, and so support callbacks
through NAT without requiring you to open for incoming connections.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
