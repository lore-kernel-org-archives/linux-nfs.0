Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54842 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422904Ab2LGQwO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2012 11:52:14 -0500
Date: Fri, 7 Dec 2012 11:52:11 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH 3/6] nfsd: pass net to nfsd_create_serv()
Message-ID: <20121207165211.GK17115@fieldses.org>
References: <20121204134920.24504.95261.stgit@localhost.localdomain>
 <20121204135016.24504.74168.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121204135016.24504.74168.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 04, 2012 at 04:50:16PM +0300, Stanislav Kinsbursky wrote:
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 21cba3d..6448391 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -334,10 +334,9 @@ static int nfsd_get_default_max_blksize(void)
>  	return ret;
>  }
>  
> -int nfsd_create_serv(void)
> +int nfsd_create_serv(struct net *net)
>  {
>  	int error;
> -	struct net *net = &init_net;

What does this apply to?  Since 3.6-rc1 we have 
57c8b13e3cd0f94944c9691ce7f58e5fcef8a12d "NFSd: set nfsd_serv to NULL
after service destruction" which includes:

@@ -332,6 +330,7 @@ static int nfsd_get_default_max_blksize(void)
 int nfsd_create_serv(void)
 {
        int error;
+       struct net *net = current->nsproxy->net_ns;
 
        WARN_ON(!mutex_is_locked(&nfsd_mutex));
        if (nfsd_serv) {

Am I missing some later patch?

--b.
