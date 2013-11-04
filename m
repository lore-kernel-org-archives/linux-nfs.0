Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39923 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719Ab3KDSxM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 13:53:12 -0500
Date: Mon, 4 Nov 2013 10:53:09 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Message-ID: <20131104185309.GA14378@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131102135238.GB18961@infradead.org>
 <5277CE23.6010207@netapp.com>
 <20131104170345.GA31499@infradead.org>
 <5277D80F.8050106@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5277D80F.8050106@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 04, 2013 at 12:23:27PM -0500, Anna Schumaker wrote:
> > state" that will return zeroes when read, even if those zeroes didn't
> > make it to disk.
> 
> And that's all done through metadata?  Doing the commit_metadata() call makes a bit more sense now.

Yes.  The only filesystem in tree that actually seems to write zeroes
is gfs2, but even then it doesn't do so through the usual mechanisms.

> > Also what does the data arm buy us over good old WRITE?
> > 
> 
> I've been working off of draft #21, the most recent commit is 2b3ab1740b1ea843faa59566fb4213a42d8c724a from Aug 19.  The eventual goal is to phase out WRITE and replace it with WRITE_PLUS, but that won't happen until at least 4.3.  I don't know why it's being done this way instead of just adding an FALLOCATE operation.

Where can I find draft 21?  The newest document in the git repo I was
pointed to earlier is draft-ietf-nfsv4-minorversion2-13.txt, and the
newest I could find on tools.ietf.org is draft 20.

I still don't understand why anyone would phase out WRITE in favour of
something that doesn't actually add any value for the write case.

I'll try to take it up directly with the working group, but my post to
the list yesterday in your SEEK thread didn't seem to have made it
trough.   I also tried to research how they came up with this idiotic
design, but the mailing list archives tell very little.  Could it be
that most of these decisions are actually made in a smokey backroom and
not on the list?
