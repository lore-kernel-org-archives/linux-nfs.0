From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/1] nfs: Panic when commit fails
Date: Wed, 21 Oct 2009 07:06:24 +0900
Message-ID: <1256076385.3423.4.camel@heimdal.trondhjem.org>
References: <4ADDF708.6020901@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: SteveD@redhat.com, linux-nfs@vger.kernel.org
To: Terry Loftin <terry.loftin@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:45223 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106AbZJTWG1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Oct 2009 18:06:27 -0400
In-Reply-To: <4ADDF708.6020901@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-10-20 at 11:44 -0600, Terry Loftin wrote:
> Actually pass the NFS_FILE_SYNC option to the server to avoid a
> Panic in nfs_direct_write_complete() when a commit fails.
> 
> At the end of an nfs write, if the nfs commit fails, all the writes
> will be rescheduled.  They are supposed to be rescheduled as NFS_FILE_SYNC
> writes, but the rpc_task structure is not completely intialized and so
> the option is not passed.  When the rescheduled writes complete, the
> return indicates that they are NFS_UNSTABLE and we try to do another
> commit.  This leads to a Panic because the commit data structure pointer
> was set to null in the initial (failed) commit attempt.
> 
> Signed-off-by: Terry Loftin <terry.loftin@hp.com>
> ---
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index e4e089a..1af78ff 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -457,6 +457,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
>  	};
>  	struct rpc_task_setup task_setup_data = {
>  		.rpc_client = NFS_CLIENT(inode),
> +		.rpc_message = &msg,
>  		.callback_ops = &nfs_write_direct_ops,
>  		.workqueue = nfsiod_workqueue,
>  		.flags = RPC_TASK_ASYNC,

Doh! Well spotted. I'll pass this along into mainline+stable.

Cheers
  Trond

