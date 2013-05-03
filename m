Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:37033 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933321Ab3ECQMr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 May 2013 12:12:47 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH 1/2] NFSv4.x: Fix handling of partially delegated locks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1367515168-11158-1-git-send-email-Trond.Myklebust@netapp.com>
Date: Fri, 3 May 2013 12:12:43 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <9873A24B-BCB9-4F95-9EC7-0DE38513505D@oracle.com>
References: <1367515168-11158-1-git-send-email-Trond.Myklebust@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

On May 2, 2013, at 1:19 PM, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> If a NFS client receives a delegation for a file after it has taken
> a lock on that file, we can currently end up in a situation where
> we mistakenly skip unlocking that file.
> 
> The following patch swaps an erroneous check in nfs4_proc_unlck for
> whether or not the file has a delegation to one which checks whether
> or not we hold a lock stateid for that file.
> 
> Reported-by: Chuck Lever <Chuck.Lever@oracle.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: stable@vger.kernel.org

Although this patch may apply cleanly to, say, 3.0-stable, the result is that LOCKUs now never appear on the wire.  It seems that older stable kernels are missing something that is needed to make this simple fix work correctly.


> Tested-by: Chuck Lever <Chuck.Lever@oracle.com>
> ---
> fs/nfs/nfs4proc.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 9da4bd5..dc1da2a 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4766,9 +4766,9 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
> 	if (status != 0)
> 		goto out;
> 	/* Is this a delegated lock? */
> -	if (test_bit(NFS_DELEGATED_STATE, &state->flags))
> -		goto out;
> 	lsp = request->fl_u.nfs4_fl.owner;
> +	if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) == 0)
> +		goto out;
> 	seqid = nfs_alloc_seqid(&lsp->ls_seqid, GFP_KERNEL);
> 	status = -ENOMEM;
> 	if (seqid == NULL)
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




