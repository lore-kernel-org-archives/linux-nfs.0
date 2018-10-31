Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34D19C0044C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 14:52:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A6C882054F
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 14:52:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="C7bvS3l6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6C882054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729030AbeJaXuY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 19:50:24 -0400
Received: from mail-vs1-f67.google.com ([209.85.217.67]:35127 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728463AbeJaXuX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 19:50:23 -0400
Received: by mail-vs1-f67.google.com with SMTP id d62so8436623vsd.2;
        Wed, 31 Oct 2018 07:52:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bmxGEhjpHem322wVZsazjxDIpFzRYNymIFO5j9HN2IA=;
        b=C7bvS3l6DauTfJPwb3QHG+YQR0KmZ5hoy4xhm3WzlSk7Uj9bZRikM6gj4Nr0ZWSCT6
         aMuYlUDfYDReNyGJqimWQdH/uHnNoH1ULM6/7C2oyMT5ltXvnlfqNajFa7Ugyk6cGoCB
         J1MdWg55NtWZ6VU6Vd1ZDmX7cgXLMZkSSAGaZ1RiFE9SpkO06zMTtgSpu5k6RNUaIOh9
         CHycTSkLaewPIhDZ+SWYg35DcJC0KoenM0NK7n9fnDDYDdjkDkPKDM7iIFIDpTcniebs
         qumTM2g9Bag6W0EjVsqaBcrrfzyxxOwsHje++n+1ZCMgtSqx0B2bZcXDLSBZNEeIYtVo
         RVoA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=bmxGEhjpHem322wVZsazjxDIpFzRYNymIFO5j9HN2IA=;
        b=ZMd3WzVExpCnvAvbbrV1J8NdAsy7hv2nFypPALonzp8FvmSO5f1sNE7FC2haXyS/M3
         CwUbwxq0kQ1IzpRn1T3S+CDD9yeOdEGoJgPYR9FXzK4Oeh4NFbualIKjUO4hGgJH5cRA
         a22vAELxHHCAi20nqKnceGCVU/SsnUcmlsQEzGR5o4SQ0wHO/cNS2JYkCVcRjRik6CC3
         3pzGC4PDdiwhmVtEcoI/Iys/sKXk/Eff0Q5N/AW3UOg+Kg4ojJnAi3R1ONeW+ZA/eNC2
         V/o6RPk0QPirxWrQDZyO83kmg5H2/zFQzoRZSH3InrFVOW+LOAs0iHCPRqGLvuzoispx
         fQ9w==
X-Gm-Message-State: AGRZ1gJQj27gvCpvxQzwPgGG2xEoamwtufw8AoJV+tVpG84HKDYIJuJD
        QgLjpmEczyZrvbzzEhD6l7AHIM6yxYinkb1vjgk=
X-Google-Smtp-Source: AJdET5d1BLr6BpL92WiNWaFvugQekrW2aFdeTUxEIARjWmt7SDAbzaz1Rzb2EQyNNTMej+HlXS53azia4JsNaujlijE=
X-Received: by 2002:a67:60c7:: with SMTP id u190mr1368968vsb.85.1540997520575;
 Wed, 31 Oct 2018 07:52:00 -0700 (PDT)
MIME-Version: 1.0
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-4-olga.kornievskaia@gmail.com> <20181027092750.GL6311@dastard>
 <CAN-5tyEeMrRVUyP61Vv-dwFUvm7q55Q3=NVJkeZN+XoCcAOCDQ@mail.gmail.com>
 <20181030090344.GN6311@dastard> <CAN-5tyHhTQ8bZk+DUrU0o1ZK3k9uhipiLPeOA3dYuXUG542mNw@mail.gmail.com>
 <20181031001437.GQ6311@dastard>
In-Reply-To: <20181031001437.GQ6311@dastard>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Wed, 31 Oct 2018 10:51:48 -0400
Message-ID: <CAN-5tyEHAUadnxuGmxC_KJzwUT7JO=-VSyioAQM0GTUR6+WY_Q@mail.gmail.com>
Subject: Re: [PATCH v4 02/11] VFS: copy_file_range check validity of input
 source offset
To:     david@fromorbit.com
Cc:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        viro@zeniv.linux.org.uk, Steve French <smfrench@gmail.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, linux-man@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 30, 2018 at 8:15 PM Dave Chinner <david@fromorbit.com> wrote:
>
> On Tue, Oct 30, 2018 at 05:10:58PM -0400, Olga Kornievskaia wrote:
> > On Tue, Oct 30, 2018 at 5:03 AM Dave Chinner <david@fromorbit.com> wrote:
> > >
> > > On Mon, Oct 29, 2018 at 10:41:22AM -0400, Olga Kornievskaia wrote:
> > > > On Sat, Oct 27, 2018 at 5:27 AM Dave Chinner <david@fromorbit.com> wrote:
> > > > >
> > > > > On Fri, Oct 26, 2018 at 04:10:48PM -0400, Olga Kornievskaia wrote:
> > > > > > From: Olga Kornievskaia <kolga@netapp.com>
> > > > > >
> > > > > > Input source offset can't be beyond the end of the file.
> > > > > >
> > > > > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > > > > ---
> > > > > >  fs/read_write.c | 3 +++
> > > > > >  1 file changed, 3 insertions(+)
> > > > > >
> > > > > > diff --git a/fs/read_write.c b/fs/read_write.c
> > > > > > index fb4ffca..b3b304e 100644
> > > > > > --- a/fs/read_write.c
> > > > > > +++ b/fs/read_write.c
> > > > > > @@ -1594,6 +1594,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> > > > > >               }
> > > > > >       }
> > > > > >
> > > > > > +     if (pos_in >= i_size_read(inode_in))
> > > > > > +             return -EINVAL;
> > > > > > +
> > > > >
> > > > > vfs_copy_file_range seems ot be missing a wide range of checks.
> > > > > rlimit, s_maxbytes, LFS file sizes, etc. This is a write, so all the
> > > > > checks in generic_write_checks() apply, right? And the same security
> > > > > issues like stripping setuid bits, etc? And we need to touch
> > > > > atime on the source file, too?
> > > >
> > > > Yes sound like needed checks.
> > > >
> > > > > We've just merged 5 or so patches in 4.19-rc8 and we're ready to
> > > > > merge another ~30 patch series to fix all the stuff missing from the
> > > > > clone/dedupe file range operations that make them safe and robust.
> > > > > It seems like copy_file_range is all the checks it needs, too?
> > > >
> > > > Are you proposing to not do this check now in favor of the proper work
> > > > that will do all of those checks you listed above?
> > >
> > > No, I'm saying that if you're adding one check, there's a whole heap
> > > of checks that still need to be added, *especially* if this is going
> > > to fall back to page cache copy between superblocks that may have
> > > different limits and constraints.
> > >
> > > There's security issues in this API. They need to be fixed before we
> > > allow it to do more and potentially expose more problems due to it's
> > > wider capability.
> >
> > Before I totally give up on this feature, can you help me understand
> > your concerns with allowing the generic copy_file_range via
> > do_splice().
>
> it's not do_splice_direct() i'm concerned about. It's /writing data
> without adequate checks/ that I'm concerned about.
> ->copy_file_range() also writes data, so it needs to undergo the
> same safety checks as well.

