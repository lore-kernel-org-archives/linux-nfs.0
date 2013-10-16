Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49317 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760112Ab3JPIvS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 04:51:18 -0400
Date: Wed, 16 Oct 2013 01:51:17 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@redhat.com,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: nfs4_file usage
Message-ID: <20131016085117.GA21665@infradead.org>
References: <20131015211445.GA23636@infradead.org>
 <525E2C5C.4020104@primarydata.com>
 <20131016064649.GB28758@infradead.org>
 <525E5228.80200@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <525E5228.80200@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 16, 2013 at 11:45:28AM +0300, Benny Halevy wrote:
> I'm reluctant about the layout stateids as it uses common hashing data structs
> locking infrastructure, and code with all other nfsd4 stateids.

The layout stateids are another thing that confuses me in the current
pnfs code.  Depending on what we find the generic state id might be
embedded into the layout stateid or they might be separate, but there
don't seem to be clear rules on how to deal with freeing things in the
later case.  I haven't brought this up because I didn't dig deep into it
enough, but it's for sure more than confusing.

> We can have a similar hash table for pnfsd_inode similar to nfs4_file

Yes, that was the plan.

> Note that nfs4_file is also per inode, not per file as might be reflected from its name.
> Maybe moving it nfs4state.c also warrants renaming it to something more accurate.

Yes, it should have an inode instead of file in the name, and it really
should be nfsd4_ prefix instead of using the client namespace. Given
that it's open/locking specific I'm not even sure that name should be
that generic.

> And while there, change file_hashval to hash on i_ino rather than the inode ptr.

That's a bad idea.  i_ino is 32-bit only while many NFS-exported
filesystems have 64-bit inode numbers.  Hashing on kernel pointers
genetrally is a fairly good idea, and we do it for the inode in other
places, too.

