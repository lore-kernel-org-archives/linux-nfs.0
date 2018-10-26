Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3976BC6786E
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 12:12:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D586F20868
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 12:12:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uB2E3jA+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D586F20868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727660AbeJZUtV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 16:49:21 -0400
Received: from mail-ua1-f65.google.com ([209.85.222.65]:38964 "EHLO
        mail-ua1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727507AbeJZUtV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 16:49:21 -0400
Received: by mail-ua1-f65.google.com with SMTP id j38so315735uae.6;
        Fri, 26 Oct 2018 05:12:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9lVv5pZSk5R9KBHyeay/lxnKoE2GtNMtn9Q5ZrjSeIQ=;
        b=uB2E3jA+Lyzjvcahp5FsnFVvMnNpchslcqMdxA8lalv2kIG6lyOGtRs35l2mXnE1us
         a2ps3LhUQyScf+or1YaGezwds6orw9ZVDU8yEQOOOJQfHd/rH8KRZHFmbp0rxrnFwDBm
         2uX7MrLjpt1E5Vg2A79WbdObdnupHQ4GZx1gGr+muFnOlfyH8gHaDDlqvr8fgc98sNyf
         et6fioWTIoVtXkCXzAAJK6nEo7z9KmiKl2YvGxtVkpPiePrVq84c1yD5yGHRvbXdoyRt
         CMv0HG9hn7JFwZIyQtn080Xa5+A7Yq9i/NENMM290qMwdLZE+cJljkMfhF89v2AoTcRz
         q0HQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=9lVv5pZSk5R9KBHyeay/lxnKoE2GtNMtn9Q5ZrjSeIQ=;
        b=U5tyEtq7RXLF1MHrlTb9epAG4HlJ30gZy/FQ4qDsVOU/KGitMEzkjl/C0TbjRUZIl4
         ztD0yQN/btxOWOiWsc1UC3SS0k4hVSXUVGXBo2LBgep3kK9SUQ1b1mA8fFoK7V0mgZ25
         vBDfvHAFso3EQRmlDdhlh1eoEsNEotonweciD8YVtD6F1YRJEtry8KNaKab4gAhoESmD
         nC8b6v1FyQblVkANJCc3AvM/XltFEWrchuPUXekRw58gd/pxcTJarX5Y9KpMYLvUDHDI
         T5+/lpUaX6SEEa/jl3jolQpSI38kvu6yq31Mak5yZu1aT+5XZkkfQvwFs75llckG4cnO
         NHkw==
X-Gm-Message-State: AGRZ1gLkLd5CnMuk8GN23U9SLfD2EVw8kU6mO9BwBc7rp2/H/GJUkf52
        7WRXshpY45i1bCo6PfKIDIgxZIiVwMJgAgTUIAROHL8p
X-Google-Smtp-Source: AJdET5egqThhmfLmjLxcVqyAvn8t3YVK0c3N7JkpvP4qIi4p5kkqWoELwysj4E1SQR5Yb2Jl5stalFAauMWDGWW74Go=
X-Received: by 2002:a9f:35cd:: with SMTP id u13mr1456988uad.5.1540555947840;
 Fri, 26 Oct 2018 05:12:27 -0700 (PDT)
MIME-Version: 1.0
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
 <20181024195837.35532-5-olga.kornievskaia@gmail.com> <CAOQ4uxiB5PLd9QjAp7pQerXOJdtkLbGAENhsGsAQehYWdK91PQ@mail.gmail.com>
In-Reply-To: <CAOQ4uxiB5PLd9QjAp7pQerXOJdtkLbGAENhsGsAQehYWdK91PQ@mail.gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Fri, 26 Oct 2018 08:12:15 -0400
Message-ID: <CAN-5tyFHiYufamwJEPf9TFG6eQMVCoTkMz8ini9RyKuAW+RuTQ@mail.gmail.com>
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

Given that this patch was merged I didn't add "reviewed-by" line.
Please let me know I need to add this line to the main VFS patch.

>
> Thanks,
> Amir.
