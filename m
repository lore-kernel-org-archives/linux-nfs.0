From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/7] nfsd: convert nfs4_cb_conn struct to hold address in
	sockaddr_storage
Date: Thu, 13 Aug 2009 11:50:14 -0400
Message-ID: <C5F58EA5-B3CD-4048-BF88-34170BBBCC13@oracle.com>
References: <1250078226-10511-1-git-send-email-jlayton@redhat.com>
	<1250078226-10511-4-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1250078226-10511-4-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 12, 2009, at 7:57 AM, Jeff Layton wrote:

> ...rather than as a separate address and port fields. This will be
> necessary for implementing callbacks over IPv6.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfsd/nfs4callback.c     |   11 ++---------
> fs/nfsd/nfs4state.c        |   13 +++++++++----
> include/linux/nfsd/state.h |    4 ++--
> 3 files changed, 13 insertions(+), 15 deletions(-)
>
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 3fd23f7..81d1c52 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -377,7 +377,6 @@ static int max_cb_time(void)
>
> int setup_callback_client(struct nfs4_client *clp)
> {
> -	struct sockaddr_in	addr;
> 	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
> 	struct rpc_timeout	timeparms = {
> 		.to_initval	= max_cb_time(),
> @@ -385,8 +384,8 @@ int setup_callback_client(struct nfs4_client *clp)
> 	};
> 	struct rpc_create_args args = {
> 		.protocol	= IPPROTO_TCP,
> -		.address	= (struct sockaddr *)&addr,
> -		.addrsize	= sizeof(addr),
> +		.address	= (struct sockaddr *) &cb->cb_addr,
> +		.addrsize	= cb->cb_addrlen,
> 		.timeout	= &timeparms,
> 		.program	= &cb_program,
> 		.prognumber	= cb->cb_prog,
> @@ -400,12 +399,6 @@ int setup_callback_client(struct nfs4_client  
> *clp)
> 	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5))
> 		return -EINVAL;
>
> -	/* Initialize address */
> -	memset(&addr, 0, sizeof(addr));
> -	addr.sin_family = AF_INET;
> -	addr.sin_port = htons(cb->cb_port);
> -	addr.sin_addr.s_addr = htonl(cb->cb_addr);
> -
> 	/* Create RPC client */
> 	client = rpc_create(&args);
> 	if (IS_ERR(client)) {
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 9295c4b..95e2185 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -931,7 +931,7 @@ parse_octet(unsigned int *lenp, char **addrp)
>
> /* parse and set the setclientid ipv4 callback address */
> static int
> -parse_ipv4(unsigned int addr_len, char *addr_val, unsigned int  
> *cbaddrp, unsigned short *cbportp)
> +parse_ipv4(unsigned int addr_len, char *addr_val, struct  
> sockaddr_in *s4)

I'm a little uncomfortable with dinking around with a function that is  
about to be replaced anyway.  Would it be cleaner to handle the  
upgrades to sockaddr_storage and replacing this code with rpc_pton()  
in a single patch?  That would be a more clear and direct change,  
better documentation, and easier to review and prove correct, perhaps.

Not a big deal, I just thought I'd mention it.

And, minor style nit: networking code usually prefers naming IPv4  
socket address variables "sin" rather than "s4".

> {
> 	int temp = 0;
> 	u32 cbaddr = 0;
> @@ -940,6 +940,8 @@ parse_ipv4(unsigned int addr_len, char  
> *addr_val, unsigned int *cbaddrp, unsigne
> 	char *addr = addr_val;
> 	int i, shift;
>
> +	s4->sin_family = AF_INET;
> +
> 	/* ipaddress */
> 	shift = 24;
> 	for(i = 4; i > 0  ; i--) {
> @@ -950,7 +952,7 @@ parse_ipv4(unsigned int addr_len, char  
> *addr_val, unsigned int *cbaddrp, unsigne
> 		if (shift > 0)
> 		shift -= 8;
> 	}
> -	*cbaddrp = cbaddr;
> +	s4->sin_addr.s_addr = htonl(cbaddr);
>
> 	/* port */
> 	shift = 8;
> @@ -962,7 +964,7 @@ parse_ipv4(unsigned int addr_len, char  
> *addr_val, unsigned int *cbaddrp, unsigne
> 		if (shift > 0)
> 			shift -= 8;
> 	}
> -	*cbportp = cbport;
> +	s4->sin_port = htons(cbport);
> 	return 1;
> }
>
> @@ -976,13 +978,16 @@ gen_callback(struct nfs4_client *clp, struct  
> nfsd4_setclientid *se)
> 		goto out_err;
>
> 	if ( !(parse_ipv4(se->se_callback_addr_len, se->se_callback_addr_val,
> -	                 &cb->cb_addr, &cb->cb_port)))
> +			  (struct sockaddr_in *) &cb->cb_addr)))
> 		goto out_err;
> +	cb->cb_addrlen = sizeof(struct sockaddr_in);
> 	cb->cb_minorversion = 0;
> 	cb->cb_prog = se->se_callback_prog;
> 	cb->cb_ident = se->se_callback_ident;
> 	return;
> out_err:
> +	cb->cb_addr.ss_family = AF_UNSPEC;
> +	cb->cb_addrlen = 0;
> 	dprintk(KERN_INFO "NFSD: this client (clientid %08x/%08x) "
> 		"will not receive delegations\n",
> 		clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index 58bb197..d866368 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -81,8 +81,8 @@ struct nfs4_delegation {
> /* client delegation callback info */
> struct nfs4_cb_conn {
> 	/* SETCLIENTID info */
> -	u32                     cb_addr;
> -	unsigned short          cb_port;
> +	struct sockaddr_storage	cb_addr;
> +	size_t			cb_addrlen;
> 	u32                     cb_prog;
> 	u32			cb_minorversion;
> 	u32                     cb_ident;	/* minorversion 0 only */
> -- 
> 1.6.0.6
>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
