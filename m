From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/2] NFS: Cleanup decode_attr_fs_locations function.
Date: Fri, 17 Oct 2008 14:55:36 -0400
Message-ID: <20081017185536.GC13791@fieldses.org>
References: <1224267468-775-1-git-send-email-dhildeb@us.ibm.com> <1224267468-775-2-git-send-email-dhildeb@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Dean Hildebrand <dhildeb@us.ibm.com>
To: Dean Hildebrand <seattleplus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60062 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753717AbYJQSzi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 14:55:38 -0400
In-Reply-To: <1224267468-775-2-git-send-email-dhildeb@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 17, 2008 at 11:17:48AM -0700, Dean Hildebrand wrote:
> a) Reduce nesting level of loops.
> b) Use correct data types.
> c) Use nloc and nserv instead of n and m variable names.
> d) Try to clean up formatting of debugging statements.
> e) Move while loops to for loops.

Does this also fix a possible infinite loop in the inner loop?

--b.

> 
> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
> ---
>  fs/nfs/nfs4xdr.c |   71 +++++++++++++++++++++++++++++-------------------------
>  1 files changed, 38 insertions(+), 33 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 5e59481..0e78fbd 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -2560,7 +2560,8 @@ out_eio:
>  
>  static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, struct nfs4_fs_locations *res)
>  {
> -	int n;
> +	u32 nloc;
> +	unsigned int i;
>  	__be32 *p;
>  	int status = -EIO;
>  
> @@ -2574,53 +2575,57 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
>  	if (unlikely(status != 0))
>  		goto out;
>  	READ_BUF(4);
> -	READ32(n);
> -	if (n <= 0)
> +	READ32(nloc);
> +	if (nloc <= 0)
>  		goto out_eio;
> -
> -	if (n > NFS4_FS_LOCATIONS_MAXENTRIES) {
> -		dprintk("%s: using first %u of %d fs locations\n",
> -			__func__, NFS4_FS_LOCATIONS_MAXENTRIES, n);
> -		n = NFS4_FS_LOCATIONS_MAXENTRIES;
> +	if (nloc > NFS4_FS_LOCATIONS_MAXENTRIES) {
> +		dprintk("%s: using first %u of %u fs locations\n",
> +			__func__, NFS4_FS_LOCATIONS_MAXENTRIES, nloc);
> +		nloc = NFS4_FS_LOCATIONS_MAXENTRIES;
>  	} else {
> -		dprintk("%s: using %d fs locations\n",
> -			__func__, n);
> +		dprintk("%s: using %u fs locations\n",
> +			__func__, nloc);
>  	}
>  
>  	res->nlocations = 0;
> -	while (res->nlocations < n) {
> -		u32 m;
> -		struct nfs4_fs_location *loc = &res->locations[res->nlocations];
> +	for (i = 0; i < nloc; i++) {
> +		u32 nserv;
> +		unsigned int totalserv, j;
> +		struct nfs4_fs_location *loc = &res->locations[i];
>  
>  		READ_BUF(4);
> -		READ32(m);
> +		READ32(nserv);
> +
> +		totalserv = nserv;
> +		if (nserv >  NFS4_FS_LOCATION_MAXSERVERS) {
> +			dprintk("%s: Using first %u of %u servers "
> +				"returned for location %u\n",
> +				__func__, NFS4_FS_LOCATION_MAXSERVERS,
> +				nserv, i);
> +			nserv = NFS4_FS_LOCATION_MAXSERVERS;
> +		}
>  
>  		loc->nservers = 0;
> -		dprintk("%s: servers ", __func__);
> -		while (loc->nservers < m) {
> +		dprintk("%s: Servers ", __func__);
> +		for (j = 0; j < nserv; j++) {
>  			struct nfs4_string *server = &loc->servers[loc->nservers];
>  			status = decode_opaque_inline(xdr, &server->len, &server->data);
>  			if (unlikely(status != 0))
>  				goto out_eio;
>  			dprintk("%s ", server->data);
> -			if (loc->nservers < NFS4_FS_LOCATION_MAXSERVERS)
> -				loc->nservers++;
> -			else {
> -				unsigned int i;
> -				dprintk("%s: using first %u of %u servers "
> -					"returned for location %u\n",
> -						__func__,
> -						NFS4_FS_LOCATION_MAXSERVERS,
> -						m, res->nlocations);
> -				for (i = loc->nservers; i < m; i++) {
> -					unsigned int len;
> -					char *data;
> -					status = decode_opaque_inline(xdr, &len, &data);
> -					if (unlikely(status != 0))
> -						goto out_eio;
> -				}
> -			}
> +			loc->nservers++;
> +		}
> +		dprintk("\n");
> +
> +		/* Decode and ignore overflow servers */
> +		for (j = loc->nservers; j < totalserv; j++) {
> +			unsigned int len;
> +			char *data;
> +			status = decode_opaque_inline(xdr, &len, &data);
> +			if (unlikely(status != 0))
> +				goto out_eio;
>  		}
> +
>  		status = decode_pathname(xdr, &loc->rootpath);
>  		if (unlikely(status != 0))
>  			goto out_eio;
> -- 
> 1.5.3.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
