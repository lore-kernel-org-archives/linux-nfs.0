Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lb2-smtp-cloud3.xs4all.net ([194.109.24.26]:39667 "EHLO
	lb2-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761AbbDNTTd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2015 15:19:33 -0400
Message-ID: <1429039169.27492.25.camel@x220>
Subject: Re: [PATCH] nfs: Fix unused variable build warning when
 CONFIG_SUNRPC_DEBUG is not set
From: Paul Bolle <pebolle@tiscali.nl>
To: Sergei Zviagintsev <sergei@s15v.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Tue, 14 Apr 2015 21:19:29 +0200
In-Reply-To: <1428962779-3741-1-git-send-email-sergei@s15v.net>
References: <1428962779-3741-1-git-send-email-sergei@s15v.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2015-04-14 at 01:06 +0300, Sergei Zviagintsev wrote:
> Commit f52cbe4c9838 ("nfs: generic_write_checks() shouldn't be done on
> swapout...") caused unused variable build warning in fs/nfs/file.c
> when CONFIG_SUNRPC_DEBUG is not set as pos variable is used only in
> dprintk() call. Fix it.

Would that warning be:
    fs/nfs/file.c: In function ‘nfs_file_write’:
    fs/nfs/file.c:677:9: warning: unused variable ‘pos’ [-Wunused-variable]
      loff_t pos = iocb->ki_pos;
             ^

Please add the warning you fix in the commit explanation. Doing that
might save other people the trouble of doing the work you already did.
Because then basically all they need to do is a web search or a "git log
--grep" for (parts of) that messages. 

> Signed-off-by: Sergei Zviagintsev <sergei@s15v.net>
> Fixes: f52cbe4c9838 ("nfs: generic_write_checks() shouldn't be done on swapout...")
> ---
>  fs/nfs/file.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 031ddcb1061d..c40e4363e746 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -674,7 +674,6 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
>  	unsigned long written = 0;
>  	ssize_t result;
>  	size_t count = iov_iter_count(from);
> -	loff_t pos = iocb->ki_pos;
>  
>  	result = nfs_key_timeout_notify(file, inode);
>  	if (result)
> @@ -688,7 +687,7 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
>  	}
>  
>  	dprintk("NFS: write(%pD2, %zu@%Ld)\n",
> -		file, count, (long long) pos);
> +		file, count, (long long) iocb->ki_pos);
>  
>  	result = -EBUSY;
>  	if (IS_SWAPFILE(inode))

Thanks,


Paul Bolle

