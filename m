From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH] Fix session initialization when following referrals
Date: Tue, 29 Sep 2009 09:43:52 +0200
Message-ID: <4AC1BAB8.7050807@panasas.com>
References: <alpine.OSX.2.00.0909291327360.21014@panthera.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfsv4@linux-nfs.org, pnfs@linux-nfs.org,
	NFS list <linux-nfs@vger.kernel.org>
To: Jjgod Jiang <jiangjiang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:60904 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751899AbZI2Hnv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Sep 2009 03:43:51 -0400
In-Reply-To: <alpine.OSX.2.00.0909291327360.21014-uDfGT2BMUji44ywRPIzf9A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep. 29, 2009, 7:35 +0200, Jjgod Jiang <jiangjiang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org> wrote:
> Hi,
> 
> When following NFSv4 referrals, nfs will initialize the session of the
> client with nfs4_alloc_session() and expecting to recover the session
> on SEQUENCE operation. However, nfs41_setup_sequence() expects the
> fc_slot_table->highest_used_slotid of this session to be -1, otherwise
> it will simply return -EAGAIN without recovering the session. This
> patch complete nfs4_alloc_session() so that nfs41_setup_sequence() can
> successfully return when following referrals.

Ack.

I'll merge this patch also in my tree for the upcoming Bakeathon.

Benny

P.S. please use linux-nfs@vger.kernel.org rather than nfsv4@linux-nfs.org

> 
> --- nfs/nfs4proc.c	2009-09-17 09:20:59.000000000 +0800
> +++ nfs4proc.c	2009-09-29 13:18:08.000000000 +0800
> @@ -4789,6 +4789,7 @@ struct nfs4_session *nfs4_alloc_session(
>   	clp->cl_cons_state = NFS_CS_SESSION_INITING;
> 
>   	tbl = &session->fc_slot_table;
> +	tbl->highest_used_slotid = -1;
>   	spin_lock_init(&tbl->slot_tbl_lock);
>   	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "ForeChannel Slot table");
> 
> 
> ------------------------------------------------------------------------
> 
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
