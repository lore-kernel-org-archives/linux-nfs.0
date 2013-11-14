Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59244 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753157Ab3KNPFw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Nov 2013 10:05:52 -0500
Date: Thu, 14 Nov 2013 10:05:46 -0500
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: sharing protocol defintions between client and server?
Message-ID: <20131114150546.GA21152@fieldses.org>
References: <20131113162116.GA14577@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131113162116.GA14577@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 13, 2013 at 08:21:16AM -0800, Christoph Hellwig wrote:
> >From a lot of the recent work it seems like there's basically no
> sharing of protocol definitions between the Linux NFS client and
> server, which seems fairly annoying to me.

What are you thinking of exactly?

I suspect that there could be more sharing.

> Is there a good historic
> reason for this and did we ever attempt to change it?  Maybe even
> use some kernel-specific rpcgen variant to generate them directly
> from the spec?

I don't know if anyone's looked into it.

There's a lot of hand-written xdr code (the encoders/decoders
themselves, the maxsz constants in fs/nfs/nfs*xdr.c, the _rsize junk in
fs/nfsd/nfs4proc.c, ...).  It seems error-prone to me though I can't
recall if we've had a lot of bugs there in practice.

--b.
