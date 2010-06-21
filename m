From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/8][RFC v05] NFSv3: add client implementation of XATTR
 protocol
Date: Mon, 21 Jun 2010 16:02:27 -0400
Message-ID: <4C1FC553.4030904@oracle.com>
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org> <alpine.LRH.2.00.1006212128160.13583@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-fsdevel@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>
To: James Morris <jmorris@namei.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1006212128160.13583@tundra.namei.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/21/10 07:29 AM, James Morris wrote:
> Add client support for the Linux NFSv3 extended attribute
> side protocol (XATTR).
>
> This extends Linux extended attributes over the network to
> servers which support the protocol.
>
> Operation is currently limited to the user.* namespace.
>
> Signed-off-by: James Morris<jmorris@namei.org>
> ---
>   fs/nfs/Kconfig            |   32 ++++++
>   fs/nfs/Makefile           |    1 +
>   fs/nfs/client.c           |   51 +++++++++-
>   fs/nfs/internal.h         |   11 ++
>   fs/nfs/nfs3xattr.c        |  241 ++++++++++++++++++++++++++++++++++++++++++++-
>   fs/nfs/nfs3xattr_user.c   |   53 ++++++++++
>   fs/nfs/nfs3xdr.c          |  187 +++++++++++++++++++++++++++++++++++
>   fs/nfs/super.c            |    2 +-
>   include/linux/nfs_fs_sb.h |    3 +-
>   include/linux/nfs_mount.h |    3 +
>   include/linux/nfs_xattr.h |   21 ++++
>   include/linux/nfs_xdr.h   |   45 +++++++++
>   12 files changed, 646 insertions(+), 4 deletions(-)
>   create mode 100644 fs/nfs/nfs3xattr_user.c
>   create mode 100644 include/linux/nfs_xattr.h

   [ ... snipped ... ]

> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
> index 75dcfc7..08d5ec9 100644
> --- a/fs/nfs/nfs3xdr.c
> +++ b/fs/nfs/nfs3xdr.c
> @@ -87,6 +87,26 @@
>   #define ACL3_setaclres_sz	(1+NFS3_post_op_attr_sz)
>
>   /*
> + * FIXME: currently, the RPC layer will allocate the maximum buffer size
> + * here for each call (which can be ~ 64k).  The Labeled NFS prototype code
> + * uses 4k, although we should not impose limits for NFS which don't exist
> + * in the OS unless absolutely necsssary.  We likely need a dynamic scheme
> + * here, possibly using pages.
> + */

Encoding directly into RPC buffers is usually only for small objects, a 
few hundred bytes at most.  What are the challenges to using the page 
cache for these right now?  We already do that for symlinks and ACLs, right?

Is there a way the server can advertise a size limit for these objects, 
similar to rsize and wsize?

