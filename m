Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og112.obsmtp.com ([64.18.0.24]:51601 "HELO
	exprod5og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754260Ab0KKHBC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Nov 2010 02:01:02 -0500
Message-ID: <4CDB94AA.3020508@panasas.com>
Date: Thu, 11 Nov 2010 09:00:58 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/18] pnfs-submit: remove _pnfs_can_return_lseg call
 from pnfs_clear_lseg_list
References: <1288884151-11128-1-git-send-email-iisaman@netapp.com>	<1288884151-11128-4-git-send-email-iisaman@netapp.com>	<4CDAADAE.80109@panasas.com> <AANLkTikLNKs2boXsvBVyurv4WPf=zJEQeZ33Sx_0b-KK@mail.gmail.com>
In-Reply-To: <AANLkTikLNKs2boXsvBVyurv4WPf=zJEQeZ33Sx_0b-KK@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-10 16:46, Fred Isaman wrote:
> On Wed, Nov 10, 2010 at 9:35 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> On 2010-11-04 17:22, Fred Isaman wrote:
>>> Instead, have mark_invalid function that marks lseg invalid and
>>> removes the reference that holds it in the list.  Now when io is finished,
>>> the lseg will automatically be removed from the list.  This is
>>> at the heart of many of the upcoming cb_layoutrecall changes.
>>>
>>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>>> ---
>>>  fs/nfs/nfs4xdr.c |    3 +-
>>>  fs/nfs/pnfs.c    |  145 ++++++++++++++++++++++++++++++++++-------------------
>>>  fs/nfs/pnfs.h    |    1 +
>>>  3 files changed, 95 insertions(+), 54 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>>> index 238eeb2..6d9ef2b 100644
>>> --- a/fs/nfs/nfs4xdr.c
>>> +++ b/fs/nfs/nfs4xdr.c
>>> @@ -1915,8 +1915,7 @@ encode_layoutreturn(struct xdr_stream *xdr,
>>>               p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
>>>               p = xdr_encode_hyper(p, args->range.offset);
>>>               p = xdr_encode_hyper(p, args->range.length);
>>> -             pnfs_get_layout_stateid(&stateid, NFS_I(args->inode)->layout,
>>> -                                     NULL);
>>> +             pnfs_copy_layout_stateid(&stateid, NFS_I(args->inode)->layout);
>>>               p = xdr_encode_opaque_fixed(p, &stateid.data,
>>>                                           NFS4_STATEID_SIZE);
>>>               p = reserve_space(xdr, 4);
>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>> index 3bbe3be..4e5c68b 100644
>>> --- a/fs/nfs/pnfs.c
>>> +++ b/fs/nfs/pnfs.c
>>> @@ -272,10 +272,42 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
>>>       lseg->layout = lo;
>>>  }
>>>
>>> +static void
>>> +_put_lseg_common(struct pnfs_layout_segment *lseg)
>>> +{
>>> +     BUG_ON(lseg->valid == true);
>>> +     list_del(&lseg->fi_list);
>>> +     if (list_empty(&lseg->layout->segs)) {
>>> +             struct nfs_client *clp;
>>> +
>>> +             clp = NFS_SERVER(lseg->layout->inode)->nfs_client;
>>> +             spin_lock(&clp->cl_lock);
>>> +             /* List does not take a reference, so no need for put here */
>>> +             list_del_init(&lseg->layout->layouts);
>>> +             spin_unlock(&clp->cl_lock);
>>> +             pnfs_invalidate_layout_stateid(lseg->layout);
>>> +     }
>>> +     rpc_wake_up(&NFS_I(lseg->layout->inode)->lo_rpcwaitq);
>>> +}
>>> +
>>> +/* The use of tmp_list is necessary because pnfs_curr_ld->free_lseg
>>> + * could sleep, so must be called outside of the lock.
>>> + */
>>> +static void
>>> +put_lseg_locked(struct pnfs_layout_segment *lseg,
>>> +             struct list_head *tmp_list)
>>> +{
>>> +     dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
>>> +             atomic_read(&lseg->pls_refcount), lseg->valid);
>>> +     if (atomic_dec_and_test(&lseg->pls_refcount)) {
>>> +             _put_lseg_common(lseg);
>>> +             list_add(&lseg->fi_list, tmp_list);
>>> +     }
>>> +}
>>> +
>>>  void
>>>  put_lseg(struct pnfs_layout_segment *lseg)
>>>  {
>>> -     bool do_wake_up;
>>>       struct inode *ino;
>>>
>>>       if (!lseg)
>>> @@ -283,15 +315,14 @@ put_lseg(struct pnfs_layout_segment *lseg)
>>>
>>>       dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
>>>               atomic_read(&lseg->pls_refcount), lseg->valid);
>>> -     do_wake_up = !lseg->valid;
>>>       ino = lseg->layout->inode;
>>> -     if (atomic_dec_and_test(&lseg->pls_refcount)) {
>>> +     if (atomic_dec_and_lock(&lseg->pls_refcount, &ino->i_lock)) {
>>> +             _put_lseg_common(lseg);
>>> +             spin_unlock(&ino->i_lock);
>>>               NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
>>>               /* Matched by get_layout_hdr_locked in pnfs_insert_layout */
>>>               put_layout_hdr(ino);
>>>       }
>>> -     if (do_wake_up)
>>> -             rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq);
>>>  }
>>>  EXPORT_SYMBOL_GPL(put_lseg);
>>>
>>> @@ -314,10 +345,18 @@ should_free_lseg(struct pnfs_layout_segment *lseg,
>>>               lseg->range.iomode == range->iomode);
>>>  }
>>>
>>> -static bool
>>> -_pnfs_can_return_lseg(struct pnfs_layout_segment *lseg)
>>> +static void mark_lseg_invalid(struct pnfs_layout_segment *lseg,
>>> +                           struct list_head *tmp_list)
>>>  {
>>> -     return atomic_read(&lseg->pls_refcount) == 1;
>>> +     assert_spin_locked(&lseg->layout->inode->i_lock);
>>> +     if (lseg->valid) {
>>> +             lseg->valid = false;
>>> +             /* Remove the reference keeping the lseg in the
>>> +              * list.  It will now be removed when all
>>> +              * outstanding io is finished.
>>> +              */
>>> +             put_lseg_locked(lseg, tmp_list);
>>> +     }
>>>  }
>>>
>>>  static void
>>> @@ -330,42 +369,31 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
>>>               __func__, lo, range->offset, range->length, range->iomode);
>>>
>>>       assert_spin_locked(&lo->inode->i_lock);
>>> -     list_for_each_entry_safe(lseg, next, &lo->segs, fi_list) {
>>> -             if (!should_free_lseg(lseg, range) ||
>>> -                 !_pnfs_can_return_lseg(lseg))
>>> -                     continue;
>>> -             dprintk("%s: freeing lseg %p iomode %d "
>>> -                     "offset %llu length %llu\n", __func__,
>>> -                     lseg, lseg->range.iomode, lseg->range.offset,
>>> -                     lseg->range.length);
>>> -             list_move(&lseg->fi_list, tmp_list);
>>> -     }
>>> -     if (list_empty(&lo->segs)) {
>>> -             struct nfs_client *clp;
>>> -
>>> -             clp = NFS_SERVER(lo->inode)->nfs_client;
>>> -             spin_lock(&clp->cl_lock);
>>> -             /* List does not take a reference, so no need for put here */
>>> -             list_del_init(&lo->layouts);
>>> -             spin_unlock(&clp->cl_lock);
>>> -             pnfs_invalidate_layout_stateid(lo);
>>> -     }
>>> -
>>> +     list_for_each_entry_safe(lseg, next, &lo->segs, fi_list)
>>> +             if (should_free_lseg(lseg, range)) {
>>> +                     dprintk("%s: freeing lseg %p iomode %d "
>>> +                             "offset %llu length %llu\n", __func__,
>>> +                             lseg, lseg->range.iomode, lseg->range.offset,
>>> +                             lseg->range.length);
>>> +                     mark_lseg_invalid(lseg, tmp_list);
>>> +             }
>>>       dprintk("%s:Return\n", __func__);
>>>  }
>>>
>>>  static void
>>> -pnfs_free_lseg_list(struct list_head *tmp_list)
>>> +pnfs_free_lseg_list(struct list_head *free_me)
>>>  {
>>> -     struct pnfs_layout_segment *lseg;
>>> +     struct pnfs_layout_segment *lseg, *tmp;
>>> +     struct inode *ino;
>>>
>>> -     while (!list_empty(tmp_list)) {
>>> -             lseg = list_entry(tmp_list->next, struct pnfs_layout_segment,
>>> -                             fi_list);
>>> -             dprintk("%s calling put_lseg on %p\n", __func__, lseg);
>>> -             list_del(&lseg->fi_list);
>>> -             put_lseg(lseg);
>>> +     list_for_each_entry_safe(lseg, tmp, free_me, fi_list) {
>>> +             BUG_ON(atomic_read(&lseg->pls_refcount) != 0);
>>> +             ino = lseg->layout->inode;
>>> +             NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
>>> +             /* Matched by get_layout_hdr_locked in pnfs_insert_layout */
>>> +             put_layout_hdr(ino);
>>>       }
>>> +     INIT_LIST_HEAD(free_me);
>>>  }
>>>
>>>  void
>>> @@ -463,6 +491,17 @@ pnfs_layout_from_open_stateid(struct pnfs_layout_hdr *lo,
>>>       dprintk("<-- %s\n", __func__);
>>>  }
>>>
>>> +/* Layoutreturn may use an invalid stateid, just copy what is there */
>>> +void pnfs_copy_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo)
>>> +{
>>> +     int seq;
>>> +
>>> +     do {
>>> +             seq = read_seqbegin(&lo->seqlock);
>>> +             memcpy(dst->data, lo->stateid.data, sizeof(lo->stateid.data));
>>> +     } while (read_seqretry(&lo->seqlock, seq));
>>> +}
>>> +
>>>  void
>>>  pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
>>>                       struct nfs4_state *open_state)
>>> @@ -546,25 +585,23 @@ has_layout_to_return(struct pnfs_layout_hdr *lo,
>>>       return out;
>>>  }
>>>
>>> +/* Return true if there is layout based io in progress in the given range.
>>> + * Assumes range has already been marked invalid, and layout marked to
>>> + * prevent any new lseg from being inserted.
>>> + */
>>>  bool
>>>  pnfs_return_layout_barrier(struct nfs_inode *nfsi,
>>>                          struct pnfs_layout_range *range)
>>>  {
>>> -     struct pnfs_layout_segment *lseg;
>>> +     struct pnfs_layout_segment *lseg, *tmp;
>>>       bool ret = false;
>>>
>>>       spin_lock(&nfsi->vfs_inode.i_lock);
>>> -     list_for_each_entry(lseg, &nfsi->layout->segs, fi_list) {
>>> -             if (!should_free_lseg(lseg, range))
>>> -                     continue;
>>> -             lseg->valid = false;
>>> -             if (!_pnfs_can_return_lseg(lseg)) {
>>> -                     dprintk("%s: wait on lseg %p refcount %d\n",
>>> -                             __func__, lseg,
>>> -                             atomic_read(&lseg->pls_refcount));
>>> +     list_for_each_entry_safe(lseg, tmp, &nfsi->layout->segs, fi_list)
>>
>> Why do you need the safe version here while the inode is locked?
>>
> 
> We don't.

OK. I'll fix that then :)

> 
> 
>>> +             if (should_free_lseg(lseg, range)) {
>>>                       ret = true;
>>
>> But this will always return "true" if there's any lseg to return,
>> not only if (!_pnfs_can_return_lseg(lseg)).
>>
>> What am I missing? :)
>>
> 
> A return of "true" means the caller should wait.  So if there is any
> lseg still left to return, we should return true.  The refcounting has
> changed so that once the pending IO is finished, the lseg will
> automatically be removed from the list.  I suspect that what you are
> missing is that...the refcount in the invalid case is one less than
> what it used to be.

Thanks. I see what you mean now.

What's missing is plh_block_lgets which is introduced only
in [PATCH 13/18] pnfs-submit: rewrite of layout state handling and cb_layoutrecall
Otherwise, new lsegs can be inserted into the list in between.

Benny

> 
> Fred
> 
>> Benny
>>
>>> +                     break;
>>>               }
>>> -     }
>>>       spin_unlock(&nfsi->vfs_inode.i_lock);
>>>       dprintk("%s:Return %d\n", __func__, ret);
>>>       return ret;
>>> @@ -574,12 +611,10 @@ void
>>>  pnfs_layoutreturn_release(struct nfs4_layoutreturn *lrp)
>>>  {
>>>       struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
>>> -     LIST_HEAD(tmp_list);
>>>
>>>       if (lrp->args.return_type != RETURN_FILE)
>>>               return;
>>>       spin_lock(&lrp->args.inode->i_lock);
>>> -     pnfs_clear_lseg_list(lo, &tmp_list, &lrp->args.range);
>>>       if (!lrp->res.valid)
>>>               ;       /* forgetful model internal release */
>>>       else if (!lrp->res.lrs_present)
>>> @@ -588,7 +623,6 @@ pnfs_layoutreturn_release(struct nfs4_layoutreturn *lrp)
>>>               pnfs_set_layout_stateid(lo, &lrp->res.stateid);
>>>       put_layout_hdr_locked(lo); /* Matched in _pnfs_return_layout */
>>>       spin_unlock(&lrp->args.inode->i_lock);
>>> -     pnfs_free_lseg_list(&tmp_list);
>>>  }
>>>
>>>  static int
>>> @@ -641,7 +675,11 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
>>>       arg.offset = 0;
>>>       arg.length = NFS4_MAX_UINT64;
>>>
>>> +     /* probably should BUGON if type != RETURN_FILE */
>>>       if (type == RETURN_FILE) {
>>> +             LIST_HEAD(tmp_list);
>>> +             struct pnfs_layout_segment *lseg, *tmp;
>>> +
>>>               spin_lock(&ino->i_lock);
>>>               lo = nfsi->layout;
>>>               if (lo && !has_layout_to_return(lo, &arg))
>>> @@ -652,10 +690,13 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
>>>                       goto out;
>>>               }
>>>
>>> +             list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
>>> +                     if (should_free_lseg(lseg, &arg))
>>> +                             mark_lseg_invalid(lseg, &tmp_list);
>>>               /* Reference matched in pnfs_layoutreturn_release */
>>>               get_layout_hdr_locked(lo);
>>> -
>>>               spin_unlock(&ino->i_lock);
>>> +             pnfs_free_lseg_list(&tmp_list);
>>>
>>>               if (layoutcommit_needed(nfsi)) {
>>>                       if (stateid && !wait) { /* callback */
>>> @@ -1171,7 +1212,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
>>>       nfsi->layout->write_end_pos = 0;
>>>       nfsi->layout->cred = NULL;
>>>       __clear_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->state);
>>> -     pnfs_get_layout_stateid(&data->args.stateid, nfsi->layout, NULL);
>>> +     pnfs_copy_layout_stateid(&data->args.stateid, nfsi->layout);
>>>
>>>       /* Reference for layoutcommit matched in pnfs_layoutcommit_release */
>>>       get_layout_hdr_locked(NFS_I(inode)->layout);
>>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>>> index 05dd5e0..000acf0 100644
>>> --- a/fs/nfs/pnfs.h
>>> +++ b/fs/nfs/pnfs.h
>>> @@ -206,6 +206,7 @@ void pnfs_layoutreturn_release(struct nfs4_layoutreturn *lpr);
>>>  void pnfs_destroy_layout(struct nfs_inode *);
>>>  void pnfs_destroy_all_layouts(struct nfs_client *);
>>>  void put_layout_hdr(struct inode *inode);
>>> +void pnfs_copy_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo);
>>>  void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
>>>                            struct nfs4_state *open_state);
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
