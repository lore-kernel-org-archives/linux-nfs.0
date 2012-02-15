Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30714 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751052Ab2BOPHc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 10:07:32 -0500
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs41: Initialize slot->seq_nr at nfs4_init_slot_table()
Date: Wed, 15 Feb 2012 15:07:21 +0000
Message-ID: <077E41FB-D306-45F5-9344-05A15330A483@netapp.com>
References: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>
 <1329259606.11759.15.camel@lade.trondhjem.org>
 <4F3AFD84.3020709@nexenta.com> <1329266587.28837.4.camel@lade.trondhjem.org>
 <20120215005315.GA9018@fieldses.org>
 <1329270628.28837.15.camel@lade.trondhjem.org>
 <1329273001.28837.19.camel@lade.trondhjem.org>
In-Reply-To: <1329273001.28837.19.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Please don't merge nfs4_reset_slot_tables and nfs4_init_slot_tables.  It  assumes a static array (realloc) which goes away with the dynamic slot table code. Instead, take a look at the patch set I sent on Feb 12

[PATCH Version 7 3/3] NFSv4.1 avoid freeing slot when tasks are waiting
[PATCH Version 1 2/3] NFSv4.1 prepare for dyamic session slots
[PATCH Version 7 1/3] NFS4.1 clean up nfs4_alloc_session

-->Andy

On Feb 14, 2012, at 9:30 PM, Myklebust, Trond wrote:

