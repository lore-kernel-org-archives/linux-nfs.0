Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7D1EC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 17:46:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B35CF217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 17:46:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729112AbeLSRqs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 12:46:48 -0500
Received: from fieldses.org ([173.255.197.46]:46986 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727594AbeLSRqs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Dec 2018 12:46:48 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 61819492; Wed, 19 Dec 2018 12:46:48 -0500 (EST)
Date:   Wed, 19 Dec 2018 12:46:48 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/3] nfsd: keep a tally of RECLAIM_COMPLETE operations
 when using nfsdcld
Message-ID: <20181219174648.GA28626@fieldses.org>
References: <20181218142926.27933-1-smayhew@redhat.com>
 <20181218142926.27933-4-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218142926.27933-4-smayhew@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 18, 2018 at 09:29:26AM -0500, Scott Mayhew wrote:
> +skip_grace:
> +	printk(KERN_INFO "NFSD: no clients to reclaim, skipping NFSv4 grace period (net %x)\n",
> +			net->ns.inum);
> +	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_lease * HZ);
> +	/*
> +	 * we could call nfsd4_end_grace() here, but it has a dprintk()
> +	 * that would be confusing if debug logging is enabled
> +	 */

In that case, I'd rather pull the dprintk out of nfsd4_end_grace into
its only other caller (nfs4_laundromat), instead of duplicating this
stuff.

> +	nn->grace_ended = true;
> +	nfsd4_record_grace_done(nn);
> +	locks_end_grace(&nn->nfsd4_manager);

(Yes, it's only three lines, but it's a little subtle, I'd rather have
it all in one place.)

--b.

> +	return 0;
>  }
>  
>  /* initialization to perform when the nfsd service is started: */
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 6384c9b94898..950ac6683be9 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1240,6 +1240,7 @@ static __net_init int nfsd_init_net(struct net *net)
>  	nn->nfsd4_lease = 45;	/* default lease time */
>  	nn->nfsd4_grace = 45;
>  	nn->somebody_reclaimed = false;
> +	nn->track_reclaim_completes = false;
>  	nn->clverifier_counter = prandom_u32();
>  	nn->clientid_counter = prandom_u32();
>  	nn->s2s_cp_cl_id = nn->clientid_counter++;
> -- 
> 2.17.1
