Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60572 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750883Ab2BOPB7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 10:01:59 -0500
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs41: Initialize slot->seq_nr at nfs4_init_slot_table()
Date: Wed, 15 Feb 2012 15:01:26 +0000
Message-ID: <0C12B635-0094-4099-B96C-3637B914A814@netapp.com>
References: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>
 <1329259606.11759.15.camel@lade.trondhjem.org>
 <4F3AFD84.3020709@nexenta.com> <1329266587.28837.4.camel@lade.trondhjem.org>
 <20120215005315.GA9018@fieldses.org>
 <1329270628.28837.15.camel@lade.trondhjem.org>
In-Reply-To: <1329270628.28837.15.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 14, 2012, at 8:50 PM, Myklebust, Trond wrote:

> On Tue, 2012-02-14 at 19:53 -0500, J. Bruce Fields wrote:
>> On Wed, Feb 15, 2012 at 12:43:08AM +0000, Myklebust, Trond wrote:
>>> Then we have a problem. The zero initialisation is already in use out
>>> there in both commercial and non-commercial versions of Linux. It is too
>>> late to change that now.
>>> 
>>> Furthermore, since none of the servers we've tested against in earlier
>>> Bakeathons and Connectathons have complained, I suggest that we rather
>>> change the spec with an errata.
>> 
>> Argh.
>> 
>> I just noticed that the server was crashing intermittently and traced it
>> to incorrect handling of the case where the client sends a one-op
>> SEQUENCE compound with seqid 0.  I'm not sure why it started popping up
>> just in 3.3--perhaps some change in the way the client uses slots made
>> that more likely.
>> 
>> The server code actually looks like it did assume initial seqid 1, but
>> accepted initial seqid 0 (except in this one case) basically by mistake.
>> 
>> In any case, I think it should be easy enough to teach it just to accept
>> any seqid on a previously unused slot, so I'll do that....
> 
> Hang on... Looking at 3.2, I think you're correct. We used to initialise
> to 1, and now we're initialising to 0.

No, commit aacd5537270a752fe12a9914a207284fc2341c6d initializes and resets the slot tables with the ivalue which is 1 for the forechannel and 0 for the back channel, just as in 3.2. 

To be clear from aacd5537:

-static int nfs4_init_slot_tables(struct nfs4_session *session)
+static int nfs4_setup_session_slot_tables(struct nfs4_session *ses)
 {
        struct nfs4_slot_table *tbl;
-       int status = 0;
+       int status;
 
-       tbl = &session->fc_slot_table;
+       dprintk("--> %s\n", __func__);
+       /* Fore channel */
+       tbl = &ses->fc_slot_table;
        if (tbl->slots == NULL) {
-               status = nfs4_init_slot_table(tbl,
-                               session->fc_attrs.max_reqs, 1);
                                                                             ^^^^^^^
                                                                             ivalue of 1

+               status = nfs4_init_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
                                                                                                                    ^^^^^
                                                                                                                  ivalue of 1
+               if (status) /* -ENOMEM */
+                       return status;
+       } else {
+               status = nfs4_reset_slot_table(tbl, ses->fc_attrs.max_reqs, 1);
                                                                                                                    ^^^^^
                                                                                                                  ivalue of 1
                if (status)
                        return status;
        }
-
-       tbl = &session->bc_slot_table;
+       /* Back channel */
+       tbl = &ses->bc_slot_table;
        if (tbl->slots == NULL) {
-               status = nfs4_init_slot_table(tbl,
-                               session->bc_attrs.max_reqs, 0);
+               status = nfs4_init_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
                if (status)
-                       nfs4_destroy_slot_tables(session);
-       }
-
+                       /* Fore and back channel share a connection so get
+                        * both slot tables or neither */
+                       nfs4_destroy_slot_tables(ses);
+       } else
+               status = nfs4_reset_slot_table(tbl, ses->bc_attrs.max_reqs, 0);
        return status;
 }


