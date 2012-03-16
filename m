Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:54379 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760812Ab2CPPMF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2012 11:12:05 -0400
Received: by wejx9 with SMTP id x9so4009778wej.19
        for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 08:12:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1331857092.24392.4.camel@lade.trondhjem.org>
References: <1331836850-5195-1-git-send-email-andros@netapp.com>
	<1331836850-5195-7-git-send-email-andros@netapp.com>
	<1331857092.24392.4.camel@lade.trondhjem.org>
Date: Fri, 16 Mar 2012 11:12:03 -0400
Message-ID: <CAHVgHyX6tu6Yf+AMXt6Y0evF+36mysb4iUA7pzZ9zg3QERWfTw@mail.gmail.com>
Subject: Re: [PATCH Version 1 06/11] NFSv4.1: send filelayout DS commits to
 the MDS on invalid deviceid
From: Andy Adamson <androsadamson@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 15, 2012 at 8:18 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> How does sending the commit to the MDS help if this is a commit-to-DS
> setup? AFAICS we need to resend all the writes through the MDS.

That is actually what happens - bad patch name. Of course, after all
the writes are re-sent, the commit is sent to the MDS...

-->Andy

BTW: I note that filelayout_commit_pagelist returns -ENOMEM on error
which is incorrect: being a pnfs_layoutdriver_type.commit_pagelist
routine, it should return one of PNFS_ATTEMPTED, PNFS_NOT_ATTEMPED.
I'll send a patch.

>
> On Thu, 2012-03-15 at 14:40 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  fs/nfs/nfs4filelayout.c |   11 ++++++++++-
>>  1 files changed, 10 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index 2528cb2..26c83b0 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -847,12 +847,16 @@ filelayout_choose_commit_list(struct nfs_page *req,
>>                             struct pnfs_layout_segment *lseg)
>>  {
>>       struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
>> +     struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
>>       u32 i, j;
>>       struct list_head *list;
>>
>>       if (fl->commit_through_mds)
>>               return &NFS_I(req->wb_context->dentry->d_inode)->commit_list;
>>
>> +     if (filelayout_test_devid_invalid(devid))
>> +             return NULL; /* Resend I/O (writes and commits) to MDS */
>> +
>>       /* Note that we are calling nfs4_fl_calc_j_index on each page
>>        * that ends up being committed to a data server.  An attractive
>>        * alternative is to add a field to nfs_write_data and nfs_page
>> @@ -933,9 +937,14 @@ find_only_write_lseg_locked(struct inode *inode)
>>  {
>>       struct pnfs_layout_segment *lseg;
>>
>> -     list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list)
>> +     list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
>> +             struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
>> +             if (filelayout_test_devid_invalid(devid))
>> +                     /* Resend I/O (writes and commits) to MDS */
>> +                     return NULL;
>>               if (lseg->pls_range.iomode == IOMODE_RW)
>>                       return get_lseg(lseg);
>> +     }
>>       return NULL;
>>  }
>>
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
