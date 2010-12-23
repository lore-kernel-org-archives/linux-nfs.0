Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42898 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541Ab0LWATV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Dec 2010 19:19:21 -0500
Subject: Re: [PATCH 15/15] pnfs: layout roc code
Content-Type: text/plain; charset=us-ascii
From: Fred Isaman <iisaman@netapp.com>
In-Reply-To: <1293055210.6422.23.camel@heimdal.trondhjem.org>
Date: Wed, 22 Dec 2010 19:19:19 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <8EF8E6E3-D746-4E1E-BFCB-143921A5A76E@netapp.com>
References: <1292990449-20057-1-git-send-email-iisaman@netapp.com> <1292990449-20057-16-git-send-email-iisaman@netapp.com> <1293055210.6422.23.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 22, 2010, at 5:00 PM, Trond Myklebust wrote:

> On Tue, 2010-12-21 at 23:00 -0500, Fred Isaman wrote:
>> A lsyout can request return-on-close.  How this interacts with the
>> forgetful model of never sending LAYOUTRETURNS is a bit ambiguous.
>> We forget any layouts marked roc, and wait for them to be completely
>> forgotten before continuing with the close.  In addition, to compensate
>> for races with any inflight LAYOUTGETs, and the fact that we do not get
>> any layout stateid back from the server, we set the barrier to the worst
>> case scenario of current_seqid + number of outstanding LAYOUTGETS.
>> 
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>> fs/nfs/inode.c         |    1 +
>> fs/nfs/nfs4_fs.h       |    2 +-
>> fs/nfs/nfs4proc.c      |   21 +++++++++++-
>> fs/nfs/nfs4state.c     |    7 +++-
>> fs/nfs/pnfs.c          |   83 ++++++++++++++++++++++++++++++++++++++++++++++++
>> fs/nfs/pnfs.h          |   28 ++++++++++++++++
>> include/linux/nfs_fs.h |    1 +
>> 7 files changed, 138 insertions(+), 5 deletions(-)
>> 
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 43a69da..c64bb40 100644
>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>> index 29d504d..90515de 100644
>> --- a/include/linux/nfs_fs.h
>> +++ b/include/linux/nfs_fs.h
>> @@ -190,6 +190,7 @@ struct nfs_inode {
>> 	struct rw_semaphore	rwsem;
>> 
>> 	/* pNFS layout information */
>> +	struct rpc_wait_queue lo_rpcwaitq;
>> 	struct pnfs_layout_hdr *layout;
>> #endif /* CONFIG_NFS_V4*/
>> #ifdef CONFIG_NFS_FSCACHE
> 
> I believe that I've asked this before. Why do we need a per-inode
> rpc_wait_queue just to support pnfs? That's a significant expansion of
> an already bloated structure.
> 
> Can we please either make this a single per-filesystem wait queue, or
> else possibly a pool of wait queues?
> 
> Trond

This was introduced to avoid deadlocks that were occurring when we had a single wait queue.   However, the deadlocks I remember were due to a combination of the fact that, at the time, we handled EAGAIN errors of IO outside the RPC code, and we sent LAYOUTRETURN on such error.  Since we do neither now, I believe a single per-filesystem wait queue will suffice.  Anyone disagree?

Fred

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

