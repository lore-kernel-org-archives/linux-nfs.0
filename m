Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54863 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965397AbbKDVvU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2015 16:51:20 -0500
Subject: Re: [PATCH] Close etab file's file descriptor on stat error.
To: Malahal Naineni <malahal@us.ibm.com>, linux-nfs@vger.kernel.org
References: <1445990490-1941-1-git-send-email-malahal@us.ibm.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <563A7DD6.7050708@RedHat.com>
Date: Wed, 4 Nov 2015 16:51:18 -0500
MIME-Version: 1.0
In-Reply-To: <1445990490-1941-1-git-send-email-malahal@us.ibm.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/27/2015 08:01 PM, Malahal Naineni wrote:
> Also, fixed erroneously closing file descriptor 0 at init time.
> 
> Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
Committed... 

steved.

> ---
>  utils/mountd/auth.c | 17 ++++++++++++++---
>  1 file changed, 14 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
> index 330cab5..894a7a5 100644
> --- a/utils/mountd/auth.c
> +++ b/utils/mountd/auth.c
> @@ -85,7 +85,7 @@ auth_reload()
>  {
>  	struct stat		stb;
>  	static ino_t		last_inode;
> -	static int		last_fd;
> +	static int		last_fd = -1;
>  	static unsigned int	counter;
>  	int			fd;
>  
> @@ -93,11 +93,22 @@ auth_reload()
>  		xlog(L_FATAL, "couldn't open %s", _PATH_ETAB);
>  	} else if (fstat(fd, &stb) < 0) {
>  		xlog(L_FATAL, "couldn't stat %s", _PATH_ETAB);
> -	} else if (stb.st_ino == last_inode) {
> +		close(fd);
> +	} else if (last_fd != -1 && stb.st_ino == last_inode) {
> +		/* We opened the etab file before, and its inode
> +		 * number hasn't changed since then.
> +		 */
>  		close(fd);
>  		return counter;
>  	} else {
> -		close(last_fd);
> +		/* Need to process entries from the etab file.  Close
> +		 * the file descriptor from the previous open (last_fd),
> +		 * and keep the current file descriptor open to prevent
> +		 * the file system reusing the current inode number
> +		 * (last_inode).
> +		 */
> +		if (last_fd != -1)
> +			close(last_fd);
>  		last_fd = fd;
>  		last_inode = stb.st_ino;
>  	}
> 
