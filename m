Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f181.google.com ([209.85.212.181]:52836 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343AbaHXRtU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2014 13:49:20 -0400
Received: by mail-wi0-f181.google.com with SMTP id bs8so1583429wib.14
        for <linux-nfs@vger.kernel.org>; Sun, 24 Aug 2014 10:49:19 -0700 (PDT)
Message-ID: <53FA259C.9050807@gmail.com>
Date: Sun, 24 Aug 2014 20:49:16 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/19] pnfs: force a layout commit when encountering busy
 segments during recall
References: <pnfs block layout driver fixes V2> <1408637375-11343-1-git-send-email-hch@lst.de> <1408637375-11343-4-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-4-git-send-email-hch@lst.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/21/2014 07:09 PM, Christoph Hellwig wrote:
> Expedite layout recall processing by forcing a layout commit when
> we see busy segments.  Without it the layout recall might have to wait
> until the VM decided to start writeback for the file, which can introduce
> long delays.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Good god, Hi Christoph

I've been sitting on client RECALL bugs over a year NOW. I have you scenario
but actually a real DEAD-LOCK instead of an annoying delay.

You have the same deadlock only it is harder for you to hit, with objects
layout it is very easy to reproduce. (Files layout would have the same
bug if it would support segments)

The scenario is as follows:

* Client is doing a LAYOUT_GET and is returned RECALL_CONFLICT

  Comment: If your server is serious about it's recalls, then all the
  while a recall is in progress it will return RECALL_CONFLICT on any
  segment in conflict with the RECALL.
  In objects layout this is easy to hit, because the LAYOUT_GET itself
  may cause the issue of the RECALL, because if the objects map grows
  do to the current LAYOUT_GET then all clients are RECALLed including
  the one issuing the call.
  But this can also happen when one client caused an operation that
  sends a RECALL on our client while our client is in the middle of
  issuing a LAYOUT_GET.

  So our client is stuck in LAYOUT_GET until RECALL from self is
  satisfied.

* The RECALL is received but LAYOUTs are busy because they need
  a LAYOUTCOMMIT. ERR_DELAY is returned.

  Note the server will busy loop on RECALLs until success (NO_MATCHING_LAYOUT)

* Ha ha. LAYOUTCOMMIT will never be called because our client is stuck inside
  LAYOUTGET, and we only call LAYOUTCOMMIT from update_inode() but LAYOUTGET
  is already in an update_inode and VFS will not concurrently call update_inode()
  twice, it will always wait for one to finish in order to notice the inode_dirty
  flag and issue a new one.

   So now we are dead-locked, LAYOUT_GET will wait for the Server to finish the
   RECALL, and will pole for LAYOUT.
   Server is stuck on Polling RECALL, waiting for the client to do a LO_COMMIT
   but this one will never happen because it is waiting for the LAYOUT_GET to
   return.

* The way to try and solve this is like you did below by pushing an immediate
  LAYOUTCOMMIT as part of the recall thread and thous releasing the segments.

I had a slight different solution though

> ---
>  fs/nfs/callback_proc.c | 16 +++++++++++-----
>  fs/nfs/pnfs.c          |  3 +++
>  2 files changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 41db525..bf017b0 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -164,6 +164,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>  	struct inode *ino;
>  	struct pnfs_layout_hdr *lo;
>  	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
> +	bool need_commit = false;
>  	LIST_HEAD(free_me_list);
>  
>  	lo = get_layout_by_fh(clp, &args->cbl_fh, &args->cbl_stateid);
> @@ -172,16 +173,21 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>  
>  	ino = lo->plh_inode;
>  	spin_lock(&ino->i_lock);
> -	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
> -	    pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
> -					&args->cbl_range))
> +	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
>  		rv = NFS4ERR_DELAY;
> -	else
> -		rv = NFS4ERR_NOMATCHING_LAYOUT;
> +	} else if (pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
> +			&args->cbl_range)) {
> +		need_commit = true;
> +		rv = NFS4ERR_DELAY;
> +	}
> +
>  	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
>  	spin_unlock(&ino->i_lock);
>  	pnfs_free_lseg_list(&free_me_list);
>  	pnfs_put_layout_hdr(lo);
> +
> +	if (need_commit)
> +		pnfs_layoutcommit_inode(ino, false);
>  	iput(ino);
>  out:
>  	return rv;

