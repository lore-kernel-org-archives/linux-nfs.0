Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA66EC0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:19:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 971F52064C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:19:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 971F52064C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726888AbeKBFYY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 01:24:24 -0400
Received: from fieldses.org ([173.255.197.46]:56516 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726594AbeKBFYY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Nov 2018 01:24:24 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 33E70242F; Thu,  1 Nov 2018 16:19:55 -0400 (EDT)
Date:   Thu, 1 Nov 2018 16:19:55 -0400
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 05/13] NFS skip recovery of copy open on dest server
Message-ID: <20181101201955.GB12930@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-6-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019152905.32418-6-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 19, 2018 at 11:28:57AM -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> Mark the open created for the source file on the destination
> server. Then if this open is going thru a recovery, then fail
> the recovery as we don't need to be recoving a "fake" open.
> We need to fail the ongoing READs and vfs_copy_file_range().

Nothing to do with this patch, really, but:

I'm not always a stickler about the 80-character-column rule, but, man,
nfs4_reclaim_open_state is deeply nested, could that be broken up a
little?  Also I notice there's a printk("AGLO: ...") in there that you
probably didn't mean to leave upstream?

--b.

> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs4_fs.h   |  1 +
>  fs/nfs/nfs4file.c  |  1 +
>  fs/nfs/nfs4state.c | 14 ++++++++++++++
>  3 files changed, 16 insertions(+)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index f229864..8b00c90 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -165,6 +165,7 @@ enum {
>  	NFS_STATE_CHANGE_WAIT,		/* A state changing operation is outstanding */
>  #ifdef CONFIG_NFS_V4_2
>  	NFS_CLNT_DST_SSC_COPY_STATE,    /* dst server open state on client*/
> +	NFS_SRV_SSC_COPY_STATE,		/* ssc state on the dst server */
>  #endif /* CONFIG_NFS_V4_2 */
>  };
>  
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index f82cb05..7909cd4 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -309,6 +309,7 @@ struct file *
>  	if (ctx->state == NULL)
>  		goto out_stateowner;
>  
> +	set_bit(NFS_SRV_SSC_COPY_STATE, &ctx->state->flags);
>  	set_bit(NFS_OPEN_STATE, &ctx->state->flags);
>  	memcpy(&ctx->state->open_stateid.other, &stateid->other,
>  	       NFS4_STATEID_OTHER_SIZE);
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 62ae0fd..b0b82c6 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1606,6 +1606,9 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
>  {
>  	struct nfs4_state *state;
>  	int status = 0;
> +#ifdef CONFIG_NFS_V4_2
> +	bool found_ssc_copy_state = false;
> +#endif /* CONFIG_NFS_V4_2 */
>  
>  	/* Note: we rely on the sp->so_states list being ordered 
>  	 * so that we always reclaim open(O_RDWR) and/or open(O_WRITE)
> @@ -1625,6 +1628,13 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
>  			continue;
>  		if (state->state == 0)
>  			continue;
> +#ifdef CONFIG_NFS_V4_2
> +		if (test_bit(NFS_SRV_SSC_COPY_STATE, &state->flags)) {
> +			nfs4_state_mark_recovery_failed(state, -EIO);
> +			found_ssc_copy_state = true;
> +			continue;
> +		}
> +#endif /* CONFIG_NFS_V4_2 */
>  		refcount_inc(&state->count);
>  		spin_unlock(&sp->so_lock);
>  		status = __nfs4_reclaim_open_state(sp, state, ops);
> @@ -1671,6 +1681,10 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
>  	}
>  	raw_write_seqcount_end(&sp->so_reclaim_seqcount);
>  	spin_unlock(&sp->so_lock);
> +#ifdef CONFIG_NFS_V4_2
> +	if (found_ssc_copy_state)
> +		return -EIO;
> +#endif /* CONFIG_NFS_V4_2 */
>  	return 0;
>  out_err:
>  	nfs4_put_open_state(state);
> -- 
> 1.8.3.1
