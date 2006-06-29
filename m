From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] CONFIG_NFSD_TCP actually impacts clients
Date: Thu, 29 Jun 2006 19:11:01 -0400
Message-ID: <1151622661.6405.9.camel@lade.trondhjem.org>
References: <200606291522.46235.cablnx@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fw5fE-0005Cn-7H
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 16:11:12 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fw5fC-00084a-Rd
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 16:11:12 -0700
To: Chris Abbey <cablnx@us.ibm.com>
In-Reply-To: <200606291522.46235.cablnx@us.ibm.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2006-06-29 at 15:22 -0500, Chris Abbey wrote:
> CONFIG_NFSD_TCP's name, description and dependency information imply
> that it only impacts nfs servers. However in fs/lockd/svc.c this config option
> gaurds binding lockd to tcp as well as udp. (If CONFIG_NFSD_TCP is not set, 
> then lockd will not bind to tcp.) If a kernel is configured as NFS client 
> only, such as for an embeddeed system, then this will cause locking to fail
> on nfs mounts using TCP instead of UDP. Callers to F_SETLK will fail with
> errno = 37 when trying to lock: "No locks available".
> 
> This patch changes the name, description, help text and dependency for
> CONFIG_NFSD_TCP to accurately reflect it's usage. The main change is really 
> the removal of 'depends on NFSD', the rest is just cleanup.

Good point, but it seems to me that it would make sense to have
CONFIG_NFS_FS automatically select it.

Cheers,
  Trond

> IBM LTC Bugzilla #24739
> 
> Signed-off-by: Chris Abbey <cablnx@us.ibm.com>
> 
> ---
> 
>  Kconfig       |   10 +++++-----
>  lockd/svc.c   |    2 +-
>  nfsd/nfssvc.c |    2 +-
>  3 files changed, 7 insertions(+), 7 deletions(-)
> diff -purN linux-2.6.16.20-virgin/fs/Kconfig linux-2.6.16.20/fs/Kconfig
> --- linux-2.6.16.20-virgin/fs/Kconfig	2006-06-05 12:18:23.000000000 -0500
> +++ linux-2.6.16.20/fs/Kconfig	2006-06-16 19:09:15.000000000 -0500
> @@ -1484,7 +1484,7 @@ config NFSD_V3_ACL
>  config NFSD_V4
>  	bool "Provide NFSv4 server support (EXPERIMENTAL)"
>  	depends on NFSD_V3 && EXPERIMENTAL
> -	select NFSD_TCP
> +	select NFS_TCP
>  	select CRYPTO_MD5
>  	select CRYPTO
>  	select FS_POSIX_ACL
> @@ -1494,12 +1494,12 @@ config NFSD_V4
>  	  should only be used if you are interested in helping to test NFSv4.
>  	  If unsure, say N.
>  
> -config NFSD_TCP
> -	bool "Provide NFS server over TCP support"
> -	depends on NFSD
> +config NFS_TCP
> +	bool "Provide NFS services over TCP"
>  	default y
>  	help
> -	  If you want your NFS server to support TCP connections, say Y here.
> +	  If you want your NFS server to support TCP connections, or your NFS
> +	  clients to be able to lock over a TCP connection, then say Y here.
>  	  TCP connections usually perform better than the default UDP when
>  	  the network is lossy or congested.  If unsure, say Y.
>  
> diff -purN linux-2.6.16.20-virgin/fs/lockd/svc.c 
> linux-2.6.16.20/fs/lockd/svc.c
> --- linux-2.6.16.20-virgin/fs/lockd/svc.c	2006-06-05 12:18:23.000000000 -0500
> +++ linux-2.6.16.20/fs/lockd/svc.c	2006-06-16 19:08:40.000000000 -0500
> @@ -243,7 +243,7 @@ lockd_up(void)
>  	}
>  
>  	if ((error = svc_makesock(serv, IPPROTO_UDP, nlm_udpport)) < 0 
> -#ifdef CONFIG_NFSD_TCP
> +#ifdef CONFIG_NFS_TCP
>  	 || (error = svc_makesock(serv, IPPROTO_TCP, nlm_tcpport)) < 0
>  #endif
>  		) {
> diff -purN linux-2.6.16.20-virgin/fs/nfsd/nfssvc.c 
> linux-2.6.16.20/fs/nfsd/nfssvc.c
> --- linux-2.6.16.20-virgin/fs/nfsd/nfssvc.c	2006-06-05 12:18:23.000000000 
> -0500
> +++ linux-2.6.16.20/fs/nfsd/nfssvc.c	2006-06-16 19:08:40.000000000 -0500
> @@ -205,7 +205,7 @@ nfsd_svc(unsigned short port, int nrserv
>  		if (error < 0)
>  			goto failure;
>  
> -#ifdef CONFIG_NFSD_TCP
> +#ifdef CONFIG_NFS_TCP
>  		error = svc_makesock(nfsd_serv, IPPROTO_TCP, port);
>  		if (error < 0)
>  			goto failure;
> 


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
