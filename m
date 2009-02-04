From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Use AF_INET6 NFSv4 callback listener only if IPv6
 is built in
Date: Wed, 04 Feb 2009 14:39:21 -0500
Message-ID: <1233776361.7161.67.camel@heimdal.trondhjem.org>
References: <20090204164857.26771.31809.stgit@ingres.1015granger.net>
	 <96EEB7FB-3E36-4F1C-8570-D2A6BB758A79@oracle.com>
	 <1233772405.7161.45.camel@heimdal.trondhjem.org>
	 <8D75C60F-AA91-46B6-B9AA-C679417C4948@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:47830 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752170AbZBDTjZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Feb 2009 14:39:25 -0500
In-Reply-To: <8D75C60F-AA91-46B6-B9AA-C679417C4948@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-02-04 at 14:04 -0500, Chuck Lever wrote:
> On Feb 4, 2009, at Feb 4, 2009, 1:33 PM, Trond Myklebust wrote:
> > On Wed, 2009-02-04 at 11:56 -0500, Chuck Lever wrote:
> >> Sorry, "fixing" is a bit too strong.  I mean working around the issue
> >> until we have a long-term solution.
> >
> > This isn't an acceptable workaround, since it causes a regression for
> > those people who do have IPv6 enabled as a module. i.e. me...
> 
> Don't you just get normal AF_INET callbacks in that case?
> 
> Is the problem that you are using an IPv6 mount address, and want to  
> ensure your callback service and lockd are listening on AF_INET6?   
> That dependency web is a problem, and for a workaround we can also  
> disable IPv6 mounts if IPv6 support is built as a module.
> 
> > The real problem here is the existence of serv->sv_family, which
> > basically means that we need to decide whether or not we want IPv6
> > functionality when we set up the server, instead of when we set up the
> > transport. Why do we need this in the first place?
> 
> 1.  we don't want to create an AF_INET6 listener for kernel RPC  
> services that can't yet support it (ie just NFSD at this point).

I'm not advocating changing all sockets to AF_INET6. I'm advocating
adding a socket family parameter to svc_create_xprt() so that
IPv6-capable services like nfs_callback_up() can first try to set up
service using AF_INET6 socket, then fall back to calling
svc_create_xprt() again with AF_INET in case of ipv6 service failure.

> 2.  svc_create() handles rpcbind registration, so it needs to know  
> whether to register both inet and inet6 netids or just inet.  Maybe we  
> should move the svc_register call to svc_create_xprt() ?

Where does svc_create() do rpcbind? AFAICS, svc_register is called by
svc_setup_socket(), which again is called by svc_create_xprt(). You've
got to set up the listening socket before you can register the service
with rpcbind, so I can't see how it could be done any other way.

> 3.  sock_create(AF_INET6) would pin ipv6.ko, but NFSD allows listener  
> sockets to come and go.  I would rather just pin ipv6.ko for the  
> duration, and unpin it in svc_destroy.  Again, svc_create_xprt might  
> be a place to do that.

It's the obvious place, since that's what creates and destroys the
socket.

Trond

