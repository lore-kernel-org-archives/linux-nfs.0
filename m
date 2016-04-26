Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49770 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752432AbcDZR1F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Apr 2016 13:27:05 -0400
Date: Tue, 26 Apr 2016 13:27:02 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
cc: hch@lst.de
Subject: blocklayoutdriver and page_cache_next_hole
Message-ID: <alpine.OSX.2.19.9992.1604261302250.92748@planck>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm doing some benchmarking on SCSI layout, and I ran into a case where
bonnie++ seemingly stopped making forward progress.

bl_pg_init_write() wants to figure out how big the layout should be and uses
page_cache_next_hole() pretty aggressively if the inode size isn't equal to
the mapping.  Problem is that page_cache_next_hole() is fairly stupid about
just walking through the page_cache radix tree by index.

The end result is that for fairly large files (>4G) my machine spends all
its time in __radix_tree_lookup(), and I might as well just use regular NFS.

Here's some bash I use to reproduce that problem (note the truncate is 4G +
1):

[root@gfs-a24c-02 local_spc4]# cat <(dd if=/dev/zero bs=1M count=4096) - > bar &
[1] 2000
4096+0 records in
4096+0 records out
4294967296 bytes (4.3 GB) copied, 10.7775 s, 399 MB/s
[1]+  Stopped                 cat <(dd if=/dev/zero bs=1M count=4096) - > bar
[root@gfs-a24c-02 local_spc4]# sync
[root@gfs-a24c-02 local_spc4]# truncate -s 4294967297  bar
[root@gfs-a24c-02 local_spc4]# dd if=/dev/zero of=bar bs=1M count=4096 conv=notrunc
4096+0 records in
4096+0 records out
4294967296 bytes (4.3 GB) copied, 82.0328 s, 52.4 MB/s

This performance problem gets far worse on larger address_maps..

A couple of ways to fix spring to mind: make page_cache_next_hole() less
stupid, or instead of trying to figure out what wb_size should be in
pg_init, provide a way for pg_init to look up a matching lseg beforehand.
Or maybe create a lsize parameter?

I'm going to continue to flail around trying to determine the best way to
fix this unless sound advice is offered.  I don't know enough about the page
cache to make improvements to page_cache_next_hole(), nor have I any good
estimate on the acceptability of the other two approaches.  Thanks for any
input.

Ben
