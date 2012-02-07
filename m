Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:25714 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756570Ab2BGOJp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 09:09:45 -0500
Message-ID: <4F31308B.1090002@parallels.com>
Date: Tue, 07 Feb 2012 18:09:15 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 4/4] NFS: make nfs_client_lock per net ns
References: <20120123172631.29637.17188.stgit@localhost6.localdomain6> <1328622659.4124.3.camel@lade.trondhjem.org>
In-Reply-To: <1328622659.4124.3.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

07.02.2012 17:51, Myklebust, Trond пишет:
> 8<-------------------------------------------------------------------------
>  From 5a489156da4fd15dd143f2b21dd9657b97dcef88 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust<Trond.Myklebust@netapp.com>
> Date: Tue, 7 Feb 2012 00:05:11 -0500
> Subject: [PATCH] NFS: Initialise the nfs_net->nfs_client_lock
>
> Ensure that we initialise the nfs_net->nfs_client_lock spinlock.
> Also ensure that nfs_server_remove_lists() doesn't try to
> dereference server->nfs_client before that is initialised.
>

Sorry.
Patch looks nice. Except one notice below.

> Signed-off-by: Trond Myklebust<Trond.Myklebust@netapp.com>
> Cc: Stanislav Kinsbursky<skinsbursky@parallels.com>
> ---
>   fs/nfs/client.c |    6 +++++-
>   1 files changed, 5 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 1a5cd49..f0dacad 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -1055,8 +1055,11 @@ static void nfs_server_insert_lists(struct nfs_server *server)
>   static void nfs_server_remove_lists(struct nfs_server *server)
>   {
>   	struct nfs_client *clp = server->nfs_client;
> -	struct nfs_net *nn = net_generic(clp->net, nfs_net_id);
> +	struct nfs_net *nn;
>
> +	if (clp == NULL)
> +		return;
> +	nn = net_generic(clp->net, nfs_net_id);
>   	spin_lock(&nn->nfs_client_lock);
>   	list_del_rcu(&server->client_link);
>   	if (clp&&  list_empty(&clp->cl_superblocks))

This check for clp != NULL can be removed.



-- 
Best regards,
Stanislav Kinsbursky
