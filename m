Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33978 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507Ab2DIWne (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 18:43:34 -0400
Date: Mon, 9 Apr 2012 18:43:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: trivial: remove unused variable from nfsd4_lock
Message-ID: <20120409224333.GE10508@fieldses.org>
References: <1333115181-16659-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1333115181-16659-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 30, 2012 at 09:46:21AM -0400, Jeff Layton wrote:
> ..."fp" is set but never used.

Thanks, applying for 3.5.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4state.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 1841f8b..a822e31 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4055,7 +4055,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	struct nfs4_openowner *open_sop = NULL;
>  	struct nfs4_lockowner *lock_sop = NULL;
>  	struct nfs4_ol_stateid *lock_stp;
> -	struct nfs4_file *fp;
>  	struct file *filp = NULL;
>  	struct file_lock file_lock;
>  	struct file_lock conflock;
> @@ -4123,7 +4122,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  			goto out;
>  	}
>  	lock_sop = lockowner(lock_stp->st_stateowner);
> -	fp = lock_stp->st_file;
>  
>  	lkflg = setlkflg(lock->lk_type);
>  	status = nfs4_check_openmode(lock_stp, lkflg);
> -- 
> 1.7.7.6
> 
