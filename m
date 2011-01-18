From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2] nfsd: kill unused macro definition
Date: Tue, 18 Jan 2011 16:58:11 -0500
Message-ID: <20110118215811.GE10903@fieldses.org>
References: <4D300BA8.80000@cn.fujitsu.com>
 <4D3018FF.1010105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60574 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750923Ab1ARV6Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Jan 2011 16:58:16 -0500
In-Reply-To: <4D3018FF.1010105@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 14, 2011 at 05:35:59PM +0800, Shan Wei wrote:
> These macros had never been used for several years.
> So, remove them.

Thanks, applying.--b.

> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
> V2: add two other unused macros, EXPORT_HASHMASK and FILE_HASH_MASK.
>  
> ---
>  fs/nfsd/export.c    |    1 -
>  fs/nfsd/nfs4idmap.c |    1 -
>  fs/nfsd/nfs4state.c |    2 +-
>  3 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index c0fcb7a..98a964a 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -300,7 +300,6 @@ svc_expkey_update(struct svc_expkey *new, struct svc_expkey *old)
>  
>  #define	EXPORT_HASHBITS		8
>  #define	EXPORT_HASHMAX		(1<< EXPORT_HASHBITS)
> -#define	EXPORT_HASHMASK		(EXPORT_HASHMAX -1)
>  
>  static struct cache_head *export_table[EXPORT_HASHMAX];
>  
> diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
> index f0695e8..ce0f6b9 100644
> --- a/fs/nfsd/nfs4idmap.c
> +++ b/fs/nfsd/nfs4idmap.c
> @@ -62,7 +62,6 @@ struct ent {
>  
>  #define ENT_HASHBITS          8
>  #define ENT_HASHMAX           (1 << ENT_HASHBITS)
> -#define ENT_HASHMASK          (ENT_HASHMAX - 1)
>  
>  static void
>  ent_init(struct cache_head *cnew, struct cache_head *citm)
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index fbd18c3..547fbc6 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -148,7 +148,7 @@ static struct list_head	ownerstr_hashtbl[OWNER_HASH_SIZE];
>  /* hash table for nfs4_file */
>  #define FILE_HASH_BITS                   8
>  #define FILE_HASH_SIZE                  (1 << FILE_HASH_BITS)
> -#define FILE_HASH_MASK                  (FILE_HASH_SIZE - 1)
> +
>  /* hash table for (open)nfs4_stateid */
>  #define STATEID_HASH_BITS              10
>  #define STATEID_HASH_SIZE              (1 << STATEID_HASH_BITS)
> -- 
> 1.6.3.3
