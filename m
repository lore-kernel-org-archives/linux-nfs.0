Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF189C04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 17:34:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A71BE20850
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 17:34:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SbRKD809"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A71BE20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726448AbeLCReK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 12:34:10 -0500
Received: from mail-vs1-f66.google.com ([209.85.217.66]:46403 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725916AbeLCReK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 12:34:10 -0500
Received: by mail-vs1-f66.google.com with SMTP id r14so7991934vsc.13;
        Mon, 03 Dec 2018 09:34:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2bNnFmVgG+n4xZ1zpC/vPexxdZhCm2/rqgQJ1NJL9W8=;
        b=SbRKD809D0AITTg/WeVfS0EElc0vl6hQh2XvWi2URD8kgeGr2JjTXMeefP5bvp5pRL
         Kvs53tZsgbpt4BOrroMTqtX+4uB5yYpZrnxnkxGiG//+imAdMNS1XucUttGx8VUZPrJ6
         wdXpLERbTfJaZuPZUZP4JcTrYQ6fOHaARHjI52TRzz2+atrlvC9CsAkmPW/pvWc4OH0S
         xi0ARHlBHioT4nXd6oQJfVenheynEEkRPkczIK56Ku/of9zPOU9tAFNY+jdoVoF5RuaP
         n6/nDXEaWlBCi4pml4Qwi71JQBGk1DuoBcnkk1xeVAw7Df9qnH4y9EqEcgWk7/T5hgld
         z8zw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=2bNnFmVgG+n4xZ1zpC/vPexxdZhCm2/rqgQJ1NJL9W8=;
        b=H1C0QFrM/OFb67LNBFy91Kgj5SASxXJ9EUQj8T+pnjRRZmo1IVpmcRV0bWVrAMK/kX
         Yg6KpTeWfNvxr7oYMjCj5gYUPD+7o+Yh8gphC74V+niTpPayfDcuZ/X5WGuuSOMvUA7r
         9v1LJiKHfr0VuwSj65f7HC1rVXSgO7wPLzcutyG0trfEXt5kRnXYs5Loo0CpZG3lvtVn
         zbh1J4KuxbUKmH1SpehLpw6xBT/+Dr8frV6O8KJHZbPPoOSX6841Q/y4TnYa3qXS6vnI
         ihXWwaA+XD0Kv2nfu2B9Zjor1R5LNnvxL+9Cq4bfVo+9HhwEdQvu6e0bsp/VnDLslHsa
         Bg9A==
X-Gm-Message-State: AA+aEWapoRRanDUbmKdtUmbX52ttF+wRw9OYrIRS01gIqNRk0S40Izz8
        Jw9qa1InzTcNqlDn4vDLFTkMa5wTa7h5o4g2tnE=
X-Google-Smtp-Source: AFSGD/XoFETgimuBcAwOjYHT1gK+ebuMXEhkGQad0dK7ctVV4xGc3j57gpcmmBCZEO/5+nfZb2Cl2+/1nkHplJA6afY=
X-Received: by 2002:a67:f453:: with SMTP id r19mr7350487vsn.164.1543858442424;
 Mon, 03 Dec 2018 09:34:02 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-8-david@fromorbit.com>
 <CAOQ4uxiCi9qJ15J=L6fNjuLGykQm5CDuJ-=Y=TwTP5c=jx-_fA@mail.gmail.com>
In-Reply-To: <CAOQ4uxiCi9qJ15J=L6fNjuLGykQm5CDuJ-=Y=TwTP5c=jx-_fA@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 3 Dec 2018 12:33:50 -0500
Message-ID: <CAN-5tyFMDnjm5cMneYyRTveyJ-6ddLCt1za-kk5eemOO2ngq=A@mail.gmail.com>
Subject: Re: [PATCH 07/11] vfs: copy_file_range should update file timestamps
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     david@fromorbit.com, linux-fsdevel@vger.kernel.org,
        linux-xfs@vger.kernel.org, linux-nfs <linux-nfs@vger.kernel.org>,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 3, 2018 at 5:47 AM Amir Goldstein <amir73il@gmail.com> wrote:
>
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
>
> FMODE_NOCMTIME seems like an xfs specific flag (for DMAPI?), which
> most generic callers of file_update_time() completely ignore.
> This seems like another argument in favor of leaving the responsibility
> of the timestamp updates to the filesystem.
>
> Maybe I am missing something?
>

I had similar question before about who is responsible for doing the
checks. I agree that attributes should be updated for the case when no
filesystem support exist for copy_file_range() but this code does it
for all the cases. I also wonder if it's appropriate to update the
attributes before the copy is actually done?

> Thanks,
> Amir.
