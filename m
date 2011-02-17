Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11046 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752519Ab1BQVdm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Feb 2011 16:33:42 -0500
Date: Thu, 17 Feb 2011 16:37:41 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: don't queue synchronous NFSv4 close rpc_release to
 nfsiod
Message-ID: <20110217163741.004adac8@corrin.poochiereds.net>
In-Reply-To: <1297972044.2964.27.camel@heimdal.trondhjem.org>
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
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 17 Feb 2011 11:47:24 -0800
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2011-02-17 at 10:10 -0500, Jeff Layton wrote: 
> > On Thu, 17 Feb 2011 08:40:52 -0500
> > Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > > 
> > > Looks like it finally failed on the 39th pass:
> > > 
> > > second check for lost reply on non-idempotent requests
> > > testing 50 idempotencies in directory "testdir"
> > > rmdir 1: Directory not empty
> > > special tests failed
> > > 
> > > When I look in the directory (several hours after it failed), the
> > > silly-renamed file is still there:
> > > 
> > > -rw---x--x. 1 root root   30 Feb 16 15:04 .nfs000000000000002d00000090
> > > 
> > > ...so I'm not sure what exactly is wrong yet, but it looks like the
> > > silly delete just never happened. Maybe there's a dentry refcount leak
> > > of some sort? There are no queued RPC's.
> > > 
> > > I'll keep looking at it but if you have ideas as to what it could be,
> > > let me know.
> > > 
> > 
> > I walked down the directory tree in crash on the live kernel and found
> > the dentry. The d_count is 0x0, so I'm not clear on why it didn't get
> > cleaned up:
> > 
> > crash> struct dentry.d_flags,d_count,d_name 0xffff880017d46a80
> >   d_flags = 0xc000, 
> >   d_count = 0x0, 
> >   d_name = {
> >     hash = 0xe08ab5c8, 
> >     len = 0x1c, 
> >     name = 0xffff880017d46ab8 ".nfs000000000000002d00000090"
> >   }, 
> > 
> > 
> > The d_flags are:
> > 
> > #define DCACHE_OP_REVALIDATE    0x4000
> > #define DCACHE_OP_DELETE        0x8000
> > 
> > ...very odd. I'd have expected to see this one set too:
> > 
> > #define DCACHE_NFSFS_RENAMED  0x0002
> > 
> > I suppose the async sillyrename call could have failed and we ended up
> > calling nfs_cancel_async_unlink? I'll stick in some printk's around
> > that area and see if I can figure out what's going on...
> > 
> 
> Perhaps I missed a call site that needs an rpc_put_task_async()?
> 

I'm not sure that would explain what we're seeing here, unless I'm just
missing something. I do know that nfs_cancel_async_unlink was never
called in my latest test run, so that does not seem to be it.

Another anomaly -- d_fsdata is NULL. How do we get into that state with
a dentry that has been silly-renamed? FWIW, here's the entire dentry
struct with my latest reproducer. Let me know if anything stands out to
you...

ffff880017d68e70
struct dentry {
  d_flags = 0xc008, 
  d_seq = {
    sequence = 0x2
  }, 
  d_hash = {
    next = 0x0, 
    pprev = 0xffffc900000b45d0
  }, 
  d_parent = 0xffff880017e50e70, 
  d_name = {
    hash = 0xe08a8918, 
    len = 0x1c, 
    name = 0xffff880017d68ea8 ".nfs000000000000002d00000031"
  }, 
  d_inode = 0xffff88002cec1070, 
  d_iname = ".nfs000000000000002d00000031\000kkk", 
  d_count = 0x0, 
  d_lock = {
    {
      rlock = {
        raw_lock = {
          slock = 0x180018
        }, 
        magic = 0xdead4ead, 
        owner_cpu = 0xffffffff, 
        owner = 0xffffffffffffffff, 
        dep_map = {
          key = 0xffffffff827df728, 
          class_cache = {0x0, 0x0}, 
          name = 0xffffffff817cb493 "&(&dentry->d_lock)->rlock", 
          cpu = 0x1, 
          ip = 0xffffffff811467bc
        }
      }, 
      {
        __padding = "\030\000\030\000\255N\255\336\377\377\377\377kkkk\377\377\377\377\377\377\377\377", 
        dep_map = {
          key = 0xffffffff827df728, 
          class_cache = {0x0, 0x0}, 
          name = 0xffffffff817cb493 "&(&dentry->d_lock)->rlock", 
          cpu = 0x1, 
          ip = 0xffffffff811467bc
        }
      }
    }
  }, 
  d_op = 0xffffffffa01402c0, 
  d_sb = 0xffff88003436b9f8, 
  d_time = 0x5a5a5a5a5a5a5a65, 
  d_fsdata = 0x0, 
  d_lru = {
    next = 0xffff880017e50f38, 
    prev = 0xffff88003436bbd0
  }, 
  d_u = {
    d_child = {
      next = 0xffff880017e50f58, 
      prev = 0xffff880017e50f58
    }, 
    d_rcu = {
      next = 0xffff880017e50f58, 
      func = 0xffff880017e50f58
    }
  }, 
  d_subdirs = {
    next = 0xffff880017d68f58, 
    prev = 0xffff880017d68f58
  }, 
  d_alias = {
    next = 0xffff88002cec11d8, 
    prev = 0xffff88002cec11d8
  }
}

-- 
Jeff Layton <jlayton@redhat.com>
