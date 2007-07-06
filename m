From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/3] NLM: fix source address of callback to client
Date: Fri, 6 Jul 2007 09:44:04 -0400
Message-ID: <20070706134404.GC10812@fieldses.org>
References: <20070705152650.GD6603@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6o6O-0006W8-HN
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 06:44:04 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I6o6R-0005V7-Gd
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 06:44:08 -0700
In-Reply-To: <20070705152650.GD6603@janus>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Jul 05, 2007 at 05:26:50PM +0200, Frank van Maarseveen wrote:
> Use the destination address of the original NLM request as the
> source address in callbacks to the client.

What are the impliciations of changing nlm_lookup_host to also match on
server ip address?  (Doesn't that go beyond the minimum changes
necessary just to get the source ip address right on grant callbacks?)

--b.

> 
> Signed-off-by: Frank van Maarseveen <frankvm@frankvm.com>
> ---
> 
> diff -urp a/fs/lockd/host.c b/fs/lockd/host.c
> --- a/fs/lockd/host.c	2007-04-27 18:05:25.000000000 +0200
> +++ b/fs/lockd/host.c	2007-07-05 15:33:11.000000000 +0200
> @@ -44,9 +44,8 @@ static struct nsm_handle *	nsm_find(cons
>   */
>  static struct nlm_host *
>  nlm_lookup_host(int server, const struct sockaddr_in *sin,
> -					int proto, int version,
> -					const char *hostname,
> -					int hostname_len)
> +		int proto, int version, const char *hostname,
> +		int hostname_len, const struct sockaddr_in *ssin)
>  {
>  	struct hlist_head *chain;
>  	struct hlist_node *pos;
> @@ -54,7 +53,9 @@ nlm_lookup_host(int server, const struct
>  	struct nsm_handle *nsm = NULL;
>  	int		hash;
>  
> -	dprintk("lockd: nlm_lookup_host(%u.%u.%u.%u, p=%d, v=%d, my role=%s, name=%.*s)\n",
> +	dprintk("lockd: nlm_lookup_host("NIPQUAD_FMT"->"NIPQUAD_FMT
> +			", p=%d, v=%d, my role=%s, name=%.*s)\n",
> +			NIPQUAD(ssin->sin_addr.s_addr),
>  			NIPQUAD(sin->sin_addr.s_addr), proto, version,
>  			server? "server" : "client",
>  			hostname_len,
> @@ -91,6 +92,8 @@ nlm_lookup_host(int server, const struct
>  			continue;
>  		if (host->h_server != server)
>  			continue;
> +		if (!nlm_cmp_addr(&host->h_saddr, ssin))
> +			continue;
>  
>  		/* Move to head of hash chain. */
>  		hlist_del(&host->h_hash);
> @@ -118,6 +121,7 @@ nlm_lookup_host(int server, const struct
>  	host->h_name	   = nsm->sm_name;
>  	host->h_addr       = *sin;
>  	host->h_addr.sin_port = 0;	/* ouch! */
> +	host->h_saddr	   = *ssin;
>  	host->h_version    = version;
>  	host->h_proto      = proto;
>  	host->h_rpcclnt    = NULL;
> @@ -180,8 +184,10 @@ struct nlm_host *
>  nlmclnt_lookup_host(const struct sockaddr_in *sin, int proto, int version,
>  			const char *hostname, int hostname_len)
>  {
> +	struct sockaddr_in ssin = {0};
> +
>  	return nlm_lookup_host(0, sin, proto, version,
> -			       hostname, hostname_len);
> +			       hostname, hostname_len, &ssin);
>  }
>  
>  /*
> @@ -191,9 +197,12 @@ struct nlm_host *
>  nlmsvc_lookup_host(struct svc_rqst *rqstp,
>  			const char *hostname, int hostname_len)
>  {
> +	struct sockaddr_in ssin = {0};
> +
> +	ssin.sin_addr = rqstp->rq_daddr.addr;
>  	return nlm_lookup_host(1, svc_addr_in(rqstp),
>  			       rqstp->rq_prot, rqstp->rq_vers,
> -			       hostname, hostname_len);
> +			       hostname, hostname_len, &ssin);
>  }
>  
>  /*
> @@ -204,8 +213,9 @@ nlm_bind_host(struct nlm_host *host)
>  {
>  	struct rpc_clnt	*clnt;
>  
> -	dprintk("lockd: nlm_bind_host(%08x)\n",
> -			(unsigned)ntohl(host->h_addr.sin_addr.s_addr));
> +	dprintk("lockd: nlm_bind_host("NIPQUAD_FMT"->"NIPQUAD_FMT")\n",
> +			NIPQUAD(host->h_saddr.sin_addr),
> +			NIPQUAD(host->h_addr.sin_addr));
>  
>  	/* Lock host handle */
>  	mutex_lock(&host->h_mutex);
> @@ -232,6 +242,7 @@ nlm_bind_host(struct nlm_host *host)
>  			.protocol	= host->h_proto,
>  			.address	= (struct sockaddr *)&host->h_addr,
>  			.addrsize	= sizeof(host->h_addr),
> +			.saddress	= (struct sockaddr *)&host->h_saddr,
>  			.timeout	= &timeparms,
>  			.servername	= host->h_name,
>  			.program	= &nlm_program,
> diff -urp a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> --- a/include/linux/lockd/lockd.h	2007-02-27 22:55:34.000000000 +0100
> +++ b/include/linux/lockd/lockd.h	2007-07-05 15:33:11.000000000 +0200
> @@ -39,6 +39,7 @@
>  struct nlm_host {
>  	struct hlist_node	h_hash;		/* doubly linked list */
>  	struct sockaddr_in	h_addr;		/* peer address */
> +	struct sockaddr_in	h_saddr;	/* our address (optional) */
>  	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
>  	char *			h_name;		/* remote hostname */
>  	u32			h_version;	/* interface version */
> 
> -- 
> Frank
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
