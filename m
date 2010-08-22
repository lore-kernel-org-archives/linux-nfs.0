Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr12.xs4all.nl ([194.109.24.32]:1637 "EHLO
	smtp-vbr12.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708Ab0HVS3G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Aug 2010 14:29:06 -0400
Date: Sun, 22 Aug 2010 20:28:53 +0200
From: Miquel van Smoorenburg <mikevs@xs4all.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 00/03] sunrpc: a few authentication cache patches
Message-ID: <20100822182848.GA26590@xs4all.net>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks for including the configurable authcache hashtable size patches
in 2.6.36. Yet another patch I can drop from our local builds.

I do have a few small enhancements though. I think the first
two should go into 2.6.36. The last one probably needs some
discussion.

Mike.

[PATCH 01/03]: sunrpc: increase MAX_HASHTABLE_BITS to 14

The maximum size of the authcache is now set to 1024 (10 bits),
but on our server we need at least 4096 (12 bits). Increase
MAX_HASHTABLE_BITS to 14. This is a maximum of 16384 entries,
each containing a pointer (8 bytes on x86_64). This is
exactly the limit of kmalloc() (128K).

[PATCH 02/03]: sunrpc: make auth_hashtable_size param mode 0444

The auth_hashtable_size parameter shows up in
/sys/module/sunrpc/parameters with mode 0644. However the hashtables
are allocated when the module is loaded, and changing the parameter
afterwards doesn't do much. So make it read-only.

[PATCH 03/03] sunrpc: scale hashtable cache size with memory

Set the number of entries of the authcache to 4096 on servers
with 4G of memory or more. Because kmallocing more than a few K
is frowned upon, change the allocator from kmalloc to __get_free_pages.
Since the minimum allocation size of __get_free_pages is 1 page,
set the number of entries in the authcache to PAGE_SIZE / (entry_size)
on servers with < 4G of memory so that exactly one page is used.

