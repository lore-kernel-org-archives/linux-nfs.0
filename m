Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46498 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210AbbHYTVN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2015 15:21:13 -0400
Date: Tue, 25 Aug 2015 15:21:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Andrew W Elble <aweits@rit.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/2] nfsd: ensure that the ol stateid hash reference
 is only put once
Message-ID: <20150825192113.GB8579@fieldses.org>
References: <1440434508-16046-1-git-send-email-jeff.layton@primarydata.com>
 <1440434508-16046-2-git-send-email-jeff.layton@primarydata.com>
 <20150824203456.GA708@fieldses.org>
 <20150824164056.26ef0c2a@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150824164056.26ef0c2a@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 24, 2015 at 04:40:56PM -0400, Jeff Layton wrote:
> On Mon, 24 Aug 2015 16:34:56 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Aug 24, 2015 at 12:41:47PM -0400, Jeff Layton wrote:
> > > When an open or lock stateid is hashed, we take an extra reference to
> > > it. When we unhash it, we drop that reference. The code however does
> > > not properly account for the case where we have two callers concurrently
> > > trying to unhash the stateid. This can lead to list corruption and the
> > > hash reference being put more than once.
> > > 
> > > Fix this by having unhash_ol_stateid use list_del_init on the st_perfile
> > > list_head, and then testing to see if that list_head is empty before
> > > releasing the hash reference. This means that some of the unhashing
> > > wrappers now become bool return functions so we can test to see whether
> > > the stateid was unhashed before we put the reference.
> > 
> > Can we make this any simpler if we make unhash_ol_stateid do the put
> > itself instead of making every caller do it?
> > 
> 
> The problem is that unhashing requires you to hold the cl_lock, whereas
> the put requires that you do not hold it.
> 
> > Also, while I'm looking at that....  The stateid-putting code is
> > partially duplicated between nfs4_put_stid and put_ol_stateid_locked,
> > with the difference just being that the latter moves stuff to a list so
> > we can put a bunch at once under one cl_lock.  It'd be nice if we could
> > remove that bit of duplication.
> > 
> > Haven't tried yet, though.
> > 
> 
> There is a lot of variation here, but again the locking dictates how it
> works. nfs4_put_stid is called without holding the cl_lock, and it only
> takes it if the refcount goes to 0.
> 
> put_ol_stateid_locked is called while holding it. Since we can't call
> sc_free while holding the spinlock, it has to defer that activity by
> putting the objects on the list.
> 
> There might be a little opportunity for consolidation there, but I
> think we're stuck with at least some duplication.

OK, fair enough.  Anyway, these look correct and we've got confirmation
from testing now, so if we do find any chances to cleanup that should
probably be incremental--applying these for now.

--b.
