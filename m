Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33488 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751653AbdEIR76 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 13:59:58 -0400
Received: by mail-it0-f68.google.com with SMTP id v135so1027290itv.0
        for <linux-nfs@vger.kernel.org>; Tue, 09 May 2017 10:59:58 -0700 (PDT)
Subject: Re: [PATCH] NFSv4: Fix exclusive create attributes encoding
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
References: <20170508142648.128870-1-trond.myklebust@primarydata.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <7609d559-b252-af61-6de2-01843df9bf50@gmail.com>
Date: Tue, 9 May 2017 13:59:56 -0400
MIME-Version: 1.0
In-Reply-To: <20170508142648.128870-1-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 05/08/2017 10:26 AM, Trond Myklebust wrote:
> When using NFS4_CREATE_EXCLUSIVE4_1 mode, the client will overestimate the
> amount of space that it needs for the attributes because it does so
> before checking whether or not the server supports a given attribute.
> 
> Fix by checking the attribute mask earlier.

Cthon general tests consistently fail with IO errors once this patch is applied, but only for NFS v4.1 (v2, v3, v4.0, and v4.2 all work fine).  Here is the output that it gives me:

GENERAL TESTS: directory /nfs/general
if test ! -x runtests; then chmod a+x runtests; fi
cd /nfs/general; rm -f Makefile runtests runtests.wrk *.sh *.c mkdummy rmdummy nroff.in makefile.tst
cp Makefile runtests runtests.wrk *.sh *.c mkdummy rmdummy nroff.in makefile.tst /nfs/general
cp: cannot create regular file '/nfs/general/Makefile': Input/output error
cp: cannot create regular file '/nfs/general/runtests': Input/output error
cp: cannot create regular file '/nfs/general/runtests.wrk': Input/output error
cp: cannot create regular file '/nfs/general/large4.sh': Input/output error
cp: cannot create regular file '/nfs/general/large.c': Input/output error
cp: cannot create regular file '/nfs/general/large1.c': Input/output error
cp: cannot create regular file '/nfs/general/large2.c': Input/output error
cp: cannot create regular file '/nfs/general/large3.c': Input/output error
cp: cannot create regular file '/nfs/general/stat.c': Input/output error
cp: cannot create regular file '/nfs/general/mkdummy': Input/output error
cp: cannot create regular file '/nfs/general/rmdummy': Input/output error
cp: cannot create regular file '/nfs/general/nroff.in': Input/output error
cp: cannot create regular file '/nfs/general/makefile.tst': Input/output error
make: *** [Makefile:32: copy] Error 1
general tests failed

