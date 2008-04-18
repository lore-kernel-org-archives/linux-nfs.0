From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] fix statd -n
Date: Fri, 18 Apr 2008 13:36:46 -0400
Message-ID: <20080418173646.GC19038@fieldses.org>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40235 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758597AbYDRRgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2008 13:36:47 -0400
In-Reply-To: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 17, 2008 at 12:38:43PM -0400, Janne Karhunen wrote:
> Apparently lockd does not expect statd to be used with -n
> switch: statd is expected to bind loopback, always. Attached
> patches show one (IPv4 specific) way of fixing it. Comments?

Maybe statd really should always bind to the loopback interface?  Is
there any reason not to?

>From a quick look at the current nfs-utils code: it looks like the -n
option only affects the operation of the sm-notify program that's called
on boot to notify peer statd's?  I'm a little confused.  (What version
of nfs-utils are you working from?)

--b.

> 
> 
> -- 
> // Janne

> --- rmtcall.c.org	2008-04-14 10:53:30.000000000 -0400
> +++ rmtcall.c	2008-04-14 13:01:27.000000000 -0400
> @@ -37,6 +37,7 @@
>  #include <netdb.h>
>  #include <string.h>
>  #include <unistd.h>
> +#include <errno.h>
>  #ifdef HAVE_IFADDRS_H
>  #include <ifaddrs.h>
>  #endif /* HAVE_IFADDRS_H */
> @@ -54,6 +55,34 @@
>  
>  static unsigned long	xid = 0;	/* RPC XID counter */
>  static int		sockfd = -1;	/* notify socket */
> +static int              ifset = 0;
> +
> +/*
> + * Notify lockd of non-standard binding 
> + */
> +inline void
> +nlm_nsm_set(unsigned int addr)
> +{
> +        ssize_t sz = 0;
> +        char buf[20];
> +        int fd;
> +
> +        if ( ifset )
> +                return ;
> +
> +        sprintf (buf,"%u",addr);
> +
> +        fd = open ("/proc/sys/fs/nfs/nlm_nsm_interface", O_RDWR);
> +        if (fd > 0) {
> +                sz = write (fd,buf,strlen((char*)buf));
> +                if ( sz == -1 )
> +                        note(N_CRIT, "statd: write: %s\n", strerror(errno));
> +                close (fd);
> +        } else
> +                note(N_CRIT, "statd: -n was specified with with no kernel support?\n");
> +
> +        ifset = 1;
> +}
>  
>  /*
>   * Initialize callback socket
> @@ -85,6 +114,7 @@ statd_get_socket(int port)
>  		struct hostent *hp = gethostbyname(MY_NAME);
>  		if (hp)
>  			sin.sin_addr = *(struct in_addr *) hp->h_addr;
> +		nlm_nsm_set ((unsigned int)sin.sin_addr.s_addr);
>  	}
>  	if (port != 0) {
>  		sin.sin_port = htons(port);

> diff -Naurp lockd.org/svc4proc.c lockd/svc4proc.c
> --- lockd.org/svc4proc.c	2008-04-14 10:58:29.000000000 -0400
> +++ lockd/svc4proc.c	2008-04-14 12:19:04.000000000 -0400
> @@ -21,6 +21,8 @@
>  
>  #define NLMDBG_FACILITY		NLMDBG_CLIENT
>  
> +extern unsigned int nlm_nsm_interface;
> +
>  /*
>   * Obtain client and file from arguments
>   */
> @@ -430,8 +432,9 @@ nlm4svc_proc_sm_notify(struct svc_rqst *
>  	memcpy(&saddr, svc_addr_in(rqstp), sizeof(saddr));
>  
>  	dprintk("lockd: SM_NOTIFY     called\n");
> -	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
> -	 || ntohs(saddr.sin_port) >= 1024) {
> +	if (((saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK))
> +	 && (nlm_nsm_interface && (saddr.sin_addr.s_addr != htonl(nlm_nsm_interface))))
> +	 || (ntohs(saddr.sin_port) >= 1024)) {
>  		char buf[RPC_MAX_ADDRBUFLEN];
>  		printk(KERN_WARNING "lockd: rejected NSM callback from %s\n",
>  				svc_print_addr(rqstp, buf, sizeof(buf)));
> diff -Naurp lockd.org/svc.c lockd/svc.c
> --- lockd.org/svc.c	2008-04-14 10:58:29.000000000 -0400
> +++ lockd/svc.c	2008-04-14 12:19:04.000000000 -0400
> @@ -64,6 +64,7 @@ static unsigned long		nlm_grace_period;
>  static unsigned long		nlm_timeout = LOCKD_DFLT_TIMEO;
>  static int			nlm_udpport, nlm_tcpport;
>  int				nsm_use_hostnames = 0;
> +unsigned int			nlm_nsm_interface = 0;
>  
>  /*
>   * Constants needed for the sysctl interface.
> @@ -425,6 +426,14 @@ static ctl_table nlm_sysctls[] = {
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec,
>  	},
> +        {
> +                .ctl_name       = CTL_UNNUMBERED,
> +                .procname       = "nlm_nsm_interface",
> +                .data           = &nlm_nsm_interface,
> +                .maxlen         = sizeof(int),
> +                .mode           = 0644,
> +                .proc_handler   = &proc_dointvec,
> +        },
>  	{ .ctl_name = 0 }
>  };
>  
> diff -Naurp lockd.org/svcproc.c lockd/svcproc.c
> --- lockd.org/svcproc.c	2008-04-14 10:58:29.000000000 -0400
> +++ lockd/svcproc.c	2008-04-14 12:19:04.000000000 -0400
> @@ -21,6 +21,8 @@
>  
>  #define NLMDBG_FACILITY		NLMDBG_CLIENT
>  
> +extern unsigned int nlm_nsm_interface;
> +
>  #ifdef CONFIG_LOCKD_V4
>  static __be32
>  cast_to_nlm(__be32 status, u32 vers)
> @@ -462,8 +464,9 @@ nlmsvc_proc_sm_notify(struct svc_rqst *r
>  	memcpy(&saddr, svc_addr_in(rqstp), sizeof(saddr));
>  
>  	dprintk("lockd: SM_NOTIFY     called\n");
> -	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
> -	 || ntohs(saddr.sin_port) >= 1024) {
> +	if (((saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK))
> +	 && (nlm_nsm_interface && (saddr.sin_addr.s_addr != htonl(nlm_nsm_interface))))
> +	 || (ntohs(saddr.sin_port) >= 1024)) {
>  		char buf[RPC_MAX_ADDRBUFLEN];
>  		printk(KERN_WARNING "lockd: rejected NSM callback from %s\n",
>  				svc_print_addr(rqstp, buf, sizeof(buf)));

