Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:57951 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013Ab2DMQub convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Apr 2012 12:50:31 -0400
Received: by vcqp1 with SMTP id p1so2164668vcq.19
        for <linux-nfs@vger.kernel.org>; Fri, 13 Apr 2012 09:50:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334332041.25130.16.camel@lade.trondhjem.org>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
	<1334004744-31842-4-git-send-email-iisaman@netapp.com>
	<1334332041.25130.16.camel@lade.trondhjem.org>
Date: Fri, 13 Apr 2012 12:50:30 -0400
Message-ID: <CADnza45zA+dnO7cX9Q_y9B679kOGdV3+Cph5hTKit6gs1ZOUKA@mail.gmail.com>
Subject: Re: [PATCH 03/26] NFS4.1: Add lseg to struct nfs4_fl_commit_bucket
From: Fred Isaman <faisaman4@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 13, 2012 at 11:47 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2012-04-09 at 16:52 -0400, Fred Isaman wrote:
>> Also create a commit_info structure to hold the bucket array and push
>> it up from the lseg to the layout where it really belongs.
>>
>> While we are at it, fix a refcounting bug due to an (incorrect)
>> implicit assumption that filelayout_scan_ds_commit_list always
>> completely emptied the src list.
>>
>> This clarifies refcounting, removes the ugly find_only_write_lseg
>> functions, and pushes the file layout commit code along on the path to
>> supporting multiple lsegs.
>>
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>>  fs/nfs/nfs4filelayout.c |  150 +++++++++++++++++++++++++----------------------
>>  fs/nfs/nfs4filelayout.h |   20 ++++++-
>>  2 files changed, 97 insertions(+), 73 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index 5acfd9e..0bbc88a 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -650,7 +650,15 @@ filelayout_free_lseg(struct pnfs_layout_segment *lseg)
>>
>>       dprintk("--> %s\n", __func__);
>>       nfs4_fl_put_deviceid(fl->dsaddr);
>> -     kfree(fl->commit_buckets);
>> +     /* This assumes a single RW lseg */
>> +     if (lseg->pls_range.iomode == IOMODE_RW) {
>> +             struct nfs4_filelayout *flo;
>> +
>> +             flo = FILELAYOUT_FROM_HDR(lseg->pls_layout);
>> +             flo->commit_info.nbuckets = 0;
>> +             kfree(flo->commit_info.buckets);
>> +             flo->commit_info.buckets = NULL;
>> +     }
>>       _filelayout_free_lseg(fl);
>>  }
>>
>> @@ -681,19 +689,27 @@ filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
>>        * to filelayout_write_pagelist().
>>        * */
>>       if ((!fl->commit_through_mds) && (lgr->range.iomode == IOMODE_RW)) {
>> +             struct nfs4_filelayout *flo = FILELAYOUT_FROM_HDR(layoutid);
>>               int i;
>>               int size = (fl->stripe_type == STRIPE_SPARSE) ?
>>                       fl->dsaddr->ds_num : fl->dsaddr->stripe_count;
>>
>> -             fl->commit_buckets = kcalloc(size, sizeof(struct nfs4_fl_commit_bucket), gfp_flags);
>> -             if (!fl->commit_buckets) {
>> +             if (flo->commit_info.nbuckets != 0) {
>> +                     /* Shouldn't happen if only one IOMODE_RW lseg */
>>                       filelayout_free_lseg(&fl->generic_hdr);
>>                       return NULL;
>
> Is this really the correct thing to do? If we're dealing with multiple
> IOMODE_RW lsegs, then surely we might find ourselves in a situation
> where we might have to add new commit buckets.
>
> Doesn't the above deserve a WARN_ON() and a FIXME comment?
>
>>               }
>> -             fl->number_of_buckets = size;
>> +             flo->commit_info.buckets = kcalloc(size,
>> +                                                sizeof(struct nfs4_fl_commit_bucket),
>> +                                                gfp_flags);
>> +             if (!flo->commit_info.buckets) {
>> +                     filelayout_free_lseg(&fl->generic_hdr);
>> +                     return NULL;
>> +             }
>> +             flo->commit_info.nbuckets = size;
>>               for (i = 0; i < size; i++) {
>> -                     INIT_LIST_HEAD(&fl->commit_buckets[i].written);
>> -                     INIT_LIST_HEAD(&fl->commit_buckets[i].committing);
>> +                     INIT_LIST_HEAD(&flo->commit_info.buckets[i].written);
>> +                     INIT_LIST_HEAD(&flo->commit_info.buckets[i].committing);
>>               }
>
> The commit_info allocation and initialisation should probably be moved
> into a different function if it is no longer part of the lseg.
>

This is done in patch 26, and called from pg_init_write.  Perhaps I
should move it earlier in the series
This is also the reason for the lack of WARN_ON, as in the moved code
it hits frequently.

My idea was that in a multi-layout scenerio, the check (for
ncommits==0) would be replaced with code that
would scan the existing buckets to see if any new needed to be added.
Regarding taking the reference to the lseg,
I am still not convinced that the bucket really needs to take a ref on
the lseg.  Eventually buckets need to be tied to
a ds, fh pair, though a ds, fh,lseg triple may be needed to deal with
certain corner cases.

Fred

> That said, I'm having trouble seeing how this architecture can survive
> in a future multiple-layout world. I'm thinking that since the
> commit_buckets need to take a reference to the lseg, then maybe we
> should keep the commit buckets tied to the lseg, and then let the commit
> code iterate through the list of lsegs with something in their commit
> buckets... What are your thoughts for how this might evolve?
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
