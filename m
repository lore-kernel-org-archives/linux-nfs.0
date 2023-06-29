Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10DD8EB64DC
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Jun 2023 15:07:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232106AbjF2PHy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 29 Jun 2023 11:07:54 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:45520 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231248AbjF2PHx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Jun 2023 11:07:53 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9BA0610CE
        for <linux-nfs@vger.kernel.org>; Thu, 29 Jun 2023 08:07:52 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 39B1861573
        for <linux-nfs@vger.kernel.org>; Thu, 29 Jun 2023 15:07:52 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3F2EFC433C8;
        Thu, 29 Jun 2023 15:07:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1688051271;
        bh=EYy/rdo1rRCcXMzkFaIquWUUsuEaF6KakHbVmxDTEq8=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=gSD9+UKIR+3Wv8v24VNs2JlSirAS1Jqxe4CI3CSYe10vsTe+W5ftV8wv9H7o7XE80
         Z/pPOsOfafsyvdRsvDir20Yo0J2HrnGjGq3+1s9us1A1E03RvD+r5I7mtSNMdIiWIY
         Gp/KhpNLWGLBgysw4uJy14vEDku4Ee8Rvu1dTTKBkccPX1ABOG0ASJngWhCVyyTt80
         diotAbpXwXmU/oX9fEEdoK/+oQ98Qo7EeuVBSiNzDwmQD/s8aifqD8ABo1DdWMH5Z1
         n2amgSpe8pTLFnwu0XczWEl6LSuFO77zzF3UYCU5bMAE0Ljn+P37X4K3A4ohSs92OA
         bQXLrJ5qRHasQ==
Date:   Thu, 29 Jun 2023 11:07:49 -0400
From:   Chuck Lever <cel@kernel.org>
To:     Dai Ngo <dai.ngo@oracle.com>
Cc:     chuck.lever@oracle.com, jlayton@kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v6 5/5] NFSD: add counter for write delegation recall due
 to conflict GETATTR
Message-ID: <ZJ2eRbqyeFxTIamR@manet.1015granger.net>
References: <1688006176-32597-1-git-send-email-dai.ngo@oracle.com>
 <1688006176-32597-6-git-send-email-dai.ngo@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1688006176-32597-6-git-send-email-dai.ngo@oracle.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Jun 28, 2023 at 07:36:16PM -0700, Dai Ngo wrote:
> Add counter to keep track of how many times write delegations are
> recalled due to conflict with GETATTR.

Should this wee patch be squashed into 3/5 ?

The patch description ought to explain /why/ we want to track
GETATTR conflicts. (even if you squash it into 3/5). Mostly I'm
trying to get the important design choices written down so we
can remember them in a year or two.


> Signed-off-by: Dai Ngo <dai.ngo@oracle.com>
> ---
>  fs/nfsd/nfs4state.c | 1 +
>  fs/nfsd/stats.c     | 2 ++
>  fs/nfsd/stats.h     | 7 +++++++
>  3 files changed, 10 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2d2656c41ffb..6ce95e738359 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -8410,6 +8410,7 @@ nfsd4_deleg_getattr_conflict(struct svc_rqst *rqstp, struct inode *inode)
>  			}
>  break_lease:
>  			spin_unlock(&ctx->flc_lock);
> +			nfsd_stats_wdeleg_getattr_inc();
>  			status = nfserrno(nfsd_open_break_lease(inode, NFSD_MAY_READ));
>  			if (status != nfserr_jukebox ||
>  					!nfsd_wait_for_delegreturn(rqstp, inode))
> diff --git a/fs/nfsd/stats.c b/fs/nfsd/stats.c
> index 777e24e5da33..63797635e1c3 100644
> --- a/fs/nfsd/stats.c
> +++ b/fs/nfsd/stats.c
> @@ -65,6 +65,8 @@ static int nfsd_show(struct seq_file *seq, void *v)
>  		seq_printf(seq, " %lld",
>  			   percpu_counter_sum_positive(&nfsdstats.counter[NFSD_STATS_NFS4_OP(i)]));
>  	}
> +	seq_printf(seq, "\nwdeleg_getattr %lld",
> +		percpu_counter_sum_positive(&nfsdstats.counter[NFSD_STATS_WDELEG_GETATTR]));
>  
>  	seq_putc(seq, '\n');
>  #endif
> diff --git a/fs/nfsd/stats.h b/fs/nfsd/stats.h
> index 9b43dc3d9991..cf5524e7ca06 100644
> --- a/fs/nfsd/stats.h
> +++ b/fs/nfsd/stats.h
> @@ -22,6 +22,7 @@ enum {
>  	NFSD_STATS_FIRST_NFS4_OP,	/* count of individual nfsv4 operations */
>  	NFSD_STATS_LAST_NFS4_OP = NFSD_STATS_FIRST_NFS4_OP + LAST_NFS4_OP,
>  #define NFSD_STATS_NFS4_OP(op)	(NFSD_STATS_FIRST_NFS4_OP + (op))
> +	NFSD_STATS_WDELEG_GETATTR,	/* count of getattr conflict with wdeleg */
>  #endif
>  	NFSD_STATS_COUNTERS_NUM
>  };
> @@ -93,4 +94,10 @@ static inline void nfsd_stats_drc_mem_usage_sub(struct nfsd_net *nn, s64 amount)
>  	percpu_counter_sub(&nn->counter[NFSD_NET_DRC_MEM_USAGE], amount);
>  }
>  
> +#ifdef CONFIG_NFSD_V4
> +static inline void nfsd_stats_wdeleg_getattr_inc(void)
> +{
> +	percpu_counter_inc(&nfsdstats.counter[NFSD_STATS_WDELEG_GETATTR]);
> +}
> +#endif
>  #endif /* _NFSD_STATS_H */
> -- 
> 2.39.3
> 
