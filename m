From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 5/5] NFSD: Create PF_INET6 listener in write_ports
Date: Tue, 26 Jan 2010 18:30:19 -0500
Message-ID: <20100126233019.GB806@fieldses.org>
References: <20100126190214.3368.89388.stgit@localhost.localdomain> <20100126190422.3368.3981.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56931 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753668Ab0AZX2q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Jan 2010 18:28:46 -0500
In-Reply-To: <20100126190422.3368.3981.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 26, 2010 at 02:04:22PM -0500, Chuck Lever wrote:
> Try to create a PF_INET6 listener for NFSD, if IPv6 is enabled in the
> kernel.
> 
> Make sure nfsd_serv's reference count is decreased if
> __write_ports_addxprt() failed to create a listener.  See
> __write_ports_addfd().
> 
> Our current plan is to rely on rpc.nfsd to create appropriate IPv6
> listeners when server-side NFS/IPv6 support is desired.  Legacy
> behavior, via the write_threads or write_svc kernel APIs, will remain
> the same -- only IPv4 listeners are created.

Looks fine, thanks, but:
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfsd/nfsctl.c |   20 +++++++++++++++++++-
>  1 files changed, 19 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index f43ecd6..f0a614e 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1003,8 +1003,26 @@ static ssize_t __write_ports_addxprt(char *buf)
>  	err = svc_create_xprt(nfsd_serv, transport,
>  				PF_INET, port, SVC_SOCK_ANONYMOUS);
>  	if (err < 0)
> -		return err;
> +		goto out_err;
> +
> +	err = svc_create_xprt(nfsd_serv, transport,
> +				PF_INET6, port, SVC_SOCK_ANONYMOUS);
> +	if (err < 0 && err != -EAFNOSUPPORT) {
> +		struct svc_xprt *xprt;
> +		xprt = svc_find_xprt(nfsd_serv, transport, PF_INET, port);
> +		if (xprt != NULL) {
> +			svc_close_xprt(xprt);
> +			svc_xprt_put(xprt);
> +		}
> +		goto out_err;
> +	}
> +
>  	return 0;
> +
> +out_err:
> +	/* Decrease the count, but don't shut down the service */
> +	nfsd_serv->sv_nrthreads--;
> +	return err;
>  }

Any objection to moving the extra error-handling to the end, as in the
following?  If there's no objection, I'll fold it into your last patch.

--b.

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f0a614e..f4474e5 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -988,6 +988,7 @@ static ssize_t __write_ports_delfd(char *buf)
 static ssize_t __write_ports_addxprt(char *buf)
 {
 	char transport[16];
+	struct svc_xprt *xprt;
 	int port, err;
 
 	if (sscanf(buf, "%15s %4u", transport, &port) != 2)
@@ -1007,18 +1008,15 @@ static ssize_t __write_ports_addxprt(char *buf)
 
 	err = svc_create_xprt(nfsd_serv, transport,
 				PF_INET6, port, SVC_SOCK_ANONYMOUS);
-	if (err < 0 && err != -EAFNOSUPPORT) {
-		struct svc_xprt *xprt;
-		xprt = svc_find_xprt(nfsd_serv, transport, PF_INET, port);
-		if (xprt != NULL) {
-			svc_close_xprt(xprt);
-			svc_xprt_put(xprt);
-		}
-		goto out_err;
-	}
-
+	if (err < 0 && err != -EAFNOSUPPORT)
+		goto out_err_cleanup_inet;
 	return 0;
-
+out_err_cleanup_inet:
+	xprt = svc_find_xprt(nfsd_serv, transport, PF_INET, port);
+	if (xprt != NULL) {
+		svc_close_xprt(xprt);
+		svc_xprt_put(xprt);
+	}
 out_err:
 	/* Decrease the count, but don't shut down the service */
 	nfsd_serv->sv_nrthreads--;
