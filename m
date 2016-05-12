Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:57854 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617AbcELJMu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 May 2016 05:12:50 -0400
Date: Thu, 12 May 2016 02:12:49 -0700
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info
 available
Message-ID: <20160512091249.GB22420@infradead.org>
References: <20160510070803.GC30896@infradead.org>
 <20160508083543.GA14316@infradead.org>
 <20160429125736.23636.47874.stgit@warthog.procyon.org.uk>
 <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
 <1734.1462801101@warthog.procyon.org.uk>
 <7963.1462869823@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7963.1462869823@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 10, 2016 at 09:43:43AM +0100, David Howells wrote:
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > All of these are easily available.  But why special case them so that
> > userspace must not ask for them?  This makes an otherwise totally
> > regular interface special now.  Note that filesystems could always fill
> > it out anyway and set it in the return mask.
> 
> Because it would be a waste of bits in the mask.  Is there a point in having
> bits that are always going to be set unconditionally when we can just
> *document* that these few fields are always going to be set.

And what exaxtly is the cost of these bits?

> So yes, you can look on it as there are special cases.  However, if I can drop
> stat emulation support, everything resolves down to the following classes:
> 
>  (1) Stuff that's unconditional: st_dev, st_blksize, st_information (maybe).
> 
>  (2) st_mode & S_IFMT.  Unconditional or conditional?  I'm not sure.
> 
>  (3) Stuff that's conditional: st_mode & ~S_IFMT, st_rdev, st_ino, ...
>      Basically everything else.

If we at least go down to one set of conditional and one optional that's
at least much better than what we currently have.
