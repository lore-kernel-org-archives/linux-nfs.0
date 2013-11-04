Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39546 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab3KDRDq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Nov 2013 12:03:46 -0500
Date: Mon, 4 Nov 2013 09:03:45 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Message-ID: <20131104170345.GA31499@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131102135238.GB18961@infradead.org>
 <5277CE23.6010207@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5277CE23.6010207@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 04, 2013 at 11:41:07AM -0500, Anna Schumaker wrote:
> > what else it would be for.
> 
> My understanding is that if I call fallocate with a mode of "0" it will write a range of 0s to the file.

While writing zeroes to the file would be a correct implementation,
that's now how the operation is defined or usually implemented.  The
defintion is that the blocks in the range will be allocated, and reads
from it will return zero (and the file size will be updated if needed).

The usual way to implement it is to created extents in an "unwritten
state" that will return zeroes when read, even if those zeroes didn't
make it to disk.

>I'll move the fsync() call here and only do it if the client doesn't ask for NFS_UNSTABLE.

As said the right way to handle it would be to use commit_metadata, as
the cache flushes a fsync does would be unessecary and too expensive for
many workloads typically using fallocate.

> > 
> > Btw, how did anyone come up with the name WRITE PLUS for something that
> > doesn't actually involve any writes?
> > 
> 
> Write plus does write more than just holes, I just didn't implement that part of the spec.  I'm implementing the NFS4_CONTENT_HOLE arm, but NFS4_CONTENT_DATA is intended to eventually replace the WRITE operation.

Where is WRITE PLUS defined?  I the various
draft-ietf-nfsv4-minorversion2-*.txt I can only find what appears to be
the predecessor, but that doesn't have a data arm.

Also what does the data arm buy us over good old WRITE?

