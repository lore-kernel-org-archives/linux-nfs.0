Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33183 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932595Ab3GWQ2O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Jul 2013 12:28:14 -0400
Date: Tue, 23 Jul 2013 12:28:13 -0400
From: "J.Bruce Fields" <bfields@citi.umich.edu>
To: Harshula Jayasuriya <harshula@redhat.com>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Subject: Re: [PATCH] nfsd: nfs4_file_get_access: need to be more careful with
 O_RDWR
Message-ID: <20130723162813.GC12569@fieldses.org>
References: <1374552314.5454.89.camel@serendib>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1374552314.5454.89.camel@serendib>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying for 3.12.--b.

On Tue, Jul 23, 2013 at 02:05:14PM +1000, Harshula Jayasuriya wrote:
> If fi_fds = {non-NULL, NULL, non-NULL} and oflag = O_WRONLY
> the WARN_ON_ONCE(!(fp->fi_fds[oflag] || fp->fi_fds[O_RDWR]))
> doesn't trigger when it should.
> 
> Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
> ---
>  fs/nfsd/nfs4state.c | 13 ++++---------
>  1 file changed, 4 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 280acef..1cb6211 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -282,19 +282,14 @@ static unsigned int file_hashval(struct inode *ino)
>  
>  static struct hlist_head file_hashtbl[FILE_HASH_SIZE];
>  
> -static void __nfs4_file_get_access(struct nfs4_file *fp, int oflag)
> -{
> -	WARN_ON_ONCE(!(fp->fi_fds[oflag] || fp->fi_fds[O_RDWR]));
> -	atomic_inc(&fp->fi_access[oflag]);
> -}
> -
>  static void nfs4_file_get_access(struct nfs4_file *fp, int oflag)
>  {
> +	WARN_ON_ONCE(!fp->fi_fds[oflag]);
>  	if (oflag == O_RDWR) {
> -		__nfs4_file_get_access(fp, O_RDONLY);
> -		__nfs4_file_get_access(fp, O_WRONLY);
> +		atomic_inc(&fp->fi_access[O_RDONLY]);
> +		atomic_inc(&fp->fi_access[O_WRONLY]);
>  	} else
> -		__nfs4_file_get_access(fp, oflag);
> +		atomic_inc(&fp->fi_access[oflag]);
>  }
>  
>  static void nfs4_file_put_fd(struct nfs4_file *fp, int oflag)
> -- 
> 1.8.1.4
> 
