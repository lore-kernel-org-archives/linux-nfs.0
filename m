From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: Re: [NFS] [PATCH] nfs2/3 ESTALE bug (libblkid uses stale cache/uuid
	values)
Date: Tue, 20 May 2008 18:32:13 -0400
Message-ID: <200805202232.m4KMWD11020355@agora.fsl.cs.sunysb.edu>
References: <20080519190356.GH15035@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org,
	Himanshu Kanda <hkanda-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
To: Theodore Tso <tytso@mit.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:59776 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764760AbYETWcl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 18:32:41 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JyaNq-00031U-F0
	for linux-nfs@vger.kernel.org; Wed, 21 May 2008 08:32:38 +1000
In-reply-to: Your message of "Mon, 19 May 2008 15:03:56 EDT."
	<20080519190356.GH15035@mit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In message <20080519190356.GH15035@mit.edu>, Theodore Tso writes:
> On Mon, May 19, 2008 at 12:04:08PM -0400, J. Bruce Fields wrote:
[...]
> In practice it's rare for a system administrator to rerun mkfs
> multiple times in the space of 200 seconds.  (Especially since mkfs
> for ext3 normally takes quite a bit of time to run on large disks,
> although I'll grant that's a bug that we'll fixing for ext4.  :-) In
> general, though, it's rare for system administrator to be constantly
> recreating filesystems on their devices.  It's happening in your test
> scenario, but in real life, it's rare that an administrator will be
> constantly reformatting a drive, especially if it's being exported by
> NFS.
[...]

> Thanks for the patch.  I'll clean it up and include in e2fsprogs, but
> I don't consider this a high priority fix to get out to everyone,
> since it's really not something that I expect will be hit in real
> life, except in test scenarios like the one run into by Erez and his
> team.
> 
> 						- Ted

Ted, I agree with you it's an uncommon scenario, running mkfs so many times,
and this isn't a high priority fix.  As long as it gets into e2fsprogs,
eventually all the distros will have it.  Thanks.

However, with more people using unioning systems, repeated mkfs's are
becoming more commonplace.  For example, users like to dynamically add and
remove branches into a union, and those branches sometimes come from small
loop devices that are mkfs'ed.

Cheers,
Erez.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft 
Defy all challenges. Microsoft(R) Visual Studio 2008. 
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

