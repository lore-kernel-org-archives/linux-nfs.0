Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF058C04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 23:05:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B260220864
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 23:05:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B260220864
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725994AbeLCXFI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 18:05:08 -0500
Received: from ipmail01.adl2.internode.on.net ([150.101.137.133]:5245 "EHLO
        ipmail01.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725961AbeLCXFI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 18:05:08 -0500
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail01.adl2.internode.on.net with ESMTP; 04 Dec 2018 09:34:54 +1030
Received: from dave by dastard with local (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gTxGo-0004Pf-C5; Tue, 04 Dec 2018 10:04:54 +1100
Date:   Tue, 4 Dec 2018 10:04:54 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 04/11] vfs: add missing checks to copy_file_range
Message-ID: <20181203230454.GI6311@dastard>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-5-david@fromorbit.com>
 <CAN-5tyH2RX_7SkvipnKkM2EF6_cHJ9qG6g9W+Ufb9+5r-Zb4hg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAN-5tyH2RX_7SkvipnKkM2EF6_cHJ9qG6g9W+Ufb9+5r-Zb4hg@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 03, 2018 at 04:33:30PM -0500, Olga Kornievskaia wrote:
> On Mon, Dec 3, 2018 at 3:34 AM Dave Chinner <david@fromorbit.com> wrote:
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -3022,6 +3022,9 @@ extern ssize_t generic_write_checks(struct kiocb *, struct iov_iter *);
> >  extern int generic_remap_checks(struct file *file_in, loff_t pos_in,
> >                                 struct file *file_out, loff_t pos_out,
> >                                 loff_t *count, unsigned int remap_flags);
> > +extern int generic_copy_file_checks(struct file *file_in, loff_t pos_in,
> > +                               struct file *file_out, loff_t pos_out,
> > +                               size_t *count, unsigned int flags);
> >  extern ssize_t generic_file_read_iter(struct kiocb *, struct iov_iter *);
> >  extern ssize_t __generic_file_write_iter(struct kiocb *, struct iov_iter *);
> >  extern ssize_t generic_file_write_iter(struct kiocb *, struct iov_iter *);
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 81adec8ee02c..0a170425935b 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -2975,6 +2975,75 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
> >         return 0;
> >  }
> >
> > +
> > +/*
> > + * Performs necessary checks before doing a file copy
> > + *
> > + * Can adjust amount of bytes to copy
> > + * Returns appropriate error code that caller should return or
> > + * zero in case the copy should be allowed.
> > + */
> > +int generic_copy_file_checks(struct file *file_in, loff_t pos_in,
> > +                        struct file *file_out, loff_t pos_out,
> > +                        size_t *req_count, unsigned int flags)
> > +{
> > +       struct inode *inode_in = file_inode(file_in);
> > +       struct inode *inode_out = file_inode(file_out);
> > +       uint64_t count = *req_count;
> > +       uint64_t bcount;
> > +       loff_t size_in, size_out;
> > +       loff_t bs = inode_out->i_sb->s_blocksize;
> > +       int ret;
> 
> I got compile warnings:
> 
> mm/filemap.c: In function ‘generic_copy_file_checks’:
> mm/filemap.c:2995:9: warning: unused variable ‘bs’ [-Wunused-variable]
>   loff_t bs = inode_out->i_sb->s_blocksize;
>          ^
> mm/filemap.c:2993:11: warning: unused variable ‘bcount’ [-Wunused-variable]
>   uint64_t bcount;

Strange. Yes, they certainly are there when I compile my stack up to
this point, but when I compile the whole series they aren't there.

I'll fix it up.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
