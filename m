From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 1/1] Prevent 3.0 from crashing if it receives a partial layout
Date: Wed, 21 Sep 2011 09:11:31 -0400
Message-ID: <CADnza47=3Q53=DO=KMdeu_snuQ-q3RV2KshfMOwXL6o+BcYaLw@mail.gmail.com>
References: <1316544755-31845-1-git-send-email-iisaman@netapp.com>
	<4E79B39B.1080102@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"Matt W. Benjamin" <matt@linuxbox.com>,
	"Adam C. Emerson" <aemerson@linuxbox.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f52.google.com ([74.125.83.52]:56545 "EHLO
	mail-gw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860Ab1IUNLb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 09:11:31 -0400
Received: by gwb1 with SMTP id 1so1632164gwb.11
        for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 06:11:31 -0700 (PDT)
In-Reply-To: <4E79B39B.1080102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 21, 2011 at 5:51 AM, Boaz Harrosh <bharrosh@panasas.com> wr=
ote:
> On 09/20/2011 09:52 PM, Fred Isaman wrote:
>> This is a backport of critical parts of
>> commit 7c24d9489f "NFSv4.1: File layout only supports whole file lay=
outs"
>>
>> It prevents the file layout driver from (incorrectly) using
>> partial layouts, but ignores the part of the referenced commmit that
>> relies on additional machinery to change the LAYOUTGET request
>> based on layout driver.
>>
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>
> Hi Fred
>
> Do you know of any plans/timetables to support segments in the files-=
layout-driver?
> Both objects and blocks do support it.
> Is there some missing generic infrastructure needed or its only LD st=
uff?
>

I plan on having something to test at BAT.

=46red

> Just that I know of a few files-based servers that can only serve seg=
ments
> and are unusable with current Linux-pNFS-client which is a great pity=
=2E
>
> I wish it could be ready for next BAT
>
> Thanks
> Boaz
>
>> ---
>> =A0fs/nfs/nfs4filelayout.c | =A0 =A08 ++++++++
>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0 | =A0 =A03 ++-
>> =A02 files changed, 10 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>> index 614c4d2..75af812 100644
>> --- a/fs/nfs/nfs4filelayout.c
>> +++ b/fs/nfs/nfs4filelayout.c
>> @@ -428,6 +428,14 @@ filelayout_check_layout(struct pnfs_layout_hdr =
*lo,
>>
>> =A0 =A0 =A0 dprintk("--> %s\n", __func__);
>>
>> + =A0 =A0 /* FIXME: remove this check when layout segment support is=
 added */
>> + =A0 =A0 if (lgr->range.offset !=3D 0 ||
>> + =A0 =A0 =A0 =A0 lgr->range.length !=3D NFS4_MAX_UINT64) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s Only whole file layouts suppor=
ted. Use MDS i/o\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__);
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 }
>> +
>> =A0 =A0 =A0 if (fl->pattern_offset > lgr->range.offset) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s pattern_offset %lld too larg=
e\n",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__=
, fl->pattern_offset);
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index a726c0a..36d2a29 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -980,7 +980,8 @@ pnfs_update_layout(struct inode *ino,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 arg.offset -=3D pg_offset;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 arg.length +=3D pg_offset;
>> =A0 =A0 =A0 }
>> - =A0 =A0 arg.length =3D PAGE_CACHE_ALIGN(arg.length);
>> + =A0 =A0 if (arg.length !=3D NFS4_MAX_UINT64)
>> + =A0 =A0 =A0 =A0 =A0 =A0 arg.length =3D PAGE_CACHE_ALIGN(arg.length=
);
>>
>> =A0 =A0 =A0 lseg =3D send_layoutget(lo, ctx, &arg, gfp_flags);
>> =A0 =A0 =A0 if (!lseg && first) {
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
