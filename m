Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5831C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 18:28:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7E21C20672
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 18:28:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728386AbeLSS2b (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 13:28:31 -0500
Received: from fieldses.org ([173.255.197.46]:47064 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728282AbeLSS2b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Dec 2018 13:28:31 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 4178A1C96; Wed, 19 Dec 2018 13:28:31 -0500 (EST)
Date:   Wed, 19 Dec 2018 13:28:31 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/3] nfsd: keep a tally of RECLAIM_COMPLETE operations
 when using nfsdcld
Message-ID: <20181219182831.GB28626@fieldses.org>
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
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 89c2a27956d0..ae74814b2397 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -1251,6 +1251,7 @@ nfsd4_cld_grace_done(struct nfsd_net *nn)
>  	free_cld_upcall(cup);
>  out_err:
>  	nfs4_release_reclaim(nn);
> +	atomic_set(&nn->nr_reclaim_complete, 0);
>  	if (ret)
>  		printk(KERN_ERR "NFSD: Unable to end grace period: %d\n", ret);
>  }
> @@ -1270,6 +1271,8 @@ nfs4_cld_state_init(struct net *net)
>  	for (i = 0; i < CLIENT_HASH_SIZE; i++)
>  		INIT_LIST_HEAD(&nn->reclaim_str_hashtbl[i]);
>  	nn->reclaim_str_hashtbl_size = 0;
> +	nn->track_reclaim_completes = true;
> +	atomic_set(&nn->nr_reclaim_complete, 0);
>  
>  	return 0;
>  }
...
> @@ -1318,6 +1322,7 @@ nfsd4_cld_tracking_exit(struct net *net)
>  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>  
>  	nfs4_release_reclaim(nn);
> +	atomic_set(&nn->nr_reclaim_complete, 0);
>  	nfsd4_remove_cld_pipe(net);
>  	nfs4_cld_state_shutdown(net);
>  }

We're initializing nr_reclaim_complete in 3 different places, probably
only one of those is really necessary?

--b.
