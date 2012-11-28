Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58231 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755047Ab2K1QrW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 11:47:22 -0500
Date: Wed, 28 Nov 2012 11:47:21 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 03/10] NFSD: Clean up forgetting clients
Message-ID: <20121128164721.GA15966@fieldses.org>
References: <1354026919-13313-1-git-send-email-bjschuma@netapp.com>
 <1354026919-13313-4-git-send-email-bjschuma@netapp.com>
 <20121128162920.GK11651@fieldses.org>
 <50B63D20.7050300@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50B63D20.7050300@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 28, 2012 at 11:34:40AM -0500, Bryan Schumaker wrote:
> On 11/28/2012 11:29 AM, J. Bruce Fields wrote:
> > On Tue, Nov 27, 2012 at 09:35:12AM -0500, bjschuma@netapp.com wrote:
> >> From: Bryan Schumaker <bjschuma@netapp.com>
> >>
> >> I added in a generic for-each loop that takes a pass over the
> >> client_lru list and calls some function.  The next few patches will
> >> update other operations to use this function as well.  A value of 0
> >> still means "forget everything that is found".
> >>
> >> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com> ---
> >> fs/nfsd/nfs4state.c | 23 ++++++++++++++++++----- 1 file changed, 18
> >> insertions(+), 5 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c index
> >> 050a35e..07abca5 100644 --- a/fs/nfsd/nfs4state.c +++
> >> b/fs/nfsd/nfs4state.c @@ -4591,19 +4591,32 @@
> >> nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct
> >> nfsd_net *nn)
> >>  
> >>  #ifdef CONFIG_NFSD_FAULT_INJECTION
> >>  
> >> -void nfsd_forget_clients(u64 num) +u64 nfsd_forget_client(struct
> >> nfsd_net *nn, struct nfs4_client *clp, u64 max)
> > 
> > It doesn't look like you really need nfsd_net?
> 
> Not for this, but I find locks through the nn->ownerstr_hashtable
> since the nfs4_client doesn't have a "cl_locks" list similar to
> "cl_openowners" (unless there is something I'm missing...?).

That's because lockowners are all reachable from openowners (e.g. see
how it's done in
release_openowner->unhash_openowner->release_open_stateid->unhash_open_stateid->release_stateid_lockowners.
Yeah, it's a little tangled.).

Alternatively you can get to the network namespace from the client
(clp->net).

--b.

> I
> figured I would introduce the function with the nfsd_net pointer
> early, rather than change it in the next patch.
> 
> I suppose I could have also put the locks patch first...
> 
> - Bryan
> 
> > 
> > --b.
> > 
> >> +{ +	nfsd4_client_record_remove(clp); +
> >> expire_client(clp); +	return 1; +} + +static u64
> >> nfsd_for_n_state(u64 max, u64 (*func)(struct nfsd_net *, struct
> >> nfs4_client *, u64)) { struct nfs4_client *clp, *next; -	int
> >> count = 0; +	u64 count = 0; struct nfsd_net *nn =
> >> net_generic(current->nsproxy->net_ns, nfsd_net_id);
> >>  
> >>  	list_for_each_entry_safe(clp, next, &nn->client_lru, cl_lru) { -
> >>  	expire_client(clp); -		if (++count == num) +
> >>  	count += func(nn, clp, max - count); +		if ((max != 0)
> >>  	&& (count >= max)) break; }
> >>  
> >> -	printk(KERN_INFO "NFSD: Forgot %d clients", count); +	return
> >> count; +} + +void nfsd_forget_clients(u64 num) +{ +	u64
> >> count = nfsd_for_n_state(num, nfsd_forget_client); +
> >> printk(KERN_INFO "NFSD: Forgot %llu clients", count); }
> >>  
> >>  static void release_lockowner_sop(struct nfs4_stateowner *sop) --
> >>  1.8.0.1
> >>
> 
> -- To unsubscribe from this list: send the line "unsubscribe
> linux-nfs" in the body of a message to majordomo@vger.kernel.org More
> majordomo info at  http://vger.kernel.org/majordomo-info.html
