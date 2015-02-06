Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:43704 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbbBFHCt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Feb 2015 02:02:49 -0500
Received: by mail-qg0-f53.google.com with SMTP id f51so9910155qge.12
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 23:02:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAKVebiXJ3n2wh3mq732QvMt+_BFL-VDNbg-jDmxB9H3o1-yz7Q@mail.gmail.com>
References: <1423197907-75541-1-git-send-email-trond.myklebust@primarydata.com>
 <1423197907-75541-2-git-send-email-trond.myklebust@primarydata.com>
 <1423197907-75541-3-git-send-email-trond.myklebust@primarydata.com>
 <1423197907-75541-4-git-send-email-trond.myklebust@primarydata.com>
 <1423197907-75541-5-git-send-email-trond.myklebust@primarydata.com> <CAKVebiXJ3n2wh3mq732QvMt+_BFL-VDNbg-jDmxB9H3o1-yz7Q@mail.gmail.com>
From: Peng Tao <tao.peng@primarydata.com>
Date: Fri, 6 Feb 2015 15:02:27 +0800
Message-ID: <CAKVebiWGj4=kY-tcJ+BjnkunqRYYi4wGsM_=rgAtYkJ98kq1dw@mail.gmail.com>
Subject: Re: [PATCH v3 5/5] NFSv4.1: Fix pnfs_put_lseg races
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 6, 2015 at 2:53 PM, Peng Tao <tao.peng@primarydata.com> wrote:
> On Fri, Feb 6, 2015 at 12:45 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> pnfs_layoutreturn_free_lseg_async() can also race with inode put in
>> the general case. We can now fix this, and also simplify the code.
>>
>> Cc: Peng Tao <tao.peng@primarydata.com>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfs/pnfs.c | 53 +++++++++++++++++++----------------------------------
>>  1 file changed, 19 insertions(+), 34 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index a1d8620e8cb7..107b321be7d4 100644
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
>> @@ -383,24 +378,12 @@ static void pnfs_layoutreturn_free_lseg(struct work_struct *work)
>>                 lo->plh_block_lgets++;
>>                 lo->plh_return_iomode = 0;
>>                 spin_unlock(&inode->i_lock);
>> +               pnfs_get_layout_hdr(lo);
>>
>> -               pnfs_send_layoutreturn(lo, stateid, iomode, true);
>> -               spin_lock(&inode->i_lock);
>> +               /* Send an async layoutreturn so we dont deadlock */
>> +               pnfs_send_layoutreturn(lo, stateid, iomode, false);
>>         } else
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
>> +               spin_unlock(&inode->i_lock);
>>  }
>>
>>  void
>> @@ -415,21 +398,23 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
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
>> +       if (test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
> pnfs_layout_need_return() iterates through all layout segments to make
> sure that if we have other segments that need to be returned, we do
> not send layoutreturn for current lseg so that if they happen to
> overlap, we don't return a layout while still holding one captive.
>
This might not be a problem for files and flexfiles for now but block
layout should be able to see it fairly easy if server is returning
overlapping layout segments to client.

Cheers,
Tao

> I guess the right thing to do is to move pnfs_layout_need_return() and
> pnfs_layoutreturn_before_put_lseg() under atomic_dec_and_lock.
>
> Cheers,
> Tao
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
>> +               spin_unlock(&inode->i_lock);
>> +               pnfs_free_lseg(lseg);
>> +               pnfs_put_layout_hdr(lo);
>>         }
>>  }
>>  EXPORT_SYMBOL_GPL(pnfs_put_lseg);
>> --
>> 2.1.0
>>
