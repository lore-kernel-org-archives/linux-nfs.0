From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 01/29] knfsd: Add infrastructure for measuring RPC
	service times.
Date: Fri, 24 Apr 2009 22:13:15 -0400
Message-ID: <20090425021315.GA24770@fieldses.org>
References: <20090331202800.739621000@sgi.com> <20090331202937.980076000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44427 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbZDYCNS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2009 22:13:18 -0400
In-Reply-To: <20090331202937.980076000@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 01, 2009 at 07:28:01AM +1100, Greg Banks wrote:
> Two new functions; svc_time_mark() remembers the current time
> in a struct svc_time; svc_time_elapsed() calculates and returns
> the time since a svc_time was marked.
> 
> Signed-off-by: Greg Banks <gnb@sgi.com>
> ---
> 
>  include/linux/sunrpc/svc.h |   12 ++++++++++++
>  net/sunrpc/svc.c           |   25 +++++++++++++++++++++++++
>  2 files changed, 37 insertions(+)
> 
> Index: bfields/include/linux/sunrpc/svc.h
> ===================================================================
> --- bfields.orig/include/linux/sunrpc/svc.h
> +++ bfields/include/linux/sunrpc/svc.h
> @@ -18,6 +18,16 @@
>  #include <linux/sunrpc/svcauth.h>
>  #include <linux/wait.h>
>  #include <linux/mm.h>
> +#include <linux/time.h>
> +
> +/*
> + * Structure used to implement a fast lockless elapsed time measure.
> + */
> +struct svc_time
> +{
> +	struct timespec	st_spec;
> +};

Are struct svc_time, ...

> +void
> +svc_time_mark(struct svc_time *st)
> +{
> +	getnstimeofday(&st->st_spec);
> +}
> +EXPORT_SYMBOL(svc_time_mark);

... and this function really necessary?  If you're not too attached to
them: it would seem simpler just to use struct timespec and
getnstimeofday directly.  (Well, at least simpler to read for someone
familiar with the kernel but not with th nfs code.)

--b.

> +
> +int
> +svc_time_elapsed(const struct svc_time *mark, struct timespec *ts)
> +{
> +	struct svc_time now;
> +
> +	svc_time_mark(&now);
> +
> +	if (now.st_spec.tv_sec < mark->st_spec.tv_sec)
> +		return -EINVAL;	/* time going backwards */
> +
> +	*ts = timespec_sub(now.st_spec, mark->st_spec);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(svc_time_elapsed);
> +
> 
> --
> Greg