I did this like below:

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 41db525..59f76bf 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -171,6 +171,14 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		goto out;
 
 	ino = lo->plh_inode;
+
+	spin_lock(&ino->i_lock);
+	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
+	spin_unlock(&ino->i_lock);
+
+	/* kick out any segs held by need to commit */
+	pnfs_layoutcommit_inode(ino, true);
+
 	spin_lock(&ino->i_lock);
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 	    pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
@@ -178,7 +186,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		rv = NFS4ERR_DELAY;
 	else
 		rv = NFS4ERR_NOMATCHING_LAYOUT;
-	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
 	pnfs_put_layout_hdr(lo);


Comments:

1. I do the pnfs_layoutcommit_inode() regrdless of busy segments because
   if it has-nothing-to-do it returns right-away. Segments may be busy
   because of need-to-commit but also because they are used by in-flight-IO
   So busy segments are not an exact indication.
   In any way we can always do pnfs_layoutcommit_inode() to kick a LAYOUTCOMMIT
   it will never do any harm.

2. This has a performance advantage, any segments held by LAYOUTCOMMIT will
   now be freed, and the RECALL will return success instead of forcing the
   server to one or more RECALL rounds with ERR_DELAY.

It is allowed by the protocol to issue a LAYOUTCOMMIT while in recall because
RECALL is governed by the BACK-CHANNEL seq_id and LAYOUTCOMMIT by the for-channel
seq_id and they need not wait for each other to finish.
(Like for example LAYOUT_GET and LAYOUT_COMMIT which are serialized by the seq_id)


> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 6e0fa71..242e73f 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -604,6 +604,9 @@ pnfs_layout_free_bulk_destroy_list(struct list_head *layout_list,
>  		spin_unlock(&inode->i_lock);
>  		pnfs_free_lseg_list(&lseg_list);
>  		pnfs_put_layout_hdr(lo);
> +
> +		if (ret)
> +			pnfs_layoutcommit_inode(inode, false);
>  		iput(inode);
>  	}
>  	return ret;
> 

With My patch I could go farther on but hit some of the other stuff you have
fixes for with the state_ids and other protocol stuff.

Also with my patch I hit races in state management, because my patch waits
for LAYOUT_COMMIT to execute synchronously from the RECALL thread, your
patch of  asynchronous LAYOUT_COMMIT has a lower chance of hitting. But I
think Trond might have fixed these races, as I have tested this code like
6 month a go.

If you are up to it you might want to test my synchronous way and see if you like
things better. I'm testing your code as well to see how it looks.

BTW: It looks like the hch-pnfs/getdeviceinfo has some of the pnfs fixes but that
the hch-pnfs/blocklayout-for-3.18 has newer fixes but without the getdeviceinfo
stuff. I'm testing with the older getdeviceinfo branch.

[hch-pnfs == git://git.infradead.org/users/hch/pnfs.git]

[Testing is not so easy because I need to merge in my pnfs-server as well as this
 here and I needed to do some forward porting as newest code was stuck on like 6
 month ago. That was easy, now I need to go figure out what Ganesha to use.

 Kernel-pnfs-server is out of the question because it is stuck on 3.12 and will not
 merge very well with this here, But I'm stupid I can just run a 3.12 based Server,
 and this here as client, Ye I'll go do this tomorrow. See who gets stuck sooner
 Ganesha or Kpnfsd
]


Thanks for working on this
Boaz

