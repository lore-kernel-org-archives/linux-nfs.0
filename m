Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52911 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752774AbaDDOeT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2014 10:34:19 -0400
Date: Fri, 4 Apr 2014 10:34:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Boaz Harrosh <openosd@gmail.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Should exportfs/mountd cope with case-insensitive directory
 names.
Message-ID: <20140404143413.GC17594@fieldses.org>
References: <20140403164652.5d7770ad@notabene.brown>
 <20140403130909.GA24700@fieldses.org>
 <533D8629.10907@gmail.com>
 <20140403171625.GA5884@fieldses.org>
 <20140403172431.GB5884@fieldses.org>
 <20140404082154.4cfdab5a@notabene.brown>
 <20140403213610.GF8343@fieldses.org>
 <20140404091324.699d0ba6@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140404091324.699d0ba6@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 04, 2014 at 09:13:24AM +1100, NeilBrown wrote:
> On Thu, 3 Apr 2014 17:36:10 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > (BTW:  I also noticed the other day that systemd is calling
> > name_to_handle_at to get a mount id.  Seems like overkill in both
> > cases--shouldn't there be a simpler way to get just the mount id?)
> 
> Yes, it is called "xstat" and is an extensible version of stat which even
> includes a 'query' bitmap to list which things you want.

Yes.

I forget that encoding the filehandle is typically just reading inode
and generation number and encoding the results in a funny way, so it's
not particularly heavy-weight.

But lumping the two together does mean that your request can fail just
because the filesystem doesn't support nfs exports.

> Unfortunately it never made it to mainline.  We should submit a patch to
> systemd to get it to use xstat instead of name_to_handle_at.  That would
> ensure that the kernel implemented it double-quick :-)

Hm....

--b.
