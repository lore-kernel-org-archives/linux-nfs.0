Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43022 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754315AbdCHU3G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Mar 2017 15:29:06 -0500
Date: Wed, 8 Mar 2017 15:18:22 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, Trond.Myklebust@primarydata.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
Message-ID: <20170308201822.GB3492@fieldses.org>
References: <20170302160123.30375-1-kolga@netapp.com>
 <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org>
 <20170303204747.GE13877@fieldses.org>
 <20170307234051.GA29977@infradead.org>
 <20170308170521.GA1020@fieldses.org>
 <20170308172549.GA32011@infradead.org>
 <7FDA8E80-3C62-48BB-9E2B-195B4BA340C0@netapp.com>
 <20170308195327.GA3492@fieldses.org>
 <85310DA6-7270-49AE-A310-76D73678B1B1@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <85310DA6-7270-49AE-A310-76D73678B1B1@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 08, 2017 at 03:00:52PM -0500, Olga Kornievskaia wrote:
> 
> > On Mar 8, 2017, at 2:53 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Wed, Mar 08, 2017 at 12:32:12PM -0500, Olga Kornievskaia wrote:
> >> 
> >>> On Mar 8, 2017, at 12:25 PM, Christoph Hellwig <hch@infradead.org>
> >>> wrote:
> >>> 
> >>> On Wed, Mar 08, 2017 at 12:05:21PM -0500, J. Bruce Fields wrote:
> >>>> Since copy isn't atomic that check is never going to be reliable.
> >>> 
> >>> That's true for everything that COPY does.  By that logic we should
> >>> not implement it at all (a logic that I'd fully support)
> >> 
> >> If you were to only keep CLONE then you’d lose a huge performance gain
> >> you get from server-to-server COPY. 
> > 
> > Yes.  Also, I think copy-like copy implementations have reasonable
> > semantics that are basically the same as read:
> > 
> > 	- copy can return successfully with less copied than requested.
> > 	- it's fine for the copied range to start and/or end past end of
> > 	  file, it'll just return a short read.
> > 	- A copy of more than 0 bytes returning 0 means you're at end of
> > 	  file.
> > 
> > The particular problem here is that that doesn't fit how clone works at
> > all.
> > 
> > It feels like what happened is that copy_file_range() was made mainly
> > for the clone case, with the idea that copy might be reluctantly
> > accepted as a second-class implementation.
> > 
> > But the performance gain of copy offload is too big to just ignore, and
> > in fact it's what copy_file_range does on every filesystem but btrfs and
> > ocfs2 (and maybe cifs?), so I don't think we can just ignore it.
> > 
> > If we had separate copy_file_range and clone_file_range, I *think* it
> > could all be made sensible.  Am I missing something?
> 
> How would the application (cp) know when to call the clone_file_range and when to call copy_file_range?

Try clone and then fall back on copy if that's not available?

Which is the same thing vfs_copy_file_range() is doing now, but it'd
seem less confusing if that logic was in the application.

--b.
