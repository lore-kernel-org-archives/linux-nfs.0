From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 02/51] nfsd: dprint each op status in	nfsd4_proc_compound
Date: Mon, 17 Nov 2008 15:56:07 +0200
Message-ID: <492177F7.3050801@panasas.com>
References: <491895A0.3040809@panasas.com> <1226349676-10167-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:9304 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751943AbYKQN4K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:56:10 -0500
In-Reply-To: <1226349676-10167-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:41 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

review 2008-11-12:
keep both dprintk's or just the bottom one (with the status)
in general: explain the kind of problem we need this for.

> ---
>  fs/nfsd/nfs4proc.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 669461e..9fa60a3 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -946,6 +946,11 @@ encode_op:
>  			nfsd4_encode_operation(resp, op);
>  			status = op->status;
>  		}
> +
> +		dprintk("nfsv4 compound op %p opcnt %d #%d: %d: status %d\n",
> +			args->ops, args->opcnt, resp->opcnt, op->opnum,
> +			be32_to_cpu(status));
> +
>  		if (cstate->replay_owner) {
>  			nfs4_put_stateowner(cstate->replay_owner);
>  			cstate->replay_owner = NULL;
