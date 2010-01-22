From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/1] nfs: fix race between renewd, umount, and the
 state manager in V4.1
Date: Fri, 22 Jan 2010 13:47:19 -0500
Message-ID: <1264186039.30757.7.camel@localhost>
References: <1264135871-13083-1-git-send-email-batsakis@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, trond@netapp.com
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44901 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756108Ab0AVSrg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jan 2010 13:47:36 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0MIlKjT026335
	for <linux-nfs@vger.kernel.org>; Fri, 22 Jan 2010 10:47:21 -0800 (PST)
In-Reply-To: <1264135871-13083-1-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-01-21 at 20:51 -0800, Alexandros Batsakis wrote:

> struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
> @@ -878,7 +888,11 @@ void nfs4_schedule_state_manager(struct nfs_client *clp)
>  	if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
>  		return;
>  	__module_get(THIS_MODULE);
> -	atomic_inc(&clp->cl_count);
> +	if (!atomic_inc_not_zero(&clp->cl_count)) {
> +		nfs4_clear_state_manager_bit(clp);
> +		module_put(THIS_MODULE);
> +		return;
> +	}

The use of atomic_inc_not_zero() should not be necessary here. Anybody
who is calling this function without holding a reference to clp is doing
something fundamentally wrong.

Trond
