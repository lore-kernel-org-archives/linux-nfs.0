Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBB2CC04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 23:40:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8B82E20850
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 23:40:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B82E20850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725946AbeLCXkc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 18:40:32 -0500
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:12079 "EHLO
        ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725909AbeLCXkc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 18:40:32 -0500
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 04 Dec 2018 10:07:16 +1030
Received: from dave by dastard with local (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gTxm6-0004SJ-Vm; Tue, 04 Dec 2018 10:37:15 +1100
Date:   Tue, 4 Dec 2018 10:37:14 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     "Darrick J. Wong" <darrick.wong@oracle.com>
Cc:     Amir Goldstein <amir73il@gmail.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [PATCH 08/11] vfs: push EXDEV check down into ->remap_file_range
Message-ID: <20181203233714.GL6311@dastard>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-9-david@fromorbit.com>
 <CAOQ4uxgwZLsO1yV37_CHaZ-O+-+-OggSP9g6m9YE57kLPc5yDw@mail.gmail.com>
 <20181203191130.GD24487@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203191130.GD24487@magnolia>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 03, 2018 at 11:11:30AM -0800, Darrick J. Wong wrote:
> On Mon, Dec 03, 2018 at 01:04:07PM +0200, Amir Goldstein wrote:
> > On Mon, Dec 3, 2018 at 10:34 AM Dave Chinner <david@fromorbit.com> wrote:
> > >
> > > From: Dave Chinner <dchinner@redhat.com>
> > >
> > > before we can enable cross-device copies into copy_file_range(),
> > > we have to ensure that ->remap_file_range() implemenations will
> > > correctly reject attempts to do cross filesystem clones. Currently
> > 
> > But you only fixed remap_file_range() implemenations of xfs and ocfs2...
> > 
> > > these checks are done above calls to ->remap_file_range(), but
> > > we need to drive them inwards so that we get EXDEV protection for all
> > > callers of ->remap_file_range().
> > >
> > > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > > ---
> > >  fs/read_write.c | 21 +++++++++++++--------
> > >  1 file changed, 13 insertions(+), 8 deletions(-)
> > >
> > > diff --git a/fs/read_write.c b/fs/read_write.c
> > > index 3288db1d5f21..174cf92eea1d 100644
> > > --- a/fs/read_write.c
> > > +++ b/fs/read_write.c
> > > @@ -1909,6 +1909,19 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
> > >         bool same_inode = (inode_in == inode_out);
> > >         int ret;
> > >
> > > +       /*
> > > +        * FICLONE/FICLONERANGE ioctls enforce that src and dest files are on
> > > +        * the same mount. Practically, they only need to be on the same file
> > > +        * system. We check this here rather than at the ioctl layers because
> > > +        * this is effectively a limitation of the fielsystem implementations,
> > > +        * not so much the API itself. Further, ->remap_file_range() can be
> > > +        * called from syscalls that don't have cross device copy restrictions
> > > +        * (such as copy_file_range()) and so we need to catch them before we
> > > +        * do any damage.
> > > +        */
> > > +       if (inode_in->i_sb != inode_out->i_sb)
> > > +               return -EXDEV;
> > > +
> > >         /* Don't touch certain kinds of inodes */
> > >         if (IS_IMMUTABLE(inode_out))
> > >                 return -EPERM;
> > > @@ -2013,14 +2026,6 @@ loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
> > >         if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
> > >                 return -EINVAL;
> > >
> > > -       /*
> > > -        * FICLONE/FICLONERANGE ioctls enforce that src and dest files are on
> > > -        * the same mount. Practically, they only need to be on the same file
> > > -        * system.
> > > -        */
> > > -       if (inode_in->i_sb != inode_out->i_sb)
> > > -               return -EXDEV;
> > > -
> > 
> 
> I think this is sort of backwards -- the checks should stay in
> do_clone_file_range, and vfs_copy_file_range should be calling that
> instead of directly calling ->remap_range():
> 
> vfs_copy_file_range()
> {
> 	file_start_write(...);
> 	ret = do_clone_file_range(...);
> 	if (ret > 0)
> 		return ret;
> 	ret = do_copy_file_range(...);
> 	file_end_write(...);
> 	return ret;
> }

I'm already confused by the way we weave in and out of "vfs_/do_*"
functions, and this just makes it worse.

Just what the hell is supposed to be in a "vfs_" prefixed function,
and why the hell is it considered a "vfs" level function if we then
export it's internal functions for individual filesystems to use?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
