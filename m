Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41419 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751357Ab2CUVFg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 17:05:36 -0400
Date: Wed, 21 Mar 2012 17:05:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v10 1/8] nfsd: convert nfs4_client->cl_cb_flags to a
 generic flags field
Message-ID: <20120321210532.GD12309@fieldses.org>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
 <1332337929-18580-2-git-send-email-jlayton@redhat.com>
 <20120321204142.GB12309@fieldses.org>
 <20120321165244.4ed5977e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120321165244.4ed5977e@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 21, 2012 at 04:52:44PM -0400, Jeff Layton wrote:
> On Wed, 21 Mar 2012 16:41:42 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Mar 21, 2012 at 09:52:02AM -0400, Jeff Layton wrote:
> > > @@ -2779,12 +2780,6 @@ static void
> > >  nfs4_set_claim_prev(struct nfsd4_open *open, bool has_session)
> > >  {
> > >  	open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
> > > -	/*
> > > -	 * On a 4.1+ client, we don't create a state record for a client
> > > -	 * until it performs RECLAIM_COMPLETE:
> > > -	 */
> > > -	if (!has_session)
> > > -		open->op_openowner->oo_owner.so_client->cl_firststate = 1;
> > 
> > That doesn't look right.  Sure you didn't mean to just make that a
> > set_bit, at least for now?
> > 
> > --b.
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> No. I think that's correct. Once the RECLAIM_COMPLETE is done, we'll
> create a client record and then the NFSD4_CLIENT_STABLE flag will be
> set. We clearly don't want to set that flag until the client is
> actually recorded onto stable storage.
> 
> One of the goals of this patch was to get rid of cl_firststate which
> had a very ambiguous meaning. NFSD4_CLIENT_STABLE now means that the
> client is recorded on stable storage, full stop.
> 
> Did I miss some subtlety that we'll need to account for in the state
> model here?

Oh, I see, I missed that nfsd4_client_record_check is setting the flag
where I think it wouldn't have been before.

This does look cleaner, thanks!

--b.
