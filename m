Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:36908 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbaA3Qta convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jan 2014 11:49:30 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 1/3] NFSv4: Fix a slot leak in nfs40_sequence_done
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1391016982-10562-1-git-send-email-trond.myklebust@primarydata.com>
Date: Thu, 30 Jan 2014 08:49:26 -0800
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5AE747F1-D056-47AB-8416-C37071A35D5B@oracle.com>
References: <1391016982-10562-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 29, 2014, at 9:36 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> The check for whether or not we sent an RPC call in nfs40_sequence_done
> is insufficient to decide whether or not we are holding a session slot,
> and thus should not be used to decide when to free that slot.
> 
> This patch replaces the RPC_WAS_SENT() test with the correct test for
> whether or not slot == NULL.
> 
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Cc: stable@vger.kernel.org # 3.12+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfs/nfs4proc.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index ae00c3ed733f..493e9cce1f11 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -539,7 +539,7 @@ static int nfs40_sequence_done(struct rpc_task *task,
> 	struct nfs4_slot *slot = res->sr_slot;
> 	struct nfs4_slot_table *tbl;
> 
> -	if (!RPC_WAS_SENT(task))
> +	if (slot == NULL)
> 		goto out;

When CONFIG_NFS_V4_1 is enabled, nfs4_sequence_done() already does the slot == NULL test, though the other nfs40_sequence_done() call sites do not.  This patch should clean that up?

> 
> 	tbl = slot->table;
> -- 
> 1.8.5.3
> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



