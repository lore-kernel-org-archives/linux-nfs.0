From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 02/13] SUNRPC: allow creating an RPC
	service	without registering with portmapper
Date: Mon, 13 Nov 2006 16:32:08 -0500
Message-ID: <1163453528.5699.9.camel@lade.trondhjem.org>
References: <20061113125640.4435.11957.stgit@localhost.localdomain>
	<20061113125757.4435.27983.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjjPn-0004fi-LT
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 13:32:27 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/leiGcAZY8PqpFSSFUINFxOM6/sZ2nxhs=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GjjPm-0007BW-Bb
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 13:32:29 -0800
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20061113125757.4435.27983.stgit@localhost.localdomain>
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

On Mon, 2006-11-13 at 07:57 -0500, Chuck Lever wrote:
> Sometimes we need to create an RPC service but not register it with the
> local portmapper.  NFSv4 delegation callback, for example.
> 
> Change the svc_makesock() API to allow optionally creating temporary or
> permanent sockets, optionally registering with the local portmapper, and
> make it return the ephemeral port of the new socket.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
> ---
> 
>  fs/lockd/svc.c                 |   26 ++++++++++++++++----------
>  fs/nfs/callback.c              |   20 +++++++++-----------
>  fs/nfsd/nfssvc.c               |    6 ++++--
>  include/linux/sunrpc/svcsock.h |    2 +-
>  net/sunrpc/svcsock.c           |    6 ++++--
>  5 files changed, 34 insertions(+), 26 deletions(-)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index 8ca1808..2c3d5ac 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -223,23 +223,29 @@ static int find_socket(struct svc_serv *
>  	return found;
>  }
>  
> +/*
> + * Make any sockets that are needed but not present.
> + * If nlm_udpport or nlm_tcpport were set as module
> + * options, make those sockets unconditionally
> + */
>  static int make_socks(struct svc_serv *serv, int proto)
>  {
> -	/* Make any sockets that are needed but not present.
> -	 * If nlm_udpport or nlm_tcpport were set as module
> -	 * options, make those sockets unconditionally
> -	 */
> -	static int		warned;
> +	static int warned;
>  	int err = 0;
> +
>  	if (proto == IPPROTO_UDP || nlm_udpport)
>  		if (!find_socket(serv, IPPROTO_UDP))
> -			err = svc_makesock(serv, IPPROTO_UDP, nlm_udpport);
> -	if (err == 0 && (proto == IPPROTO_TCP || nlm_tcpport))
> +			err = svc_makesock(serv, IPPROTO_UDP, nlm_udpport,
> +						SVC_SOCK_DEFAULTS);
> +	if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport))
>  		if (!find_socket(serv, IPPROTO_TCP))
> -			err= svc_makesock(serv, IPPROTO_TCP, nlm_tcpport);
> -	if (!err)
> +			err = svc_makesock(serv, IPPROTO_TCP, nlm_tcpport,
> +						SVC_SOCK_DEFAULTS);
> +
> +	if (err >= 0) {
>  		warned = 0;
> -	else if (warned++ == 0)
> +		err = 0;
> +	} else if (warned++ == 0)
>  		printk(KERN_WARNING
>  		       "lockd_up: makesock failed, error=%d\n", err);
>  	return err;
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 7933e2e..e393532 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -106,7 +106,6 @@ static void nfs_callback_svc(struct svc_
>  int nfs_callback_up(void)
>  {
>  	struct svc_serv *serv;
> -	struct svc_sock *svsk;
>  	int ret = 0;
>  
>  	lock_kernel();
> @@ -119,17 +118,14 @@ int nfs_callback_up(void)
>  	ret = -ENOMEM;
>  	if (!serv)
>  		goto out_err;
> -	/* FIXME: We don't want to register this socket with the portmapper */
> -	ret = svc_makesock(serv, IPPROTO_TCP, nfs_callback_set_tcpport);
> -	if (ret < 0)
> +
> +	ret = svc_makesock(serv, IPPROTO_TCP, nfs_callback_set_tcpport,
> +				(SVC_SOCK_ANONYMOUS | SVC_SOCK_TEMPORARY));

Why are you requesting that this socket to be put on the sv_tempsocks
list? That has got to be wrong.

Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
