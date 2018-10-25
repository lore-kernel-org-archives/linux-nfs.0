Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE561C46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 04:38:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7D66220838
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 04:38:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l+EytUjA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D66220838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727125AbeJYNJ3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 09:09:29 -0400
Received: from mail-yb1-f196.google.com ([209.85.219.196]:39497 "EHLO
        mail-yb1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726803AbeJYNJ3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 09:09:29 -0400
Received: by mail-yb1-f196.google.com with SMTP id j9-v6so3133403ybj.6;
        Wed, 24 Oct 2018 21:38:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=aLV1P1iB5gtdabbjEWdvTSnZflZW7TgZIDzURFzZdu4=;
        b=l+EytUjAFOR4t5fFl4xQZcgIUikyD3CKWDB1eaW+6HW3MJ21L1BwQJj7cqQYJGEFe5
         QV5AI+iVWVNsnpBzgeOrAx0m6FsOXfRwprVBTabHR+9+16TgsAGWYAUcaU0/+FuFo0PV
         h9quf9snE6Gcm5U5pLIBaU4sVrPPU+q7AKqq0FrluvzI/sU+a/xeKOgzlI4OPtNE/hCM
         jr+o/DkfXsa66B6L4Uvygpr/wzjC1spjJjd6dkZOUDdp6J7rr7qDP4sdLPzPe187yv6d
         /YMvH2gc1RkDx5y8PqKtgkd/HieJMZ5Np+FppHK0cbDoZDlzEyiQcnnCD5CxO9GBX+l3
         et9Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=aLV1P1iB5gtdabbjEWdvTSnZflZW7TgZIDzURFzZdu4=;
        b=qolZ+0yPbbpuI6Nb/T+tDK78T7qO5QckIxtp7vCENdJ0KlOhNogq0Q4qXscYmHJQ9P
         3YnK2xk5GT+OztzM4ihg2nzHjqNOBK5KYVKC0NB9/7iUAM2SBizpcuJxx92Y/vkF/sYp
         6QhmOJR2fi5IsOWtG7BzEM2nLOa2ClWecmZ1V3GCj26d9hodT0jkQoyh2V2Q9PXzAcsK
         Hi+z7bAu84ti4QZ3VUYRh0FB0znxzi3Z2DNDIHIdhAH2ZM44u3NBaY/XMNFczbsbSUri
         zuWKS5Lw+U1tY26QB9oTBq+AGWjIVo/I4RMgPKSEhW+deK1GBZI6Na1LRh5VqaSSTcGa
         hAkA==
X-Gm-Message-State: AGRZ1gJ+9MLkqV2KwmI8XnC6Q1mjWdGf/s2df3RHNOoAAmQSZUID0QwY
        lB7ubmhIXa7VQebDX0DAtHTgvt26ad/+nj4pKkI=
X-Google-Smtp-Source: AJdET5cFMIqlN2qZ/LsEaZI1iwXL7MY0ZXuoJv6k9Br/1Kyfpi0FMI6hoI1S3Emjjxhh9rt1G368Weq8FPml+1honug=
X-Received: by 2002:a25:bdd0:: with SMTP id g16-v6mr3627ybk.397.1540442309930;
 Wed, 24 Oct 2018 21:38:29 -0700 (PDT)
MIME-Version: 1.0
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com> <20181024195837.35532-6-olga.kornievskaia@gmail.com>
In-Reply-To: <20181024195837.35532-6-olga.kornievskaia@gmail.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Thu, 25 Oct 2018 07:38:20 +0300
Message-ID: <CAOQ4uxg4_eF2_uur7-S=SCc5QzyVUfqRBjr9yYDGLsq5Ai4GXA@mail.gmail.com>
Subject: Re: [PATCH v2 04/13] NFS: add cross file system check for copy_file_range
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
> Add a check to disallow cross file systems copy offload, both
> files are expected to be of NFS type.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs4file.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index 4288a6e..7137e7b 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
>  {
>         ssize_t ret;
>
> +       if (file_in->f_inode->i_sb->s_type != file_out->f_inode->i_sb->s_type)
> +               return -EXDEV;
> +

You would need to doo  the patches in following order:
1. add same sb check in nfs
2. relax same sb check in vfs
3. implement cross fs copy in nfs
4. relax same sb to same sb type in nfs

Thanks,
Amir.
