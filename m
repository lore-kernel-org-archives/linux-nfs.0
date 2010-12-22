Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9989 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751637Ab0LVWIM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Dec 2010 17:08:12 -0500
Subject: Re: [PATCH 06/15] pnfs: change how lsegs are removed from layout list
Content-Type: text/plain; charset=us-ascii
From: Fred Isaman <iisaman@netapp.com>
In-Reply-To: <1293054191.6422.16.camel@heimdal.trondhjem.org>
Date: Wed, 22 Dec 2010 17:08:10 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <73A41B1B-39EE-422F-8C43-1CBF830524A2@netapp.com>
References: <1292990449-20057-1-git-send-email-iisaman@netapp.com> <1292990449-20057-7-git-send-email-iisaman@netapp.com> <1293054191.6422.16.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 22, 2010, at 4:43 PM, Trond Myklebust wrote:

> On Tue, 2010-12-21 at 23:00 -0500, Fred Isaman wrote:
>> This is to prepare the way for sensible io draining.  Instead of just
>> removing the lseg from the list, we instead clear the VALID flag
>> (preventing new io from grabbing references to the lseg) and remove
>> the reference holding it in the list.  Thus the lseg will be removed
>> once any io in progress completes and any references still held are
>> dropped.
>> 
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>> fs/nfs/inode.c |    2 +-
>> fs/nfs/pnfs.c  |  121 ++++++++++++++++++++++++++++++++++++-------------------
>> fs/nfs/pnfs.h  |    8 +++-
>> 3 files changed, 87 insertions(+), 44 deletions(-)
>> 
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index e67e31c..43a69da 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
> 
>> -/* Called without i_lock held, as the free_lseg call may sleep */
>> -static void
>> -destroy_lseg(struct kref *kref)
>> +static void free_lseg(struct pnfs_layout_segment *lseg)
>> {
>> -	struct pnfs_layout_segment *lseg =
>> -		container_of(kref, struct pnfs_layout_segment, pls_refcount);
>> 	struct inode *ino = lseg->pls_layout->plh_inode;
>> 
>> -	dprintk("--> %s\n", __func__);
>> +	BUG_ON(atomic_read(&lseg->pls_refcount) != 0);
>> 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
>> 	/* Matched by get_layout_hdr in pnfs_insert_layout */
>> 	put_layout_hdr(ino);
>> }
> 
> <snip>
> 
>> static void
>> -pnfs_free_lseg_list(struct list_head *tmp_list)
>> +pnfs_free_lseg_list(struct list_head *free_me)
>> {
>> -	struct pnfs_layout_segment *lseg;
>> +	struct pnfs_layout_segment *lseg, *tmp;
>> 
>> -	while (!list_empty(tmp_list)) {
>> -		lseg = list_entry(tmp_list->next, struct pnfs_layout_segment,
>> -				pls_list);
>> -		dprintk("%s calling put_lseg on %p\n", __func__, lseg);
>> -		list_del(&lseg->pls_list);
>> -		put_lseg(lseg);
>> -	}
>> +	list_for_each_entry_safe(lseg, tmp, free_me, pls_list)
>> +		free_lseg(lseg);
>> +	INIT_LIST_HEAD(free_me);
>> }
> 
> The above looks very dubious to me. Why is this change needed, and what
> guarantees do we have that free_lseg() will do the right thing w.r.t.
> removing stuff from the list?

Note that this is called with a list of lsegs which already have refcount==0 and have been removed from generic layer lists such that no new reference is coming.  All that is expected of free_lseg is that the layout driver gets a chance to free any resources it has attached to the lseg, and that we release the reference the lseg holds on the layout header itself.

The primary reason for this is that the file layouts ld->free_lseg call can call nfs_put_client, which can sleep.  So this allows the ld->free_lseg to be postponed until we can drop locks, similar to the dispose_list function in fs/inode.c

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

