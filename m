Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AFF9C04EBF
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 10:47:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F35AB20850
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 10:47:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UkheMb3b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F35AB20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726115AbeLCKsX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 05:48:23 -0500
Received: from mail-yb1-f194.google.com ([209.85.219.194]:33033 "EHLO
        mail-yb1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725907AbeLCKsX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 05:48:23 -0500
Received: by mail-yb1-f194.google.com with SMTP id f125so335143ybc.0;
        Mon, 03 Dec 2018 02:47:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7bcB3r6I62FZ5AnIBxpBym3H8xID8B6CGGqT9NYFMMg=;
        b=UkheMb3bz5HtMEYb17tynaaJADu6PR5e3sFsfGDDX0tv/vlaoVEJ1fJi9Tcxw01e7c
         ijFs/whiiyC+8OSJWlr/eLKPk7VxNVuKWoMKnSP3VrkRDT07rWEifJyNrhad0ofszT4r
         ha8ruGnsb74+QY+ur5q8bfdwKDZrpTt/5kjAcYurgx+NfOpjC8uFPNJheOehqe97R8av
         9pIjuDVTde2695R+PVCy4huB8nacVUHdXDujDTqMx1eS1aVt/FZzMhvCbRivLV4ir33t
         y1vqKW3UuqzDNcBZBSlc/+pAQ/E5E9Q6yMJAd5mtGeHGQZy/koWS3/kCaIaN95baOpTK
         0apA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=7bcB3r6I62FZ5AnIBxpBym3H8xID8B6CGGqT9NYFMMg=;
        b=dTNH1PbBKbER5f/MoKvvQJ5AzBKmkr6opA+8eSn9+qVFyYQN6ddWwhXk8v1mB2W9Wq
         NZvJrcqk7FPdx7ZKR9uibMRrfA7Ga2RojP4GXcSzvLbdg1txwuiQjZLrioRyPUjBPh1C
         1S71pkgdWB2KGXD2wh8DDp7tOJjUTUr+icK2dDtczD+DQTV6cvfrQErfdCNIB8FsezU4
         EXWHlMdr/5xRbR84O33Umq4ukHE7O+cCGyB1F9PhXsBSPbCtREAvNEYazu/pWBNk0AMl
         UsrqJUOnlljOn5Ep6YY9JYumpbza5tDFWMI1IMzkCnHH75Y9ubJQTS71H2WE5FBPQPH8
         ctFw==
X-Gm-Message-State: AA+aEWYOcR8TncP+dRi+p/uYdcv14dlTjjR7R9xnSPGQA0zb8ZH/nY11
        qIwmKaUdEWeQCRcOLm0yYkWgJGsWDvy46v2vVnmQsTVn
X-Google-Smtp-Source: AFSGD/Xpw8L7hVEa6Kymc0bVf7U/Ie4+R0oB22xCofxojIWYobATqEMKbShmjjjPxk7ty1NpSohiVd09aPbDI2CXxMY=
X-Received: by 2002:a25:e4c1:: with SMTP id b184-v6mr14741231ybh.337.1543834071245;
 Mon, 03 Dec 2018 02:47:51 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-8-david@fromorbit.com>
In-Reply-To: <20181203083416.28978-8-david@fromorbit.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 3 Dec 2018 12:47:39 +0200
Message-ID: <CAOQ4uxiCi9qJ15J=L6fNjuLGykQm5CDuJ-=Y=TwTP5c=jx-_fA@mail.gmail.com>
Subject: Re: [PATCH 07/11] vfs: copy_file_range should update file timestamps
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
> Timestamps are not updated right now, so programs looking for
> timestamp updates for file modifications (like rsync) will not
> detect that files have changed. We are also accessing the source
> data when doing a copy (but not when cloning) so we need to update
> atime on the source file as well.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/read_write.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 3b101183ea19..3288db1d5f21 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1576,6 +1576,16 @@ static ssize_t do_copy_file_range(struct file *file_in, loff_t pos_in,
>  {
>         ssize_t ret;
>
> +       /* Update source timestamps, because we are accessing file data */
> +       file_accessed(file_in);
> +
> +       /* Update destination timestamps, since we can alter file contents. */
> +       if (!(file_out->f_mode & FMODE_NOCMTIME)) {
> +               ret = file_update_time(file_out);
> +               if (ret)
> +                       return ret;
> +       }
> +

If there is a consistency about who is responsible of calling file_accessed()
and file_update_time() it eludes me. grep tells me that they are mostly
handled by filesystem code or generic helpers called by filesystem code
and not in the vfs helpers.

FMODE_NOCMTIME seems like an xfs specific flag (for DMAPI?), which
most generic callers of file_update_time() completely ignore.
This seems like another argument in favor of leaving the responsibility
of the timestamp updates to the filesystem.

Maybe I am missing something?

Thanks,
Amir.
