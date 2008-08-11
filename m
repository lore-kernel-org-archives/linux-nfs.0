From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] fix nfsd stateid encoding
Date: Mon, 11 Aug 2008 11:58:42 -0400
Message-ID: <20080811155842.GC32193@fieldses.org>
References: <48A04820.5000409@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58858 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852AbYHKP6n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Aug 2008 11:58:43 -0400
In-Reply-To: <48A04820.5000409@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 11, 2008 at 05:09:36PM +0300, Benny Halevy wrote:
> Bruce, in a couple locations the nfsd needs to encode the stateid.seqid
> as a uint32_t rather than as opaque.

Agreed, thanks.

Though I have a hard time figuring out whether this has any impact in
practice.  Presumably the only change on the wire is that we'll get the
endianness of the stateid4.seqid right?  But that field is mostly opaque
to the client anyway; 3530 says

	The server is required to increment the seqid field
	monotonically at each transition of the stateid.  This is
	important since the client will inspect the seqid in OPEN
	stateids to determine the order of OPEN processing done by the
	server.

but doesn't say why this is important.  I'm sure this has been brought
up on the ietf list before, but can't recall whether someone came up
with a justification for the importance of this.

Anyway, so I figure these should be queued up for the next (2.6.28)
merge window.  Thanks!

--b.

> 
> Patch #1 fixes that for cb_recall.
> Patch #2 fixes the deleg stateid returned by open.
> 
> The patches should apply to linux-2.6/master 
> commit 796aadeb1b2db9b5d463946766c5bbfd7717158c
> 
> Benny
