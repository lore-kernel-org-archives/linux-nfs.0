Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:50679 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933170Ab2EaTge (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 15:36:34 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 31 May 2012 15:36:33 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 88ABE6E80FE
	for <linux-nfs@vger.kernel.org>; Thu, 31 May 2012 15:36:10 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4VJa6Kp070484
	for <linux-nfs@vger.kernel.org>; Thu, 31 May 2012 15:36:08 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4VJZjDl011329
	for <linux-nfs@vger.kernel.org>; Thu, 31 May 2012 13:35:45 -0600
Date: Thu, 31 May 2012 14:35:44 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Sachin Prabhu <sprabhu@redhat.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@netapp.com>
Subject: Re: [PATCH] NFSv2: EOF incorrectly set on short read
Message-ID: <20120531193544.GA4094@us.ibm.com>
References: <1338482700-15470-1-git-send-email-sprabhu@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1338482700-15470-1-git-send-email-sprabhu@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sachin Prabhu [sprabhu@redhat.com] wrote:
> In cases where the server returns fewer bytes then those requested, we
> can incorrectly set the eof flag for the file. Fixing this allows the
> request to be retried with updated offset and count arguments.
> 
> Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
> ---
>  fs/nfs/proc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
> index a706b6b..617c741 100644
> --- a/fs/nfs/proc.c
> +++ b/fs/nfs/proc.c
> @@ -651,7 +651,7 @@ static int nfs_read_done(struct rpc_task *task, struct nfs_read_data *data)
>  		/* Emulate the eof flag, which isn't normally needed in NFSv2
>  		 * as it is guaranteed to always return the file attributes
>  		 */
> -		if (data->args.offset + data->args.count >= data->res.fattr->size)
> +		if (data->args.offset + data->res.count >= data->res.fattr->size)
>  			data->res.eof = 1;
>  	}
>  	return 0;

Good catch!

Regards, Malahal.

