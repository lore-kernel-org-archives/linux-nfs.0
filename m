Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2103CC46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 05:54:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CDA2F20831
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 05:54:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OYQdGVah"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDA2F20831
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727146AbeJYOZx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 10:25:53 -0400
Received: from mail-yb1-f195.google.com ([209.85.219.195]:44035 "EHLO
        mail-yb1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726867AbeJYOZw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 10:25:52 -0400
Received: by mail-yb1-f195.google.com with SMTP id p144-v6so3172536yba.11;
        Wed, 24 Oct 2018 22:54:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AorFrLiGYGjfWJoSPMVcRA8QJzANAgu9QiayGum+uUI=;
        b=OYQdGVahgrUl80kL+docyzbMUrAOvjGtYkmsdRKY0P8I5sn+xY3V/Ac8oq3QO/wife
         WRynfJ9bEtJBp1q3f0Jsd3Vmugn0qn9XcNwv4kkGqjdmCppf5uqJ2WlmcNZI1KAWjoAl
         c+Qs/kVI3n+Si8UJ7bJKjQndwZurHeX/k2Yhqg+iVpybcXokdfYVo1jfY29Au1SSMlEz
         CGR51FU0Z6nIohRtVyGx6XehGyxSE+s8P7DyteqFLuXJzTLY9BkBU//wl6NytI0wsQY6
         kqDSUsKmZT4QnyGRI+l/rWQMQslqGoB+THcA2VIy1e8Cor5Tzhj3QuGrSi2GEfU/9m6d
         Ge0A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=AorFrLiGYGjfWJoSPMVcRA8QJzANAgu9QiayGum+uUI=;
        b=sSbCqzz1O1Hs41bMs5nrdb4NmtgpxDJvAa/zCAn4T8Ast0fMdAYtOGTtu+wszQ4Yyj
         6BLTRe6lUuqM5sxVHHiKRObB+rNzBikzvmn+devBOetUOlyoxCZD9QD08Jm2ot6+szLA
         hC+N+PQf0q0kH+1xZpiUan2xcRoEnEyS3vQKPJnnoZA0WSHh5HhLUD7cqwZVqzD50vXH
         lzSyxvkoddtI47vfFT09ds63aoockdjXeQRPvi6HhgNXKNejFnR4vtXzr6Wv9C22g+xI
         vIeqixFD11dn3lKIJM0gmNcxKwQV+U3kgXPHythHWbH9W5MkvJL6Jalk/VjQJkkQ6cFd
         30DA==
X-Gm-Message-State: AGRZ1gK7Imh2xJ63JRui1vGxxiGbh8D6PsLkMIrH7ArtmNkjth+5bz3I
        Sc6+qE8CCwj1ELC9t8ls6Dzui1C4A4A+j61/a7E4MclF2sg=
X-Google-Smtp-Source: AJdET5cO2sJazHOoXI9yTDUI6V34mll3O2Hy50anHlWN8nDoWXS2CNqg8mTTdTo2s+YFHNcf2rOJ8SXqiKhKcRY5Noc=
X-Received: by 2002:a25:5208:: with SMTP id g8-v6mr159944ybb.462.1540446881226;
 Wed, 24 Oct 2018 22:54:41 -0700 (PDT)
MIME-Version: 1.0
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com> <20181024195837.35532-5-olga.kornievskaia@gmail.com>
In-Reply-To: <20181024195837.35532-5-olga.kornievskaia@gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Thu, 25 Oct 2018 08:54:30 +0300
Message-ID: <CAOQ4uxiB5PLd9QjAp7pQerXOJdtkLbGAENhsGsAQehYWdK91PQ@mail.gmail.com>
Subject: Re: [PATCH v2 03/13] OverlayFS: add cross-device check for copy_file_range
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Steve French <smfrench@gmail.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        overlayfs <linux-unionfs@vger.kernel.org>,
        linux-man@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Oct 24, 2018 at 10:59 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> From: Olga Kornievskaia <kolga@netapp.com>
>
> VFS copy_file_range was relaxed to allow for cross-device copy.
> Add a check for now, to disallow cross-device copy offload until
> appropriate support is added.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> `
> ---
>  fs/overlayfs/file.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> index aeaefd2..5282853 100644
> --- a/fs/overlayfs/file.c
> +++ b/fs/overlayfs/file.c
> @@ -483,6 +483,9 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
>                                    struct file *file_out, loff_t pos_out,
>                                    size_t len, unsigned int flags)
>  {
> +       if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
> +               return -EXDEV;
>

Note that this could be relaxed later on to same fs type
allowing for cross container copy_file_range() to be performced
as clone_file_range() when upper is a shared fs with clone support.

Don't worry about it though, I can make this change later after testing
the use case.

As long as this patch comes in the series *before* relaxing the VFS check,
You may add:
Reviewed-by: Amir Goldstein <amir73il@gmail.com>

Thanks,
Amir.
