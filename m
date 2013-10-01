Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751812Ab3JAWOg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Oct 2013 18:14:36 -0400
Date: Tue, 1 Oct 2013 18:14:34 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 10/49] pnfsd: use sbid hash table to map
 super_blocks to devid major identifiers
Message-ID: <20131001221433.GB30994@pad.fieldses.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220831-13136-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380220831-13136-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

See previous comments.  What guarantees these superblock pointers stay
good as long as they're in the cache?

--b.

On Thu, Sep 26, 2013 at 02:40:31PM -0400, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@panasas.com>
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [pnfsd: alloc_sid should kmalloc a object not a pointer]
> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4pnfsd.c | 120 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/pnfsd.h     |   2 +
>  2 files changed, 122 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index cb28207..9a7cbc9 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -25,3 +25,123 @@
>  
>  #define NFSDDBG_FACILITY                NFSDDBG_PNFS
>  
> +static DEFINE_SPINLOCK(layout_lock);
> +
> +/* hash table for nfsd4_pnfs_deviceid.sbid */
> +#define SBID_HASH_BITS	8
> +#define SBID_HASH_SIZE	(1 << SBID_HASH_BITS)
> +#define SBID_HASH_MASK	(SBID_HASH_SIZE - 1)
> +
> +struct sbid_tracker {
> +	u64 id;
> +	struct super_block *sb;
> +	struct list_head hash;
> +};
> +
> +static u64 current_sbid;
> +static struct list_head sbid_hashtbl[SBID_HASH_SIZE];
> +
> +static unsigned long
> +sbid_hashval(struct super_block *sb)
> +{
> +	return hash_ptr(sb, SBID_HASH_BITS);
> +}
> +
> +static struct sbid_tracker *
> +alloc_sbid(void)
> +{
> +	return kmalloc(sizeof(struct sbid_tracker), GFP_KERNEL);
> +}
> +
> +static void
> +destroy_sbid(struct sbid_tracker *sbid)
> +{
> +	spin_lock(&layout_lock);
> +	list_del(&sbid->hash);
> +	spin_unlock(&layout_lock);
> +	kfree(sbid);
> +}
> +
> +void
> +nfsd4_free_pnfs_slabs(void)
> +{
> +	int i;
> +	struct sbid_tracker *sbid;
> +
> +	for (i = 0; i < SBID_HASH_SIZE; i++) {
> +		while (!list_empty(&sbid_hashtbl[i])) {
> +			sbid = list_first_entry(&sbid_hashtbl[i],
> +						struct sbid_tracker,
> +						hash);
> +			destroy_sbid(sbid);
> +		}
> +	}
> +}
> +
> +int
> +nfsd4_init_pnfs_slabs(void)
> +{
> +	int i;
> +
> +	for (i = 0; i < SBID_HASH_SIZE; i++)
> +		INIT_LIST_HEAD(&sbid_hashtbl[i]);
> +
> +	return 0;
> +}
> +
> +static u64
> +alloc_init_sbid(struct super_block *sb)
> +{
> +	struct sbid_tracker *sbid;
> +	struct sbid_tracker *new = alloc_sbid();
> +	unsigned long hash_idx = sbid_hashval(sb);
> +	u64 id = 0;
> +
> +	if (likely(new)) {
> +		spin_lock(&layout_lock);
> +		id = ++current_sbid;
> +		new->id = (id << SBID_HASH_BITS) | (hash_idx & SBID_HASH_MASK);
> +		id = new->id;
> +		BUG_ON(id == 0);
> +		new->sb = sb;
> +
> +		list_for_each_entry (sbid, &sbid_hashtbl[hash_idx], hash)
> +			if (sbid->sb == sb) {
> +				kfree(new);
> +				id = sbid->id;
> +				spin_unlock(&layout_lock);
> +				return id;
> +			}
> +		list_add(&new->hash, &sbid_hashtbl[hash_idx]);
> +		spin_unlock(&layout_lock);
> +	}
> +	return id;
> +}
> +
> +static u64
> +find_create_sbid(struct super_block *sb)
> +{
> +	struct sbid_tracker *sbid;
> +	unsigned long hash_idx = sbid_hashval(sb);
> +	int pos = 0;
> +	u64 id = 0;
> +
> +	spin_lock(&layout_lock);
> +	list_for_each_entry (sbid, &sbid_hashtbl[hash_idx], hash) {
> +		pos++;
> +		if (sbid->sb != sb)
> +			continue;
> +		if (pos > 1) {
> +			list_del(&sbid->hash);
> +			list_add(&sbid->hash, &sbid_hashtbl[hash_idx]);
> +		}
> +		id = sbid->id;
> +		break;
> +	}
> +	spin_unlock(&layout_lock);
> +
> +	if (!id)
> +		id = alloc_init_sbid(sb);
> +
> +	return id;
> +}
> diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
> index 7c46791..29ea2e7 100644
> --- a/fs/nfsd/pnfsd.h
> +++ b/fs/nfsd/pnfsd.h
> @@ -36,4 +36,6 @@
>  
>  #include <linux/nfsd/nfsd4_pnfs.h>
>  
> +#include "xdr4.h"
> +
>  #endif /* LINUX_NFSD_PNFSD_H */
> -- 
> 1.8.3.1
> 
