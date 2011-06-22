Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19652 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759140Ab1FVWs4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 18:48:56 -0400
Subject: Re: [nfs, rpc] crap with refcounting and rmmod races
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Jun 2011 18:48:54 -0400
In-Reply-To: <20110622215145.GF11521@ZenIV.linux.org.uk>
References: <20110622191239.GD11521@ZenIV.linux.org.uk>
	 <20110622215145.GF11521@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1308782934.25875.22.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-06-22 at 22:51 +0100, Al Viro wrote: 
> On Wed, Jun 22, 2011 at 08:12:40PM +0100, Al Viro wrote:
> 
> > 	Note that extra references to vfsmount do not prevent umount from
> > removing the sucker from the tree and dropping the preexisting reference
> > to it.  umount -l will do that just fine.
> > 
> > 	This thing is called as ->rpc_release(); do we have anything
> > protecting the issuer of rpc_run_task() from being rmmod'ed before (or
> > during) the call of ->rpc_release()?
> 
> Ah, I see...  All these suckers end up running from rpc_task_free(),
> scheduled via nfsiod_workqueue.  Reference to vfsmount or superblock
> (in case of async_unlink; async close should also use nfs_sb_{,de}active()
> instead of playing with vfsmounts, BTW) pins the module down until we

It is fairly trivial to define a 'struct nfs_path' that takes a
reference to the dentry and a reference to the super block if you'd
prefer that we get rid of the 'struct path' in nfs_open_context.

> are into the ->rpc_release() in question.  And rmmod nfd done after
> that point will wait in destroy_workqueue() called by nfsiod_stop().
> 
> Subtle and worth documenting explicitly, IMO...

The same thing is true for the sunrpc module: the rmmod sunrpc will wait
in the destroy_workqueue() for rpciod until all the remaining
asynchronous rpc tasks are done. That is documented in the changelog, at
least, but I agree that we can add a few comments in the code too.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

