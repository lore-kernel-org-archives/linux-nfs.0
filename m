Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D5C1C46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 15:31:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1277620834
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 15:31:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EMMMtbz9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1277620834
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727751AbeJZAEp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 20:04:45 -0400
Received: from mail-vs1-f66.google.com ([209.85.217.66]:46052 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727367AbeJZAEp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 20:04:45 -0400
Received: by mail-vs1-f66.google.com with SMTP id g201so5761411vsd.12;
        Thu, 25 Oct 2018 08:31:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VSDb3VuWsAAvUNdGk5f19gk0en4vxKGyKmaSQEGO5VA=;
        b=EMMMtbz9kXSHhZT/8EFGiWT9yluGGlI9Pok1RctktvcUAAja1OUDRBcER0R3IliN0G
         2Ufy03VMDEoiceR+LAdam8aKCKYQlr0jSYds2jWq54Brs0hax5hQbeV3LrDUOcS5IHXs
         aBR6NdCCicUYqbUKCi/vdbaH55o03nSFk42DDOc77P0TNKHes2ZGUKkYs+iD+MJFMg9r
         viRtSNhamxpZymMttEFDBu3wHUZzSOnq5PmSh2CoBwOg4tQphwTs6hXb0jXdtdnVwJMu
         ymNq7SPzUWrKiwosuoks2XkZcWBSikpQE4fSWCDrSUva2FtYZWTl3VpnDiGaS1LIk0Cw
         xylw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=VSDb3VuWsAAvUNdGk5f19gk0en4vxKGyKmaSQEGO5VA=;
        b=W3S26pX/A2wnmspRy4z0Dvyi1EW0fHYcs6n8b3w6X+bqjHCrsanrbF3yc6z8+b/BND
         YU0+aTsPAE5P9oW3RN8Z0k+eZfeWn0FmsHBWpwJxxWCtWSPqyY9Tf8GshkkdZ2xFl+WI
         NInQqXyhnRoC4vnjutVPwvNxn7VkKx07ME716ocuMHGIZ11rqjpXx+wiAwbL3hWOAohu
         A3sjmr7+yL4r9G2zoHYNK7ObZ+pZyGBBsICBHby/yHHwg0iHAXGCM6fNXx2DBO6tV1Ta
         Rk5JHV/z15wpwwydCSIfhV1coC//vzX6Kin3qIYSYqDi6LgW9+IAgMA4wfPLbXDyEaY8
         LxXA==
X-Gm-Message-State: AGRZ1gLBF4lTa0J1XcrnDyN3/ZCsTxH5XYQbBGz/Jd8bB2X6WLPZgGk5
        38/NDSeUM2VUcS0i0lRfgfPna4Y4ZrpWpIusLHg=
X-Google-Smtp-Source: AJdET5eUBtXYJR/4UQwnWf8Ekwu9PSfp1sLzaQsmAqsBjFf96MAcjPqkwXHZq/KN5ivSiJp1FUUcp39X4ToQj7lLOcw=
X-Received: by 2002:a67:a858:: with SMTP id r85mr898742vse.215.1540481487112;
 Thu, 25 Oct 2018 08:31:27 -0700 (PDT)
MIME-Version: 1.0
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
 <20181024195837.35532-5-olga.kornievskaia@gmail.com> <CAOQ4uxiB5PLd9QjAp7pQerXOJdtkLbGAENhsGsAQehYWdK91PQ@mail.gmail.com>
In-Reply-To: <CAOQ4uxiB5PLd9QjAp7pQerXOJdtkLbGAENhsGsAQehYWdK91PQ@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 25 Oct 2018 11:31:15 -0400
Message-ID: <CAN-5tyHSz2UV=UNpQPLTeSVvxkYp85bT6ZPJGP2kS7D6aQWn4Q@mail.gmail.com>
Subject: Re: [PATCH v2 03/13] OverlayFS: add cross-device check for copy_file_range
To:     Amir Goldstein <amir73il@gmail.com>
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

On Thu, Oct 25, 2018 at 1:54 AM Amir Goldstein <amir73il@gmail.com> wrote:
>
> On Wed, Oct 24, 2018 at 10:59 PM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> >
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > VFS copy_file_range was relaxed to allow for cross-device copy.
> > Add a check for now, to disallow cross-device copy offload until
> > appropriate support is added.
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > `
> > ---
> >  fs/overlayfs/file.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> > index aeaefd2..5282853 100644
> > --- a/fs/overlayfs/file.c
> > +++ b/fs/overlayfs/file.c
> > @@ -483,6 +483,9 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
> >                                    struct file *file_out, loff_t pos_out,
> >                                    size_t len, unsigned int flags)
> >  {
> > +       if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
> > +               return -EXDEV;
> >
>
> Note that this could be relaxed later on to same fs type
> allowing for cross container copy_file_range() to be performced
> as clone_file_range() when upper is a shared fs with clone support.
>
> Don't worry about it though, I can make this change later after testing
> the use case.
>
> As long as this patch comes in the series *before* relaxing the VFS check,
> You may add:
> Reviewed-by: Amir Goldstein <amir73il@gmail.com>

Thank you. I will reorder the patches and yes I thought the individual
FS maintainers/folks would relax the check according to their
functionality. This patch just provides same semantics with respect to
the cross device checking but at the driver level.

>
> Thanks,
> Amir.
