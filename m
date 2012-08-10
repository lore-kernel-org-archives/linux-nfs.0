Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:40431 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756042Ab2HJLFT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Aug 2012 07:05:19 -0400
Received: by ggdk6 with SMTP id k6so1435947ggd.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Aug 2012 04:05:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344535551-4412-2-git-send-email-bjschuma@netapp.com>
References: <1344535551-4412-1-git-send-email-bjschuma@netapp.com> <1344535551-4412-2-git-send-email-bjschuma@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Fri, 10 Aug 2012 13:04:57 +0200
Message-ID: <CAJ75kXaWVOXxRgVBp6FR3DqVr1ZMbhPNzGQ9yNUkjddDa2-g8A@mail.gmail.com>
Subject: Re: [PATCH 2/3] NFS: return -ENOKEY when the upcall fails to map the name
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 9, 2012 at 8:05 PM,  <bjschuma@netapp.com> wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
>
> This allows the normal error-paths to handle the error, rather than
> making a special call to complete_request_key() just for this instance.
>
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfs/idmap.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index c2b4004..9864b48 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -756,9 +756,8 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
>         }
>
>         if (!(im.im_status & IDMAP_STATUS_SUCCESS)) {
> -               ret = mlen;
> -               complete_request_key(cons, -ENOKEY);
> -               goto out_incomplete;
> +               ret = -ENOKEY;
> +               goto out;

and I think this patch could fix the "unable to handle kernel NULL
pointer dereference on wait_for_key_construction" I reported earlier.

-- 
William
