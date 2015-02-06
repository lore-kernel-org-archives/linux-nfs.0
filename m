Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:58952 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317AbbBFEh4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 23:37:56 -0500
Received: by mail-vc0-f170.google.com with SMTP id kv7so4302404vcb.1
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 20:37:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAKVebiXjdAVE=QduWmRC7KkQUhC8fk4kNVg4cFOk7MtqaPFuEw@mail.gmail.com>
References: <1423191577-72230-1-git-send-email-trond.myklebust@primarydata.com>
	<1423191577-72230-2-git-send-email-trond.myklebust@primarydata.com>
	<1423191577-72230-3-git-send-email-trond.myklebust@primarydata.com>
	<1423191577-72230-4-git-send-email-trond.myklebust@primarydata.com>
	<1423191577-72230-5-git-send-email-trond.myklebust@primarydata.com>
	<CAKVebiXjdAVE=QduWmRC7KkQUhC8fk4kNVg4cFOk7MtqaPFuEw@mail.gmail.com>
Date: Thu, 5 Feb 2015 23:37:55 -0500
Message-ID: <CAHQdGtRb5aqrQ4LX2p_K4T3enDd-tokCB5uWYGovmvTNfOMrLw@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] NFSv4.1: Fix pnfs_put_lseg races
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Peng Tao <tao.peng@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 5, 2015 at 10:38 PM, Peng Tao <tao.peng@primarydata.com> wrote:
> On Fri, Feb 6, 2015 at 10:59 AM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> pnfs_layoutreturn_free_lseg_async() can also race with inode put in
>> the general case. We can now fix this, and also simplify the code.
>>
>> Cc: Peng Tao <tao.peng@primarydata.com>
>> ---
>>  fs/nfs/pnfs.c | 54 +++++++++++++++++++-----------------------------------
>>  1 file changed, 19 insertions(+), 35 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index a1d8620e8cb7..79878611fdb0 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -361,14 +361,9 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
>>         return true;
>>  }
>>
>> -static void pnfs_layoutreturn_free_lseg(struct work_struct *work)
>> +static void pnfs_layoutreturn_before_put_lseg(struct pnfs_layout_segment *lseg,
>> +               struct pnfs_layout_hdr *lo, struct inode *inode)
>>  {
>> -       struct pnfs_layout_segment *lseg;
>> -       struct pnfs_layout_hdr *lo;
>> -       struct inode *inode;
>> -
>> -       lseg = container_of(work, struct pnfs_layout_segment, pls_work);
>> -       WARN_ON(atomic_read(&lseg->pls_refcount));
>>         lo = lseg->pls_layout;
>>         inode = lo->plh_inode;
>>
>> @@ -383,24 +378,11 @@ static void pnfs_layoutreturn_free_lseg(struct work_struct *work)
>>                 lo->plh_block_lgets++;
>>                 lo->plh_return_iomode = 0;
>>                 spin_unlock(&inode->i_lock);
>> +               pnfs_get_layout_hdr(lo);
>>
>> -               pnfs_send_layoutreturn(lo, stateid, iomode, true);
>> -               spin_lock(&inode->i_lock);
>> -       } else
>> -               /* match pnfs_get_layout_hdr #2 in pnfs_put_lseg */
>> -               pnfs_put_layout_hdr(lo);
>> -       pnfs_layout_remove_lseg(lo, lseg);
>> -       spin_unlock(&inode->i_lock);
>> -       pnfs_free_lseg(lseg);
>> -       /* match pnfs_get_layout_hdr #1 in pnfs_put_lseg */
>> -       pnfs_put_layout_hdr(lo);
>> -}
>> -
>> -static void
>> -pnfs_layoutreturn_free_lseg_async(struct pnfs_layout_segment *lseg)
>> -{
>> -       INIT_WORK(&lseg->pls_work, pnfs_layoutreturn_free_lseg);
>> -       queue_work(nfsiod_workqueue, &lseg->pls_work);
>> +               /* Send an async layoutreturn so we dont deadlock */
>> +               pnfs_send_layoutreturn(lo, stateid, iomode, false);
>> +       }
>>  }
>>
>>  void
>> @@ -415,21 +397,23 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
>>         dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
>>                 atomic_read(&lseg->pls_refcount),
>>                 test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
>> +
>> +       /* Handle the case where refcount != 1 */
>> +       if (atomic_add_unless(&lseg->pls_refcount, -1, 1))
>> +               return;
>> +
>>         lo = lseg->pls_layout;
>>         inode = lo->plh_inode;
>> +       /* Do we need a layoutreturn? */
>> +       if (pnfs_layout_need_return(lo, lseg))
> pnfs_layout_need_return() needs inode->i_lock protection because it
> iterates lo->plh_segs list.

Ack. I'll put out a v3 that changes that.

>
>> +               pnfs_layoutreturn_before_put_lseg(lseg, lo, inode);
>> +
>>         if (atomic_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
>>                 pnfs_get_layout_hdr(lo);
>> -               if (pnfs_layout_need_return(lo, lseg)) {
>> -                       spin_unlock(&inode->i_lock);
>> -                       /* hdr reference dropped in nfs4_layoutreturn_release */
>> -                       pnfs_get_layout_hdr(lo);
>> -                       pnfs_layoutreturn_free_lseg_async(lseg);
>> -               } else {
>> -                       pnfs_layout_remove_lseg(lo, lseg);
>> -                       spin_unlock(&inode->i_lock);
>> -                       pnfs_free_lseg(lseg);
>> -                       pnfs_put_layout_hdr(lo);
>> -               }
>> +               pnfs_layout_remove_lseg(lo, lseg);
> This might end up removing lseg before actually sending out
> layoutreturn. And it can affect return-on-close handling such that we
> send close while still having lseg at hand. That said, I don't see it
> a problem because it only happens when we are about to free the lseg
> anyway so no one can use it for I/O at this point.

So, this is the exact point of doing the layoutreturn _before_ we do
the final test of lseg->pls_refcount. It means that we can ensure that
the lseg is still around.

The danger here is not so much missing a layoutreturn due to a race
(although that is not optimal), but rather it is leaving the lseg
attached to the layout header, but with lseg->pls_refcount == 0. If
the refcount is bumped in that situation, then bad things can happen
(the lseg can get freed while we're doing the layoutreturn).
Also there is the danger of the inode disappearing from underneath us,
as stated in the changelog.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
