From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 14/51] nfsd41: introduce nfs41_{get,set}_slot_state
Date: Mon, 17 Nov 2008 16:01:25 +0200
Message-ID: <49217935.1060307@panasas.com>
References: <491895A0.3040809@panasas.com> <1226349925-10621-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:18142 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751692AbYKQOB2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:01:28 -0500
In-Reply-To: <1226349925-10621-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:45 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Marc Eshel <eshel@almaden.ibm.com>
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

review 11-12: change slot state into a bitmap
do not need atomic ops since done under the state lock.

> ---
>  fs/nfsd/nfs4state.c        |   12 ++++++++++++
>  include/linux/nfsd/state.h |    3 +++
>  2 files changed, 15 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index dcb075d..23e83e2 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -321,6 +321,18 @@ static struct list_head close_lru;
>  #define SESSION_HASH_SIZE	1031
>  static struct list_head sessionid_hashtbl[SESSION_HASH_SIZE];
>  
> +int
> +nfs41_get_slot_state(struct nfs41_slot *slot)
> +{
> +	return atomic_read(&slot->sl_state);
> +}
> +
> +void
> +nfs41_set_slot_state(struct nfs41_slot *slot, int state)
> +{
> +	atomic_set(&slot->sl_state, state);
> +}
> +
>  static int
>  hash_sessionid(nfs41_sessionid *sessionid)
>  {
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index 7684188..85cdaf1 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -356,6 +356,9 @@ struct nfs4_stateid {
>  	((err) != nfserr_stale_stateid) &&      \
>  	((err) != nfserr_bad_stateid))
>  
> +#if defined(CONFIG_NFSD_V4_1)
> +extern void nfs41_set_slot_state(struct nfs41_slot *, int);
> +#endif /* CONFIG_NFSD_V4_1 */
>  extern __be32 nfs4_preprocess_stateid_op(struct svc_fh *current_fh,
>  		stateid_t *stateid, int flags, struct file **filp);
>  extern void nfs4_lock_state(void);
