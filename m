Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34020 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388988AbeHARRv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Aug 2018 13:17:51 -0400
Date: Wed, 1 Aug 2018 11:31:36 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>,
        Eric Biggers <ebiggers@google.com>
Subject: Re: [PATCH] nfsd: constify write_op[]
Message-ID: <20180801153136.GC18338@fieldses.org>
References: <20180717180125.142261-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180717180125.142261-1-ebiggers3@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 17, 2018 at 11:01:25AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> write_op[] is never modified, so make it 'const'.

Thanks, applying for 2.19.--b.

> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/nfsd/nfsctl.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 2c46451c7d60..19aa4ded2590 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -73,7 +73,7 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
>  static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size);
>  #endif
>  
> -static ssize_t (*write_op[])(struct file *, char *, size_t) = {
> +static ssize_t (*const write_op[])(struct file *, char *, size_t) = {
>  	[NFSD_Fh] = write_filehandle,
>  	[NFSD_FO_UnlockIP] = write_unlock_ip,
>  	[NFSD_FO_UnlockFS] = write_unlock_fs,
> -- 
> 2.18.0.203.gfac676dfb9-goog
