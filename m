Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f182.google.com ([209.85.160.182]:55832 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbaEYIqz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 May 2014 04:46:55 -0400
Received: by mail-yk0-f182.google.com with SMTP id 9so5343588ykp.27
        for <linux-nfs@vger.kernel.org>; Sun, 25 May 2014 01:46:55 -0700 (PDT)
Message-ID: <5381ADF2.4050209@gmail.com>
Date: Sun, 25 May 2014 16:46:42 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
CC: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 13/52] nfsd4: use xdr_reserve_space in attribute encoding
References: <1400787148-25941-1-git-send-email-bfields@redhat.com> <1400787148-25941-14-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-14-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/23/2014 03:31, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> This is a cosmetic change for now; no change in behavior.
> 
> Note we're just depending on xdr_reserve_space to do the bounds checking
> for us, we're not really depending on its adjustment of iovec or xdr_buf
> lengths yet, as those are fixed up by as necessary after the fact by
> read-link operations and by nfs4svc_encode_compoundres.  However we do
> have to update xdr->iov on read-like operations to prevent
> xdr_reserve_space from messing with the already-fixed-up length of the
> the head.
> 
> When the attribute encoding fails partway through we have to undo the
> length adjustments made so far.  We do it manually for now, but later
> patches will add an xdr_truncate_encode() helper to handle cases like
> this.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/acl.h       |   2 +-
>  fs/nfsd/idmap.h     |   4 +-
>  fs/nfsd/nfs4acl.c   |  11 +-
>  fs/nfsd/nfs4idmap.c |  42 ++++----
>  fs/nfsd/nfs4proc.c  |   1 +
>  fs/nfsd/nfs4xdr.c   | 286 +++++++++++++++++++++++++++++++---------------------
>  6 files changed, 202 insertions(+), 144 deletions(-)
> 
> diff --git a/fs/nfsd/acl.h b/fs/nfsd/acl.h
> index b481e1f..a986ceb 100644
> --- a/fs/nfsd/acl.h
> +++ b/fs/nfsd/acl.h
> @@ -49,7 +49,7 @@ struct svc_rqst;
>  
>  struct nfs4_acl *nfs4_acl_new(int);
>  int nfs4_acl_get_whotype(char *, u32);
> -__be32 nfs4_acl_write_who(int who, __be32 **p, int *len);
> +__be32 nfs4_acl_write_who(struct xdr_stream *xdr, int who);
>  
>  int nfsd4_get_nfs4_acl(struct svc_rqst *rqstp, struct dentry *dentry,
>  		struct nfs4_acl **acl);
> diff --git a/fs/nfsd/idmap.h b/fs/nfsd/idmap.h
> index 66e58db..a3f3490 100644
> --- a/fs/nfsd/idmap.h
> +++ b/fs/nfsd/idmap.h
> @@ -56,7 +56,7 @@ static inline void nfsd_idmap_shutdown(struct net *net)
>  
>  __be32 nfsd_map_name_to_uid(struct svc_rqst *, const char *, size_t, kuid_t *);
>  __be32 nfsd_map_name_to_gid(struct svc_rqst *, const char *, size_t, kgid_t *);
> -__be32 nfsd4_encode_user(struct svc_rqst *, kuid_t, __be32 **, int *);
> -__be32 nfsd4_encode_group(struct svc_rqst *, kgid_t, __be32 **, int *);
> +__be32 nfsd4_encode_user(struct xdr_stream *, struct svc_rqst *, kuid_t);
> +__be32 nfsd4_encode_group(struct xdr_stream *, struct svc_rqst *, kgid_t);
>  
>  #endif /* LINUX_NFSD_IDMAP_H */
> diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
> index 7c7c025..d714156 100644
> --- a/fs/nfsd/nfs4acl.c
> +++ b/fs/nfsd/nfs4acl.c
> @@ -919,20 +919,19 @@ nfs4_acl_get_whotype(char *p, u32 len)
>  	return NFS4_ACL_WHO_NAMED;
>  }
>  
> -__be32 nfs4_acl_write_who(int who, __be32 **p, int *len)
> +__be32 nfs4_acl_write_who(struct xdr_stream *xdr, int who)
>  {
> +	__be32 *p;
>  	int i;
> -	int bytes;
>  
>  	for (i = 0; i < ARRAY_SIZE(s2t_map); i++) {
>  		if (s2t_map[i].type != who)
>  			continue;
> -		bytes = 4 + (XDR_QUADLEN(s2t_map[i].stringlen) << 2);
> -		if (bytes > *len)
> +		p = xdr_reserve_space(xdr, s2t_map[i].stringlen + 4);
> +		if (!p)
>  			return nfserr_resource;
> -		*p = xdr_encode_opaque(*p, s2t_map[i].string,
> +		p = xdr_encode_opaque(p, s2t_map[i].string,
>  					s2t_map[i].stringlen);
> -		*len -= bytes;
>  		return 0;
>  	}
>  	WARN_ON_ONCE(1);
> diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
> index c0dfde6..a0ab0a8 100644
> --- a/fs/nfsd/nfs4idmap.c
> +++ b/fs/nfsd/nfs4idmap.c
> @@ -551,44 +551,43 @@ idmap_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen
>  	return 0;
>  }
>  
> -static __be32 encode_ascii_id(u32 id, __be32 **p, int *buflen)
> +static __be32 encode_ascii_id(struct xdr_stream *xdr, u32 id)
>  {
>  	char buf[11];
>  	int len;
> -	int bytes;
> +	__be32 *p;
>  
>  	len = sprintf(buf, "%u", id);
> -	bytes = 4 + (XDR_QUADLEN(len) << 2);
> -	if (bytes > *buflen)
> +	p = xdr_reserve_space(xdr, len + 4);
> +	if (!p)
>  		return nfserr_resource;
> -	*p = xdr_encode_opaque(*p, buf, len);
> -	*buflen -= bytes;
> +	p = xdr_encode_opaque(p, buf, len);
>  	return 0;
>  }
>  
> -static __be32 idmap_id_to_name(struct svc_rqst *rqstp, int type, u32 id, __be32 **p, int *buflen)
> +static __be32 idmap_id_to_name(struct xdr_stream *xdr,
> +			       struct svc_rqst *rqstp, int type, u32 id)
>  {
>  	struct ent *item, key = {
>  		.id = id,
>  		.type = type,
>  	};
> +	__be32 *p;
>  	int ret;
> -	int bytes;
>  	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
>  
>  	strlcpy(key.authname, rqst_authname(rqstp), sizeof(key.authname));
>  	ret = idmap_lookup(rqstp, idtoname_lookup, &key, nn->idtoname_cache, &item);
>  	if (ret == -ENOENT)
> -		return encode_ascii_id(id, p, buflen);
> +		return encode_ascii_id(xdr, id);
>  	if (ret)
>  		return nfserrno(ret);
>  	ret = strlen(item->name);
>  	WARN_ON_ONCE(ret > IDMAP_NAMESZ);
> -	bytes = 4 + (XDR_QUADLEN(ret) << 2);
> -	if (bytes > *buflen)
> +	p = xdr_reserve_space(xdr, ret + 4);
> +	if (!p)
>  		return nfserr_resource;
> -	*p = xdr_encode_opaque(*p, item->name, ret);
> -	*buflen -= bytes;
> +	p = xdr_encode_opaque(p, item->name, ret);
>  	cache_put(&item->h, nn->idtoname_cache);
>  	return 0;
>  }
> @@ -622,11 +621,12 @@ do_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen, u
>  	return idmap_name_to_id(rqstp, type, name, namelen, id);
>  }
>  
> -static __be32 encode_name_from_id(struct svc_rqst *rqstp, int type, u32 id, __be32 **p, int *buflen)
> +static __be32 encode_name_from_id(struct xdr_stream *xdr,
> +				  struct svc_rqst *rqstp, int type, u32 id)
>  {
>  	if (nfs4_disable_idmapping && rqstp->rq_cred.cr_flavor < RPC_AUTH_GSS)
> -		return encode_ascii_id(id, p, buflen);
> -	return idmap_id_to_name(rqstp, type, id, p, buflen);
> +		return encode_ascii_id(xdr, id);
> +	return idmap_id_to_name(xdr, rqstp, type, id);
>  }
>  
>  __be32
> @@ -655,14 +655,16 @@ nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name, size_t namelen,
>  	return status;
>  }
>  
> -__be32 nfsd4_encode_user(struct svc_rqst *rqstp, kuid_t uid,  __be32 **p, int *buflen)
> +__be32 nfsd4_encode_user(struct xdr_stream *xdr, struct svc_rqst *rqstp,
> +			 kuid_t uid)
>  {
>  	u32 id = from_kuid(&init_user_ns, uid);
> -	return encode_name_from_id(rqstp, IDMAP_TYPE_USER, id, p, buflen);
> +	return encode_name_from_id(xdr, rqstp, IDMAP_TYPE_USER, id);
>  }
>  
> -__be32 nfsd4_encode_group(struct svc_rqst *rqstp, kgid_t gid, __be32 **p, int *buflen)
> +__be32 nfsd4_encode_group(struct xdr_stream *xdr, struct svc_rqst *rqstp,
> +			  kgid_t gid)
>  {
>  	u32 id = from_kgid(&init_user_ns, gid);
> -	return encode_name_from_id(rqstp, IDMAP_TYPE_GROUP, id, p, buflen);
> +	return encode_name_from_id(xdr, rqstp, IDMAP_TYPE_GROUP, id);
>  }
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index db14965..1433854 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1261,6 +1261,7 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
>  	struct kvec *head = buf->head;
>  
>  	xdr->buf = buf;
> +	xdr->iov = head;
>  	xdr->p   = head->iov_base + head->iov_len;
>  	xdr->end = head->iov_base + PAGE_SIZE - 2 * RPC_MAX_AUTH_SIZE;
>  }
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 2ed8036..0ab7aae 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1755,18 +1755,20 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
>  /* Encode as an array of strings the string given with components
>   * separated @sep, escaped with esc_enter and esc_exit.
>   */
> -static __be32 nfsd4_encode_components_esc(char sep, char *components,
> -				   __be32 **pp, int *buflen,
> -				   char esc_enter, char esc_exit)
> +static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep,
> +					  char *components, char esc_enter,
> +					  char esc_exit)
>  {
> -	__be32 *p = *pp;
> -	__be32 *countp = p;
> +	__be32 *p;
> +	__be32 *countp;
>  	int strlen, count=0;
>  	char *str, *end, *next;
>  
>  	dprintk("nfsd4_encode_components(%s)\n", components);
> -	if ((*buflen -= 4) < 0)
> +	p = xdr_reserve_space(xdr, 4);
> +	if (!p)
>  		return nfserr_resource;
> +	countp = p;
>  	WRITE32(0); /* We will fill this in with @count later */
>  	end = str = components;
>  	while (*end) {
> @@ -1789,7 +1791,8 @@ static __be32 nfsd4_encode_components_esc(char sep, char *components,
>  
>  		strlen = end - str;
>  		if (strlen) {
> -			if ((*buflen -= ((XDR_QUADLEN(strlen) << 2) + 4)) < 0)
> +			p = xdr_reserve_space(xdr, strlen + 4);
> +			if (!p)
>  				return nfserr_resource;
>  			WRITE32(strlen);
>  			WRITEMEM(str, strlen);
> @@ -1799,7 +1802,6 @@ static __be32 nfsd4_encode_components_esc(char sep, char *components,
>  			end++;
>  		str = end;
>  	}
> -	*pp = p;
>  	p = countp;
>  	WRITE32(count);
>  	return 0;
> @@ -1808,40 +1810,39 @@ static __be32 nfsd4_encode_components_esc(char sep, char *components,
>  /* Encode as an array of strings the string given with components
>   * separated @sep.
>   */
> -static __be32 nfsd4_encode_components(char sep, char *components,
> -				   __be32 **pp, int *buflen)
> +static __be32 nfsd4_encode_components(struct xdr_stream *xdr, char sep,
> +				      char *components)
>  {
> -	return nfsd4_encode_components_esc(sep, components, pp, buflen, 0, 0);
> +	return nfsd4_encode_components_esc(xdr, sep, components, 0, 0);
>  }
>  
>  /*
>   * encode a location element of a fs_locations structure
>   */
> -static __be32 nfsd4_encode_fs_location4(struct nfsd4_fs_location *location,
> -				    __be32 **pp, int *buflen)
> +static __be32 nfsd4_encode_fs_location4(struct xdr_stream *xdr,
> +					struct nfsd4_fs_location *location)
>  {
>  	__be32 status;
> -	__be32 *p = *pp;
>  
> -	status = nfsd4_encode_components_esc(':', location->hosts, &p, buflen,
> +	status = nfsd4_encode_components_esc(xdr, ':', location->hosts,
>  						'[', ']');
>  	if (status)
>  		return status;
> -	status = nfsd4_encode_components('/', location->path, &p, buflen);
> +	status = nfsd4_encode_components(xdr, '/', location->path);
>  	if (status)
>  		return status;
> -	*pp = p;
>  	return 0;
>  }
>  
>  /*
>   * Encode a path in RFC3530 'pathname4' format
>   */
> -static __be32 nfsd4_encode_path(const struct path *root,
> -		const struct path *path, __be32 **pp, int *buflen)
> +static __be32 nfsd4_encode_path(struct xdr_stream *xdr,
> +				const struct path *root,
> +				const struct path *path)
>  {
>  	struct path cur = *path;
> -	__be32 *p = *pp;
> +	__be32 *p;
>  	struct dentry **components = NULL;
>  	unsigned int ncomponents = 0;
>  	__be32 err = nfserr_jukebox;
> @@ -1872,9 +1873,9 @@ static __be32 nfsd4_encode_path(const struct path *root,
>  		components[ncomponents++] = cur.dentry;
>  		cur.dentry = dget_parent(cur.dentry);
>  	}
> -
> -	*buflen -= 4;
> -	if (*buflen < 0)
> +	err = nfserr_resource;
> +	p = xdr_reserve_space(xdr, 4);
> +	if (!p)
>  		goto out_free;
>  	WRITE32(ncomponents);
>  
> @@ -1884,8 +1885,8 @@ static __be32 nfsd4_encode_path(const struct path *root,
>  
>  		spin_lock(&dentry->d_lock);
>  		len = dentry->d_name.len;
> -		*buflen -= 4 + (XDR_QUADLEN(len) << 2);
> -		if (*buflen < 0) {
> +		p = xdr_reserve_space(xdr, len + 4);
> +		if (!p) {
>  			spin_unlock(&dentry->d_lock);
>  			goto out_free;
>  		}
> @@ -1897,7 +1898,6 @@ static __be32 nfsd4_encode_path(const struct path *root,
>  		ncomponents--;
>  	}
>  
> -	*pp = p;
>  	err = 0;
>  out_free:
>  	dprintk(")\n");
> @@ -1908,8 +1908,8 @@ out_free:
>  	return err;
>  }
>  
> -static __be32 nfsd4_encode_fsloc_fsroot(struct svc_rqst *rqstp,
> -		const struct path *path, __be32 **pp, int *buflen)
> +static __be32 nfsd4_encode_fsloc_fsroot(struct xdr_stream *xdr,
> +			struct svc_rqst *rqstp, const struct path *path)
>  {
>  	struct svc_export *exp_ps;
>  	__be32 res;
> @@ -1917,7 +1917,7 @@ static __be32 nfsd4_encode_fsloc_fsroot(struct svc_rqst *rqstp,
>  	exp_ps = rqst_find_fsidzero_export(rqstp);
>  	if (IS_ERR(exp_ps))
>  		return nfserrno(PTR_ERR(exp_ps));
> -	res = nfsd4_encode_path(&exp_ps->ex_path, path, pp, buflen);
> +	res = nfsd4_encode_path(xdr, &exp_ps->ex_path, path);
>  	exp_put(exp_ps);
>  	return res;
>  }
> @@ -1925,28 +1925,26 @@ static __be32 nfsd4_encode_fsloc_fsroot(struct svc_rqst *rqstp,
>  /*
>   *  encode a fs_locations structure
>   */
> -static __be32 nfsd4_encode_fs_locations(struct svc_rqst *rqstp,
> -				     struct svc_export *exp,
> -				     __be32 **pp, int *buflen)
> +static __be32 nfsd4_encode_fs_locations(struct xdr_stream *xdr,
> +			struct svc_rqst *rqstp, struct svc_export *exp)
>  {
>  	__be32 status;
>  	int i;
> -	__be32 *p = *pp;
> +	__be32 *p;
>  	struct nfsd4_fs_locations *fslocs = &exp->ex_fslocs;
>  
> -	status = nfsd4_encode_fsloc_fsroot(rqstp, &exp->ex_path, &p, buflen);
> +	status = nfsd4_encode_fsloc_fsroot(xdr, rqstp, &exp->ex_path);
>  	if (status)
>  		return status;
> -	if ((*buflen -= 4) < 0)
> +	p = xdr_reserve_space(xdr, 4);
> +	if (!p)
>  		return nfserr_resource;
>  	WRITE32(fslocs->locations_count);
>  	for (i=0; i<fslocs->locations_count; i++) {
> -		status = nfsd4_encode_fs_location4(&fslocs->locations[i],
> -						   &p, buflen);
> +		status = nfsd4_encode_fs_location4(xdr, &fslocs->locations[i]);
>  		if (status)
>  			return status;
>  	}
> -	*pp = p;
>  	return 0;
>  }
>  
> @@ -1965,15 +1963,15 @@ static u32 nfs4_file_type(umode_t mode)
>  }
>  
>  static inline __be32
> -nfsd4_encode_aclname(struct svc_rqst *rqstp, struct nfs4_ace *ace,
> -		__be32 **p, int *buflen)
> +nfsd4_encode_aclname(struct xdr_stream *xdr, struct svc_rqst *rqstp,
> +		     struct nfs4_ace *ace)
>  {
>  	if (ace->whotype != NFS4_ACL_WHO_NAMED)
> -		return nfs4_acl_write_who(ace->whotype, p, buflen);
> +		return nfs4_acl_write_who(xdr, ace->whotype);
>  	else if (ace->flag & NFS4_ACE_IDENTIFIER_GROUP)
> -		return nfsd4_encode_group(rqstp, ace->who_gid, p, buflen);
> +		return nfsd4_encode_group(xdr, rqstp, ace->who_gid);
>  	else
> -		return nfsd4_encode_user(rqstp, ace->who_uid, p, buflen);
> +		return nfsd4_encode_user(xdr, rqstp, ace->who_uid);
>  }
>  
>  #define WORD0_ABSENT_FS_ATTRS (FATTR4_WORD0_FS_LOCATIONS | FATTR4_WORD0_FSID | \
> @@ -1982,31 +1980,28 @@ nfsd4_encode_aclname(struct svc_rqst *rqstp, struct nfs4_ace *ace,
>  
>  #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>  static inline __be32
> -nfsd4_encode_security_label(struct svc_rqst *rqstp, void *context, int len, __be32 **pp, int *buflen)
> +nfsd4_encode_security_label(struct xdr_stream *xdr, struct svc_rqst *rqstp,
> +			    void *context, int len)
>  {
>  	__be32 *p = *pp;

  CC [M]  fs/nfsd/nfs4xdr.o
fs/nfsd/nfs4xdr.c: In function ‘nfsd4_encode_security_label’:
fs/nfsd/nfs4xdr.c:1984:15: error: ‘pp’ undeclared (first use in this function)
  __be32 *p = *pp;
               ^
fs/nfsd/nfs4xdr.c:1984:15: note: each undeclared identifier is reported only once for each function it appears in
make[1]: *** [fs/nfsd/nfs4xdr.o] Error 1
make: *** [fs/nfsd/] Error 2

thanks,
Kinglong Mee
