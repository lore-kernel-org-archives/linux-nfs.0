Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43026 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754210AbdCHUdb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Mar 2017 15:33:31 -0500
Date: Wed, 8 Mar 2017 15:32:36 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "kolga@netapp.com" <kolga@netapp.com>,
        "hch@infradead.org" <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
Message-ID: <20170308203236.GC3492@fieldses.org>
References: <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org>
 <20170303204747.GE13877@fieldses.org>
 <20170307234051.GA29977@infradead.org>
 <20170308170521.GA1020@fieldses.org>
 <20170308172549.GA32011@infradead.org>
 <7FDA8E80-3C62-48BB-9E2B-195B4BA340C0@netapp.com>
 <20170308195327.GA3492@fieldses.org>
 <85310DA6-7270-49AE-A310-76D73678B1B1@netapp.com>
 <1489004308.3098.10.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1489004308.3098.10.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 08, 2017 at 08:18:31PM +0000, Trond Myklebust wrote:
> On Wed, 2017-03-08 at 15:00 -0500, Olga Kornievskaia wrote:
> > > On Mar 8, 2017, at 2:53 PM, J. Bruce Fields <bfields@fieldses.org>
> > > wrote:
> > > 
> > > On Wed, Mar 08, 2017 at 12:32:12PM -0500, Olga Kornievskaia wrote:
> > > > 
> > > > > On Mar 8, 2017, at 12:25 PM, Christoph Hellwig <hch@infradead.o
> > > > > rg>
> > > > > wrote:
> > > > > 
> > > > > On Wed, Mar 08, 2017 at 12:05:21PM -0500, J. Bruce Fields
> > > > > wrote:
> > > > > > Since copy isn't atomic that check is never going to be
> > > > > > reliable.
> > > > > 
> > > > > That's true for everything that COPY does.  By that logic we
> > > > > should
> > > > > not implement it at all (a logic that I'd fully support)
> > > > 
> > > > If you were to only keep CLONE then you’d lose a huge performance
> > > > gain
> > > > you get from server-to-server COPY. 
> > > 
> > > Yes.  Also, I think copy-like copy implementations have reasonable
> > > semantics that are basically the same as read:
> > > 
> > > 	- copy can return successfully with less copied than requested.
> > > 	- it's fine for the copied range to start and/or end past end
> > > of
> > > 	  file, it'll just return a short read.
> > > 	- A copy of more than 0 bytes returning 0 means you're at end
> > > of
> > > 	  file.
> > > 
> > > The particular problem here is that that doesn't fit how clone
> > > works at
> > > all.
> > > 
> > > It feels like what happened is that copy_file_range() was made
> > > mainly
> > > for the clone case, with the idea that copy might be reluctantly
> > > accepted as a second-class implementation.
> 
> Historically? No... Christoph added clone as a valid implementation of
> copy_file_range() almost a year after Zach and Anna defined the
> semantics of vfs_copy_file_range(). git blame is your friend...

Yeah, I know.  It still feels to me like the interface was originally
designed with clone in mind, but that's my vague impression from the man
pages and half-remembered conversations.

Though the lack of a "just copy the whole file regardless of size" case
is weird for clone.  All you can do is stat the file and then hope it
doesn't change before you issue the copy_file_range.  But I'd think it'd
be easy for an atomic clone implementation to handle, say, getting a
snapshot of a log file while it's getting continuously appended to.

> > > But the performance gain of copy offload is too big to just ignore,
> > > and
> > > in fact it's what copy_file_range does on every filesystem but
> > > btrfs and
> > > ocfs2 (and maybe cifs?), so I don't think we can just ignore it.
> > > 
> > > If we had separate copy_file_range and clone_file_range, I *think*
> > > it
> > > could all be made sensible.  Am I missing something?
> > > 
> > 
> > How would the application (cp) know when to call the clone_file_range
> > and when to call copy_file_range?
> 
> cp can probably call copy_file_range(), but any application that needs
> atomic semantics (i.e. a binary operation success/fail) must call
> clone_file_range().

I don't believe there's a clone_file_range().  I see the vfs interface,
but no system call.

And implementing a simple cp is harder than it should be when you don't
know whether it's implemented as copy or clone.  You have to stat for
the file size first, retry if you got it wrong, and also retry if you
get a short read.  The example in the clone_file_range() man page is
incomplete.

--b.
