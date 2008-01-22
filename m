From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: parenthesize NFS_*(inode) parameters
Date: Tue, 22 Jan 2008 11:58:51 -0500
Message-ID: <126C1947-AB76-4C93-95F7-2787081DBEC3@oracle.com>
References: <1201012083-9860-1-git-send-email-bhalevy@panasas.com>
	<1201013438.30335.5.camel@heimdal.trondhjem.org>
	<47960DA7.1010203@panasas.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset="us-ascii"
Cc: NFSv4@linux-nfs.org, linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <47960DA7.1010203@panasas.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Benny-

On Jan 22, 2008, at 10:37 AM, Benny Halevy wrote:
> On Jan. 22, 2008, 16:50 +0200, Trond Myklebust  
> <Trond.Myklebust@netapp.com> wrote:
>> On Tue, 2008-01-22 at 16:28 +0200, Benny Halevy wrote:
>>> Otherwise e.g., NFS_SERVER(&nfsi->vfs_inode) does not compile.
>>>
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>> ---
>>>  include/linux/nfs_fs.h |    4 ++--
>>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>>> index 0477a4c..5a5d3fe 100644
>>> --- a/include/linux/nfs_fs.h
>>> +++ b/include/linux/nfs_fs.h
>>> @@ -221,10 +221,10 @@ static inline struct nfs_inode *NFS_I 
>>> (struct inode *inode)
>>>  {
>>>  	return container_of(inode, struct nfs_inode, vfs_inode);
>>>  }
>>> -#define NFS_SB(s)		((struct nfs_server *)(s->s_fs_info))
>>> +#define NFS_SB(s)		((struct nfs_server *)((s)->s_fs_info))
>>>
>>>  #define NFS_FH(inode)			(&NFS_I(inode)->fh)
>>> -#define NFS_SERVER(inode)		(NFS_SB(inode->i_sb))
>>> +#define NFS_SERVER(inode)		(NFS_SB((inode)->i_sb))
>>>  #define NFS_CLIENT(inode)		(NFS_SERVER(inode)->client)
>>>  #define NFS_PROTO(inode)		(NFS_SERVER(inode)->nfs_client->rpc_ops)
>>>  #define NFS_COOKIEVERF(inode)		(NFS_I(inode)->cookieverf)
>>
>> They should really be converted into inlined functions.
>>
>> Cheers
>>   Trond
>
> Agreed.  How about the following:
> ---
> [PATCH] nfs: convert NFS_*(inode) helpers to static inline
>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> (Patch passes all connectathon tests)
>
>  fs/nfs/dir.c           |    8 ++--
>  fs/nfs/inode.c         |    8 ++--
>  fs/nfs/read.c          |    2 +-
>  include/linux/nfs_fs.h |   78 ++++++++++++++++++++++++++++++++++++ 
> +----------
>  4 files changed, 70 insertions(+), 26 deletions(-)
>
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index f697b5c..7b64c22 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -192,7 +192,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t  
> *desc, struct page *page)
>  		/* We requested READDIRPLUS, but the server doesn't grok it */
>  		if (error == -ENOTSUPP && desc->plus) {
>  			NFS_SERVER(inode)->caps &= ~NFS_CAP_READDIRPLUS;
> -			clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
> +			clear_bit(NFS_INO_ADVISE_RDPLUS, NFS_FLAGSP(inode));

Since you already have NFS_USE_READDIRPLUS defined below, maybe the  
equivalent clear_bit functionality can also be an inlined function.   
It is even used in more than one place.

I feel like NFS_FLAGSP (returning a pointer) is somewhat awkward, but  
that's just my taste I suppose.

>  			desc->plus = 0;
>  			goto again;
>  		}
> @@ -579,7 +579,7 @@ static int nfs_readdir(struct file *filp, void  
> *dirent, filldir_t filldir)
>  			break;
>  		}
>  		if (res == -ETOOSMALL && desc->plus) {
> -			clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
> +			clear_bit(NFS_INO_ADVISE_RDPLUS, NFS_FLAGSP(inode));
>  			nfs_zap_caches(inode);
>  			desc->plus = 0;
>  			desc->entry->eof = 0;
> @@ -1731,7 +1731,7 @@ static void __nfs_access_zap_cache(struct  
> inode *inode)
>  void nfs_access_zap_cache(struct inode *inode)
>  {
>  	/* Remove from global LRU init */
> -	if (test_and_clear_bit(NFS_INO_ACL_LRU_SET, &NFS_FLAGS(inode))) {
> +	if (test_and_clear_bit(NFS_INO_ACL_LRU_SET, NFS_FLAGSP(inode))) {
>  		spin_lock(&nfs_access_lru_lock);
>  		list_del_init(&NFS_I(inode)->access_cache_inode_lru);
>  		spin_unlock(&nfs_access_lru_lock);
> @@ -1845,7 +1845,7 @@ static void nfs_access_add_cache(struct inode  
> *inode, struct nfs_access_entry *s
>  	smp_mb__after_atomic_inc();
>
>  	/* Add inode to global LRU list */
> -	if (!test_and_set_bit(NFS_INO_ACL_LRU_SET, &NFS_FLAGS(inode))) {
> +	if (!test_and_set_bit(NFS_INO_ACL_LRU_SET, NFS_FLAGSP(inode))) {
>  		spin_lock(&nfs_access_lru_lock);
>  		list_add_tail(&NFS_I(inode)->access_cache_inode_lru,  
> &nfs_access_lru_list);
>  		spin_unlock(&nfs_access_lru_lock);
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index db5d96d..9c5e6f7 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -192,7 +192,7 @@ void nfs_invalidate_atime(struct inode *inode)
>   */
>  static void nfs_invalidate_inode(struct inode *inode)
>  {
> -	set_bit(NFS_INO_STALE, &NFS_FLAGS(inode));
> +	set_bit(NFS_INO_STALE, NFS_FLAGSP(inode));

Likewise for NFS_INO_STALE... A separate inline for setting  
NFS_INO_STALE might be a little nicer.

>  	nfs_zap_caches_locked(inode);
>  }
>
> @@ -229,7 +229,7 @@ nfs_init_locked(struct inode *inode, void *opaque)
>  	struct nfs_find_desc	*desc = (struct nfs_find_desc *)opaque;
>  	struct nfs_fattr	*fattr = desc->fattr;
>
> -	NFS_FILEID(inode) = fattr->fileid;
> +	set_nfs_fileid(inode, fattr->fileid);
>  	nfs_copy_fh(NFS_FH(inode), desc->fh);
>  	return 0;
>  }
> @@ -291,7 +291,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh  
> *fh, struct nfs_fattr *fattr)
>  			inode->i_fop = &nfs_dir_operations;
>  			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS)
>  			    && fattr->size <= NFS_LIMIT_READDIRPLUS)
> -				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
> +				set_bit(NFS_INO_ADVISE_RDPLUS, NFS_FLAGSP(inode));

And for setting NFS_INO_ADVISE_RDPLUS.

>  			/* Deal with crossing mountpoints */
>  			if (!nfs_fsid_equal(&NFS_SB(sb)->fsid, &fattr->fsid)) {
>  				if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
> @@ -659,7 +659,7 @@ __nfs_revalidate_inode(struct nfs_server  
> *server, struct inode *inode)
>  		if (status == -ESTALE) {
>  			nfs_zap_caches(inode);
>  			if (!S_ISDIR(inode->i_mode))
> -				set_bit(NFS_INO_STALE, &NFS_FLAGS(inode));
> +				set_bit(NFS_INO_STALE, NFS_FLAGSP(inode));
>  		}
>  		goto out;
>  	}
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index 4587a86..02f2d36 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -338,7 +338,7 @@ int nfs_readpage_result(struct rpc_task *task,  
> struct nfs_read_data *data)
>  	nfs_add_stats(data->inode, NFSIOS_SERVERREADBYTES, data->res.count);
>
>  	if (task->tk_status == -ESTALE) {
> -		set_bit(NFS_INO_STALE, &NFS_FLAGS(data->inode));
> +		set_bit(NFS_INO_STALE, NFS_FLAGSP(data->inode));
>  		nfs_mark_for_revalidate(data->inode);
>  	}
>  	return 0;
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 2d15d4a..98fd14c 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -196,28 +196,72 @@ struct nfs_inode {
>  #define NFS_INO_STALE		(2)		/* possible stale inode */
>  #define NFS_INO_ACL_LRU_SET	(3)		/* Inode is on the LRU list */
>
> -static inline struct nfs_inode *NFS_I(struct inode *inode)
> +static inline struct nfs_inode *NFS_I(const struct inode *inode)
>  {
>  	return container_of(inode, struct nfs_inode, vfs_inode);
>  }
> -#define NFS_SB(s)		((struct nfs_server *)(s->s_fs_info))
>
> -#define NFS_FH(inode)			(&NFS_I(inode)->fh)
> -#define NFS_SERVER(inode)		(NFS_SB(inode->i_sb))
> -#define NFS_CLIENT(inode)		(NFS_SERVER(inode)->client)
> -#define NFS_PROTO(inode)		(NFS_SERVER(inode)->nfs_client->rpc_ops)
> -#define NFS_COOKIEVERF(inode)		(NFS_I(inode)->cookieverf)
> -#define NFS_MINATTRTIMEO(inode) \
> -	(S_ISDIR(inode->i_mode)? NFS_SERVER(inode)->acdirmin \
> -			       : NFS_SERVER(inode)->acregmin)
> -#define NFS_MAXATTRTIMEO(inode) \
> -	(S_ISDIR(inode->i_mode)? NFS_SERVER(inode)->acdirmax \
> -			       : NFS_SERVER(inode)->acregmax)
> +static inline struct nfs_server *NFS_SB(const struct super_block *s)
> +{
> +	return (struct nfs_server *)(s->s_fs_info);
> +}
>
> -#define NFS_FLAGS(inode)		(NFS_I(inode)->flags)
> -#define NFS_STALE(inode)		(test_bit(NFS_INO_STALE, &NFS_FLAGS 
> (inode)))
> +static inline struct nfs_fh *NFS_FH(const struct inode *inode)
> +{
> +	return &NFS_I(inode)->fh;
> +}

Since these are no longer macros, maybe we should change the case of  
their names too.  I realize NFS_USE_READDIRPLUS has set a precedent,  
but perhaps it's an ugly one we should fix now.

>
> -#define NFS_FILEID(inode)		(NFS_I(inode)->fileid)
> +static inline struct nfs_server *NFS_SERVER(const struct inode  
> *inode)
> +{
> +	return NFS_SB(inode->i_sb);
> +}
> +
> +static inline struct rpc_clnt *NFS_CLIENT(const struct inode *inode)
> +{
> +	return NFS_SERVER(inode)->client;
> +}
> +
> +static inline const struct nfs_rpc_ops *NFS_PROTO(const struct  
> inode *inode)
> +{
> +	return NFS_SERVER(inode)->nfs_client->rpc_ops;
> +}
> +
> +static inline __be32 *NFS_COOKIEVERF(const struct inode *inode)
> +{
> +	return NFS_I(inode)->cookieverf;
> +}
> +
> +static inline unsigned NFS_MINATTRTIMEO(const struct inode *inode)
> +{
> +	struct nfs_server *nfss = NFS_SERVER(inode);
> +	return S_ISDIR(inode->i_mode) ? nfss->acdirmin : nfss->acregmin;
> +}
> +
> +static inline unsigned NFS_MAXATTRTIMEO(const struct inode *inode)
> +{
> +	struct nfs_server *nfss = NFS_SERVER(inode);
> +	return S_ISDIR(inode->i_mode) ? nfss->acdirmax : nfss->acregmax;
> +}
> +
> +static inline unsigned long *NFS_FLAGSP(const struct inode *inode)
> +{
> +	return &NFS_I(inode)->flags;
> +}
> +
> +static inline int NFS_STALE(const struct inode *inode)
> +{
> +	return test_bit(NFS_INO_STALE, NFS_FLAGSP(inode));
> +}
> +
> +static inline __u64 NFS_FILEID(const struct inode *inode)
> +{
> +	return NFS_I(inode)->fileid;
> +}
> +
> +static inline void set_nfs_fileid(struct inode *inode, __u64 fileid)
> +{
> +	NFS_I(inode)->fileid = fileid;
> +}
>
>  static inline void nfs_mark_for_revalidate(struct inode *inode)
>  {
> @@ -237,7 +281,7 @@ static inline int nfs_server_capable(struct  
> inode *inode, int cap)
>
>  static inline int NFS_USE_READDIRPLUS(struct inode *inode)
>  {
> -	return test_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
> +	return test_bit(NFS_INO_ADVISE_RDPLUS, NFS_FLAGSP(inode));
>  }
>
>  static inline void nfs_set_verifier(struct dentry * dentry,  
> unsigned long verf)
>
>
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
