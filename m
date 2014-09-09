Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:44418 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbaIIU47 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 16:56:59 -0400
Received: by mail-qg0-f41.google.com with SMTP id a108so4410813qge.28
        for <linux-nfs@vger.kernel.org>; Tue, 09 Sep 2014 13:56:58 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 9 Sep 2014 16:56:51 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH v3 7/8] nfsd: set and test NFSD4_CLIENT_STABLE bit to
 reduce nfsdcltrack upcalls
Message-ID: <20140909165651.3f373521@tlielax.poochiereds.net>
In-Reply-To: <20140909204617.GC17979@fieldses.org>
References: <1410187609-10319-1-git-send-email-jlayton@primarydata.com>
	<1410187609-10319-8-git-send-email-jlayton@primarydata.com>
	<20140909204617.GC17979@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 9 Sep 2014 16:46:17 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Sep 08, 2014 at 10:46:48AM -0400, Jeff Layton wrote:
> > The nfsdcltrack upcall doesn't utilize the NFSD4_CLIENT_STABLE flag,
> > which basically results in an upcall every time we call into the client
> > tracking ops.
> > 
> > Change it to set this bit on a successful "check" or "create" request,
> > and clear it on a "remove" request.  Also, check to see if that bit is
> > set before upcalling on a "check" or "remove" request, and skip
> > upcalling appropriately, depending on its state.
> > 
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/nfsd/nfs4recover.c | 22 ++++++++++++++++++----
> >  1 file changed, 18 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> > index ae313861a6f5..5697e9d2e875 100644
> > --- a/fs/nfsd/nfs4recover.c
> > +++ b/fs/nfsd/nfs4recover.c
> > @@ -1291,7 +1291,8 @@ nfsd4_umh_cltrack_create(struct nfs4_client *clp)
> >  	grace_start = nfsd4_cltrack_grace_start(nn->boot_time);
> >  
> >  	nfsd4_cltrack_upcall_lock(clp);
> > -	nfsd4_umh_cltrack_upcall("create", hexid, reclaim_complete, grace_start);
> > +	if (!nfsd4_umh_cltrack_upcall("create", hexid, reclaim_complete, grace_start))
> > +		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
> 
> Don't you also want to skip the upcall when STABLE is set?
> 
> (Not a big deal in the 4.1 case as it's only called once per client (in
> RECLAIM_COMPLETE) but annoying in the 4.0 case where it's called on
> every OPEN_CONFIRM.)
> 
> --b.
> 

Ahh right, I was thinking that we'd only get one OPEN_CONFIRM per
client, but you have to do it for each openowner...

No, we can't do that. Consider the case where we might do some "check"
ops before the "create" operation (i.e. we need to do some reclaims).

The "check" will set the STABLE flag, and then the create operation
gets skipped. That means that the grace period won't get lifted early
even when the RECLAIM_COMPLETE comes in since the reclaim_complete
field in the DB didn't get updated.

We could (in principle) add a new flag that indicates whether a
"create" has already been done for a client, and use that to skip
subsequent "create" ops. Sound reasonable?

> >  	nfsd4_cltrack_upcall_unlock(clp);
> >  
> >  	kfree(reclaim_complete);
> > @@ -1304,6 +1305,9 @@ nfsd4_umh_cltrack_remove(struct nfs4_client *clp)
> >  {
> >  	char *hexid;
> >  
> > +	if (!test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
> > +		return;
> > +
> >  	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
> >  	if (!hexid) {
> >  		dprintk("%s: can't allocate memory for upcall!\n", __func__);
> > @@ -1311,7 +1315,9 @@ nfsd4_umh_cltrack_remove(struct nfs4_client *clp)
> >  	}
> >  
> >  	nfsd4_cltrack_upcall_lock(clp);
> > -	nfsd4_umh_cltrack_upcall("remove", hexid, NULL, NULL);
> > +	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags) &&
> > +	    nfsd4_umh_cltrack_upcall("remove", hexid, NULL, NULL) == 0)
> > +		clear_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
> >  	nfsd4_cltrack_upcall_unlock(clp);
> >  
> >  	kfree(hexid);
> > @@ -1323,6 +1329,9 @@ nfsd4_umh_cltrack_check(struct nfs4_client *clp)
> >  	int ret;
> >  	char *hexid, *legacy;
> >  
> > +	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
> > +		return 0;
> > +
> >  	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
> >  	if (!hexid) {
> >  		dprintk("%s: can't allocate memory for upcall!\n", __func__);
> > @@ -1331,9 +1340,14 @@ nfsd4_umh_cltrack_check(struct nfs4_client *clp)
> >  	legacy = nfsd4_cltrack_legacy_recdir(&clp->cl_name);
> >  
> >  	nfsd4_cltrack_upcall_lock(clp);
> > -	ret = nfsd4_umh_cltrack_upcall("check", hexid, legacy, NULL);
> > +	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags)) {
> > +		ret = 0;
> > +	} else {
> > +		ret = nfsd4_umh_cltrack_upcall("check", hexid, legacy, NULL);
> > +		if (!ret)
> > +			set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
> > +	}
> >  	nfsd4_cltrack_upcall_unlock(clp);
> > -
> >  	kfree(legacy);
> >  	kfree(hexid);
> >  	return ret;
> > -- 
> > 1.9.3
> > 


-- 
Jeff Layton <jlayton@primarydata.com>
