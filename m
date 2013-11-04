Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:40223 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263Ab3KDTyM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 14:54:12 -0500
Date: Mon, 4 Nov 2013 11:54:08 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <bjschuma@netapp.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Message-ID: <20131104195408.GA7383@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131102135238.GB18961@infradead.org>
 <5277CE23.6010207@netapp.com>
 <20131104170345.GA31499@infradead.org>
 <5277D80F.8050106@netapp.com>
 <20131104185309.GA14378@infradead.org>
 <3AC4ECC6-0496-4593-8791-92BCAD2567CC@oracle.com>
 <20131104191907.GA9337@infradead.org>
 <8EB0049A-9225-4C4A-8099-774B2EB48323@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8EB0049A-9225-4C4A-8099-774B2EB48323@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 04, 2013 at 11:50:51AM -0800, Chuck Lever wrote:
> I think a successful argument could be made that initialization or hole punching may not belong in a WRITE_PLUS operation.  For example, using a COMMIT for a long-running server-performed file initialization doesn't make sense to me.  The infrastructure we introduced for COPY_OFFLOAD seems better suited for file initialization.

I've been going through the latest draft and will submit a counter
proposal in a few days time.

> > It's not like adding new operations to NFS is all that hard.
> 
> Actually, it is harder than you think.  For various reasons, it takes five or more years to create a new NFS protocol specification, something we hope to address.

I see the pain in getting new minor versions out.  But that pain is
shared between adding a new operation and a new arm to an union.

> By the way, e-mail from non-members to nfsv4@ietf.org is moderated.  The moderator may be traveling or otherwise unavailable, as IETF 88 is happening this week.  If you subscribe to the list, you should be able to post without restriction.

I have been subscribed longer than I've been posting to it.

