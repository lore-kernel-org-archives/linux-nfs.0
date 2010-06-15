From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] SQUASHME: DEVONLY: pnfs: Add -pnfs suffix to EXTRAVERSION
Date: Mon, 14 Jun 2010 20:09:38 -0400
Message-ID: <4C16C4C2.8060806@panasas.com>
References: <4C0E0387.8070502@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:40335 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755579Ab0FOAJk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jun 2010 20:09:40 -0400
Received: by vws13 with SMTP id 13so429065vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Jun 2010 17:09:39 -0700 (PDT)
In-Reply-To: <4C0E0387.8070502@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged at pnfs-all-2.6.35-rc3-2010-06-14

Thanks!

Benny

On Jun. 08, 2010, 4:47 -0400, Boaz Harrosh <bharrosh@panasas.com> wrote:
> 
> The official way of adding a tree identifier tag to the Kernel
> version-string is a presence of a localversion-* file next to
> the Makefile. It's content is appended to the Linus supplied
> version-string from Makefile.
> 
> After this patch the output is the same as before xxx-2.6.35-rc2-pnfs
> But is a more comfortable way to manage it.
> 
> (The appended "+" in post 2.6.35-rc Kernels is not resolved with
>  this. But I have sent a patch to Linus to fix this issue)
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  Makefile          |    2 +-
>  localversion-pnfs |    1 +
>  2 files changed, 2 insertions(+), 1 deletions(-)
>  create mode 100644 localversion-pnfs
> 
> diff --git a/Makefile b/Makefile
> index 6ac434c..654c31a 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -1,7 +1,7 @@
>  VERSION = 2
>  PATCHLEVEL = 6
>  SUBLEVEL = 35
> -EXTRAVERSION = -rc2-pnfs
> +EXTRAVERSION = -rc2
>  NAME = Sheep on Meth
>  
>  # *DOCUMENTATION*
> diff --git a/localversion-pnfs b/localversion-pnfs
> new file mode 100644
> index 0000000..7523328
> --- /dev/null
> +++ b/localversion-pnfs
> @@ -0,0 +1 @@
> +-pnfs
