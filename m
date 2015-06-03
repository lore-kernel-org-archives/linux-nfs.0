Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56990 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752863AbbFCSnH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2015 14:43:07 -0400
Date: Wed, 3 Jun 2015 14:43:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 5/5 v3] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150603184306.GB9627@fieldses.org>
References: <556D0654.7020504@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <556D0654.7020504@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Al?  Does this seem like a sane use of the new fs_pin stuff?

(If so, we could use an ACK of those exports.)

--b.

On Tue, Jun 02, 2015 at 09:26:44AM +0800, Kinglong Mee wrote:
> If there are some mount points(not exported for nfs) under pseudo root,
> after client's operation of those entry under the root, anyone *can't*
> unmount those mount points until export cache expired.
> 
> /nfs/xfs        *(rw,insecure,no_subtree_check,no_root_squash)
> /nfs/pnfs       *(rw,insecure,no_subtree_check,no_root_squash)
> total 0
> drwxr-xr-x. 3 root root 84 Apr 21 22:27 pnfs
> drwxr-xr-x. 3 root root 84 Apr 21 22:27 test
> drwxr-xr-x. 2 root root  6 Apr 20 22:01 xfs
> Filesystem                      1K-blocks    Used Available Use% Mounted on
> ......
> /dev/sdd                          1038336   32944   1005392   4% /nfs/pnfs
> /dev/sdc                         10475520   32928  10442592   1% /nfs/xfs
> /dev/sde                           999320    1284    929224   1% /nfs/test
> /mnt/pnfs/:
> total 0
> -rw-r--r--. 1 root root 0 Apr 21 22:23 attr
> drwxr-xr-x. 2 root root 6 Apr 21 22:19 tmp
> 
> /mnt/xfs/:
> total 0
> umount: /nfs/test/: target is busy
>         (In some cases useful info about processes that
> 	use the device is found by lsof(8) or fuser(1).)
> 
> It's caused by exports cache of nfsd holds the reference of
> the path (here is /nfs/test/), so, it can't be umounted.
> 
> I don't think that's user expect, they want umount /nfs/test/.
> Bruce think user can also umount /nfs/pnfs/ and /nfs/xfs.
> 
> Also, using kzalloc for all memory allocating without kmalloc.
> 
> v1 --> v3:
> 1. using path_get_pin/path_put_unpin for path pin
> 2. using kzalloc for memory allocating
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/export.c | 38 ++++++++++++++++++++++++++++----------
>  fs/nfsd/export.h | 10 +++++++++-
>  2 files changed, 37 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index f79521a..6cc7b74 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -43,9 +43,9 @@ static void expkey_put(struct kref *ref)
>  
>  	if (test_bit(CACHE_VALID, &key->h.flags) &&
>  	    !test_bit(CACHE_NEGATIVE, &key->h.flags))
> -		path_put(&key->ek_path);
> +		path_put_unpin(&key->ek_path, &key->ek_pin);
>  	auth_domain_put(key->ek_client);
> -	kfree(key);
> +	kfree_rcu(key, rcu_head);
>  }
>  
>  static void expkey_request(struct cache_detail *cd,
> @@ -83,7 +83,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
>  		return -EINVAL;
>  	mesg[mlen-1] = 0;
>  
> -	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +	buf = kzalloc(PAGE_SIZE, GFP_KERNEL);
>  	err = -ENOMEM;
>  	if (!buf)
>  		goto out;
> @@ -120,6 +120,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
>  		goto out;
>  
>  	key.ek_client = dom;	
> +	key.cd = cd;
>  	key.ek_fsidtype = fsidtype;
>  	memcpy(key.ek_fsid, buf, len);
>  
> @@ -210,6 +211,13 @@ static inline void expkey_init(struct cache_head *cnew,
>  	new->ek_fsidtype = item->ek_fsidtype;
>  
>  	memcpy(new->ek_fsid, item->ek_fsid, sizeof(new->ek_fsid));
> +	new->cd = item->cd;
> +}
> +
> +static void expkey_pin_kill(struct fs_pin *pin)
> +{
> +	struct svc_expkey *key = container_of(pin, struct svc_expkey, ek_pin);
> +	cache_force_expire(key->cd, &key->h);
>  }
>  
>  static inline void expkey_update(struct cache_head *cnew,
> @@ -218,13 +226,14 @@ static inline void expkey_update(struct cache_head *cnew,
>  	struct svc_expkey *new = container_of(cnew, struct svc_expkey, h);
>  	struct svc_expkey *item = container_of(citem, struct svc_expkey, h);
>  
> +	init_fs_pin(&new->ek_pin, expkey_pin_kill);
>  	new->ek_path = item->ek_path;
> -	path_get(&item->ek_path);
> +	path_get_pin(&new->ek_path, &new->ek_pin);
>  }
>  
>  static struct cache_head *expkey_alloc(void)
>  {
> -	struct svc_expkey *i = kmalloc(sizeof(*i), GFP_KERNEL);
> +	struct svc_expkey *i = kzalloc(sizeof(*i), GFP_KERNEL);
>  	if (i)
>  		return &i->h;
>  	else
> @@ -309,11 +318,12 @@ static void nfsd4_fslocs_free(struct nfsd4_fs_locations *fsloc)
>  static void svc_export_put(struct kref *ref)
>  {
>  	struct svc_export *exp = container_of(ref, struct svc_export, h.ref);
> -	path_put(&exp->ex_path);
> +
> +	path_put_unpin(&exp->ex_path, &exp->ex_pin);
>  	auth_domain_put(exp->ex_client);
>  	nfsd4_fslocs_free(&exp->ex_fslocs);
>  	kfree(exp->ex_uuid);
> -	kfree(exp);
> +	kfree_rcu(exp, rcu_head);
>  }
>  
>  static void svc_export_request(struct cache_detail *cd,
> @@ -520,7 +530,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
>  		return -EINVAL;
>  	mesg[mlen-1] = 0;
>  
> -	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +	buf = kzalloc(PAGE_SIZE, GFP_KERNEL);
>  	if (!buf)
>  		return -ENOMEM;
>  
> @@ -694,15 +704,22 @@ static int svc_export_match(struct cache_head *a, struct cache_head *b)
>  		path_equal(&orig->ex_path, &new->ex_path);
>  }
>  
> +static void export_pin_kill(struct fs_pin *pin)
> +{
> +	struct svc_export *exp = container_of(pin, struct svc_export, ex_pin);
> +	cache_force_expire(exp->cd, &exp->h);
> +}
> +
>  static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
>  {
>  	struct svc_export *new = container_of(cnew, struct svc_export, h);
>  	struct svc_export *item = container_of(citem, struct svc_export, h);
>  
> +	init_fs_pin(&new->ex_pin, export_pin_kill);
>  	kref_get(&item->ex_client->ref);
>  	new->ex_client = item->ex_client;
>  	new->ex_path = item->ex_path;
> -	path_get(&item->ex_path);
> +	path_get_pin(&new->ex_path, &new->ex_pin);
>  	new->ex_fslocs.locations = NULL;
>  	new->ex_fslocs.locations_count = 0;
>  	new->ex_fslocs.migrated = 0;
> @@ -740,7 +757,7 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
>  
>  static struct cache_head *svc_export_alloc(void)
>  {
> -	struct svc_export *i = kmalloc(sizeof(*i), GFP_KERNEL);
> +	struct svc_export *i = kzalloc(sizeof(*i), GFP_KERNEL);
>  	if (i)
>  		return &i->h;
>  	else
> @@ -811,6 +828,7 @@ exp_find_key(struct cache_detail *cd, struct auth_domain *clp, int fsid_type,
>  
>  	key.ek_client = clp;
>  	key.ek_fsidtype = fsid_type;
> +	key.cd = cd;
>  	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
>  
>  	ek = svc_expkey_lookup(cd, &key);
> diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
> index 1f52bfc..1cf6ada 100644
> --- a/fs/nfsd/export.h
> +++ b/fs/nfsd/export.h
> @@ -4,6 +4,7 @@
>  #ifndef NFSD_EXPORT_H
>  #define NFSD_EXPORT_H
>  
> +#include <linux/fs_pin.h>
>  #include <linux/sunrpc/cache.h>
>  #include <uapi/linux/nfsd/export.h>
>  
> @@ -46,6 +47,8 @@ struct exp_flavor_info {
>  
>  struct svc_export {
>  	struct cache_head	h;
> +	struct cache_detail	*cd;
> +
>  	struct auth_domain *	ex_client;
>  	int			ex_flags;
>  	struct path		ex_path;
> @@ -58,7 +61,9 @@ struct svc_export {
>  	struct exp_flavor_info	ex_flavors[MAX_SECINFO_LIST];
>  	enum pnfs_layouttype	ex_layout_type;
>  	struct nfsd4_deviceid_map *ex_devid_map;
> -	struct cache_detail	*cd;
> +
> +	struct fs_pin		ex_pin;
> +	struct rcu_head		rcu_head;
>  };
>  
>  /* an "export key" (expkey) maps a filehandlefragement to an
> @@ -67,12 +72,15 @@ struct svc_export {
>   */
>  struct svc_expkey {
>  	struct cache_head	h;
> +	struct cache_detail	*cd;
>  
>  	struct auth_domain *	ek_client;
>  	int			ek_fsidtype;
>  	u32			ek_fsid[6];
>  
>  	struct path		ek_path;
> +	struct fs_pin		ek_pin;
> +	struct rcu_head		rcu_head;
>  };
>  
>  #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))
> -- 
> 2.4.2
