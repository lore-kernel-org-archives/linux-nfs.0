Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E08F5C2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:46:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 971212082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:46:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="F3nPEBFt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 971212082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728214AbeJ3CgE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:36:04 -0400
Received: from mail-ua1-f67.google.com ([209.85.222.67]:39102 "EHLO
        mail-ua1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726205AbeJ3CgE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:36:04 -0400
Received: by mail-ua1-f67.google.com with SMTP id j38so3362875uae.6;
        Mon, 29 Oct 2018 10:46:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wSqRAiDsbEdBaMtgBJIEuXk59ZzDzR+NGmoJCX2+6S4=;
        b=F3nPEBFtnFZW6wYTjavQdZKRXqnJ15V7oFo8IAIt42SvOQVU8M+egBr2Qpp314PqHa
         4qH+frW9uW5KHz07wNcbKKeIfM4ZTL+Hr+eEAJ4iAA9gbhD2lgGYrURi1g1s9tair5Nb
         ZePGuCG8cPRIPmyj0jxr0cx5B3QmvOfYtIeiv16mNqhVj/xnFQuTk4VvObHItwD1fVyK
         r4EWroiOlvWLgT8WzdFbDCMPKMGZNJgcilBHat44b346EgF15cVF74v8stiZPECFKNFj
         244c8J8Tc3eGr/Dh2cE/0rTa7GQWvmj+dkSNTKuX5gMHlKM1G5TVPD3+dmMeoC+wkEno
         bAng==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=wSqRAiDsbEdBaMtgBJIEuXk59ZzDzR+NGmoJCX2+6S4=;
        b=VPsKrLuLOGHiSVjVCkhVnMzqiqpr/Lp1pwHunLlZJIN02098WkP0ysrC8mOVng0CSZ
         MNIfeagifJYDy+Q6PkCzNvfDm8RQHOWvXiSDitxKfYtNG9DcmsPm8+7vfR0uzGYbYkaE
         D3t/cBp5DgmZpx/m1yOu/EWPsTiKZakLuLB+E04Y7hiqdIHuLyt5FmGnIUEqdRe73Ujh
         uH/CDxUM1L9hkv+mwrdQ1yr6Q8qpkcUBcABsZVIqRqvTm9ewLzV3B8ZvlajErYtKut0f
         xEgdkhaN0nB3XBUlIXKh5ZuJoyzuqSBeihdN500KEgVeyP3eNr/GprZZqig2R3Jpd5dK
         sH3g==
X-Gm-Message-State: AGRZ1gJAlmWA9LqnaTE6bgZEzqr6rMVrTEv4b9oBlCgD5BBZ26faJOzX
        j3oTd0SW1Wo7sp3G/UBZbz/UZU2qPspvaZEXro1gew==
X-Google-Smtp-Source: AJdET5fCtgKYOYXjAHvdPzejKQT++543pP+UAK7lECzd/bVfDjxuUjW/ByypC8aY9U4UaBHGrH2sMMCfvqM0JAXYbfQ=
X-Received: by 2002:ab0:918:: with SMTP id w24mr6893536uag.51.1540835184551;
 Mon, 29 Oct 2018 10:46:24 -0700 (PDT)
MIME-Version: 1.0
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com> <20181029174059.38326-14-olga.kornievskaia@gmail.com>
In-Reply-To: <20181029174059.38326-14-olga.kornievskaia@gmail.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Mon, 29 Oct 2018 13:46:12 -0400
Message-ID: <CAN-5tyEuxrsJYEaWPoY63FKHZN7ZPSrmNwqOoZMo52yU_MHLQA@mail.gmail.com>
Subject: Re: [PATCH v5 12/12] NFS: replace cross device check in copy_file_range
To:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        viro@zeniv.linux.org.uk, Steve French <smfrench@gmail.com>,
        Miklos Szeredi <miklos@szeredi.hu>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, linux-man@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please note this is PATCH v5 (it got added to the thread of PATCH v4).

On Mon, Oct 29, 2018 at 1:41 PM Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
>
> From: Olga Kornievskaia <kolga@netapp.com>
>
> Add a check to disallow cross file systems copy offload, both
> files are expected to be of NFS4.2+ type.
>
> Reviewed-by: Jeff Layton <jlayton@kernel.org>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs4file.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index 989f174..fde4465 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -138,11 +138,16 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
>         struct nl4_server *nss = NULL;
>         nfs4_stateid *cnrs = NULL;
>         ssize_t ret;
> +       struct nfs_client *c_in;
>
>         if (pos_in >= i_size_read(file_inode(file_in)))
>                 return -EINVAL;
>
> -       if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
> +       if (file_in->f_op != &nfs4_file_operations)
> +               return -EXDEV;
> +
> +       c_in = (NFS_SERVER(file_inode(file_in)))->nfs_client;
> +       if (c_in->cl_minorversion < 2)
>                 return -EXDEV;
>
>         if (file_inode(file_in) == file_inode(file_out))
> --
> 1.8.3.1
>
