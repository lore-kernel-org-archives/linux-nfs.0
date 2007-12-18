From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/7] SUNRPC: make new svc_create_kthread function
Date: Tue, 18 Dec 2007 17:10:39 +0000
Message-ID: <20071218171039.GA5908@infradead.org>
References: <1197996159-20799-1-git-send-email-jlayton@redhat.com> <1197996159-20799-2-git-send-email-jlayton@redhat.com> <1197996159-20799-3-git-send-email-jlayton@redhat.com> <1197996159-20799-4-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:56584 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758225AbXLRRKm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Dec 2007 12:10:42 -0500
In-Reply-To: <1197996159-20799-4-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> +int
> +svc_create_kthread(svc_thread_fn func, struct svc_rqst *rqstp)
> +{
> +	struct svc_serv *serv = rqstp->rq_server;
> +	struct task_struct *task;
> +
> +	task = kthread_create((int (*)(void *)) func, rqstp, serv->sv_name);
> +	if (IS_ERR(task))
> +		return PTR_ERR(task);
> +
> +	if (serv->sv_nrpools > 1)
> +		svc_pool_map_set_cpumask(task, rqstp->rq_pool->sp_id, NULL);
> +
> +	svc_sock_update_bufs(serv);
> +	wake_up_process(task);
> +	return 0;

I don't think we'll need this helper at all.  For the normal case of
not using a pool the caller can just call svc_sock_update_bufs even
before creating the thread, and the just use kthread_run.  That'll also
get rid of all this horrible casting things around for the thread entry
point function pointer.

