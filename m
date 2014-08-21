Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:64022 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbaHUApQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 20:45:16 -0400
Received: by mail-ie0-f181.google.com with SMTP id rp18so3807157iec.40
        for <linux-nfs@vger.kernel.org>; Wed, 20 Aug 2014 17:45:15 -0700 (PDT)
Message-ID: <1408581916.4029.15.camel@leira.trondhjem.org>
Subject: Re: [PATCH 2/2] NFS: avoid deadlocks with loop-back mounted NFS
 filesystems.
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 20 Aug 2014 20:45:16 -0400
In-Reply-To: <20140818062254.1449.99502.stgit@notabene.brown>
References: <20140818061727.1449.89101.stgit@notabene.brown>
	 <20140818062254.1449.99502.stgit@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2014-08-18 at 16:22 +1000, NeilBrown wrote:
> Support for loop-back mounted NFS filesystems is useful when NFS is
> used to access shared storage in a high-availability cluster.
> 
> If the node running the NFS server fails, some other node can mount the
> filesystem and start providing NFS service.  If that node already had
> the filesystem NFS mounted, it will now have it loop-back mounted.
> 
> nfsd can suffer a deadlock when allocating memory and entering direct
> reclaim.
> While direct reclaim does not write to the NFS filesystem it can send
> and wait for a COMMIT through nfs_release_page().
> 
> This patch modifies nfs_release_page() and the functions it calls so
> that if the COMMIT is sent to the local host (i.e. is routed over the
> loop-back interface) then nfs_release_page() will not wait forever for
> that COMMIT to complete.  This is achieved using a new flag
> FLUSH_COND_CONNECTED.  When this is set the flush is conditional and
> will only wait if the client is connected to a non-local server.
> 
> Aborting early should be safe as kswapd uses the same code but never
> waits for the COMMIT.
> 
> Always aborting early could upset the balance of memory management so
> when the commit was sent to the local host we still wait but with a
> 100ms timeout.  This is enough to significantly slow down any process
> that is allocating lots of memory and often long enough to let the
> commit complete.
> 
> In those rare cases where it is nfsd, or something that nfsd is
> waiting for, that is calling nfs_release_page(), 100ms is not so long
> that throughput will be seriously affected.
> 
> When fail-over happens a remote (foreign) client will first become
> disconnected and then turn into a local client.
> To prevent deadlocks from happening at this point, we still have a
> timeout when the COMMIT has been sent to a remote client. In this case
> the timeout is longer (1 second).
> 
> So when a node that has mounted a remote filesystem loses the
> connection, nfs_release_page() will stop blocking and start failing.
> Memory allocators will then be able to make progress without blocking
> in NFS.  Any process which writes to a file will still be blocked in
> balance_dirty_pages().
> 
> This patch makes use of the new 'private' field in
> "struct wait_bit_key" to store the start time of a commit, so the
> 'action' function called by __wait_on_bit() knows how much longer
> it is appropriate to wait.
> 

This puts way too much RPC connection logic in the NFS layer: we really
should not have to care. Is there any reason why we could not just use
RPC_TASK_SOFTCONN to have the commit fail if the connection is broken?

Note that all this has to come with a huge WARNING: all your data may be
lost even if you think you just fsync()ed it. Is there any difference
between doing this and using the 'async' export option on the knfsd
side?

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


