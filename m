From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: mountpoint-crossing
Date: Sun, 13 Dec 2009 17:33:15 -0500
Message-ID: <1260743595.3076.12.camel@localhost>
References: <20091213213945.GB20421@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48406 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751534AbZLMWdc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Dec 2009 17:33:32 -0500
In-Reply-To: <20091213213945.GB20421@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-12-13 at 16:39 -0500, J. Bruce Fields wrote: 
> On a recent kernel:
> 
> 	# mount -tnfs4 pearlet1:/ /mnt/
> 	# find /mnt/
> 	/mnt/
> 	find: File system loop detected; `/mnt/DIR' is part of the same
> 	file system loop as `/mnt/'.
> 
> Here /mnt/DIR is a server-side mountpoint, hence has a different fsid
> than /mnt/.  Wireshark confirms that the server is returning a different
> fsid.  However, 'strace -v find /mnt/' shows stat returning
> st_dev=makedev(0, 22) for both /mnt and /mnt/DIR.
> 
> If I then do a 'ls /mnt/DIR', followed by another find, the error goes
> away, and this time an strace shows that stat is returning (0, 23) for
> /mnt/DIR.
> 
> I don't see any obvious problem with the network trace, so it looks to
> me like the client is failing to recognize the mountpoint when it
> should?

This is a known consequence of the way we treat submounts (and
referrals); we're basically treating them as a special kind of symlink.
The problem then arises when syscalls such as stat() fail to set the
LOOKUP_FOLLOW flag, and so the user is granted a temporary peek of the
underlying inode.

I'm not sure how we should treat this. I suppose we could change the
test in __link_path_walk() so that it always call follow_link() if the
inode is not a symlink...

Cheers
  Trond
