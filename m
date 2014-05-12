Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758554AbaELOTC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 May 2014 10:19:02 -0400
Date: Mon, 12 May 2014 10:18:40 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 39/43] nfsd4: really fix nfs4err_resource in 4.1 case
Message-ID: <20140512141840.GC2633@pad.redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-40-git-send-email-bfields@redhat.com>
 <20140512053317.GA29134@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140512053317.GA29134@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 11, 2014 at 10:33:17PM -0700, Christoph Hellwig wrote:
> > +	if (op->status == nfserr_resource && nfsd4_has_session(&resp->cstate)) {
> > +		struct nfsd4_slot *slot = resp->cstate.slot;
> > +
> > +		if (slot->sl_flags & NFSD4_SLOT_CACHETHIS)
> > +			op->status = nfserr_rep_too_big_to_cache;
> > +		else
> > +			op->status = nfserr_rep_too_big;
> 
> There is a closing brace missing here, which breaks the compile for me.

Aie, sorry, I guess I didn't test anything after moving that patch back
in the series.  I normally do a quick test-compile of whatever a patch
touched while rebasing, then run a set of regression tests before
posting.  But in this case I think I finished the rebase in a hurry
Friday, then posted Sunday without remembering what exactly I'd last
done....

Anyway, fixed, new tests are running--thanks for the review.

--b.
