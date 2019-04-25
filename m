Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0F0CC43218
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 14:32:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DE3AF2067D
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 14:32:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725959AbfDYOcn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 10:32:43 -0400
Received: from fieldses.org ([173.255.197.46]:51016 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725900AbfDYOcn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 10:32:43 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 5E6471C83; Thu, 25 Apr 2019 10:32:43 -0400 (EDT)
Date:   Thu, 25 Apr 2019 10:32:43 -0400
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     Anna Schumaker <Anna.Schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/9] NFSv4: Convert the NFS client idmapper to use the
 container user namespace
Message-ID: <20190425143243.GA8133@fieldses.org>
References: <20190424214650.4658-1-trond.myklebust@hammerspace.com>
 <20190424214650.4658-2-trond.myklebust@hammerspace.com>
 <20190424214650.4658-3-trond.myklebust@hammerspace.com>
 <20190424214650.4658-4-trond.myklebust@hammerspace.com>
 <20190424214650.4658-5-trond.myklebust@hammerspace.com>
 <20190424214650.4658-6-trond.myklebust@hammerspace.com>
 <20190424214650.4658-7-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190424214650.4658-7-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Apr 24, 2019 at 05:46:47PM -0400, Trond Myklebust wrote:
> When mapping NFS identities using the NFSv4 idmapper, we want to substitute
> for the uids and gids that would normally go on the wire as part of a
> NFSv3 request. So we use the same mapping in the NFSv4 upcall as we
> use in the NFSv3 RPC call (i.e. the mapping stored in the rpc_clnt cred).

I'm a little lost.  Do I have it right that the following id's are all
the same?:

	- id's used on the wire
	- id's used in NFSv4 idmapper upcalls
	- id's used in the namespace of the mounting process

And is it assumed that those are all in one namespace?  So different
containers can't use different on-the-wire id's?

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  fs/nfs/nfs4idmap.c | 27 ++++++++++++++++++++-------
>  1 file changed, 20 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
> index bf34ddaa2ad7..4884fdae28fb 100644
> --- a/fs/nfs/nfs4idmap.c
> +++ b/fs/nfs/nfs4idmap.c
> @@ -69,8 +69,16 @@ struct idmap {
>  	struct rpc_pipe		*idmap_pipe;
>  	struct idmap_legacy_upcalldata *idmap_upcall_data;
>  	struct mutex		idmap_mutex;
> +	const struct cred	*cred;
>  };
>  
> +static struct user_namespace *idmap_userns(const struct idmap *idmap)
> +{
> +	if (idmap && idmap->cred)
> +		return idmap->cred->user_ns;
> +	return &init_user_ns;
> +}
> +
>  /**
>   * nfs_fattr_init_names - initialise the nfs_fattr owner_name/group_name fields
>   * @fattr: fully initialised struct nfs_fattr
> @@ -271,14 +279,15 @@ static struct key *nfs_idmap_request_key(const char *name, size_t namelen,
>  					 const char *type, struct idmap *idmap)
>  {
>  	char *desc;
> -	struct key *rkey;
> +	struct key *rkey = ERR_PTR(-EAGAIN);
>  	ssize_t ret;
>  
>  	ret = nfs_idmap_get_desc(name, namelen, type, strlen(type), &desc);
>  	if (ret < 0)
>  		return ERR_PTR(ret);
>  
> -	rkey = request_key(&key_type_id_resolver, desc, "");
> +	if (!idmap->cred || idmap->cred->user_ns == &init_user_ns)
> +		rkey = request_key(&key_type_id_resolver, desc, "");
>  	if (IS_ERR(rkey)) {
>  		mutex_lock(&idmap->idmap_mutex);
>  		rkey = request_key_with_auxdata(&key_type_id_resolver_legacy,
> @@ -452,6 +461,9 @@ nfs_idmap_new(struct nfs_client *clp)
>  	if (idmap == NULL)
>  		return -ENOMEM;
>  
> +	mutex_init(&idmap->idmap_mutex);
> +	idmap->cred = get_cred(clp->cl_rpcclient->cl_cred);
> +
>  	rpc_init_pipe_dir_object(&idmap->idmap_pdo,
>  			&nfs_idmap_pipe_dir_object_ops,
>  			idmap);
> @@ -462,7 +474,6 @@ nfs_idmap_new(struct nfs_client *clp)
>  		goto err;
>  	}
>  	idmap->idmap_pipe = pipe;
> -	mutex_init(&idmap->idmap_mutex);
>  
>  	error = rpc_add_pipe_dir_object(clp->cl_net,
>  			&clp->cl_rpcclient->cl_pipedir_objects,
> @@ -475,6 +486,7 @@ nfs_idmap_new(struct nfs_client *clp)
>  err_destroy_pipe:
>  	rpc_destroy_pipe_data(idmap->idmap_pipe);
>  err:
> +	put_cred(idmap->cred);
>  	kfree(idmap);
>  	return error;
>  }
> @@ -491,6 +503,7 @@ nfs_idmap_delete(struct nfs_client *clp)
>  			&clp->cl_rpcclient->cl_pipedir_objects,
>  			&idmap->idmap_pdo);
>  	rpc_destroy_pipe_data(idmap->idmap_pipe);
> +	put_cred(idmap->cred);
>  	kfree(idmap);
>  }
>  
> @@ -735,7 +748,7 @@ int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_
>  	if (!nfs_map_string_to_numeric(name, namelen, &id))
>  		ret = nfs_idmap_lookup_id(name, namelen, "uid", &id, idmap);
>  	if (ret == 0) {
> -		*uid = make_kuid(&init_user_ns, id);
> +		*uid = make_kuid(idmap_userns(idmap), id);
>  		if (!uid_valid(*uid))
>  			ret = -ERANGE;
>  	}
> @@ -752,7 +765,7 @@ int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size
>  	if (!nfs_map_string_to_numeric(name, namelen, &id))
>  		ret = nfs_idmap_lookup_id(name, namelen, "gid", &id, idmap);
>  	if (ret == 0) {
> -		*gid = make_kgid(&init_user_ns, id);
> +		*gid = make_kgid(idmap_userns(idmap), id);
>  		if (!gid_valid(*gid))
>  			ret = -ERANGE;
>  	}
> @@ -766,7 +779,7 @@ int nfs_map_uid_to_name(const struct nfs_server *server, kuid_t uid, char *buf,
>  	int ret = -EINVAL;
>  	__u32 id;
>  
> -	id = from_kuid(&init_user_ns, uid);
> +	id = from_kuid_munged(idmap_userns(idmap), uid);
>  	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
>  		ret = nfs_idmap_lookup_name(id, "user", buf, buflen, idmap);
>  	if (ret < 0)
> @@ -780,7 +793,7 @@ int nfs_map_gid_to_group(const struct nfs_server *server, kgid_t gid, char *buf,
>  	int ret = -EINVAL;
>  	__u32 id;
>  
> -	id = from_kgid(&init_user_ns, gid);
> +	id = from_kgid_munged(idmap_userns(idmap), gid);
>  	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
>  		ret = nfs_idmap_lookup_name(id, "group", buf, buflen, idmap);
>  	if (ret < 0)
> -- 
> 2.21.0