Thank you Dave for clarifying and elaborating on the points. As you
pointed out this concerns apply to the current code the same way as to
the patch series. Those concerns should be address however I feel like
they shouldn't be the responsibility of this particular patch series.
Therefore, I ask for the community to either make any final comments
for any changes that are needed to "version 7" patches and if no more
comments arise I would like to ask for this to be added to the queue
for the next kernel version.

Then the next patch series would be just VFS and would add appropriate
checks and then allow for the generic copy_file_range() via do_splice.

> > I have mentioned I'm not a VFS expert thus I come from just looking at
> > the available documentation and the code.
> >
> > I don't see any restrictions on the files being passed in the
> > do_splice_direct(). There are no restrictions that they must be from
> > the same filesystem or file system type. But perhaps this not the
> > concern you had but more about checking validity of arguments?
> >
> > I have looked at Dave Wong's, if I'm not mistaken these 2 are the
> > relevant patches:
> > [PATCH 02/28] vfs: check file ranges before cloning files
> >  -- a couple but not all checks apply to copy_file_range() .
>
> Yes, of course - clone/dedupe have different constraints, but the
> core checks are still needed for copy_file_range().
>
> For example, the man page says:
>
> EINVAL
>         Requested range extends beyond the end of the source
>         file; or the flags argument is not 0.
>
> Your patch above doesn't actually check that - it only checks if the
> pos_in is beyond EOF. It needs to check if pos_in + len is beyond
> EOF. After checking for wraps, of course.

