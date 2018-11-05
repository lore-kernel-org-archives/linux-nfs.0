Return-Path: <SRS0=wnB3=NQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7B10C0044C
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Nov 2018 21:34:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 593B72081C
	for <linux-nfs@archiver.kernel.org>; Mon,  5 Nov 2018 21:34:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 593B72081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387672AbeKFGzk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Nov 2018 01:55:40 -0500
Received: from fieldses.org ([173.255.197.46]:33874 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387441AbeKFGzk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Nov 2018 01:55:40 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 25113BCD; Mon,  5 Nov 2018 16:33:58 -0500 (EST)
Date:   Mon, 5 Nov 2018 16:33:58 -0500
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 10/13] NFSD check stateids against copy stateids
Message-ID: <20181105213358.GB9111@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-11-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019152905.32418-11-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 19, 2018 at 11:29:02AM -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> Incoming stateid (used by a READ) could be a saved copy stateid.
> On first use make it active and check that the copy has started
> within the allowable lease time.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/nfs4state.c | 43 +++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 43 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 7764a8b..16359de 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -5206,6 +5206,47 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
>  
>  	return 0;
>  }
> +/*
> + * A READ from an inter server to server COPY will have a
> + * copy stateid. Return the parent nfs4_stid.
> + */
> +static __be32 _find_cpntf_state(struct nfsd_net *nn, stateid_t *st,
> +		     struct nfs4_cpntf_state **cps)
> +{
> +	struct nfs4_cpntf_state *state = NULL;
> +
> +	if (st->si_opaque.so_clid.cl_id != nn->s2s_cp_cl_id)
> +		return nfserr_bad_stateid;
> +	spin_lock(&nn->s2s_cp_lock);
> +	state = idr_find(&nn->s2s_cp_stateids, st->si_opaque.so_id);
> +	spin_unlock(&nn->s2s_cp_lock);
> +	if (!state)
> +		return nfserr_bad_stateid;
> +	*cps = state;
> +	return 0;
> +}
> +
> +static __be32 find_cpntf_state(struct nfsd_net *nn, stateid_t *st,
> +			       struct nfs4_stid **stid)
> +{
> +	__be32 status;
> +	struct nfs4_cpntf_state *cps = NULL;
> +
> +	status = _find_cpntf_state(nn, st, &cps);
> +	if (status)
> +		return status;
> +
> +	/* Did the inter server to server copy start in time? */
> +	if (cps->cp_active == false && !time_after(cps->cp_timeout, jiffies))

Is there any other time limit, or can the destination server keeping
using this stateid indefinitely as long as it manages to get its first
READ in before cp_timeout?

> +		return nfserr_partner_no_auth;
> +	else
> +		cps->cp_active = true;
> +
> +	*stid = cps->cp_p_stid;
> +	refcount_inc(&cps->cp_p_stid->sc_count);

Does the caller hold some lock?  If not, what's prevnting cps from being
freed before we get around to incrementing sc_count here?

I would have expected the refcount_inc to happen before we drop
s2s_cp_lock, but, like I say, maybe I'm missing some other locking.

--b.

> +
> +	return nfs_ok;
> +}
>  
>  /*
>   * Checks for stateid operations
> @@ -5238,6 +5279,8 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
>  	status = nfsd4_lookup_stateid(cstate, stateid,
>  				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
>  				&s, nn);
> +	if (status == nfserr_bad_stateid)
> +		status = find_cpntf_state(nn, stateid, &s);
>  	if (status)
>  		return status;
>  	status = nfsd4_stid_check_stateid_generation(stateid, s,
> -- 
> 1.8.3.1
