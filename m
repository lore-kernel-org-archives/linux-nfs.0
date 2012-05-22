Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33344 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759094Ab2EVPHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 11:07:49 -0400
Date: Tue, 22 May 2012 11:07:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Simo Sorce <simo@redhat.com>, "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
Message-ID: <20120522150748.GF891@fieldses.org>
References: <1337087550-9821-1-git-send-email-simo@redhat.com>
 <1337087550-9821-4-git-send-email-simo@redhat.com>
 <20120522124728.GB891@fieldses.org>
 <1337691607.16840.178.camel@willson.li.ssimo.org>
 <4FBB91EE.3010307@parallels.com>
 <1337692966.16840.181.camel@willson.li.ssimo.org>
 <4FBB9551.9010407@parallels.com>
 <20120522142035.GC891@fieldses.org>
 <4FBBA667.4090409@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FBBA667.4090409@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 22, 2012 at 06:44:55PM +0400, Stanislav Kinsbursky wrote:
> Yep, we discussed it already.
> The problem is that connect call to unix sockets is done from rpciod
> workqueue because of selinux restrictions.
> IOW UNIX socket path will be traversed staring from rpciod kernel
> thread root. Currently this problem is existent for portmapper
> registration calls - for example LockD, started in container with
> nested root, will be registered in global rpcbind instead of local
> (container's) one.

Thanks for the reminder!

> One of solutions was to export set_fs_root(), but Al Viro doesn't like it.
> 
> So currently I'm thinking about patching network layer - i.e.
> implementing an ability to pass desired path to unix sockets connect
> and bind calls.
> IOW, I'm talking about introducing of "bindat" and "connectat" system calls...

So then we'd resolve the path in the right context and pass down a
(vfsmount, dentry) that rpciod could use in bindat/connectat calls?

> >In particular: the current svcgssd communication method is using one of
> >the sunrpc caches.  If we convert now to this method (which uses a unix
> >socket) would there be a loss in functionality, until the unix sockets
> >problems are fixed?
> >
> 
> I'm afraid, that you are right...
> This new client will connect to root daemon - not containerized one...
> How soon this new unix-socket way will become common practice?
> Maybe I'd be able to patch unix sockets before distro's will use this new version.
> But I don't know, what would be best to do...

Ugh.

Simo, remind me of the reasons for using a unix socket?

--b.
