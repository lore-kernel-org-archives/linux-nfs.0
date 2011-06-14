Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50207 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058Ab1FNQCN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 12:02:13 -0400
Received: by yxi11 with SMTP id 11so1467375yxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2011 09:02:13 -0700 (PDT)
In-Reply-To: <BANLkTi=URdDv2=Q0tCYcAe2L2mAvBCgKPA@mail.gmail.com>
References: <cover.1307921137.git.rees@umich.edu>
	<ea5e2bf59d726fbfec6f63af9eda83dbc15cb96d.1307921137.git.rees@umich.edu>
	<BANLkTimtiDZNZPnBK6864Rwh-XhDAkcHVQ@mail.gmail.com>
	<F19688880B763E40B28B2B462677FBF805BED9D55D@MX09A.corp.emc.com>
	<BANLkTimH7cxZWr26Fv2TuSPZOWA4pR74nQ@mail.gmail.com>
	<BANLkTi=URdDv2=Q0tCYcAe2L2mAvBCgKPA@mail.gmail.com>
Date: Tue, 14 Jun 2011 12:02:12 -0400
Message-ID: <BANLkTi=pHD=6h7nwVft+QMOrAGWrrx5H3w@mail.gmail.com>
Subject: Re: [PATCH 04/34] pnfs: hook nfs_write_begin/end to allow layout
 driver manipulation
From: Fred Isaman <iisaman@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
Cc: tao.peng@emc.com, rees@umich.edu, linux-nfs@vger.kernel.org,
        honey@citi.umich.edu
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jun 14, 2011 at 11:53 AM, Peng Tao <bergwolf@gmail.com> wrote:
> On Tue, Jun 14, 2011 at 10:05 PM, Fred Isaman <iisaman@netapp.com> wrote:
>> On Tue, Jun 14, 2011 at 7:01 AM,  <tao.peng@emc.com> wrote:
>>> Hi, Fred,
>>>
>>>> -----Original Message-----
>>>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org]
>>>> On Behalf Of Fred Isaman
>>>> Sent: Monday, June 13, 2011 10:44 PM
>>>> To: Jim Rees
>>>> Cc: linux-nfs@vger.kernel.org; peter honeyman
>>>> Subject: Re: [PATCH 04/34] pnfs: hook nfs_write_begin/end to allow layout driver
>>>> manipulation
>>>>
>>>> On Sun, Jun 12, 2011 at 7:43 PM, Jim Rees <rees@umich.edu> wrote:
>>>> > From: Peng Tao <bergwolf@gmail.com>
>>>> >
>>>> > Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>>>> > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> > Reported-by: Alexandros Batsakis <batsakis@netapp.com>
>>>> > Signed-off-by: Andy Adamson <andros@netapp.com>
>>>> > Signed-off-by: Fred Isaman <iisaman@netapp.com>
>>>> > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> > Signed-off-by: Peng Tao <bergwolf@gmail.com>
>>>> > ---
>>>> >  fs/nfs/file.c          |   26 ++++++++++-
>>>> >  fs/nfs/pnfs.c          |   41 +++++++++++++++++
>>>> >  fs/nfs/pnfs.h          |  115
>>>> ++++++++++++++++++++++++++++++++++++++++++++++++
>>>> >  fs/nfs/write.c         |   12 +++--
>>>> >  include/linux/nfs_fs.h |    3 +-
>>>> >  5 files changed, 189 insertions(+), 8 deletions(-)
>>>> >
>>>> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>>>> > index 2f093ed..1768762 100644
>>>> > --- a/fs/nfs/file.c
>>>> > +++ b/fs/nfs/file.c
>>>> > @@ -384,12 +384,15 @@ static int nfs_write_begin(struct file *file, struct
>>>> address_space *mapping,
>>>> >        pgoff_t index = pos >> PAGE_CACHE_SHIFT;
>>>> >        struct page *page;
>>>> >        int once_thru = 0;
>>>> > +       struct pnfs_layout_segment *lseg;
>>>> >
>>>> >        dfprintk(PAGECACHE, "NFS: write_begin(%s/%s(%ld), %u@%lld)\n",
>>>> >                file->f_path.dentry->d_parent->d_name.name,
>>>> >                file->f_path.dentry->d_name.name,
>>>> >                mapping->host->i_ino, len, (long long) pos);
>>>> > -
>>>> > +       lseg = pnfs_update_layout(mapping->host,
>>>> > +                                 nfs_file_open_context(file),
>>>> > +                                 pos, len, IOMODE_RW, GFP_NOFS);
>>>>
>>>>
>>>> This looks like it is left over from before the rearrangements done to
>>>> where pnfs_update_layout.
>>>> In particular, we don't want to hold the reference on the lseg from
>>>> here until flush time.  And there
>>>> seems to be no reason to.  If the client needs a layout to deal with
>>>> read-in here, it should instead
>>>> trigger the nfs_want_read_modify_write clause.
>>> Yes, you are right. Directly calling pnfs_update_layout here can be avoided.
>>> But it seems triggering nfs_want_read_modify_write will acquire a read-only layout segment via readpage code path.
>>> For write, client will need a read-write layout segment so it would mean two layoutget for each new segment (one in nfs_readpage and one at flush time). It may not be good for performance.
>>> Does current generic code have method to avoid this?
>>>
>>> Thanks,
>>> Tao
>>>
>>
>> No.  However, note that this only hits in the case where you are doing
>> subpage writes.
> block layout driver need the segment to determine if it should dirty
> other pages in the same fsblock based on if it is a first write to an
> INVALID extent. So it still hits whenever an fsblock is dirtied for
> the first time.
>
> Thanks,
> Tao
>

Why can't this be delayed until flush?

Fred
