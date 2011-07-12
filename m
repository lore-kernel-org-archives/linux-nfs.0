Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56770 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753247Ab1GLLJw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 07:09:52 -0400
Date: Tue, 12 Jul 2011 07:09:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2 v3] nfsd41: error out when client sets maxreq_sz
 or, maxresp_sz too small
Message-ID: <20110712110950.GC2162@fieldses.org>
References: <4E0EDE78.1060208@cn.fujitsu.com>
 <20110706162650.GB30349@fieldses.org>
 <4E17CE8C.8000504@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E17CE8C.8000504@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jul 09, 2011 at 11:44:12AM +0800, Mi Jinlong wrote:
> According to RFC5661, 18.36.3, 
> 
>  "if the client selects a value for ca_maxresponsesize such that
>   a replier on a channel could never send a response,the server
>   SHOULD return NFS4ERR_TOOSMALL in the CREATE_SESSION reply."
> 
> This patch let server error out when client sets maxreq_sz less than
> SEQUENCE request size, and maxresp_sz less than a SEQUENCE reply size.
> 
> v3:
>     use constant for min request size and min response size,
>     add two function for channel attrs checking(back channel checking
>     not be implement),
>     move size check from xdr create_session to nfsd4_create_session,
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4state.c |   33 +++++++++++++++++++++++++++++++++
>  1 files changed, 33 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e98f3c2..e30bf37 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1507,6 +1507,34 @@ nfsd4_replay_create_session(struct nfsd4_create_session *cr_ses,
>  	return slot->sl_status;
>  }
>  
> +#define NFSD_MIN_REQ_HDR_SEQ_SZ	((\
> +			2 * 2 + /* credential,verifier: AUTH_NULL, length 0 */ \
> +			1 +	/* MIN tag is length with zero, only length */ \
> +			3 +	/* version, opcount, opcode */ \
> +			XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + \
> +				/* seqid, slotID, slotID, cache */ \
> +			4 ) * sizeof(__be32))
> +
> +#define NFSD_MIN_RESP_HDR_SEQ_SZ ((\
> +			2 +	/* verifier: AUTH_NULL, length 0 */\
> +			1 +	/* status */ \
> +			1 +	/* MIN tag is length with zero, only length */ \
> +			3 +	/* opcount, opcode, opstatus*/ \
> +			XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + \
> +				/* seqid, slotID, slotID, slotID, status */ \
> +			5 ) * sizeof(__be32))
> +
> +static __be32 check_forechannel_attrs(struct nfsd4_channel_attrs fchannel)
> +{
> +	return fchannel.maxreq_sz < NFSD_MIN_REQ_HDR_SEQ_SZ
> +		|| fchannel.maxresp_sz < NFSD_MIN_RESP_HDR_SEQ_SZ;
> +}
> +
> +static __be32 check_backchannel_attrs(struct nfsd4_channel_attrs bchannel)
> +{
> +	return 0;
> +}

Let's not bother with check_backchannel_attrs() until it actually does
something.

Other than that, this looks fine.--b.

> +
>  __be32
>  nfsd4_create_session(struct svc_rqst *rqstp,
>  		     struct nfsd4_compound_state *cstate,
> @@ -1575,6 +1603,11 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  	cr_ses->flags &= ~SESSION4_PERSIST;
>  	cr_ses->flags &= ~SESSION4_RDMA;
>  
> +	status = nfserr_toosmall;
> +	if (check_forechannel_attrs(cr_ses->fore_channel)
> +	    || check_backchannel_attrs(cr_ses->back_channel))
> +		goto out;
> +
>  	status = nfserr_jukebox;
>  	new = alloc_init_session(rqstp, conf, cr_ses);
>  	if (!new)
> -- 
> 1.7.5.4
> 
> 
