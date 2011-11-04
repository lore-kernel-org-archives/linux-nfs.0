Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:7253 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932185Ab1KDOkk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 10:40:40 -0400
Message-ID: <4EB3F957.2060309@netapp.com>
Date: Fri, 04 Nov 2011 10:40:23 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: andros@netapp.com
CC: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH (resend) Version 2 3/3] NFSv4.1: fix backchennel bug
References: <1318919979-14606-1-git-send-email-andros@netapp.com>
In-Reply-To: <1318919979-14606-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"backchennel" in the subject should be "backchannel"

- Bryan

On 10/18/2011 02:39 AM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Slotid's start from 0 which means we check against
> NFS41_BC_MAX_CALLBACKS - 1.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/callback_proc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 98ff5fc..12bd9d0 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -339,7 +339,7 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
>  	dprintk("%s enter. slotid %d seqid %d\n",
>  		__func__, args->csa_slotid, args->csa_sequenceid);
>  
> -	if (args->csa_slotid > NFS41_BC_MAX_CALLBACKS)
> +	if (args->csa_slotid > NFS41_BC_MAX_CALLBACKS - 1)
>  		return htonl(NFS4ERR_BADSLOT);
>  
>  	slot = nfs4_lookup_slot_locked(tbl, args->csa_slotid);

