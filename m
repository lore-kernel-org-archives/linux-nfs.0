Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f194.google.com ([209.85.216.194]:47651 "EHLO
	mail-qc0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965647AbaGPTQm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 15:16:42 -0400
Received: by mail-qc0-f194.google.com with SMTP id i17so398823qcy.1
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 12:16:41 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 16 Jul 2014 15:16:40 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 09/10] nfsd: Fix delegation revocation
Message-ID: <20140716151640.6bb42713@tlielax.poochiereds.net>
In-Reply-To: <20140716183047.GA19002@infradead.org>
References: <1405521125-2303-1-git-send-email-jlayton@primarydata.com>
	<1405521125-2303-10-git-send-email-jlayton@primarydata.com>
	<20140716183047.GA19002@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Jul 2014 11:30:47 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> > -/* Called under the state lock. */
> 
> You're removing a comment hat only becomes true after your patch :)
> 
> But I agree that it's obsolete, the lockdep_assert_held is better than
> the comment.
> 

Yeah, the other problem is that that comment is ambiguous. Does it mean
the state_lock or the client_mutex (which is also sometimes termed
"state lock" in this code).

> > @@ -685,11 +686,10 @@ static void revoke_delegation(struct nfs4_delegation *dp)
> >  	struct nfs4_client *clp = dp->dl_stid.sc_client;
> >  
> >  	if (clp->cl_minorversion == 0)
> > -		destroy_delegation(dp);
> > +		destroy_revoked_delegation(dp);
> 
> Seems a little confusing as we didn't turn the code into a REVOKED_DELEG
> stateid type yet, but given that destroy_revoked_delegation doesn't
> care this is probably fine.
> 

True, but since we're destroying it anyway we don't need to revoke it.
Still it is less confusing and since I'm respinning for other reasons,
I can change that too...

> >  	else {
> > -		unhash_delegation(dp);
> >  		dp->dl_stid.sc_type = NFS4_REVOKED_DELEG_STID;
> > -		list_add(&dp->dl_recall_lru, &clp->cl_revoked);
> > +		list_move(&dp->dl_recall_lru, &clp->cl_revoked);
> 
> What protects access to cl_revoked, btw?
> 

At this point in the series, the client_mutex does. There's a patch
later that protects the cl_revoked list with the cl_lock, but it
depends on some other locking changes and so it's harder to move it to
the front of the series just yet.

> Otherwise this looks fine to me,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> (would have been a little nicer to read if you had kept
> destroy_revoked_delegation, otherwise diff obsfucates the fact that it
> didn't change at all..

Thanks. Do you mean destroy_delegation? destroy_revoked_delegation
still exists -- destroy_delegation is removed, but it's just a wrapper
around nfs4_put_delegation at this point...

-- 
Jeff Layton <jlayton@primarydata.com>
