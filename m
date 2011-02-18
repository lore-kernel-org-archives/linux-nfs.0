Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30040 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758445Ab1BRUAf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Feb 2011 15:00:35 -0500
Date: Fri, 18 Feb 2011 15:04:35 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: don't queue synchronous NFSv4 close rpc_release to
 nfsiod
Message-ID: <20110218150435.3870147c@corrin.poochiereds.net>
In-Reply-To: <20110217163741.004adac8@corrin.poochiereds.net>
References: <1297781939-1400-1-git-send-email-jlayton@redhat.com>
	<1297783898.10103.22.camel@heimdal.trondhjem.org>
	<20110215113053.345e3abc@tlielax.poochiereds.net>
	<1297813624.10103.34.camel@heimdal.trondhjem.org>
	<1297865354.6596.13.camel@heimdal.trondhjem.org>
	<1297866373.6596.18.camel@heimdal.trondhjem.org>
	<20110216095002.1e7944c9@tlielax.poochiereds.net>
	<1297869677.6596.30.camel@heimdal.trondhjem.org>
	<20110216131307.0880ad00@tlielax.poochiereds.net>
	<20110217084052.34a6686b@barsoom.rdu.redhat.com>
	<20110217101014.39bcc80b@barsoom.rdu.redhat.com>
	<1297972044.2964.27.camel@heimdal.trondhjem.org>
	<20110217163741.004adac8@corrin.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 17 Feb 2011 16:37:41 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Thu, 17 Feb 2011 11:47:24 -0800
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > On Thu, 2011-02-17 at 10:10 -0500, Jeff Layton wrote: 
> > > On Thu, 17 Feb 2011 08:40:52 -0500
> > > Jeff Layton <jlayton@redhat.com> wrote:
> > > 
> > > > 
> > > > Looks like it finally failed on the 39th pass:
> > > > 
> > > > second check for lost reply on non-idempotent requests
> > > > testing 50 idempotencies in directory "testdir"
> > > > rmdir 1: Directory not empty
> > > > special tests failed
> > > > 
> > > > When I look in the directory (several hours after it failed), the
> > > > silly-renamed file is still there:
> > > > 
> > > > -rw---x--x. 1 root root   30 Feb 16 15:04 .nfs000000000000002d00000090
> > > > 
> > > > ...so I'm not sure what exactly is wrong yet, but it looks like the
> > > > silly delete just never happened. Maybe there's a dentry refcount leak
> > > > of some sort? There are no queued RPC's.
> > > > 
> > > > I'll keep looking at it but if you have ideas as to what it could be,
> > > > let me know.
> > > > 
> > > 
> > > I walked down the directory tree in crash on the live kernel and found
> > > the dentry. The d_count is 0x0, so I'm not clear on why it didn't get
> > > cleaned up:
> > > 
> > > crash> struct dentry.d_flags,d_count,d_name 0xffff880017d46a80
> > >   d_flags = 0xc000, 
> > >   d_count = 0x0, 
> > >   d_name = {
> > >     hash = 0xe08ab5c8, 
> > >     len = 0x1c, 
> > >     name = 0xffff880017d46ab8 ".nfs000000000000002d00000090"
> > >   }, 
> > > 
> > > 
> > > The d_flags are:
> > > 
> > > #define DCACHE_OP_REVALIDATE    0x4000
> > > #define DCACHE_OP_DELETE        0x8000
> > > 
> > > ...very odd. I'd have expected to see this one set too:
> > > 
> > > #define DCACHE_NFSFS_RENAMED  0x0002
> > > 
> > > I suppose the async sillyrename call could have failed and we ended up
> > > calling nfs_cancel_async_unlink? I'll stick in some printk's around
> > > that area and see if I can figure out what's going on...
> > > 
> > 
> > Perhaps I missed a call site that needs an rpc_put_task_async()?
> > 
> 
> I'm not sure that would explain what we're seeing here, unless I'm just
> missing something. I do know that nfs_cancel_async_unlink was never
> called in my latest test run, so that does not seem to be it.
> 
> Another anomaly -- d_fsdata is NULL. How do we get into that state with
> a dentry that has been silly-renamed? FWIW, here's the entire dentry
> struct with my latest reproducer. Let me know if anything stands out to
> you...
> 

My current thinking is that the problems I'm seeing here are not
directly related to the bug we're trying to fix. It looks like
sillyrename is still just plain broken a'la your email entitled:

    2.6.38-rc2... NFS sillyrename is broken...

...I'll plan to keep an eye out for the fix from Nick, and re-test this
when it hits.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
