From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: server 4.1 issues list
Date: Thu, 07 Oct 2010 14:10:17 -0400
Message-ID: <4CAE0D09.5040704@panasas.com>
References: <20101007155306.GA28053@fieldses.org> <20101007175424.GA31443@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og106.obsmtp.com ([64.18.0.182]:42583 "HELO
	exprod5og106.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753557Ab0JGSKR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Oct 2010 14:10:17 -0400
In-Reply-To: <20101007175424.GA31443@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-10-07 13:54, J. Bruce Fields wrote:
> On Thu, Oct 07, 2010 at 11:53:06AM -0400, bfields wrote:
>> Someone also asked whether we've fixed the backchannel attribute
>> checking.  We haven't, but that should be fairly quick--I'll take a look
>> at it now.
> 
> Actually there's a bit of tedious arithmetic to do here to figure out
> what we need e.g. for the maximum request size.  I'm setting this aside
> for now, so this is up for grabs.

Ack. FWIW :)

> 
> --b.
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 6233917..0f8e90b 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1493,6 +1493,23 @@ nfsd4_replay_create_session(struct nfsd4_create_session *cr_ses,
>  	return slot->sl_status;
>  }
>  
> +static __be32 verify_backchannel_attributes(struct nfsd4_create_session *cr_ses)
> +{
> +	struct nfsd4_channel_attrs *attrs;
> +
> +	if (!cses->flags & SESSION4_BACK_CHAN)
> +		return nfs_ok;
> +	if (attrs.maxreqs < 1)
> +		return nfserr_inval;
> +	/* XXX: check other fields here; see
> +	 * http://tools.ietf.org/search/rfc5661#section-18.36 to
> +	 * determine when we can modify the fields to be acceptable, and
> +	 * when we must return inval.  We'll need to figure out the
> +	 * things like how large a callback request we need to be able to
> +	 * send. */
> +	return nfs_ok;
> +}
> +
>  __be32
>  nfsd4_create_session(struct svc_rqst *rqstp,
>  		     struct nfsd4_compound_state *cstate,
> @@ -1553,6 +1570,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  	cr_ses->flags &= ~SESSION4_PERSIST;
>  	cr_ses->flags &= ~SESSION4_RDMA;
>  
> +	status = verify_backchannel_attributes(cr_ses);
> +	if (status)
> +		goto out;
>  	status = nfserr_jukebox;
>  	new = alloc_init_session(rqstp, conf, cr_ses);
>  	if (!new)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
=
