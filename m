Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59416 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752932Ab3J2Njw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 09:39:52 -0400
Date: Tue, 29 Oct 2013 09:39:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: no need to unhash_stid before free
Message-ID: <20131029133951.GG29606@fieldses.org>
References: <1381730515-18045-1-git-send-email-bhalevy@primarydata.com>
 <20131028183214.GH31322@fieldses.org>
 <526F5CFF.2080003@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <526F5CFF.2080003@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 09:00:15AM +0200, Benny Halevy wrote:
> On 2013-10-28 20:32, J. Bruce Fields wrote:
> > On Mon, Oct 14, 2013 at 09:01:55AM +0300, Benny Halevy wrote:
> >> idr_remove is about to be called before kmem_cache_free so unhashing it
> >> is redundant
> > 
> > This leaves only two unhash_stid callers, in release_lock_stateid and
> > unhash_stid, both called just before destroying the stateid, so perhaps
> > we should remove those and unhash_stid?
> 
> In my state lock elimination patchset I actually keep using unhash_stid
> after refactoring non-blocking unhashing from the blocking release
> so I don't think it's worth it to remove the call.
> That said, we can still open code it but encapsulating the assignment
> in unhash_stid() which the compiler can inline anyway seems cleaner to me.

OK, sure, sounds fine.

--b.

> 
> Benny
> 
> > 
> > --b.
> > 
> >>
> >> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> >> ---
> >>  fs/nfsd/nfs4state.c | 7 ++-----
> >>  1 file changed, 2 insertions(+), 5 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index 0874998..06984e3 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -668,7 +668,6 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
> >>  static void release_open_stateid(struct nfs4_ol_stateid *stp)
> >>  {
> >>  	unhash_open_stateid(stp);
> >> -	unhash_stid(&stp->st_stid);
> >>  	free_generic_stateid(stp);
> >>  }
> >>  
> >> @@ -690,7 +689,6 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
> >>  	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
> >>  
> >>  	if (s) {
> >> -		unhash_stid(&s->st_stid);
> >>  		free_generic_stateid(s);
> >>  		oo->oo_last_closed_stid = NULL;
> >>  	}
> >> @@ -3998,10 +3996,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
> >>  
> >>  	nfsd4_close_open_stateid(stp);
> >>  
> >> -	if (cstate->minorversion) {
> >> -		unhash_stid(&stp->st_stid);
> >> +	if (cstate->minorversion)
> >>  		free_generic_stateid(stp);
> >> -	} else
> >> +	else
> >>  		oo->oo_last_closed_stid = stp;
> >>  
> >>  	if (list_empty(&oo->oo_owner.so_stateids)) {
> >> -- 
> >> 1.8.3.1
> >>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
