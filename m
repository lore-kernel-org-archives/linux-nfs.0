Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46205 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750907Ab3FDUSR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 16:18:17 -0400
Date: Tue, 4 Jun 2013 16:17:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, dhowells@redhat.com,
        sage@inktank.com, smfrench@gmail.com, swhiteho@redhat.com,
        Trond.Myklebust@netapp.com, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        piastryyy@gmail.com
Subject: Re: [PATCH v1 04/11] locks: make "added" in __posix_lock_file a bool
Message-ID: <20130604201743.GA15594@fieldses.org>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
 <1370056054-25449-5-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1370056054-25449-5-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 31, 2013 at 11:07:27PM -0400, Jeff Layton wrote:
> ...save 3 bytes of stack space.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

ACK.--b.

> ---
>  fs/locks.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index a7d2253..cef0e04 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -800,7 +800,8 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
>  	struct file_lock *left = NULL;
>  	struct file_lock *right = NULL;
>  	struct file_lock **before;
> -	int error, added = 0;
> +	int error;
> +	bool added = false;
>  
>  	/*
>  	 * We may need two file_lock structures for this operation,
> @@ -894,7 +895,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
>  				continue;
>  			}
>  			request = fl;
> -			added = 1;
> +			added = true;
>  		}
>  		else {
>  			/* Processing for different lock types is a bit
> @@ -905,7 +906,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
>  			if (fl->fl_start > request->fl_end)
>  				break;
>  			if (request->fl_type == F_UNLCK)
> -				added = 1;
> +				added = true;
>  			if (fl->fl_start < request->fl_start)
>  				left = fl;
>  			/* If the next lock in the list has a higher end
> @@ -935,7 +936,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
>  				locks_release_private(fl);
>  				locks_copy_private(fl, request);
>  				request = fl;
> -				added = 1;
> +				added = true;
>  			}
>  		}
>  		/* Go on to next lock.
> -- 
> 1.7.1
> 
