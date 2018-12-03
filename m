Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E926EC04EBF
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 23:19:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BC6972081C
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 23:19:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC6972081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725909AbeLCXT1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 18:19:27 -0500
Received: from ipmailnode02.adl6.internode.on.net ([150.101.137.148]:3493 "EHLO
        ipmailnode02.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725858AbeLCXT1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 18:19:27 -0500
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail02.adl6.internode.on.net with ESMTP; 04 Dec 2018 09:49:22 +1030
Received: from dave by dastard with local (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gTxUn-0004Qt-3W; Tue, 04 Dec 2018 10:19:21 +1100
Date:   Tue, 4 Dec 2018 10:19:21 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [PATCH 07/11] vfs: copy_file_range should update file timestamps
Message-ID: <20181203231921.GJ6311@dastard>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-8-david@fromorbit.com>
 <CAOQ4uxiCi9qJ15J=L6fNjuLGykQm5CDuJ-=Y=TwTP5c=jx-_fA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxiCi9qJ15J=L6fNjuLGykQm5CDuJ-=Y=TwTP5c=jx-_fA@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 03, 2018 at 12:47:39PM +0200, Amir Goldstein wrote:
> On Mon, Dec 3, 2018 at 10:34 AM Dave Chinner <david@fromorbit.com> wrote:
> >
> > From: Dave Chinner <dchinner@redhat.com>
> >
> > Timestamps are not updated right now, so programs looking for
> > timestamp updates for file modifications (like rsync) will not
> > detect that files have changed. We are also accessing the source
> > data when doing a copy (but not when cloning) so we need to update
> > atime on the source file as well.
> >
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> >  fs/read_write.c | 10 ++++++++++
> >  1 file changed, 10 insertions(+)
> >
> > diff --git a/fs/read_write.c b/fs/read_write.c
> > index 3b101183ea19..3288db1d5f21 100644
> > --- a/fs/read_write.c
> > +++ b/fs/read_write.c
> > @@ -1576,6 +1576,16 @@ static ssize_t do_copy_file_range(struct file *file_in, loff_t pos_in,
> >  {
> >         ssize_t ret;
> >
> > +       /* Update source timestamps, because we are accessing file data */
> > +       file_accessed(file_in);
> > +
> > +       /* Update destination timestamps, since we can alter file contents. */
> > +       if (!(file_out->f_mode & FMODE_NOCMTIME)) {
> > +               ret = file_update_time(file_out);
> > +               if (ret)
> > +                       return ret;
> > +       }
> > +
> 
> If there is a consistency about who is responsible of calling file_accessed()
> and file_update_time() it eludes me. grep tells me that they are mostly
> handled by filesystem code or generic helpers called by filesystem code
> and not in the vfs helpers.

This isn't the "vfs helper" - this is the code that executes a data
copy. We have to do these timestamp updates regardless of the copy
mechanism used so it makes no real sense to force every
implementation to do it, and then also have to ensure the generic
fallback does it as well. Do it once for everyone, then nobody else
needs to care about it.

> FMODE_NOCMTIME seems like an xfs specific flag (for DMAPI?), which

It's a generic VFS flag that originally only XFS used. We check it
in places where data IO to XFS files might be done. Given that we
have vfs functions doing write on behalf of XFS filesystems (such as
remap_file_range() and copy_file_range() the timestamp updates need
to check this flag.

> most generic callers of file_update_time() completely ignore.

Because most cases don't get called from a context that can have
FMODE_NOCMTIME set. If more filesystems start to use FMODE_NOCMTIME
then it will have to be more widely checked.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
