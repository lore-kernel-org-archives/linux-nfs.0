Return-Path: <bfields@fieldses.org>
Date: Wed, 21 Feb 2018 19:48:17 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: aglo@umich.edu, bcodding@redhat.com, linux-nfs@vger.kernel.org,
	trondmy@primarydata.com, tigran.mkrtchyan@desy.de
Subject: Re: [PATCH] nfsd4: send the special close_stateid in v4.0 replies as
 well
Message-ID: <20180222004817.GF6535@fieldses.org>
References: <20180215201618.2617-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180215201618.2617-1-jlayton@kernel.org>
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 15, 2018 at 03:16:18PM -0500, Jeff Layton wrote:
> From: Jeff Layton <jlayton@redhat.com>
> 
> We already send it for v4.1, but RFC7530 also notes that the stateid in
> the close reply is bogus.
> 
> Always send the special close stateid, even in v4.0 responses. No client
> should put any meaning on it whatsoever. For now, we continue to
> increment the stateid value, though that might not be necessary either.

Thanks!  Applying for 4.17.--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4state.c | 19 +++++++++++++++----
>  1 file changed, 15 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 150521c9671b..08c700864fee 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -5481,15 +5481,26 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		goto out; 
>  
>  	stp->st_stid.sc_type = NFS4_CLOSED_STID;
> +
> +	/*
> +	 * Technically we don't _really_ have to increment or copy it, since
> +	 * it should just be gone after this operation and we clobber the
> +	 * copied value below, but we continue to do so here just to ensure
> +	 * that racing ops see that there was a state change.
> +	 */
>  	nfs4_inc_and_copy_stateid(&close->cl_stateid, &stp->st_stid);
>  
>  	nfsd4_close_open_stateid(stp);
>  	mutex_unlock(&stp->st_mutex);
>  
> -	/* See RFC5661 sectionm 18.2.4 */
> -	if (stp->st_stid.sc_client->cl_minorversion)
> -		memcpy(&close->cl_stateid, &close_stateid,
> -				sizeof(close->cl_stateid));
> +	/* v4.1+ suggests that we send a special stateid in here, since the
> +	 * clients should just ignore this anyway. Since this is not useful
> +	 * for v4.0 clients either, we set it to the special close_stateid
> +	 * universally.
> +	 *
> +	 * See RFC5661 section 18.2.4, and RFC7530 section 16.2.5
> +	 */
> +	memcpy(&close->cl_stateid, &close_stateid, sizeof(close->cl_stateid));
>  
>  	/* put reference from nfs4_preprocess_seqid_op */
>  	nfs4_put_stid(&stp->st_stid);
> -- 
> 2.14.3