> +#define XATTR3_xattrname_sz	(1+(XATTR_NAME_MAX>>2))
> +#define XATTR3_xattrval_sz	(1+(XATTR_SIZE_MAX>>2))
> +#define XATTR3_xattrlist_sz	(1+(XATTR_LIST_MAX>>2))
> +
> +#define XATTR3_getxattrargs_sz	(NFS3_fh_sz+XATTR3_xattrname_sz+1)
> +#define XATTR3_getxattrres_sz	(1+NFS3_post_op_attr_sz+XATTR3_xattrval_sz)
> +
> +#define XATTR3_setxattrargs_sz	(NFS3_fh_sz+XATTR3_xattrname_sz+XATTR3_xattrval_sz+1)
> +#define XATTR3_setxattrres_sz	(1+NFS3_post_op_attr_sz)
> +
> +#define XATTR3_listxattrargs_sz	(NFS3_fh_sz+1)
> +#define XATTR3_listxattrres_sz	(1+NFS3_post_op_attr_sz+XATTR3_xattrlist_sz)
> +
> +/*
>    * Map file type to S_IFMT bits
>    */
>   static const umode_t nfs_type2fmt[] = {
> @@ -726,6 +746,72 @@ nfs3_xdr_setaclargs(struct rpc_rqst *req, __be32 *p,
>   }
>   #endif  /* CONFIG_NFS_V3_ACL */
>
> +#ifdef CONFIG_NFS_V3_XATTR
> +/*
> + * Special case of xdr_encode_opaque, where the xattr helpers hand us
> + * separate namespace and name buffers, which we encode as a single XDR
> + * string over the wire.  Neither namespace nor name may be empty or null.
> + */
> +static __be32 *xattr_encode_name(__be32 *p, const char *namespace, const char *name)

By convention this function would be called "xdr_encode_xattr_name()".

Are these names going to be UTF-8 strings?

> +{
> +	unsigned int nslen, namelen, totlen, quadlen, padding;
> +
> +	nslen = strlen(namespace);
> +	namelen = strlen(name);
> +	totlen = nslen + namelen;
> +	quadlen = XDR_QUADLEN(totlen);
> +	padding = (quadlen<<  2) - totlen;
> +
> +	*p++ = cpu_to_be32(totlen);
> +	memcpy(p, namespace, nslen);
> +	memcpy((char *)p + nslen, name, namelen);
> +
> +	if (padding != 0)
> +		memset((char *)p + totlen, 0, padding);
> +	p += quadlen;
> +	return p;
> +}
> +
> +/*
> + * Encode GETXATTR arguments
> + */
> +static int nfs3_xdr_getxattrargs(struct rpc_rqst *req, __be32 *p,
> +				 struct nfs3_getxattrargs *args)
> +{
> +	p = xdr_encode_fhandle(p, args->fh);
> +	p = xattr_encode_name(p, args->xattr_namespace, args->xattr_name);
> +	*p++ = htonl(args->xattr_size_max);
> +	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
> +	return 0;
> +}
> +
> +/*
> + * Encode SETXATTR arguments
> + */
> +static int nfs3_xdr_setxattrargs(struct rpc_rqst *req, __be32 *p,
> +				 struct nfs3_setxattrargs *args)
> +{
> +	p = xdr_encode_fhandle(p, args->fh);
> +	p = xattr_encode_name(p, args->xattr_namespace, args->xattr_name);
> +	p = xdr_encode_array(p, args->xattr_val, args->xattr_val_len);
> +	*p++ = htonl(args->xattr_flags);
> +	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
> +	return 0;
> +}
> +
> +/*
> + * Encode LISTXATTR arguments
> + */
> +static int nfs3_xdr_listxattrargs(struct rpc_rqst *req, __be32 *p,
> +				  struct nfs3_listxattrargs *args)
> +{
> +	p = xdr_encode_fhandle(p, args->fh);
> +	*p++ = htonl(args->xattr_list_max);
> +	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
> +	return 0;
> +}
> +#endif	/* CONFIG_NFS_V3_XATTR */
> +
>   /*
>    * NFS XDR decode functions
>    */
> @@ -1135,6 +1221,69 @@ nfs3_xdr_setaclres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
>   }
>   #endif  /* CONFIG_NFS_V3_ACL */
>
> +#ifdef CONFIG_NFS_V3_XATTR
> +/*
> + * Decode GETXATTR reply
> + *
> + * FIXME: determine appropriate error returns
> + */
> +static int nfs3_xdr_getxattrres(struct rpc_rqst *req, __be32 *p,
> +				struct nfs3_getxattrres *res)
> +{
> +	char *xattr_val;
> +	unsigned int xattr_max_size = res->xattr_val_len;
> +	int status = ntohl(*p++);
> +
> +	if (status != 0)
> +		return nfs_stat_to_errno(status);
> +
> +	p = xdr_decode_post_op_attr(p, res->fattr);
> +	p = xdr_decode_string_inplace(p,&xattr_val,
> +	&res->xattr_val_len,
> +	                              xattr_max_size);
> +	if (p == NULL)
> +		return -EINVAL;
> +	memcpy(res->xattr_val, xattr_val, res->xattr_val_len);
> +	return 0;
> +}
> +
> +/*
> + * Decode SETXATTR reply
> + */
> +static int nfs3_xdr_setxattrres(struct rpc_rqst *req, __be32 *p,
> +				struct nfs3_setxattrres *res)
> +{
> +	int status = ntohl(*p++);
> +
> +	if (status)
> +		return nfs_stat_to_errno(status);
> +	xdr_decode_post_op_attr(p, res->fattr);
> +	return 0;
> +}
> +
> +/*
> + * Decode LISTXATTR reply
> + */
> +static int nfs3_xdr_listxattrres(struct rpc_rqst *req, __be32 *p,
> +				 struct nfs3_listxattrres *res)
> +{
> +	char *xattr_list;
> +	unsigned int size = res->xattr_list_len;
> +	int status = ntohl(*p++);
> +
> +	if (status != 0)
> +		return nfs_stat_to_errno(status);
> +
> +	p = xdr_decode_post_op_attr(p, res->fattr);
> +	p = xdr_decode_string_inplace(p,&xattr_list,
> +	&res->xattr_list_len, size);
> +	if (p == NULL)
> +		return -EINVAL;
> +	memcpy(res->xattr_list, xattr_list, res->xattr_list_len);
> +	return 0;
> +}
> +#endif	/* CONFIG_NFS_V3_XATTR */
> +
>   #define PROC(proc, argtype, restype, timer)				\
>   [NFS3PROC_##proc] = {							\
>   	.p_proc      = NFS3PROC_##proc,					\
> @@ -1206,3 +1355,41 @@ struct rpc_version		nfsacl_version3 = {
>   	.procs			= nfs3_acl_procedures,
>   };
>   #endif  /* CONFIG_NFS_V3_ACL */
> +
> +#ifdef CONFIG_NFS_V3_XATTR
> +static struct rpc_procinfo	nfs3_xattr_procedures[] = {
> +	[XATTRPROC3_GETXATTR] = {
> +		.p_proc		= XATTRPROC3_GETXATTR,
> +		.p_encode	= (kxdrproc_t) nfs3_xdr_getxattrargs,
> +		.p_decode	= (kxdrproc_t) nfs3_xdr_getxattrres,
> +		.p_arglen	= XATTR3_getxattrargs_sz,
> +		.p_replen	= XATTR3_getxattrres_sz,
> +		.p_timer	= 1,
> +		.p_name		= "GETXATTR",
> +	},
> +	[XATTRPROC3_SETXATTR] = {
> +		.p_proc		= XATTRPROC3_SETXATTR,
> +		.p_encode	= (kxdrproc_t) nfs3_xdr_setxattrargs,
> +		.p_decode	= (kxdrproc_t) nfs3_xdr_setxattrres,
> +		.p_arglen	= XATTR3_setxattrargs_sz,
> +		.p_replen	= XATTR3_setxattrres_sz,
> +		.p_timer	= 1,
> +		.p_name		= "SETXATTR",
> +	},
> +	[XATTRPROC3_LISTXATTR] = {
> +		.p_proc		= XATTRPROC3_LISTXATTR,
> +		.p_encode	= (kxdrproc_t) nfs3_xdr_listxattrargs,
> +		.p_decode	= (kxdrproc_t) nfs3_xdr_listxattrres,
> +		.p_arglen	= XATTR3_listxattrargs_sz,
> +		.p_replen	= XATTR3_listxattrres_sz,
> +		.p_timer	= 1,
> +		.p_name		= "LISTXATTR",
> +	},
> +};
> +
> +struct rpc_version		nfs_xattr_version3 = {
> +	.number			= 3,
> +	.nrprocs		= ARRAY_SIZE(nfs3_xattr_procedures),
> +	.procs			= nfs3_xattr_procedures,
> +};
> +#endif	/* CONFIG_NFS_V3_XATTR */

   [ ... snipped ... ]

> diff --git a/include/linux/nfs_xattr.h b/include/linux/nfs_xattr.h
> new file mode 100644
> index 0000000..98fdbed
> --- /dev/null
> +++ b/include/linux/nfs_xattr.h
> @@ -0,0 +1,21 @@
> +/*
> + * Extended attribute protocol for NFSv3 (XATTR)
> + *
> + *
> + * Copyright (C) 2009 Red Hat, Inc., James Morris<jmorris@redhat.com>
> + *
> + */
> +#ifndef __LINUX_NFS_XATTR_H
> +#define __LINUX_NFS_XATTR_H
> +
> +#include<linux/xattr.h>
> +
> +#define NFS_XATTR_PROGRAM	391063	/* TODO: find another value */

RFC 5531, appendix B proscribes the appropriate method for requesting an 
RPC program number assignment.

Even though the NFSACL protocol doesn't have one, I have to agree with 
Deniel that we should have the RPCL definition of the on-the-wire 
protocol first, so we can review it and ensure our user space and kernel 
XDR functions remain consistent and correct over time.  Is there an RFC?

Especially if we expect non-Linux implementations, I would think an 
IANA-assigned program number and a proper RPCL definition would be 
apriori requirements.

> +
> +/* xattr procedure numbers */
> +#define XATTRPROC3_GETXATTR	1
> +#define XATTRPROC3_SETXATTR	2
> +#define XATTRPROC3_LISTXATTR	3
> +#define XATTRPROC3_RMXATTR	4

NIT: Fwiw, I tend to prefer enums for this.

> +
> +#endif  /* __LINUX_NFS_XATTR_H */

