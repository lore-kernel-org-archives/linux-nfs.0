Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from li9-11.members.linode.com ([67.18.176.11]:46385 "EHLO
	test.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818Ab1EaMfY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 May 2011 08:35:24 -0400
Date: Tue, 31 May 2011 08:35:18 -0400
From: "Ted Ts'o" <tytso@mit.edu>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: infinite getdents64 loop
Message-ID: <20110531123518.GB4215@thunk.org>
References: <201105281502.32719.sweet_f_a@gmx.de>
 <201105301137.02061.sweet_f_a@gmx.de>
 <1306767521.5971.2.camel@lade.trondhjem.org>
 <201105311147.24939.sweet_f_a@gmx.de>
 <4DE4C063.9060100@itwm.fraunhofer.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DE4C063.9060100@itwm.fraunhofer.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, May 31, 2011 at 12:18:11PM +0200, Bernd Schubert wrote:
> 
> Out of interest, did anyone ever benchmark if dirindex provides any
> advantages to readdir?  And did those benchmarks include the
> disadvantages of the present implementation (non-linear inode
> numbers from readdir, so disk seeks on stat() (e.g. from 'ls -l') or
> 'rm -fr $dir')?

The problem is that seekdir/telldir is terminally broken (and so is
NFSv2 for using a such a tiny cookie) in that it fundamentally assumes
a linear data structure.  If you're going to use any kind of
tree-based data structure, a 32-bit "offset" for seekdir/telldir just
doesn't cut it.  We actually play games where we memoize the low
32-bits of the hash and keep track of which cookies we hand out via
seekdir/telldir so that things mostly work --- except for NFSv2, where
with the 32-bit cookie, you're just hosed.

The reason why we have to iterate over the directory in hash tree
order is because if we have a leaf node split, half the directories
entries get copied to another directory entry, given the promises made
by seekdir() and telldir() about directory entries appearing exactly
once during a readdir() stream, even if you hold the fd open for weeks
or days, mean that you really have to iterate over things in hash
order.

I'd have to look, since it's been too many years, but as I recall the
problem was that there is a common path for NFSv2 and NFSv3/v4, so we
don't know whether we can hand back a 32-bit cookie or a 64-bit
cookie, so we're always handing the NFS server a 32-bit "offset", even
though ew could do better.  Actually, if we had an interface where we
could give you a 128-bit "offset" into the directory, we could
probably eliminate the duplicate cookie problem entirely.  We just
send 64-bits worth of hash, plus the first two bytes of the of file
name.

> 3) Disable dirindexing for readdirs

That won't work, since it will break POSIX compliance.  Once again,
we're tied by the decisions made decades ago...

						- Ted
