Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36684 "EHLO
	mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166AbcGHKpg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 06:45:36 -0400
Received: by mail-qt0-f193.google.com with SMTP id w59so4637738qtd.3
        for <linux-nfs@vger.kernel.org>; Fri, 08 Jul 2016 03:45:33 -0700 (PDT)
Message-ID: <1467974731.24149.7.camel@poochiereds.net>
Subject: Re: [PATCH] nfsd: Correct a comment for NFSD_MAY_ defines location
From: Jeff Layton <jlayton@poochiereds.net>
To: Oleg Drokin <green@linuxhacker.ru>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Fri, 08 Jul 2016 06:45:31 -0400
In-Reply-To: <1467942578-3081513-1-git-send-email-green@linuxhacker.ru>
References: <1467942578-3081513-1-git-send-email-green@linuxhacker.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-07-07 at 21:49 -0400, Oleg Drokin wrote:
> Those are now defined in fs/nfsd/vfs.h
> 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  fs/nfsd/nfsfh.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> index a891944..7e49dcb 100644
> --- a/fs/nfsd/nfsfh.c
> +++ b/fs/nfsd/nfsfh.c
> @@ -298,7 +298,7 @@ out:
>   * that it expects something not of the given type.
>   *
>   * @access is formed from the NFSD_MAY_* constants defined in
> - * include/linux/nfsd/nfsd.h.
> + * fs/nfsd/vfs.h.
>   */
>  __be32
>  fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
> int access)

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
