Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:47909 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951Ab1FNN6U convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 09:58:20 -0400
Received: by gxk21 with SMTP id 21so3481394gxk.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2011 06:58:19 -0700 (PDT)
In-Reply-To: <F19688880B763E40B28B2B462677FBF805BED9D553@MX09A.corp.emc.com>
References: <cover.1307921137.git.rees@umich.edu>
	<9f228c643de1f0378835d6ec9a493c1320bf001d.1307921137.git.rees@umich.edu>
	<BANLkTi=Pw-mO25APweSFxyA5bhtYwt5f2Q@mail.gmail.com>
	<F19688880B763E40B28B2B462677FBF805BED9D553@MX09A.corp.emc.com>
Date: Tue, 14 Jun 2011 09:58:19 -0400
Message-ID: <BANLkTikhro947yx2ZxcG_NudyczdmGTCMg@mail.gmail.com>
Subject: Re: [PATCH 03/34] pnfs: let layoutcommit code handle multiple segments
From: Fred Isaman <iisaman@netapp.com>
To: tao.peng@emc.com
Cc: rees@umich.edu, linux-nfs@vger.kernel.org, honey@citi.umich.edu
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jun 14, 2011 at 6:40 AM,  <tao.peng@emc.com> wrote:
> Hi, Fred,
>
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org]
>> On Behalf Of Fred Isaman
>> Sent: Monday, June 13, 2011 10:37 PM
>> To: Jim Rees
>> Cc: linux-nfs@vger.kernel.org; peter honeyman
>> Subject: Re: [PATCH 03/34] pnfs: let layoutcommit code handle multiple segments
>>
>> On Sun, Jun 12, 2011 at 7:43 PM, Jim Rees <rees@umich.edu> wrote:
>> > From: Peng Tao <bergwolf@gmail.com>
>> >
>> > Some layout driver like block will have multiple segments.
>> > Generic code should be able to handle it.
>> >
>> > Signed-off-by: Peng Tao <peng_tao@emc.com>
>> > ---
>> >  fs/nfs/pnfs.c |   17 +++++++++++++----
>> >  fs/nfs/pnfs.h |    1 +
>> >  2 files changed, 14 insertions(+), 4 deletions(-)
>> >
>> > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> > index e3d618b..f03a5e0 100644
>> > --- a/fs/nfs/pnfs.c
>> > +++ b/fs/nfs/pnfs.c
>> > @@ -892,7 +892,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
>> >        dprintk("%s:Begin\n", __func__);
>> >
>> >        assert_spin_locked(&lo->plh_inode->i_lock);
>> > -       list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
>> > +       list_for_each_entry_reverse(lseg, &lo->plh_segs, pls_list) {
>>
>> This is a sortred list, and the order of search matters.  You can't
>> just reverse it here.
> The layout segment list is in offset increasing order. But the lookup code here assumes it's a decreasing ordered list.
> To fix it, we should either reverse lookup the list, or change the break condition test. Otherwise lookup always fails if not matching the first one.

I agree there is a problem here that affects the generic code.  I've
just sent a separate patch that deals with that.

Fred

>
>>
>> >                if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
>> >                    is_matching_lseg(&lseg->pls_range, range)) {
>> >                        ret = get_lseg(lseg);
>> > @@ -1193,10 +1193,18 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
>> >  static struct pnfs_layout_segment *pnfs_list_write_lseg(struct inode *inode)
>> >  {
>> >        struct pnfs_layout_segment *lseg, *rv = NULL;
>> > +       loff_t max_pos = 0;
>> > +
>> > +       list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
>> > +               if (lseg->pls_range.iomode == IOMODE_RW) {
>> > +                       if (max_pos < lseg->pls_end_pos)
>> > +                               max_pos = lseg->pls_end_pos;
>> > +                       if (test_and_clear_bit(NFS_LSEG_LAYOUTCOMMIT,
>> &lseg->pls_flags))
>> > +                               rv = lseg;
>> > +               }
>> > +       }
>> > +       rv->pls_end_pos = max_pos;
>> >
>>
>> The idea here was that it could be extended to use segment by
>> returning a list of affected lsegs,
>> not so,e random one.  Because otherwise you have problems with the
>> fact that relevant but not
>> returned lsegs are going to get there refcounts messed up.
> The above code relies on NFS_INO_LAYOUTCOMMIT bit to ensure that only one inode lseg has NFS_LSEG_LAYOUTCOMMIT set. But, you are right. The layoutcommit code needs a second thought.
> How about making it return a list of affected lsegs and pass them around layoutcommit_procs?
>
> Thanks,
> Tao
>
>>
>> Fred
>>
>> > -       list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list)
>> > -               if (lseg->pls_range.iomode == IOMODE_RW)
>> > -                       rv = lseg;
>> >        return rv;
>> >  }
>> >
>> > @@ -1211,6 +1219,7 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
>> >        if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
>> >                /* references matched in nfs4_layoutcommit_release */
>> >                get_lseg(wdata->lseg);
>> > +               set_bit(NFS_LSEG_LAYOUTCOMMIT,
>> &wdata->lseg->pls_flags);
>> >                wdata->lseg->pls_lc_cred =
>> >                        get_rpccred(wdata->args.context->state->owner-
>> >so_cred);
>> >                mark_as_dirty = true;
>> > diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> > index b071b56..a3fc0f2 100644
>> > --- a/fs/nfs/pnfs.h
>> > +++ b/fs/nfs/pnfs.h
>> > @@ -36,6 +36,7 @@
>> >  enum {
>> >        NFS_LSEG_VALID = 0,     /* cleared when lseg is recalled/returned */
>> >        NFS_LSEG_ROC,           /* roc bit received from server */
>> > +       NFS_LSEG_LAYOUTCOMMIT,  /* layoutcommit bit set for
>> layoutcommit */
>> >  };
>> >
>> >  struct pnfs_layout_segment {
>> > --
>> > 1.7.4.1
>> >
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> >
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
