Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tundra.namei.org ([65.99.196.166]:39924 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752374Ab3EBXeR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 19:34:17 -0400
Date: Fri, 3 May 2013 09:37:47 +1000 (EST)
From: James Morris <jmorris@namei.org>
To: Steve Dickson <SteveD@redhat.com>
cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 14/17] NFS: Extend NFS xattr handlers to accept the
 security namespace
In-Reply-To: <1367515151-31015-15-git-send-email-SteveD@redhat.com>
Message-ID: <alpine.LRH.2.02.1305030937410.1113@tundra.namei.org>
References: <1367515151-31015-1-git-send-email-SteveD@redhat.com> <1367515151-31015-15-git-send-email-SteveD@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2 May 2013, Steve Dickson wrote:

> From: David Quigley <dpquigl@davequigley.com>
> 
> The existing NFSv4 xattr handlers do not accept xattr calls to the security
> namespace. This patch extends these handlers to accept xattrs from the security
> namespace in addition to the default NFSv4 ACL namespace.
> 
> Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
> Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
> Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
> Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>

Acked-by: James Morris <james.l.morris@oracle.com>


> ---
>  fs/nfs/nfs4proc.c   | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  security/security.c |  1 +
>  2 files changed, 51 insertions(+)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 0e5b319..7b65c99 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5518,6 +5518,53 @@ static size_t nfs4_xattr_list_nfs4_acl(struct dentry *dentry, char *list,
>  	return len;
>  }
>  
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +static inline int nfs4_server_supports_labels(struct nfs_server *server)
> +{
> +	return server->caps & NFS_CAP_SECURITY_LABEL;
> +}
> +
> +static int nfs4_xattr_set_nfs4_label(struct dentry *dentry, const char *key,
> +				   const void *buf, size_t buflen,
> +				   int flags, int type)
> +{
> +	if (security_ismaclabel(key))
> +		return nfs4_set_security_label(dentry, buf, buflen);
> +
> +	return -EOPNOTSUPP;
> +}
> +
> +static int nfs4_xattr_get_nfs4_label(struct dentry *dentry, const char *key,
> +				   void *buf, size_t buflen, int type)
> +{
> +	if (security_ismaclabel(key))
> +		return nfs4_get_security_label(dentry->d_inode, buf, buflen);
> +	return -EOPNOTSUPP;
> +}
> +
> +static size_t nfs4_xattr_list_nfs4_label(struct dentry *dentry, char *list,
> +				       size_t list_len, const char *name,
> +				       size_t name_len, int type)
> +{
> +	size_t len = 0;
> +
> +	if (nfs_server_capable(dentry->d_inode, NFS_CAP_SECURITY_LABEL)) {
> +		len = security_inode_listsecurity(dentry->d_inode, NULL, 0);
> +		if (list && len <= list_len)
> +			security_inode_listsecurity(dentry->d_inode, list, len);
> +	}
> +	return len;
> +}
> +
> +static const struct xattr_handler nfs4_xattr_nfs4_label_handler = {
> +	.prefix = XATTR_SECURITY_PREFIX,
> +	.list	= nfs4_xattr_list_nfs4_label,
> +	.get	= nfs4_xattr_get_nfs4_label,
> +	.set	= nfs4_xattr_set_nfs4_label,
> +};
> +#endif
> +
> +
>  /*
>   * nfs_fhget will use either the mounted_on_fileid or the fileid
>   */
> @@ -7270,6 +7317,9 @@ static const struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
>  
>  const struct xattr_handler *nfs4_xattr_handlers[] = {
>  	&nfs4_xattr_nfs4_acl_handler,
> +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> +	&nfs4_xattr_nfs4_label_handler,
> +#endif
>  	NULL
>  };
>  
> diff --git a/security/security.c b/security/security.c
> index df8ade2..758af6b 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -660,6 +660,7 @@ int security_inode_listsecurity(struct inode *inode, char *buffer, size_t buffer
>  		return 0;
>  	return security_ops->inode_listsecurity(inode, buffer, buffer_size);
>  }
> +EXPORT_SYMBOL(security_inode_listsecurity);
>  
>  void security_inode_getsecid(const struct inode *inode, u32 *secid)
>  {
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
James Morris
<jmorris@namei.org>
