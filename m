From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 15/51] FIXME: nfsd41: free up slot unless operation
 is	dropped
Date: Mon, 17 Nov 2008 16:01:56 +0200
Message-ID: <49217954.7000809@panasas.com>
References: <491895A0.3040809@panasas.com> <1226349946-10659-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:7763 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752145AbYKQOB7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:01:59 -0500
In-Reply-To: <1226349946-10659-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:45 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Marc Eshel <eshel@almaden.ibm.com>
> 
> Mark slot is NFS4_SLOT_AVAILABLE before exiting nfsd4_proc_compound
> unless op->status == nfserr_dropit
> 
> FIXME: bhalevy: verify slot gets freed eventually in the dropit case.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

review 11-12: code replaced by DRC

> ---
>  fs/nfsd/nfs4proc.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index bfebeaa..876f285 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -979,8 +979,15 @@ out_free:
>  #if defined(CONFIG_NFSD_V4_1)
>  	if (current_ses) {
>  		struct nfs41_slot *cs_slot = current_ses->cs_slot;
> -		if (cs_slot)
> +		if (cs_slot) {
> +			if (op && op->status != nfserr_dropit) {
> +				dprintk("%s: SET SLOT STATE TO AVAILABLE\n",
> +					__func__);
> +				nfs41_set_slot_state(cs_slot,
> +						     NFS4_SLOT_AVAILABLE);
> +			}
>  			nfs41_put_session(cs_slot->sl_session);
> +		}
>  		kfree(current_ses);
>  	}
>  #endif /* CONFIG_NFSD_V4_1 */