There was a reason why I didn't include the "pos_in + len" check. It
sparked the conversation why should "pos_in + len" be an error, when a
"read" system call would just return a "short" read and EOF. So I
dropped the check for "pst_in + len" to be an error.

https://www.spinics.net/lists/linux-nfs/msg62627.html  (probably not
all the conversations but some of them)

> > [PATCH 04/28] vfs: strengthen checking of file range inputs to
> > generic_remap_checks
> >  -- these checks apply to the code once we fall back to the
> > do_splice().
>
> man page says:
>
> EFBIG
>        An  attempt  was made to write a file that exceeds the
>        implementation-defined maximum file size or the process's
>        file size limit, or to write at a position past the maximum
>        allowed offset.
>
> These conditions apply to the destination file regards of the method
> used to copy the data. That's what the generic methods now check for
> clone/dedupe, and need to be used here, too.

Agreed and once Darrek patches are in, copy_file_range() can use them too.

> e.g. In the case of NFS, if the user ion the NFS client is not
> allowed to copy a file (e.g. say user RLIMIT restrictions) then that
> should not be bypassed just because the NFS client can do a server
> side copy. The restriction has been placed on the local user calling
> copy_file_range(), not on the server side implementation.
>
> > Also, can you elaborate one what "security issues" are present in this
> > API? Is it "stripping setuid bits" and so something like calling
> > file_remove_priv() that should be done when the fallback to the
> > do_splice_direct() happens?
>
> From 4.19-rc8:
>
> 7debbf015f58 xfs: update ctime and remove suid before cloning files
>
> Which then got moved into the generic remap_file_range code in
> Darrick's "vfs: remap helper should update destination inode
> metadata" patch:
>
> https://git.kernel.org/pub/scm/fs/xfs/xfs-linux.git/commit/?h=for-next&id=8dde90bca6fca3736ea20109654bcf6dcf2ecf1d
>
> We can't assume that a server side copy is going to strip setuid
> bits or even update target files c/mtimes.

I would like to discuss your concerns about updating attributes
(c/m/atimes), why shouldn't it be a ->copy_file_range()
responsibility. copy_file_rage is basically a read+write. As far as I
can tell, vfs_read and vfs_write (in VFS) don't deal with updating
attributes. I'm guessing it's assumed that underlying file systems are
going to take care of it (unless of course I misread the code).

> > As for the atime, wouldn't the ->copy_file_range() be updating the
> > file attributes? I guess for the fallback case, the attributes need to
> > be updated.
>
> Generic VFS code should take care of atime updates. Hence if the
> source file needs an atime update, it should be in the generic code
> and done for all copy methods.
>
> > If those are checks/issues needed to be addressed and would then get
> > the generic copy_file_range() in, I could give a go at a patch (or 2).
>
> yes, those are the ones I'm aware of. BUt there may be more, I
> haven't really looked that closely...
>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
