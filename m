Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13152 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932564Ab1KDObd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 10:31:33 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id pA4EVW8a023867
	for <linux-nfs@vger.kernel.org>; Fri, 4 Nov 2011 07:31:33 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH (resend) Version 2 3/3] NFSv4.1: fix backchennel bug
Date: Fri, 4 Nov 2011 07:31:31 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BFA925D@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <1318919979-14606-1-git-send-email-andros@netapp.com>
References: <1318919979-14606-1-git-send-email-andros@netapp.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Adamson, Andy
> Sent: Tuesday, October 18, 2011 2:40 AM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org; Adamson, Andy
> Subject: [PATCH (resend) Version 2 3/3] NFSv4.1: fix backchennel bug
> 
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
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c index
> 98ff5fc..12bd9d0 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -339,7 +339,7 @@ validate_seqid(struct nfs4_slot_table *tbl, struct
> cb_sequenceargs * args)
>  	dprintk("%s enter. slotid %d seqid %d\n",
>  		__func__, args->csa_slotid, args->csa_sequenceid);
> 
> -	if (args->csa_slotid > NFS41_BC_MAX_CALLBACKS)
> +	if (args->csa_slotid > NFS41_BC_MAX_CALLBACKS - 1)
>  		return htonl(NFS4ERR_BADSLOT);

Why not just replace '>' with '>='?

Cheers
  Trond
