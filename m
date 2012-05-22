Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64744 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753007Ab2EVPbN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 11:31:13 -0400
Date: Tue, 22 May 2012 11:31:06 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Simo Sorce <simo@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
Message-ID: <20120522153105.GC11739@pad.fieldses.org>
References: <1337087550-9821-4-git-send-email-simo@redhat.com>
 <20120522124728.GB891@fieldses.org>
 <1337691607.16840.178.camel@willson.li.ssimo.org>
 <4FBB91EE.3010307@parallels.com>
 <1337692966.16840.181.camel@willson.li.ssimo.org>
 <4FBB9551.9010407@parallels.com>
 <20120522142035.GC891@fieldses.org>
 <4FBBA667.4090409@parallels.com>
 <20120522150748.GF891@fieldses.org>
 <1337699781.16840.190.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1337699781.16840.190.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 22, 2012 at 11:16:21AM -0400, Simo Sorce wrote:
> On Tue, 2012-05-22 at 11:07 -0400, J. Bruce Fields wrote:
> > On Tue, May 22, 2012 at 06:44:55PM +0400, Stanislav Kinsbursky wrote:
> > > Yep, we discussed it already.
> > > The problem is that connect call to unix sockets is done from rpciod
> > > workqueue because of selinux restrictions.
> > > IOW UNIX socket path will be traversed staring from rpciod kernel
> > > thread root. Currently this problem is existent for portmapper
> > > registration calls - for example LockD, started in container with
> > > nested root, will be registered in global rpcbind instead of local
> > > (container's) one.
> > 
> > Thanks for the reminder!
> > 
> > > One of solutions was to export set_fs_root(), but Al Viro doesn't like it.
> > > 
> > > So currently I'm thinking about patching network layer - i.e.
> > > implementing an ability to pass desired path to unix sockets connect
> > > and bind calls.
> > > IOW, I'm talking about introducing of "bindat" and "connectat" system calls...
> > 
> > So then we'd resolve the path in the right context and pass down a
> > (vfsmount, dentry) that rpciod could use in bindat/connectat calls?
> > 
> > > >In particular: the current svcgssd communication method is using one of
> > > >the sunrpc caches.  If we convert now to this method (which uses a unix
> > > >socket) would there be a loss in functionality, until the unix sockets
> > > >problems are fixed?
> > > >
> > > 
> > > I'm afraid, that you are right...
> > > This new client will connect to root daemon - not containerized one...
> > > How soon this new unix-socket way will become common practice?
> > > Maybe I'd be able to patch unix sockets before distro's will use this new version.
> > > But I don't know, what would be best to do...
> > 
> > Ugh.
> > 
> > Simo, remind me of the reasons for using a unix socket?
> 
> It's an RPC protocol, and we do not want the size limitations of other
> upcall mechanisms, we really want a stream.

So what ruled out TCP over lo?

--b.
