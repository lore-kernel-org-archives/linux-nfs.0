From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 10/51] nfsd41: sessionid hashing
Date: Mon, 17 Nov 2008 15:58:50 +0200
Message-ID: <4921789A.6090502@panasas.com>
References: <491895A0.3040809@panasas.com> <1226349842-10469-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:14483 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752122AbYKQN6x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:58:53 -0500
In-Reply-To: <1226349842-10469-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:44 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Marc Eshel <eshel@almaden.ibm.com>
> 
> Use crc32 of sessionid to look it up on the server.
> Select CRC32 when NFSD_V4_1 is selected in fs/Kconfig.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/Kconfig          |    1 +
>  fs/nfsd/nfs4state.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 52 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index aee944e..cb0e3de 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -1320,6 +1320,7 @@ config NFSD_V4
>  config NFSD_V4_1
>  	bool "NFS server support for NFSv4.1 (EXPERIMENTAL)"
>  	depends on NFSD_V4 && EXPERIMENTAL
> +	select CRC32
>  	help
>  	  This option enables support for minor version 1 of the NFSv4 protocol
>  	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS server.
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index bf4d2c2..0e1bc72 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -52,6 +52,7 @@
>  #include <linux/namei.h>
>  #include <linux/swap.h>
>  #include <linux/mutex.h>
> +#include <linux/crc32.h>
>  #include <linux/lockd/bind.h>
>  #include <linux/module.h>
>  
> @@ -311,6 +312,52 @@ static struct list_head client_lru;
>  static struct list_head close_lru;
>  
>  #if defined(CONFIG_NFSD_V4_1)
> +/* Use a prime for hash table size */
> +#define SESSION_HASH_SIZE	1031

review 11-12: reduce to 512

> +static struct list_head sessionid_hashtbl[SESSION_HASH_SIZE];
> +
> +static int
> +hash_sessionid(nfs41_sessionid *sessionid)
> +{
> +	u32 csum = 0;
> +	int idx;
> +
> +	csum = crc32(0, sessionid, sizeof(*sessionid));

why use crc32?
re-use one of the available in linux/hash.h

> +	idx = csum % SESSION_HASH_SIZE;
> +	dprintk("%s IDX: %u csum %u\n", __func__, idx, csum);

ditch that

> +	return idx;
> +}
> +
> +static inline void
> +dump_sessionid(const char *fn, nfs41_sessionid *sessionid)
> +{
> +	u32 *ptr = (u32 *)(*sessionid);
> +	dprintk("%s: %u:%u:%u:%u\n", fn, ptr[0], ptr[1], ptr[2], ptr[3]);
> +}
> +
> +struct nfs41_session *
> +find_in_sessionid_hashtbl(nfs41_sessionid *sessionid)
> +{
> +	struct nfs41_session *elem;
> +	int idx;
> +
> +	dump_sessionid(__func__, sessionid);
> +	idx = hash_sessionid(sessionid);
> +	dprintk("%s: idx is %d\n", __func__, idx);
> +	/* Search in the appropriate list */
> +	list_for_each_entry(elem, &sessionid_hashtbl[idx], se_hash) {
> +		dump_sessionid("list traversal", &elem->se_sessionid);
> +		if (!memcmp(elem->se_sessionid, sessionid,
> +			    sizeof(nfs41_sessionid))) {
> +			dprintk("%s: found session %p\n", __func__, elem);

can probably get rid of the dprintk

> +			return elem;
> +		}
> +	}
> +
> +	dprintk("%s: session not found\n", __func__);
> +	return NULL;
> +}
> +
>  static void
>  destroy_session(struct nfs41_session *ses)
>  {
> @@ -3154,6 +3201,10 @@ nfs4_state_init(void)
>  		INIT_LIST_HEAD(&unconf_str_hashtbl[i]);
>  		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
>  	}
> +#if defined(CONFIG_NFSD_V4_1)
> +	for (i = 0; i < SESSION_HASH_SIZE; i++)
> +		INIT_LIST_HEAD(&sessionid_hashtbl[i]);
> +#endif /* CONFIG_NFSD_V4_1 */
>  	for (i = 0; i < FILE_HASH_SIZE; i++) {
>  		INIT_LIST_HEAD(&file_hashtbl[i]);
>  	}
