Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754357Ab1BQPKR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Feb 2011 10:10:17 -0500
Date: Thu, 17 Feb 2011 10:10:14 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: don't queue synchronous NFSv4 close rpc_release to
 nfsiod
Message-ID: <20110217101014.39bcc80b@barsoom.rdu.redhat.com>
In-Reply-To: <20110217084052.34a6686b@barsoom.rdu.redhat.com>
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
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 17 Feb 2011 08:40:52 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> 
> Looks like it finally failed on the 39th pass:
> 
> second check for lost reply on non-idempotent requests
> testing 50 idempotencies in directory "testdir"
> rmdir 1: Directory not empty
> special tests failed
> 
> When I look in the directory (several hours after it failed), the
> silly-renamed file is still there:
> 
> -rw---x--x. 1 root root   30 Feb 16 15:04 .nfs000000000000002d00000090
> 
> ...so I'm not sure what exactly is wrong yet, but it looks like the
> silly delete just never happened. Maybe there's a dentry refcount leak
> of some sort? There are no queued RPC's.
> 
> I'll keep looking at it but if you have ideas as to what it could be,
> let me know.
> 

I walked down the directory tree in crash on the live kernel and found
the dentry. The d_count is 0x0, so I'm not clear on why it didn't get
cleaned up:

crash> struct dentry.d_flags,d_count,d_name 0xffff880017d46a80
  d_flags = 0xc000, 
  d_count = 0x0, 
  d_name = {
    hash = 0xe08ab5c8, 
    len = 0x1c, 
    name = 0xffff880017d46ab8 ".nfs000000000000002d00000090"
  }, 


The d_flags are:

#define DCACHE_OP_REVALIDATE    0x4000
#define DCACHE_OP_DELETE        0x8000

...very odd. I'd have expected to see this one set too:

#define DCACHE_NFSFS_RENAMED  0x0002

I suppose the async sillyrename call could have failed and we ended up
calling nfs_cancel_async_unlink? I'll stick in some printk's around
that area and see if I can figure out what's going on...

-- 
Jeff Layton <jlayton@redhat.com>
