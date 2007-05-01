From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [PATCH 0/18] export operations rewrite
Date: Tue, 1 May 2007 11:39:05 +0100
Message-ID: <20070501103905.GA30906@infradead.org>
References: <20070317010946.GA24947@infradead.org> <17932.34141.590792.120454@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <17932.34141.590792.120454@notabene.brown>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Mar 30, 2007 at 01:34:53PM +1000, Neil Brown wrote:
> On Saturday March 17, hch@infradead.org wrote:
> 
> less that 2 weeks later....

more than one month later.... :)

> My only question involves motivation.
> 
>   You say "less complex", but to me it just looks "different" - though
>   being very familiar with the original, that might be a biased view.
>   Can you say more about how it is less complex?
>   Maybe the extension to generic 64bit support will make that clear...
> 
>   But then generic 64bit support should just be an independent set of
>   helper functions that can be plugged in to the export_operations
>   structure.
> 
> For what it does, the code looks fine, and I can see some definite
> improvements here and there, but I'm not clear on the over-all
> motivation.

When looking at suppor for 64bit inodes I stumbled over a few things
I really dislike in the current code:

 - I really hate the current function pointer indirection for
   find_exported_dentry.  Using the same method table for communication
   in two different ways just feels very bad to me.
 - passing the fid completely untyped to filesystem seem too error
   prone to me, and is rather contrary to how we do things elsewhere
   in the kernel.
 - the calling conversion on the decode side where we first call
   ->decode_fh to split the filehandle into two blobs only to
   recurse back into exportfs and then recurse back into the filesystem
   seems rather odd.  By having two methods to get the dentry and
   parent directly from the on the wire file handle this big callstack
   collapses to a very simple one.

So yes, we probably could do 64bit inode filehandles with the old scheme
(and in fact xfs, ocfs2 and gfs2 already have support for it), but revamping
the layering will make it quite a bit cleaner.  I'll doug up those patches
again, but on the decode side 64bit inode support is really trivial
after these, it's just another case statement in the generic routines.