-->Andy

> 
> Ah... I see what happened.
> 
> commit aacd5537270a752fe12a9914a207284fc2341c6d (NFSv4.1: cleanup init
> and reset of session slot tables) seems to have removed the call to
> nfs4_reset_slot_tables() that was doing that initialisation. OK.
> this is a Linux 3.3-rcX only regression, and should be treated as
> such...
> 
> How about the following instead so that we ensure we fully share the
> initialisation code between nfs4_reset_slot_tables and
> nfs4_init_slot_tables?
> 
> 8<-------------------------------------------------------------------------
> From 8ae8d177cc106ecdb3e29b48c78ec37cf76ea549 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Tue, 14 Feb 2012 20:33:19 -0500
> Subject: [PATCH] NFSv4.1: Fix a NFSv4.1 session initialisation regression
> 
> Commit aacd553 (NFSv4.1: cleanup init and reset of session slot tables)
> introduces a regression in the session initialisation code. New tables
> now find their sequence ids initialised to 0, rather than the mandated
> value of 1 (see RFC5661).
> 
> Reported-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/nfs4proc.c |   58 ++++++++++++++++++++++++++++++++---------------------
> 1 files changed, 35 insertions(+), 23 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d202e04..9f76ce9 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5008,37 +5008,53 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
> 	return status;
> }
> 
> +static struct nfs4_slot *nfs4_session_alloc_slots(u32 max_slots, gfp_t gfp_flags)
> +{
> +	return kcalloc(max_slots, sizeof(struct nfs4_slot), gfp_flags);
> +}
> +
> +static void nfs4_session_add_slots(struct nfs4_slot_table *tbl,
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
>  * Reset a slot table
>  */
> static int nfs4_reset_slot_table(struct nfs4_slot_table *tbl, u32 max_reqs,
> -				 int ivalue)
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
> +		new = nfs4_session_alloc_slots(max_reqs, GFP_NOFS);
> 		if (!new)
> 			goto out;
> -		ret = 0;
> -		kfree(tbl->slots);
> 	}
> -	spin_lock(&tbl->slot_tbl_lock);
> -	if (new) {
> -		tbl->slots = new;
> -		tbl->max_slots = max_reqs;
> -	}
> -	for (i = 0; i < tbl->max_slots; ++i)
> -		tbl->slots[i].seq_nr = ivalue;
> -	spin_unlock(&tbl->slot_tbl_lock);
> +	ret = 0;
> +
> +	nfs4_session_add_slots(tbl, new, max_reqs, ivalue);
> 	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
> 		tbl, tbl->slots, tbl->max_slots);
> out:
> @@ -5064,7 +5080,7 @@ static void nfs4_destroy_slot_tables(struct nfs4_session *session)
>  * Initialize slot table
>  */
> static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
> -		int max_slots, int ivalue)
> +		u32 max_slots, u32 ivalue)
> {
> 	struct nfs4_slot *slot;
> 	int ret = -ENOMEM;
> @@ -5073,16 +5089,12 @@ static int nfs4_init_slot_table(struct nfs4_slot_table *tbl,
> 
> 	dprintk("--> %s: max_reqs=%u\n", __func__, max_slots);
> 
> -	slot = kcalloc(max_slots, sizeof(struct nfs4_slot), GFP_NOFS);
> +	slot = nfs4_session_alloc_slots(max_slots, GFP_NOFS);
> 	if (!slot)
> 		goto out;
> 	ret = 0;
> 
> -	spin_lock(&tbl->slot_tbl_lock);
> -	tbl->max_slots = max_slots;
> -	tbl->slots = slot;
> -	tbl->highest_used_slotid = -1;  /* no slot is currently used */
> -	spin_unlock(&tbl->slot_tbl_lock);
> +	nfs4_session_add_slots(tbl, slot, max_slots, ivalue);
> 	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
> 		tbl, tbl->slots, tbl->max_slots);
> out:
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

