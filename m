From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/3] nfsd: don't take nfsd_mutex twice when setting
 number of threads.
Date: Thu, 11 Jun 2009 13:52:55 -0400
Message-ID: <20090611135255.0fa2f728@barsoom.rdu.redhat.com>
References: <20090528062730.15937.70579.stgit@notabene.brown>
	<20090528063303.15937.55202.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39419 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752927AbZFKRw5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Jun 2009 13:52:57 -0400
In-Reply-To: <20090528063303.15937.55202.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 28 May 2009 16:33:03 +1000
NeilBrown <neilb@suse.de> wrote:

> Currently when we right a number to 'threads' in nfsdfs,
> we take the nfsd_mutex, update the number of threads, then take the
> mutex again to read the number of threads.
> 
> Mostly this isn't a big deal.  However if we are write '0', and
> portmap happens to be dead, then we can get unpredictable behaviour.
> If the nfsd threads all got killed quickly and the last thread is
> waiting for portmap to respond, then the second time we take the mutex
> we will block waiting for the last thread.
> However if the nfsd threads didn't die quite that fast, then there
> will be no contention when we try to take the mutex again.
> 
> Unpredictability isn't fun, and waiting for the last thread to exit is
> pointless, so avoid taking the lock twice.
> To achieve this, get nfsd_svc return a non-negative number of active
> threads when not returning a negative error.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
> 
>  fs/nfsd/nfsctl.c |   13 +++++++++----
>  fs/nfsd/nfssvc.c |    2 ++
>  2 files changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index af16849..1ddd4f9 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -207,10 +207,14 @@ static struct file_operations pool_stats_operations = {
>  static ssize_t write_svc(struct file *file, char *buf, size_t size)
>  {
>  	struct nfsctl_svc *data;
> +	int err;
>  	if (size < sizeof(*data))
>  		return -EINVAL;
>  	data = (struct nfsctl_svc*) buf;
> -	return nfsd_svc(data->svc_port, data->svc_nthreads);
> +	err = nfsd_svc(data->svc_port, data->svc_nthreads);
> +	if (err < 0)
> +		return err;
> +	return 0;
>  }
>  
>  /**
> @@ -692,10 +696,11 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
>  		if (newthreads < 0)
>  			return -EINVAL;
>  		rv = nfsd_svc(NFS_PORT, newthreads);
> -		if (rv)
> +		if (rv < 0)
>  			return rv;
> -	}
> -	sprintf(buf, "%d\n", nfsd_nrthreads());
> +	} else
> +		rv = nfsd_nrthreads();
> +	sprintf(buf, "%d\n", rv);
>  	return strlen(buf);
>  }
>  
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index cbba4a9..df6c59e 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -413,6 +413,8 @@ nfsd_svc(unsigned short port, int nrservs)
>  		goto failure;
>  
>  	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
> +	if (error == 0)
> +		error = nfsd_serv->sv_nrthreads - 1;
						^^^^
Why -1 here? I thought you wanted nfsd_svc to return the number of
threads?

Also, looks like Bruce's tree has changed a bit recently and I don't
think this patch will apply cleanly now. You may need to respin...

>   failure:
>  	svc_destroy(nfsd_serv);		/* Release server */
>   out:
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Jeff Layton <jlayton@redhat.com>
