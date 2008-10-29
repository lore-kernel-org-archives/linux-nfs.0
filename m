From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 0/9] writeback data integrity and other fixes (take 3)
Date: Wed, 29 Oct 2008 11:30:29 +0100
Message-ID: <20081029103029.GC5953@wotan.suse.de>
References: <20081028144715.683011000@suse.de> <20081028153953.GB3082@wotan.suse.de> <20081028222746.GB4985@disturbed> <20081029001653.GF15599@wotan.suse.de> <20081029031645.GE4985@disturbed> <20081029091203.GA32545@infradead.org> <20081029092143.GA5953@wotan.suse.de> <20081029094417.GA21824@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, xfs@oss.sgi.com,
	linux-fsdevel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>
To: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20081029094417.GA21824@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 29, 2008 at 05:44:17AM -0400, Christoph Hellwig wrote:
> On Wed, Oct 29, 2008 at 10:21:43AM +0100, Nick Piggin wrote:
> > Please do.
> 
> Well, there's one stumling block I haven't made progress on yet:
> 
> I've changed the prototype of ->fsync to lose the dentry as we should
> always have a valid file struct.  Except that nfsd doesn't on
> directories.  So I either need to fake up a file there, or bail out
> and add a ->dir_sync export operation that needs just a dentry.

OK. I don't know much about hthat code, but I would think nfsd
should look as close to the syscall layer as possible. I guess
there must be something prohibitive (some protocol semantics?).

Is there anything that particularly makes it a file operation
as opposed to an inode operation?
