Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:57708 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129Ab1AERGo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 12:06:44 -0500
Subject: Re: [PATCH] nfs4: set source address when callback is generated
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110105005835.GA14744@fieldses.org>
Date: Wed, 5 Jan 2011 12:06:04 -0500
Cc: Takuma Umeya <tumeya@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Message-Id: <F369CCC7-285D-4F4D-80D4-EEAC273E561C@oracle.com>
References: <20101215050901.GB13532@redhat.com> <20101216034945.GH9646@fieldses.org> <A4BB9763-B67F-4559-B3FF-F7BC2DBD3B3A@oracle.com> <20110105005835.GA14744@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 4, 2011, at 7:58 PM, J. Bruce Fields wrote:

> On Thu, Dec 16, 2010 at 10:54:00AM -0500, Chuck Lever wrote:
>> I don't recall creating svc_addr_u, but I'll take a stab at a guess.
>> 
>> It looks like someone thought that we should retain the idea of storing just the address part of the socket address, and not the other stuff (like the family and port, since this code doesn't appear to need that additional information).  It greatly reduces the size of the field.  A full sockaddr_storage is more than 128 bytes, since it has to be able to store an AF_UNIX pathname.
>> 
>> Doing this, there is a lot less data to keep around, but an IPv6 socket address has other items outside of in6_addr that can be used to form a full address.  We decided at some point we could copy this information from the other address storage field in the rqstp.
>> 
>> But the result of this space savings means we must construct a full socket address when needed, using logic such as the above.
> 
> Seems to me we should either just waste the extra 100 bytes or define
> something that would be useful elsewhere as well....

In nfs-utils, we define:

	union nfs_sockaddr {
		struct sockaddr_in	s4;
		struct sockaddr_in6	s6;
		struct sockaddr		sa;
	};

A variable of this type is large enough to hold a full IPv6 sockaddr, but is significantly smaller than a sockaddr_storage.

The addition of the "struct sockaddr" element is to enable access to such variables via a "struct sockaddr *" without type punning.  This seems to be preferred by gcc over type casting in order to handle optimizations involving address aliasing.  It also allows more precise type checking.

A full conversion to use such a construct in kernel RPC and NFS components is, I fear, too late for 2.6.38, but might be considered for a future release if there is consensus on this approach.

> But if we do it this way we can at least simplify a little.
> 
> --b.
> 
> commit 6f3d772fb8a039de8f21d725f5e38c252b4c0efd
> Author: Takuma Umeya <tumeya@redhat.com>
> Date:   Wed Dec 15 14:09:01 2010 +0900
> 
>    nfs4: set source address when callback is generated
> 
>    when callback is generated in NFSv4 server, it doesn't set the source
>    address. When an alias IP is utilized on NFSv4 server and suppose the
>    client is accessing via that alias IP (e.g. eth0:0), the client invokes
>    the callback to the IP address that is set on the original device (e.g.
>    eth0). This behavior results in timeout of xprt.
>    The patch sets the IP address that the client should invoke callback to.
> 
>    Signed-off-by: Takuma Umeya <tumeya@redhat.com>
>    [bfields@redhat.com: Simplify gen_callback arguments, use helper function]
>    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index a085805..dd183af 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -484,6 +484,7 @@ static int setup_callback_client(struct nfs4_client *clp,
> 		.net		= &init_net,
> 		.address	= (struct sockaddr *) &conn->cb_addr,
> 		.addrsize	= conn->cb_addrlen,
> +		.saddress	= (struct sockaddr *) &conn->cb_saddr,
> 		.timeout	= &timeparms,
> 		.program	= &cb_program,
> 		.version	= 0,
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 87d4c48..b583e4e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1163,10 +1163,26 @@ find_unconfirmed_client_by_str(const char *dname, unsigned int hashval)
> 	return NULL;
> }
> 
> +static void rpc_svcaddr2sockaddr(struct sockaddr *sa, unsigned short family, union svc_addr_u *svcaddr)
> +{
> +	switch (family) {
> +	case AF_INET:
> +		((struct sockaddr_in *)sa)->sin_family = AF_INET;
> +		((struct sockaddr_in *)sa)->sin_addr = svcaddr->addr;
> +		return;
> +	case AF_INET6:
> +		((struct sockaddr_in6 *)sa)->sin6_family = AF_INET6;
> +		((struct sockaddr_in6 *)sa)->sin6_addr = svcaddr->addr6;
> +		return;
> +	}
> +}
> +
> static void
> -gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, u32 scopeid)
> +gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_rqst *rqstp)
> {
> 	struct nfs4_cb_conn *conn = &clp->cl_cb_conn;
> +	struct sockaddr	*sa = svc_addr(rqstp);
> +	u32 scopeid = rpc_get_scope_id(sa);
> 	unsigned short expected_family;
> 
> 	/* Currently, we only support tcp and tcp6 for the callback channel */
> @@ -1192,6 +1208,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, u32 scopeid)
> 
> 	conn->cb_prog = se->se_callback_prog;
> 	conn->cb_ident = se->se_callback_ident;
> +	rpc_svcaddr2sockaddr((struct sockaddr *)&conn->cb_saddr, expected_family, &rqstp->rq_daddr);
> 	return;
> out_err:
> 	conn->cb_addr.ss_family = AF_UNSPEC;
> @@ -1768,7 +1785,6 @@ __be32
> nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> 		  struct nfsd4_setclientid *setclid)
> {
> -	struct sockaddr		*sa = svc_addr(rqstp);
> 	struct xdr_netobj 	clname = { 
> 		.len = setclid->se_namelen,
> 		.data = setclid->se_name,
> @@ -1871,7 +1887,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> 	 * for consistent minorversion use throughout:
> 	 */
> 	new->cl_minorversion = 0;
> -	gen_callback(new, setclid, rpc_get_scope_id(sa));
> +	gen_callback(new, setclid, rqstp);
> 	add_to_unconfirmed(new, strhashval);
> 	setclid->se_clientid.cl_boot = new->cl_clientid.cl_boot;
> 	setclid->se_clientid.cl_id = new->cl_clientid.cl_id;
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 84b2302..cf6dc83 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -96,6 +96,7 @@ struct nfs4_delegation {
> struct nfs4_cb_conn {
> 	/* SETCLIENTID info */
> 	struct sockaddr_storage	cb_addr;
> +	struct sockaddr_storage	cb_saddr;
> 	size_t			cb_addrlen;
> 	u32                     cb_prog; /* used only in 4.0 case;
> 					    per-session otherwise */

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