> On Tue, 2012-02-14 at 20:50 -0500, Trond Myklebust wrote:
>> Hang on... Looking at 3.2, I think you're correct. We used to initialise
>> to 1, and now we're initialising to 0.
>> 
>> Ah... I see what happened.
>> 
>> commit aacd5537270a752fe12a9914a207284fc2341c6d (NFSv4.1: cleanup init
>> and reset of session slot tables) seems to have removed the call to
>> nfs4_reset_slot_tables() that was doing that initialisation. OK... So
>> this is a Linux 3.3-rcX only regression, and should be treated as
>> such...
>> 
>> How about the following instead so that we ensure we fully share the
>> initialisation code between nfs4_reset_slot_tables and
>> nfs4_init_slot_tables?
>> 
> 
> Here's a version 2 that does a few more cleanups by merging the
> nfs4_init_slot_table() and nfs4_reset_slot_table() into a single
> function.
> 
> 8<-------------------------------------------------------------------------
> From dea20ac15be192d0b4c4e367b7b61740ceee8dc4 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Tue, 14 Feb 2012 20:33:19 -0500
> Subject: [PATCH v2] NFSv4.1: Fix a NFSv4.1 session initialisation regression
> 
> Commit aacd553 (NFSv4.1: cleanup init and reset of session slot tables)
> introduces a regression in the session initialisation code. New tables
> now find their sequence ids initialised to 0, rather than the mandated
> value of 1 (see RFC5661).
> 
> Fix the problem by merging nfs4_reset_slot_table() and nfs4_init_slot_table().
> Since the tbl->max_slots is initialised to 0, the test in
> nfs4_reset_slot_table for max_reqs != tbl->max_slots will automatically
> pass for an empty table.
> 
> Reported-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/nfs4proc.c |  109 ++++++++++++++++++++--------------------------------
> 1 files changed, 42 insertions(+), 67 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d202e04..1684c9b 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5008,37 +5008,53 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
> 	return status;
> }
> 
> +static struct nfs4_slot *nfs4_alloc_slots(u32 max_slots, gfp_t gfp_flags)
> +{
> +	return kcalloc(max_slots, sizeof(struct nfs4_slot), gfp_flags);
> +}
> +
> +static void nfs4_add_and_init_slots(struct nfs4_slot_table *tbl,
> +		struct nfs4_slot *new,
> +		u32 max_slots,
> +		u32 ivalue)
> +{
> +	struct nfs4_slot *old = NULL;
> +	u32 i;
> +
> +	spin_lock(&tbl->slot_tbl_lock);
> +	if (new) {
> +		old = tbl->slots;
> +		tbl->slots = new;
> +		tbl->max_slots = max_slots;
> +	}
> +	tbl->highest_used_slotid = -1;	/* no slot is currently used */
> +	for (i = 0; i < tbl->max_slots; i++)
> +		tbl->slots[i].seq_nr = ivalue;
> +	spin_unlock(&tbl->slot_tbl_lock);
> +	kfree(old);
> +}
> +
> /*
> - * Reset a slot table
> + * (re)Initialise a slot table
>  */
> -static int nfs4_reset_slot_table(struct nfs4_slot_table *tbl, u32 max_reqs,
> -				 int ivalue)
> +static int nfs4_realloc_slot_table(struct nfs4_slot_table *tbl, u32 max_reqs,
> +				 u32 ivalue)
> {
> 	struct nfs4_slot *new = NULL;
> -	int i;
> -	int ret = 0;
> +	int ret = -ENOMEM;
> 
> 	dprintk("--> %s: max_reqs=%u, tbl->max_slots %d\n", __func__,
> 		max_reqs, tbl->max_slots);
> 
> 	/* Does the newly negotiated max_reqs match the existing slot table? */
> 	if (max_reqs != tbl->max_slots) {
> -		ret = -ENOMEM;
> -		new = kmalloc(max_reqs * sizeof(struct nfs4_slot),
> -			      GFP_NOFS);
> +		new = nfs4_alloc_slots(max_reqs, GFP_NOFS);
> 		if (!new)
> 			goto out;
> -		ret = 0;
> -		kfree(tbl->slots);
> -	}
> -	spin_lock(&tbl->slot_tbl_lock);
> -	if (new) {
> -		tbl->slots = new;
> -		tbl->max_slots = max_reqs;
> 	}
> -	for (i = 0; i < tbl->max_slots; ++i)
> -		tbl->slots[i].seq_nr = ivalue;
> -	spin_unlock(&tbl->slot_tbl_lock);
> +	ret = 0;
> +
> +	nfs4_add_and_init_slots(tbl, new, max_reqs, ivalue);
> 	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
> 		tbl, tbl->slots, tbl->max_slots);
> out:
> @@ -5061,36 +5077,6 @@ static void nfs4_destroy_slot_tables(struct nfs4_session *session)
> }
> 
> /*
> - * Initialize slot table
> - */
> -static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
> -		int max_slots, int ivalue)
> -{
> -	struct nfs4_slot *slot;
> -	int ret = -ENOMEM;
> -
> -	BUG_ON(max_slots > NFS4_MAX_SLOT_TABLE);
> -
> -	dprintk("--> %s: max_reqs=%u\n", __func__, max_slots);
> -
> -	slot = kcalloc(max_slots, sizeof(struct nfs4_slot), GFP_NOFS);
> -	if (!slot)
> -		goto out;
> -	ret = 0;
> -
> -	spin_lock(&tbl->slot_tbl_lock);
> -	tbl->max_slots = max_slots;
> -	tbl->slots = slot;
> -	tbl->highest_used_slotid = -1;  /* no slot is currently used */
> -	spin_unlock(&tbl->slot_tbl_lock);
> -	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
> -		tbl, tbl->slots, tbl->max_slots);
> -out:
> -	dprintk("<-- %s: return %d\n", __func__, ret);
> -	return ret;
> -}
> -
> -/*
>  * Initialize or reset the forechannel and backchannel tables
>  */
> static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
> @@ -5101,25 +5087,16 @@ static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
> 	dprintk("--> %s\n", __func__);
> 	/* Fore channel */
> 	tbl = &ses->fc_slot_table;
> -	if (tbl->slots == NULL) {
> -		status = nfs4_init_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
> -		if (status) /* -ENOMEM */
> -			return status;
> -	} else {
> -		status = nfs4_reset_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
> -		if (status)
> -			return status;
> -	}
> +	status = nfs4_realloc_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
> +	if (status) /* -ENOMEM */
> +		return status;
> 	/* Back channel */
> 	tbl = &ses->bc_slot_table;
> -	if (tbl->slots == NULL) {
> -		status = nfs4_init_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
> -		if (status)
> -			/* Fore and back channel share a connection so get
> -			 * both slot tables or neither */
> -			nfs4_destroy_slot_tables(ses);
> -	} else
> -		status = nfs4_reset_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
> +	status = nfs4_realloc_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
> +	if (status && tbl->slots == NULL)
> +		/* Fore and back channel share a connection so get
> +		 * both slot tables or neither */
> +		nfs4_destroy_slot_tables(ses);
> 	return status;
> }
> 
> @@ -5133,13 +5110,11 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
> 		return NULL;
> 
> 	tbl = &session->fc_slot_table;
> -	tbl->highest_used_slotid = -1;
> 	spin_lock_init(&tbl->slot_tbl_lock);
> 	rpc_init_priority_wait_queue(&tbl->slot_tbl_waitq, "ForeChannel Slot table");
> 	init_completion(&tbl->complete);
> 
> 	tbl = &session->bc_slot_table;
> -	tbl->highest_used_slotid = -1;
> 	spin_lock_init(&tbl->slot_tbl_lock);
> 	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "BackChannel Slot table");
> 	init_completion(&tbl->complete);
> -- 
> 1.7.7.6
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

