Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36433 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751532AbbAGVVi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2015 16:21:38 -0500
Date: Wed, 7 Jan 2015 16:21:35 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Lutz Vieweg <lvml@5t9.de>, linux-nfs@vger.kernel.org
Subject: Re: xprt_adjust_timeout followed by lockd: server not responding /
 server OK
Message-ID: <20150107212135.GC8119@fieldses.org>
References: <1416877610.325.37.camel@abezella-laptop.us.archive.org>
 <m86lsu$4l9$1@ger.gmane.org>
 <1420230301.10991.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420230301.10991.1.camel@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 02, 2015 at 03:25:01PM -0500, Trond Myklebust wrote:
> On Fri, 2015-01-02 at 18:52 +0100, Lutz Vieweg wrote:
> > On 11/25/2014 02:06 AM, andrew bezella wrote:
> > > [ 3809.070778] xprt_adjust_timeout: rq_timeout = 0!
> > > [ 3809.070784] lockd: server nfs-home not responding, still trying
> > > [ 3809.332988] lockd: server nfs-home OK
> > 
> > I'm seeing the very same annoying symptom every few minutes on a
> > CentOS 7 client with kernel 3.17.1 (server also running CentOS 7
> > with the same kernel).
> > 
> > Both servers are connected to the same 10GBit/s switch and don't
> > currently have much load...
> 
> Does the following patch help?

By the way, looks fine to me.  Can you take it?

--b.

> 
> Cheers
>   Trond
> 
> 8<-------------------------------------------------------------
> >From aff134222d6b17cdedad319f131f8e6e533e1256 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Fri, 2 Jan 2015 15:05:25 -0500
> Subject: [PATCH] LOCKD: Fix a race when initialising nlmsvc_timeout
> 
> This commit fixes a race whereby nlmclnt_init() first starts the lockd
> daemon, and then calls nlm_bind_host() with the expectation that
> nlmsvc_timeout has already been initialised. Unfortunately, there is no
> no synchronisation between lockd() and lockd_up() to guarantee that this
> is the case.
> 
> Fix is to move the initialisation of nlmsvc_timeout into lockd_create_svc
> 
> Fixes: 9a1b6bf818e74 ("LOCKD: Don't call utsname()->nodename...")
> Cc: Bruce Fields <bfields@fieldses.org>
> Cc: stable@vger.kernel.org # 3.10.x
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/lockd/svc.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index e94c887da2d7..55505cbe11af 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -138,10 +138,6 @@ lockd(void *vrqstp)
>  
>  	dprintk("NFS locking service started (ver " LOCKD_VERSION ").\n");
>  
> -	if (!nlm_timeout)
> -		nlm_timeout = LOCKD_DFLT_TIMEO;
> -	nlmsvc_timeout = nlm_timeout * HZ;
> -
>  	/*
>  	 * The main request loop. We don't terminate until the last
>  	 * NFS mount or NFS daemon has gone away.
> @@ -350,6 +346,10 @@ static struct svc_serv *lockd_create_svc(void)
>  		printk(KERN_WARNING
>  			"lockd_up: no pid, %d users??\n", nlmsvc_users);
>  
> +	if (!nlm_timeout)
> +		nlm_timeout = LOCKD_DFLT_TIMEO;
> +	nlmsvc_timeout = nlm_timeout * HZ;
> +
>  	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, svc_rpcb_cleanup);
>  	if (!serv) {
>  		printk(KERN_WARNING "lockd_up: create service failed\n");
> -- 
> 2.1.0
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
