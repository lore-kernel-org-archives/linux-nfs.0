Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52249 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754750Ab1BOOs2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 09:48:28 -0500
Received: by wwa36 with SMTP id 36so257828wwa.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Feb 2011 06:48:27 -0800 (PST)
In-Reply-To: <20110215092531.GB29871@infradead.org>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
	<1297711116-3139-9-git-send-email-andros@netapp.com>
	<20110215092531.GB29871@infradead.org>
Date: Tue, 15 Feb 2011 09:48:26 -0500
Message-ID: <AANLkTik+dVSmWgO6LRANo2xTt6iMqQ7ehvgqk-igQFhM@mail.gmail.com>
Subject: Re: [PATCH 08/16] pnfs: wave 3: lseg refcounting
From: Fred Isaman <iisaman@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: andros@netapp.com, trond.myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 15, 2011 at 4:25 AM, Christoph Hellwig <hch@infradead.org> wrote:
>> +_put_lseg_common(struct pnfs_layout_segment *lseg)
>
> The naming of _put_lseg_common is pretty weird compared to standard Linux
> function naming.  I'd either expect __put_lseg or put_lseg_common.
>
>> +{
>> +     struct inode *ino = lseg->pls_layout->plh_inode;
>
> Please call this inode.  ino is usually used for variables of type ino_t.
>
>
>> +     BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
>> +     list_del(&lseg->pls_list);
>> +     if (list_empty(&lseg->pls_layout->plh_segs)) {
>> +             set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
>> +             /* Matched by initial refcount set in alloc_init_layout_hdr */
>> +             put_layout_hdr_locked(lseg->pls_layout);
>> +     }
>> +     rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq);
>> +}
>> +
>
>
>
>> @@ -242,22 +257,35 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
>>               atomic_read(&lseg->pls_refcount),
>>               test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
>>       if (atomic_dec_and_test(&lseg->pls_refcount)) {
>> +             _put_lseg_common(lseg);
>>               list_add(&lseg->pls_list, tmp_list);
>>               return 1;
>>       }
>>       return 0;
>
> Given that put_lseg_locked is pretty trivial now, and has a awkward
> calling convention I would just inline it into the only caller.
>
>> +static void
>> +put_lseg(struct pnfs_layout_segment *lseg)
>> +{
>> +     struct inode *ino;
>
> Again, please call this inode.
>
>> +
>> +     if (!lseg)
>> +             return;
>> +
>> +     dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
>> +             atomic_read(&lseg->pls_refcount),
>> +             test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
>> +     ino = lseg->pls_layout->plh_inode;
>> +     if (atomic_dec_and_lock(&lseg->pls_refcount, &ino->i_lock)) {
>> +             LIST_HEAD(free_me);
>> +
>> +             _put_lseg_common(lseg);
>> +             list_add(&lseg->pls_list, &free_me);
>> +             spin_unlock(&ino->i_lock);
>> +             pnfs_free_lseg_list(&free_me);
>> +     }
>
> What's the point of the list operations here?  You'd be much better to
> just do a
>
>        free_lseg(lseg);
>
> after releasing the lock.
>

pnfs_free_lseg_list, besides calling free_lseg, also potentially
removes the layout from the clients list of inodes with layouts.

Fred

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
