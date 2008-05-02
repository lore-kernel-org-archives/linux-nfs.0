From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Fri, 2 May 2008 11:38:41 +1000
Message-ID: <18458.28833.539314.455215@notabene.brown>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	<20080501204820.GA5951@infradead.org>
	<1209681898.25560.613.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org,
	linux-nfs@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: message from David Woodhouse on Thursday May 1
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday May 1, dwmw2@infradead.org wrote:
> On Thu, 2008-05-01 at 16:48 -0400, Christoph Hellwig wrote:
> > Yes, and get_fsid would be extremly useful, especially for those
> > filesystems that already have an uuid in the superblock
> > (*cough*, XFS, *cough*), but it'll need some co-operations with
> > nfs-utils on when to use it.
> 
> Why do you need to co-operate with userspace? Userspace shouldn't need
> to do anything -- we'll just generate a suitable fsid/uuid for
> ourselves, unless userspace deliberately overrides it for the export in
> question.

Actually it is the kernel that doesn't need to do anything....
Mapping between the filesystem and the filesystem part of the
filehandle is done entirely in user space.
The kernel says "Here is a filehandle fragement, what filesystem
should I be accessing".

So what you really want is to teach nfs-utils to recognise JFFS2 and
extract an appropriate uuid.
It already uses libblkid to get uuids for ext3 and XFS and others.
Extending that to handle JFFS2 should be much of a drama.

> 
> > Patch looks good for me except for the few introduced overlong lines.
> 
> Bah, don't you start. A less onanistic problem with it is the deadlock
> with NFS readdirplus (->readdir->encode_entry->compose_entry_fh->lookup)
> 
> I wonder if we should postpone the calls to compose_entry_fh() until
> _after_ readdir() has completed. Leave space in the response for the
> filehandles, but only walk through it again calling compose_entry_fh()
> once we're done in readdir. That would allow us to get rid of the
> various icky hacks that file systems have to avoid that deadlock.

Why is there a deadlock here?
Both readdir and lookup are called with i_mutex held on the directory
so there should need to do any extra locking (he said, naively).  In
the readdirplus cases, i_mutex is held across both the readdir and the
lookup....

One problem with your proposed solution is that filehandles aren't all
the same length, so you cannot reliably leave space for them.

Awkward.

NeilBrown
