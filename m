Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:45113 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400Ab3BOVPM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2013 16:15:12 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH RFC] nfsd: report length of the largest hash chain in reply cache stats
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1360958672-5692-1-git-send-email-jlayton@redhat.com>
Date: Fri, 15 Feb 2013 16:14:56 -0500
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Message-Id: <299C8DF9-5BFC-4E26-8F7E-CE3415D1140F@oracle.com>
References: <20130215133406.20b1ef09@tlielax.poochiereds.net> <1360958672-5692-1-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 15, 2013, at 3:04 PM, Jeff Layton <jlayton@redhat.com> wrote:

> So we can get a feel for how effective the hashing function is.
> 
> As Chuck Lever pointed out to me, it's generally acceptable to do
> "expensive" stuff when reading the stats since that's a relatively
> rare activity.

A good measure of the efficacy of a hash function is the ratio of the maximum chain length to the optimal chain length (which can be computed by dividing the total number of cache entries by the number of hash chains).

If we plan to stick with a hash table for this cache, there should be some indication when the hash function falls over.  This will matter because the DRC can now grow much larger, which is turning out to be the real fundamental change with this work.

A philosophical question though is "How can we know when the DRC is large enough?"


> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfsd/nfscache.c | 20 ++++++++++++++++++++
> 1 file changed, 20 insertions(+)
> 
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index a5ac9ab..172e211 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -551,6 +551,25 @@ nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *data)
> 	return 1;
> }
> 
> +/* Get stats on the hashtable itself */
> +static unsigned int
> +nfsd_repcache_max_chain_len(void)
> +{
> +	int i;
> +	struct hlist_node *pos;
> +	unsigned int max = 0;
> +
> +	for (i = 0; i < HASHSIZE; ++i) {
> +		unsigned int cur = 0;
> +
> +		hlist_for_each(pos, &cache_hash[i])
> +			++cur;
> +		max = max(cur, max);
> +	}
> +
> +	return max;
> +}
> +
> /*
>  * Note that fields may be added, removed or reordered in the future. Programs
>  * scraping this file for info should test the labels to ensure they're
> @@ -566,6 +585,7 @@ static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
> 	seq_printf(m, "cache misses:    %u\n", nfsdstats.rcmisses);
> 	seq_printf(m, "not cached:      %u\n", nfsdstats.rcnocache);
> 	seq_printf(m, "checksum misses: %u\n", csum_misses);
> +	seq_printf(m, "max chain len:   %u\n", nfsd_repcache_max_chain_len());
> 	spin_unlock(&cache_lock);
> 	return 0;
> }
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




