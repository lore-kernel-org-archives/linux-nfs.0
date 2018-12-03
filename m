Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49C36C04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:46:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 11EBA20850
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:46:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kLE0C/EG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11EBA20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726507AbeLCMr1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 07:47:27 -0500
Received: from mail-yb1-f193.google.com ([209.85.219.193]:40623 "EHLO
        mail-yb1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726334AbeLCMr1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 07:47:27 -0500
Received: by mail-yb1-f193.google.com with SMTP id c15so1833594ybf.7;
        Mon, 03 Dec 2018 04:46:31 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=brSVA1xRAkPNSlKUMep4W/cRvwl2IOG7NleJYiGFAnk=;
        b=kLE0C/EGshcA/uzfLPkKCgKgplxOO6Qd6HiFhOxAZVa+tCQXjv+zrH2FYwFF8xmIRP
         WTEtymJUsvRTMsH/4DojhR13smASWh87vzPvxSq9ACoHnCmvRb8cA/0PbyG4/LzLHg4h
         FeZLHwBsUdDL4V6tNRJjwkZxpX5sQjec0P2OP+jCPJ/WF0X4H3CdCYmCjKM1OGFhqZNF
         N5SfhRyvjDWrTUftbyJmTRyKJKE6pWxAeTeLI+vCwyon5D3+jYW79WGl/UWfZEci0eiD
         Cl55ytmHRTNA7XEB12UqyU2MpWnc+Lcwl12VlAaTtV3T3pfraihdajVKzMvn5rCcvFzu
         ch5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=brSVA1xRAkPNSlKUMep4W/cRvwl2IOG7NleJYiGFAnk=;
        b=pV8HWazi39QqD8cdv1zdX7217P57o8GbvlQpqtdAJFkPGypvjuBlr/VjVb6UOSMIh9
         LoGoeaXkmhNzCsBo9rFbEiplbicBx5xngQ3zI3afzntHmOcQ+a6w5WIQ+GwTPJJBffO/
         +VV6zv2u/72NPrK/LynJ0O0LZdkgeBYs8fYBc628UWg0p334L6Vf4lDEvnLJIRg8j2GA
         630qCOeKodsVYHPTq8tR3tpkLwsbaoejoH9Re+Z+f2W8m6uGEfLLbBGDo9V8Z8ZW9KNC
         CeX9f57fgNKbqftC+G8zBl+n9X1PrvRB4mvdG6A9qewo20y/LZfwE9ngO4Rv96esEESw
         fhTg==
X-Gm-Message-State: AA+aEWZgl5t49ndC1GFdELnkKzBFZITAHGu/LY04O0o+9zv5rHHibW/V
        tvDFW4lY41cyzGZcXVT9ACdojHHabMy9zkW8KmM=
X-Google-Smtp-Source: AFSGD/VE46vGgAGVXFNiT+g7Gfk/Jkq5Ed91ioKRzo+iQ+p3WEDTmkCTmvbEyfJdN3tCD52FdwkMI4c7eHLWft9JRDA=
X-Received: by 2002:a25:d80c:: with SMTP id p12mr6216751ybg.507.1543841191464;
 Mon, 03 Dec 2018 04:46:31 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-2-david@fromorbit.com>
In-Reply-To: <20181203083416.28978-2-david@fromorbit.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 3 Dec 2018 14:46:20 +0200
Message-ID: <CAOQ4uxhOQY8M5rbgHKREN5qpeDGHv0-xK3r37Lj6XfqFoE4qjg@mail.gmail.com>
Subject: Re: [PATCH 01/11] vfs: copy_file_range source range over EOF should fail
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel <linux-fsdevel@vger.kernel.org>,
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

On Mon, Dec 3, 2018 at 10:34 AM Dave Chinner <david@fromorbit.com> wrote:
>
> From: Dave Chinner <dchinner@redhat.com>
>
> The man page says:
>
> EINVAL Requested range extends beyond the end of the source file
>
> But the current behaviour is that copy_file_range does a short
> copy up to the source file EOF. Fix the kernel behaviour to match
> the behaviour described in the man page.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/read_write.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 4dae0399c75a..09d1816cf3cf 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1581,6 +1581,10 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>         if (len == 0)
>                 return 0;
>
> +       /* If the source range crosses EOF, fail the copy */
> +       if (pos_in >= i_size(inode_in) || pos_in + len > i_size(inode_in))
> +               return -EINVAL;
> +

i_size_read()...

Otherwise
Reviewed-by: Amir Goldstein <amir73il@gmail.com>

Thanks,
Amir.


> --
> 2.19.1
>