Thanks,
Anna

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4xdr.c | 75 ++++++++++++++++++++++++++------------------------------
>  1 file changed, 35 insertions(+), 40 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index dbfe48ac3529..3aebfdc82b30 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1000,8 +1000,9 @@ static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *ve
>  
>  static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
>  				const struct nfs4_label *label,
> +				const umode_t *umask,
>  				const struct nfs_server *server,
> -				bool excl_check, const umode_t *umask)
> +				const uint32_t attrmask[])
>  {
>  	char owner_name[IDMAP_NAMESZ];
>  	char owner_group[IDMAP_NAMESZ];
> @@ -1016,22 +1017,20 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
>  	/*
>  	 * We reserve enough space to write the entire attribute buffer at once.
>  	 */
> -	if (iap->ia_valid & ATTR_SIZE) {
> +	if ((iap->ia_valid & ATTR_SIZE) && (attrmask[0] & FATTR4_WORD0_SIZE)) {
>  		bmval[0] |= FATTR4_WORD0_SIZE;
>  		len += 8;
>  	}
> -	if (!(server->attr_bitmask[2] & FATTR4_WORD2_MODE_UMASK))
> -		umask = NULL;
>  	if (iap->ia_valid & ATTR_MODE) {
> -		if (umask) {
> +		if (umask && (attrmask[2] & FATTR4_WORD2_MODE_UMASK)) {
>  			bmval[2] |= FATTR4_WORD2_MODE_UMASK;
>  			len += 8;
> -		} else {
> +		} else if (attrmask[1] & FATTR4_WORD1_MODE) {
>  			bmval[1] |= FATTR4_WORD1_MODE;
>  			len += 4;
>  		}
>  	}
> -	if (iap->ia_valid & ATTR_UID) {
> +	if ((iap->ia_valid & ATTR_UID) && (attrmask[1] & FATTR4_WORD1_OWNER)) {
>  		owner_namelen = nfs_map_uid_to_name(server, iap->ia_uid, owner_name, IDMAP_NAMESZ);
>  		if (owner_namelen < 0) {
>  			dprintk("nfs: couldn't resolve uid %d to string\n",
> @@ -1044,7 +1043,8 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
>  		bmval[1] |= FATTR4_WORD1_OWNER;
>  		len += 4 + (XDR_QUADLEN(owner_namelen) << 2);
>  	}
> -	if (iap->ia_valid & ATTR_GID) {
> +	if ((iap->ia_valid & ATTR_GID) &&
> +	   (attrmask[1] & FATTR4_WORD1_OWNER_GROUP)) {
>  		owner_grouplen = nfs_map_gid_to_group(server, iap->ia_gid, owner_group, IDMAP_NAMESZ);
>  		if (owner_grouplen < 0) {
>  			dprintk("nfs: couldn't resolve gid %d to string\n",
> @@ -1056,32 +1056,26 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
>  		bmval[1] |= FATTR4_WORD1_OWNER_GROUP;
>  		len += 4 + (XDR_QUADLEN(owner_grouplen) << 2);
>  	}
> -	if (iap->ia_valid & ATTR_ATIME_SET) {
> -		bmval[1] |= FATTR4_WORD1_TIME_ACCESS_SET;
> -		len += 16;
> -	} else if (iap->ia_valid & ATTR_ATIME) {
> -		bmval[1] |= FATTR4_WORD1_TIME_ACCESS_SET;
> -		len += 4;
> -	}
> -	if (iap->ia_valid & ATTR_MTIME_SET) {
> -		bmval[1] |= FATTR4_WORD1_TIME_MODIFY_SET;
> -		len += 16;
> -	} else if (iap->ia_valid & ATTR_MTIME) {
> -		bmval[1] |= FATTR4_WORD1_TIME_MODIFY_SET;
> -		len += 4;
> +	if (attrmask[1] & FATTR4_WORD1_TIME_ACCESS_SET) {
> +		if (iap->ia_valid & ATTR_ATIME_SET) {
> +			bmval[1] |= FATTR4_WORD1_TIME_ACCESS_SET;
> +			len += 16;
> +		} else if (iap->ia_valid & ATTR_ATIME) {
> +			bmval[1] |= FATTR4_WORD1_TIME_ACCESS_SET;
> +			len += 4;
> +		}
>  	}
> -
> -	if (excl_check) {
> -		const u32 *excl_bmval = server->exclcreat_bitmask;
> -		bmval[0] &= excl_bmval[0];
> -		bmval[1] &= excl_bmval[1];
> -		bmval[2] &= excl_bmval[2];
> -
> -		if (!(excl_bmval[2] & FATTR4_WORD2_SECURITY_LABEL))
> -			label = NULL;
> +	if (attrmask[1] & FATTR4_WORD1_TIME_MODIFY_SET) {
> +		if (iap->ia_valid & ATTR_MTIME_SET) {
> +			bmval[1] |= FATTR4_WORD1_TIME_MODIFY_SET;
> +			len += 16;
> +		} else if (iap->ia_valid & ATTR_MTIME) {
> +			bmval[1] |= FATTR4_WORD1_TIME_MODIFY_SET;
> +			len += 4;
> +		}
>  	}
>  
> -	if (label) {
> +	if (label && (attrmask[2] & FATTR4_WORD2_SECURITY_LABEL)) {
>  		len += 4 + 4 + 4 + (XDR_QUADLEN(label->len) << 2);
>  		bmval[2] |= FATTR4_WORD2_SECURITY_LABEL;
>  	}
> @@ -1188,8 +1182,8 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
>  	}
>  
>  	encode_string(xdr, create->name->len, create->name->name);
> -	encode_attrs(xdr, create->attrs, create->label, create->server, false,
> -		     &create->umask);
> +	encode_attrs(xdr, create->attrs, create->label, &create->umask,
> +			create->server, create->server->attr_bitmask);
>  }
>  
>  static void encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct compound_hdr *hdr)
> @@ -1409,13 +1403,13 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
>  	switch(arg->createmode) {
>  	case NFS4_CREATE_UNCHECKED:
>  		*p = cpu_to_be32(NFS4_CREATE_UNCHECKED);
> -		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server, false,
> -			     &arg->umask);
> +		encode_attrs(xdr, arg->u.attrs, arg->label, &arg->umask,
> +				arg->server, arg->server->attr_bitmask);
>  		break;
>  	case NFS4_CREATE_GUARDED:
>  		*p = cpu_to_be32(NFS4_CREATE_GUARDED);
> -		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server, false,
> -			     &arg->umask);
> +		encode_attrs(xdr, arg->u.attrs, arg->label, &arg->umask,
> +				arg->server, arg->server->attr_bitmask);
>  		break;
>  	case NFS4_CREATE_EXCLUSIVE:
>  		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE);
> @@ -1424,8 +1418,8 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
>  	case NFS4_CREATE_EXCLUSIVE4_1:
>  		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE4_1);
>  		encode_nfs4_verifier(xdr, &arg->u.verifier);
> -		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server, true,
> -			     &arg->umask);
> +		encode_attrs(xdr, arg->u.attrs, arg->label, &arg->umask,
> +				arg->server, arg->server->exclcreat_bitmask);
>  	}
>  }
>  
> @@ -1681,7 +1675,8 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
>  {
>  	encode_op_hdr(xdr, OP_SETATTR, decode_setattr_maxsz, hdr);
>  	encode_nfs4_stateid(xdr, &arg->stateid);
> -	encode_attrs(xdr, arg->iap, arg->label, server, false, NULL);
> +	encode_attrs(xdr, arg->iap, arg->label, NULL, server,
> +			server->attr_bitmask);
>  }
>  
>  static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclientid *setclientid, struct compound_hdr *hdr)
> 
