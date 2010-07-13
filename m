From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 2/2] SQUASHME: pnfs-submit: clean up nfs_lock_alloc_layout
Date: Tue, 13 Jul 2010 17:02:40 +0300
Message-ID: <4C3C7200.9070508@panasas.com>
References: <4C3B611C.1000208@panasas.com>	<1278960015-32215-1-git-send-email-bhalevy@panasas.com> <AANLkTin5Wo-9paVQvfXZwDx5KZFkpSSspTCIN6vRCc8h@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44922 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756210Ab0GMOCt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jul 2010 10:02:49 -0400
Received: by wyb42 with SMTP id 42so153921wyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jul 2010 07:02:47 -0700 (PDT)
In-Reply-To: <AANLkTin5Wo-9paVQvfXZwDx5KZFkpSSspTCIN6vRCc8h-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 13, 2010, 16:44 +0300, "William A. (Andy) Adamson" <androsadamson@gmail.com> wrote:
> On Mon, Jul 12, 2010 at 2:40 PM, Benny Halevy <bhalevy@panasas.com> wrote:
>> Fix a bug where the function returned without taking the i_lock
>> if the layout hdr was already allocated.
>> Simplify by moving inode locking to caller.
> 
> No, the original function I sent had no such bug.
> 

True.  It was my bad.

>>
>> Rename function as it no longer grabs the lock.
>> Clean up the implementation so it's clearer what's going on
>> and what are the likely cases vs. the unlikely ones.
> 
> I do not think this is any clearer!
> 

I think that getting the lock by the caller is simpler
than having the callee take it, but it doesn't matter that much.

My main problems with your patch were:
a. usage of the 'new' variable, setting it to NULL if it was used
rather than using simple if/else logic.

b. if alloc_init_layout failed after releasing the lock
the function always returned NULL, even if someone else
was able to allocate it in parallel (very unlikely, but possible)

c. the fast path had to go through 2 unlikely if's

Benny

>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/pnfs.c |   42 ++++++++++++++++++++++--------------------
>>  1 files changed, 22 insertions(+), 20 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 4ba7595..053a5c1 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -938,36 +938,37 @@ alloc_init_layout(struct inode *ino)
>>  }
>>
>>  /*
>> - * Lock and possibly allocate the inode layout
>> + * Retrieve and possibly allocate the inode layout
>>  *
>> - * If successful, ino->i_lock is taken, and the caller must unlock.
>> + * ino->i_lock must be taken by the caller.
>>  */
>>  static struct pnfs_layout_type *
>> -nfs_lock_alloc_layout(struct inode *ino)
>> +pnfs_alloc_layout(struct inode *ino)
>>  {
>> +       struct nfs_inode *nfsi = NFS_I(ino);
>>        struct pnfs_layout_type *new = NULL;
>>
>> -       dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, NFS_I(ino)->layout);
>> +       dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
>>
>> -       if (NFS_I(ino)->layout == NULL) {
>> -               new = alloc_init_layout(ino);
>> -               if (new == NULL)
>> -                       return NULL;
>> -               spin_lock(&ino->i_lock);
>> -               if (NFS_I(ino)->layout == NULL) {
>> -                       NFS_I(ino)->layout = new;
>> -                       new = NULL;
>> -               }
>> -       }
>> -       if (new) {
>> +       BUG_ON(!spin_is_locked(&ino->i_lock));
>> +       if (likely(nfsi->layout))
>> +               return nfsi->layout;
>> +
>> +       spin_unlock(&ino->i_lock);
>> +       new = alloc_init_layout(ino);
>> +       spin_lock(&ino->i_lock);
>> +
>> +       if (likely(nfsi->layout == NULL)) {     /* Won the race? */
>> +               nfsi->layout = new;
>> +       } else if (new) {
>>                /* Reference the layout accross i_lock release and grab */
>> -               get_layout(NFS_I(ino)->layout);
>> +               get_layout(nfsi->layout);
>>                spin_unlock(&ino->i_lock);
>>                NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops->free_layout(new);
>>                spin_lock(&ino->i_lock);
>> -               put_layout_locked(NFS_I(ino)->layout);
>> +               put_layout_locked(nfsi->layout);
>>        }
>> -       return NFS_I(ino)->layout;
>> +       return nfsi->layout;
>>  }
>>
>>  /*
>> @@ -1055,10 +1056,11 @@ _pnfs_update_layout(struct inode *ino,
>>
>>        if (take_ref)
>>                *lsegpp = NULL;
>> -       lo = nfs_lock_alloc_layout(ino);
>> +       spin_lock(&ino->i_lock);
>> +       lo = pnfs_alloc_layout(ino);
>>        if (lo == NULL) {
>>                dprintk("%s ERROR: can't get pnfs_layout_type\n", __func__);
>> -               goto out;
>> +               goto out_unlock;
>>        }
>>
>>        /* Check to see if the layout for the given range already exists */
>> --
>> 1.7.1.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
