From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 0/2] fix nfsd stateid encoding
Date: Mon, 11 Aug 2008 12:27:47 -0400
Message-ID: <20080811162747.GA772@fieldses.org>
References: <48A04820.5000409@panasas.com> <20080811155842.GC32193@fieldses.org> <48A064BC.1050302@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40075 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014AbYHKQ1t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Aug 2008 12:27:49 -0400
In-Reply-To: <48A064BC.1050302@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 11, 2008 at 07:11:40PM +0300, Benny Halevy wrote:
> On Aug. 11, 2008, 18:58 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Mon, Aug 11, 2008 at 05:09:36PM +0300, Benny Halevy wrote:
> >> Bruce, in a couple locations the nfsd needs to encode the stateid.seqid
> >> as a uint32_t rather than as opaque.
> > 
> > Agreed, thanks.
> > 
> > Though I have a hard time figuring out whether this has any impact in
> > practice.  Presumably the only change on the wire is that we'll get the
> > endianness of the stateid4.seqid right?  But that field is mostly opaque
> > to the client anyway; 3530 says
> > 
> > 	The server is required to increment the seqid field
> > 	monotonically at each transition of the stateid.  This is
> > 	important since the client will inspect the seqid in OPEN
> > 	stateids to determine the order of OPEN processing done by the
> > 	server.
> > 
> > but doesn't say why this is important.  I'm sure this has been brought
> > up on the ietf list before, but can't recall whether someone came up
> > with a justification for the importance of this.
> > 
> > Anyway, so I figure these should be queued up for the next (2.6.28)
> > merge window.  Thanks!
> 
> Actually, I think this breaks delegreturn.
> Since we decode the stateid.si_generation correctly, it will get swabbed
> in delegreturn on little-endian servers.  This will cause
> nfs4_preprocess_stateid_op/check_stateid_generation as called by
> nfsd4_delegreturn to fail. And eventually, unhash_delegation
> wouldn't be called.

Yipes.  If delegations have always been broken and we haven't noticed,
then there's a more serious problem here--we should at least look into
why pynfs isn't catching that.

Oh, I see: si_generation is always zero for delegation stateid's!

> Hence, I think these patches are appropriate for 2.6.27 and
> even to older stable releases.

So unless I've missed something, I think this still looks more like a
style/consistency question?

--b.

> 
> Benny
> 
> > 
> > --b.
> > 
> >> Patch #1 fixes that for cb_recall.
> >> Patch #2 fixes the deleg stateid returned by open.
> >>
> >> The patches should apply to linux-2.6/master 
> >> commit 796aadeb1b2db9b5d463946766c5bbfd7717158c
> >>
> >> Benny
> > _______________________________________________
> > pNFS mailing list
> > pNFS@linux-nfs.org
> > http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
> 
