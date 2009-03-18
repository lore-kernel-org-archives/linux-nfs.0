From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 36/40] NFSD: Prevent buffer overflow in write_threads()
Date: Wed, 18 Mar 2009 19:54:58 -0400
Message-ID: <20090318235458.GR18894@fieldses.org>
References: <20090312155609.16019.86499.stgit@ingres.1015granger.net> <20090312161129.16019.26502.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:52176 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553AbZCRXzD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 19:55:03 -0400
In-Reply-To: <20090312161129.16019.26502.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 12, 2009 at 12:11:30PM -0400, Chuck Lever wrote:
> Fix up write_threads() to eliminate the small possibility of
> overflowing its output buffer.

A gripe: could you be more specific about that "small possibility"?

Looks like the answer in this case is that the buffer overflow is
currently impossible, and that this is defensive programming against
someone making SIMPLE_TRANSACTION_LIMIT ridiculously small, or
something.  OK, but that should be stated very clearly in the commit
message.

(A lot of people may read a patch that begins "Prevent buffer overflow".
Let's be kind to them!  (A less alarming subject might also not be a bad
idea.))

Ditto for some of the other patches.

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfsd/nfsctl.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index ce54d72..e8009c8 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -666,9 +666,9 @@ static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
>  static ssize_t write_threads(struct file *file, char *buf, size_t size)
>  {
>  	char *mesg = buf;
> -	int rv;
> +
>  	if (size > 0) {
> -		int newthreads;
> +		int rv, newthreads;
>  		rv = get_int(&mesg, &newthreads);
>  		if (rv)
>  			return rv;
> @@ -678,8 +678,9 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
>  		if (rv)
>  			return rv;
>  	}
> -	sprintf(buf, "%d\n", nfsd_nrthreads());
> -	return strlen(buf);
> +
> +	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n",
> +							nfsd_nrthreads());
>  }
>  
>  /**
> 
