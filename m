Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55D62C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 18:36:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2E55B20672
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 18:36:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728802AbeLSSgB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 13:36:01 -0500
Received: from fieldses.org ([173.255.197.46]:47068 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728458AbeLSSgB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Dec 2018 13:36:01 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 6C3EC492; Wed, 19 Dec 2018 13:36:00 -0500 (EST)
Date:   Wed, 19 Dec 2018 13:36:00 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/3] nfsd: keep a tally of RECLAIM_COMPLETE operations
 when using nfsdcld
Message-ID: <20181219183600.GC28626@fieldses.org>
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
> When using nfsdcld for NFSv4 client tracking, track the number of
> RECLAIM_COMPLETE operations we receive from "known" clients to help in
> deciding if we can lift the grace period early (or whether we need to
> start a v4 grace period at all).
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfsd/netns.h       |  3 +++
>  fs/nfsd/nfs4recover.c |  5 +++++
>  fs/nfsd/nfs4state.c   | 52 +++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfsctl.c      |  1 +
>  4 files changed, 61 insertions(+)
> 
> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> index 32cb8c027483..b42aaa22fba2 100644
> --- a/fs/nfsd/netns.h
> +++ b/fs/nfsd/netns.h
> @@ -104,6 +104,9 @@ struct nfsd_net {
>  	time_t nfsd4_grace;
>  	bool somebody_reclaimed;
>  
> +	bool track_reclaim_completes;
> +	atomic_t nr_reclaim_complete;
> +
>  	bool nfsd_net_up;
>  	bool lockd_up;
>  
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
> @@ -1279,6 +1282,7 @@ nfs4_cld_state_shutdown(struct net *net)
>  {
>  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>  
> +	nn->track_reclaim_completes = false;
>  	kfree(nn->reclaim_str_hashtbl);
>  }
>  
> @@ -1318,6 +1322,7 @@ nfsd4_cld_tracking_exit(struct net *net)
>  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>  
>  	nfs4_release_reclaim(nn);
> +	atomic_set(&nn->nr_reclaim_complete, 0);
>  	nfsd4_remove_cld_pipe(net);
>  	nfs4_cld_state_shutdown(net);
>  }
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 777fbb0d2761..5dfc3cd51d08 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -77,6 +77,7 @@ static u64 current_sessionid = 1;
>  /* forward declarations */
>  static bool check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner);
>  static void nfs4_free_ol_stateid(struct nfs4_stid *stid);
> +void nfsd4_end_grace(struct nfsd_net *nn);
>  
>  /* Locking: */
>  
> @@ -1988,10 +1989,41 @@ destroy_client(struct nfs4_client *clp)
>  	__destroy_client(clp);
>  }
>  
> +static void inc_reclaim_complete(struct nfs4_client *clp)
> +{
> +	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> +
> +	if (!nn->track_reclaim_completes)
> +		return;
> +	if (!test_bit(NFSD4_CLIENT_RECLAIM_COMPLETE, &clp->cl_flags))
> +		return;

Looking at the code....  This test will never fail, will it?  We could
make it a WARN_ON_ONCE(!test_bit(...)) but it doesn't look like a likely
bug to me.

> +	if (!nfsd4_find_reclaim_client(clp->cl_name, nn))
> +		return;
> +	if (atomic_inc_return(&nn->nr_reclaim_complete) ==
> +			nn->reclaim_str_hashtbl_size) {
> +		printk(KERN_INFO "NFSD: all clients done reclaiming, ending NFSv4 grace period (net %x)\n",
> +				clp->net->ns.inum);
> +		nfsd4_end_grace(nn);
> +	}
> +}
> +
> +static void dec_reclaim_complete(struct nfs4_client *clp)
> +{
> +	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
> +
> +	if (!nn->track_reclaim_completes)
> +		return;
> +	if (!test_bit(NFSD4_CLIENT_RECLAIM_COMPLETE, &clp->cl_flags))
> +		return;
> +	if (nfsd4_find_reclaim_client(clp->cl_name, nn))
> +		atomic_dec(&nn->nr_reclaim_complete);
> +}
> +
>  static void expire_client(struct nfs4_client *clp)
>  {
>  	unhash_client(clp);
>  	nfsd4_client_record_remove(clp);
> +	dec_reclaim_complete(clp);
>  	__destroy_client(clp);
>  }

This doesn't look right to me.  If a client reclaims and then
immediately calls DESTROY_CLIENTID or something--that should still count
as a reclaim, and that shouldn't prevent us from ending the grace period
early.

I think dec_reclaim_complete is unnecessary.

--b.

>  
> @@ -3339,6 +3371,7 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp,
>  
>  	status = nfs_ok;
>  	nfsd4_client_record_create(cstate->session->se_client);
> +	inc_reclaim_complete(cstate->session->se_client);
>  out:
>  	return status;
>  }
> @@ -4734,6 +4767,10 @@ static bool clients_still_reclaiming(struct nfsd_net *nn)
>  	unsigned long double_grace_period_end = nn->boot_time +
>  						2 * nn->nfsd4_lease;
>  
> +	if (nn->track_reclaim_completes &&
> +			atomic_read(&nn->nr_reclaim_complete) ==
> +			nn->reclaim_str_hashtbl_size)
> +		return false;
>  	if (!nn->somebody_reclaimed)
>  		return false;
>  	nn->somebody_reclaimed = false;
> @@ -7253,10 +7290,25 @@ nfs4_state_start_net(struct net *net)
>  		return ret;
>  	locks_start_grace(net, &nn->nfsd4_manager);
>  	nfsd4_client_tracking_init(net);
> +	if (nn->track_reclaim_completes && nn->reclaim_str_hashtbl_size == 0)
> +		goto skip_grace;
>  	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %x)\n",
>  	       nn->nfsd4_grace, net->ns.inum);
>  	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_grace * HZ);
>  	return 0;
> +
> +skip_grace:
> +	printk(KERN_INFO "NFSD: no clients to reclaim, skipping NFSv4 grace period (net %x)\n",
> +			net->ns.inum);
> +	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_lease * HZ);
> +	/*
> +	 * we could call nfsd4_end_grace() here, but it has a dprintk()
> +	 * that would be confusing if debug logging is enabled
> +	 */
> +	nn->grace_ended = true;
> +	nfsd4_record_grace_done(nn);
> +	locks_end_grace(&nn->nfsd4_manager);
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
