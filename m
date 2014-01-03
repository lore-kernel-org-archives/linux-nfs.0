Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45040 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753392AbaACXSD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jan 2014 18:18:03 -0500
Date: Fri, 3 Jan 2014 18:18:00 -0500
From: "J.,Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Gareth Williams <gareth@garethwilliams.me.uk>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        trond.myklebust@primarydata.com
Subject: Re: [PATCH 2/2 v2] NFSD: Don't start lockd when only NFSv4 is running
Message-ID: <20140103231800.GF5164@fieldses.org>
References: <01763B6D-C8CB-46B7-87AC-CE189496019A@oracle.com>
 <6E281EC9-49CB-4BDA-BDF3-7A6F4B703156@gmail.com>
 <CAB6yy34woYZaJ=k=Ga9iT_mmBWBiCUj1SprT=Se2SVrOu6YO_Q@mail.gmail.com>
 <5D65FDE6-D1AB-442C-BFD8-141AB87FF321@gmail.com>
 <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com>
 <52C1577B.9080100@gmail.com>
 <52C15847.9030208@gmail.com>
 <68E6D30F-B2D6-4919-9748-E7F1162AC3B7@oracle.com>
 <52C2377E.8040006@gmail.com>
 <52C2536A.5070906@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52C2536A.5070906@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 31, 2013 at 01:17:30PM +0800, Kinglong Mee wrote:
> When starting without nfsv2 and nfsv3, nfsd should not setup lockd,
> especially when rpcbind is stop.
> 
> v2:
> move setting nfsd_version4's vs_rpcb_optnl option to new patch [1/2]

Thanks, these look good.  Applying both with minor rewrites of the
changelogs.

--b.

> 
> Reported-by: Gareth Williams <gareth@garethwilliams.me.uk>
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/netns.h  |  1 +
>  fs/nfsd/nfssvc.c | 26 +++++++++++++++++++++-----
>  2 files changed, 22 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> index 849a7c3..d32b3aa 100644
> --- a/fs/nfsd/netns.h
> +++ b/fs/nfsd/netns.h
> @@ -95,6 +95,7 @@ struct nfsd_net {
>  	time_t nfsd4_grace;
>  
>  	bool nfsd_net_up;
> +	bool lockd_up;
>  
>  	/*
>  	 * Time of server startup
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 760c85a..55b5b57 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -241,6 +241,11 @@ static void nfsd_shutdown_generic(void)
>  	nfsd_racache_shutdown();
>  }
>  
> +static bool nfsd_needs_lockd(void)
> +{
> +	return (nfsd_versions[2] != NULL) || (nfsd_versions[3] != NULL);
> +}
> +
>  static int nfsd_startup_net(int nrservs, struct net *net)
>  {
>  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> @@ -255,9 +260,14 @@ static int nfsd_startup_net(int nrservs, struct net *net)
>  	ret = nfsd_init_socks(net);
>  	if (ret)
>  		goto out_socks;
> -	ret = lockd_up(net);
> -	if (ret)
> -		goto out_socks;
> +
> +	if (nfsd_needs_lockd() && !nn->lockd_up) {
> +		ret = lockd_up(net);
> +		if (ret)
> +			goto out_socks;
> +		nn->lockd_up = 1;
> +	}
> +
>  	ret = nfs4_state_start_net(net);
>  	if (ret)
>  		goto out_lockd;
> @@ -266,7 +276,10 @@ static int nfsd_startup_net(int nrservs, struct net *net)
>  	return 0;
>  
>  out_lockd:
> -	lockd_down(net);
> +	if (nn->lockd_up) {
> +		lockd_down(net);
> +		nn->lockd_up = 0;
> +	}
>  out_socks:
>  	nfsd_shutdown_generic();
>  	return ret;
> @@ -277,7 +290,10 @@ static void nfsd_shutdown_net(struct net *net)
>  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>  
>  	nfs4_state_shutdown_net(net);
> -	lockd_down(net);
> +	if (nn->lockd_up) {
> +		lockd_down(net);
> +		nn->lockd_up = 0;
> +	}
>  	nn->nfsd_net_up = false;
>  	nfsd_shutdown_generic();
>  }
> -- 
> 1.8.4.2
