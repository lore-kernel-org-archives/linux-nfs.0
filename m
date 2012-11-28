Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47393 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755543Ab2K1PJn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 10:09:43 -0500
Date: Wed, 28 Nov 2012 10:09:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH 1/2] nfsd: make NFSv4 lease time per net
Message-ID: <20121128150941.GF11651@fieldses.org>
References: <20121127111007.10271.54338.stgit@localhost.localdomain>
 <20121127111144.10271.97169.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121127111144.10271.97169.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 27, 2012 at 02:11:44PM +0300, Stanislav Kinsbursky wrote:
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index dab350d..4930981 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -912,7 +912,8 @@ static ssize_t nfsd4_write_time(struct file *file, char *buf, size_t size, time_
>   */
>  static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
>  {
> -	return nfsd4_write_time(file, buf, size, &nfsd4_lease);
> +	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
> +	return nfsd4_write_time(file, buf, size, &nn->nfsd4_lease);

This is called in the context of whatever process writes to
nfsv4leasetime, so should be using its network namespace, right?

--b.
