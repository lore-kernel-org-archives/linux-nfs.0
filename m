From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 4/14] locks: add locking function that returns conflicting lock
Date: Sat, 3 Feb 2007 21:02:33 -0500
Message-ID: <20070204020233.GJ7588@fieldses.org>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu> <96a0abaf64b433a7e7450e7e35d0baf2c44103db.1170479265.git.bfields@citi.umich.edu> <20070203085450.GD18828@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070203085450.GD18828@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Feb 03, 2007 at 08:54:50AM +0000, Christoph Hellwig wrote:
> Is there any reason we want to have both variants?  I think vfs_lock_file
> should simple get the last argument and we shouldn't have a separate
> vfs_lock_file_conf (which btw doesn't have an exactly descriptive name).
> The also allows you to kill __posix_lock_file_conf and only keep a single
> posix_lock_file routines that gets the argument aswell.

That sounds reasonable.

> And btw, in case you ask why I demand all these addition cleanuos:
> you're touching an already more than messy codebase and make it more
> complex, that needs some cleanups to counterbalance :)

I find locks.c really hard to read, so I'm happy for any suggestions for
cleanups....

--b.
