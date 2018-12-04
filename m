Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91CC6C04EB8
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 09:17:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 544E22082B
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 09:17:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LS6xqhYy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 544E22082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725769AbeLDJRv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 04:17:51 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:34685 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725764AbeLDJRv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 04:17:51 -0500
Received: by mail-yw1-f68.google.com with SMTP id g75so6671272ywb.1;
        Tue, 04 Dec 2018 01:17:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=J1Bgzw4RTpk8iJ+E52msBmCaL5bOiwXQP8FT5zcIPpI=;
        b=LS6xqhYy88zFbj/lsH+vMCaNN5w0hUm8CoczZ5J//H8QDc1ie1e08ZcQTCFw8nG4Ok
         GC4sarZ31ycdcm1FpGnW5SdwMehd8cav7OEbKAxSkxoHhIMxGFGL2sjNXsOc4ebO2LUC
         a0fXrbIZTvzxH8LNGUzc0GVa/tUh414BPtBXO0kLs5RtSkNUbzOiemY62x5R8R9Egru/
         hCvPApebQ8WEXaV358+8b+u0Wawgnv/pzzDwy/CfkxhM9q+vX2QDJPFaAeQrMIkRPERD
         +dYyTiUtUCcQKgzpXKT76dxQgdGRTx6KynViICx8mAH1cuu+X3ltQz0oyxXWEQIuF1NB
         0ZKA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=J1Bgzw4RTpk8iJ+E52msBmCaL5bOiwXQP8FT5zcIPpI=;
        b=Ezrw5o/QBjKEk/e+I+yoZOaBtzu8kArF+TXCtKP8RrIHsBYOdgurnA4JguhU9Ezav1
         z3u6axZTq6mRKGBtLuFtq/DQ3zIXS4FqpMfKbvH4pn04XJHMc3uDWOMC5RQtDm0kmg+T
         XylT+1sGVsN/23QcnJns2GmnZCgT0FQ8JW6sReDuOK1m3+szmai0DOblXIWHs8iQWvHU
         0S00Hk3S8JyjtueExK65tdzv0ibSMaD1n+mDKdMCg7T9Qg8oyPWEPsXDzSUNQJDj7lIt
         Ki/Ei0aukBB8eyas+vkUY1Q/lSO3+eNYOfXuEbmUeVNz+zswI/PaV+YRw0HqACd8y1x2
         mmpA==
X-Gm-Message-State: AA+aEWZpbY1p22E9j0TtpNHZYCTyTPGxG8y/bIOzGQVADAaGFPbCvrIm
        1swttudTDhxddqsQIt4RbLsWZo/BtyodGyMEono=
X-Google-Smtp-Source: AFSGD/W5wbnQ15lFHabzmylOMcgAjhkOej3XnDMKRkzDNulYgZ6DP+l8uAxyAc7FIp4/gtkSLV8rXj4j9HWhO8NEmxc=
X-Received: by 2002:a81:c144:: with SMTP id e4mr19656450ywl.409.1543915070031;
 Tue, 04 Dec 2018 01:17:50 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-9-david@fromorbit.com>
 <CAOQ4uxgwZLsO1yV37_CHaZ-O+-+-OggSP9g6m9YE57kLPc5yDw@mail.gmail.com>
 <20181203191130.GD24487@magnolia> <20181203233714.GL6311@dastard> <20181203235837.GF24487@magnolia>
In-Reply-To: <20181203235837.GF24487@magnolia>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Tue, 4 Dec 2018 11:17:38 +0200
Message-ID: <CAOQ4uxgRe8yqeRv-UEqCa+YD2buTUq5FdguHtJoQAgtBEpTTVw@mail.gmail.com>
Subject: Re: [PATCH 08/11] vfs: push EXDEV check down into ->remap_file_range
To:     "Darrick J. Wong" <darrick.wong@oracle.com>
Cc:     Dave Chinner <david@fromorbit.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

> > > I think this is sort of backwards -- the checks should stay in
> > > do_clone_file_range, and vfs_copy_file_range should be calling that
> > > instead of directly calling ->remap_range():
> > >
> > > vfs_copy_file_range()
> > > {
> > >     file_start_write(...);
> > >     ret = do_clone_file_range(...);
> > >     if (ret > 0)
> > >             return ret;
> > >     ret = do_copy_file_range(...);
> > >     file_end_write(...);
> > >     return ret;
> > > }
> >
> > I'm already confused by the way we weave in and out of "vfs_/do_*"
> > functions, and this just makes it worse.
> >
> > Just what the hell is supposed to be in a "vfs_" prefixed function,
> > and why the hell is it considered a "vfs" level function if we then
> > export it's internal functions for individual filesystems to use?
>
> I /think/ vfs_ functions are file_start_write()/file_end_write()
> wrappers around a similarly named function that lacks the freeze
> protection??

That is definitely not an official definition of vfs_ vs. do_, but I found
this rule to be a common practice, which is why I swapped
{do,vfs}_clone_file_range(). But around vfs you can find many examples
where do_ helpers wrap vfs_ helpers.

>
> (AFAICT Amir made that split so that overlayfs could use these
> functions, though I do not know if everything vfs_ was made that way
> /specifically/ for overlayfs or if that's the way things have been and
> ovlfs simply takes advantage of it...)
>
> Guhhh, none of this is documented......
>

It looks like in git epoc, things were pretty straight forward.
vfs_XXX was the interface called after sys_XXX converted
userspace arguments (e.g. char *name, int fd) to vfs objects
(e.g. struct path,dentry,inode,file). Sometimes vfs_ helpers called
do_ helpers for several reasons. See for example epoc version
of fs/namei.c fs/read_write.c.
Even then there were exception. For example do_sendfile()
doesn't even have a vfs_ interface, although it is clear what
that prospect interface would look like.
To that end, do_splice_direct() acts as the standard do_ helper
to that non-existing vfs_ interface.

From there on, I guess things kinda grew organically.
fs/namei.c syscalls grew do_XXXat() helpers between syscalls
and vfs_XXX interface.

Overlayfs uses vfs_ interface 99% of the time, so from that perspective
it is regarded as an interface with vfs objects as arguments that does
NOT skip security_ checks and does NOT bypass freeze protection.

Overlayfs calling do_clone_file_range() and do_splice_direct() are
the only exception to this rule.
If we would want to replace those calls in ovl_copy_up_data() with
a single call to do_copy_file_range(), than said helper should NOT
be taking freeze protection and should do the fallback between
filesystem copy_file_range and generic_copy_file_range.

Cheers,
Amir.
