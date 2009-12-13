From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: mountpoint-crossing
Date: Sun, 13 Dec 2009 16:39:45 -0500
Message-ID: <20091213213945.GB20421@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44554 "HELO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754096AbZLMVji (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Dec 2009 16:39:38 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On a recent kernel:

	# mount -tnfs4 pearlet1:/ /mnt/
	# find /mnt/
	/mnt/
	find: File system loop detected; `/mnt/DIR' is part of the same
	file system loop as `/mnt/'.

Here /mnt/DIR is a server-side mountpoint, hence has a different fsid
than /mnt/.  Wireshark confirms that the server is returning a different
fsid.  However, 'strace -v find /mnt/' shows stat returning
st_dev=makedev(0, 22) for both /mnt and /mnt/DIR.

If I then do a 'ls /mnt/DIR', followed by another find, the error goes
away, and this time an strace shows that stat is returning (0, 23) for
/mnt/DIR.

I don't see any obvious problem with the network trace, so it looks to
me like the client is failing to recognize the mountpoint when it
should?

--b.
