From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: allocation under spinlock
Date: Wed, 24 Feb 2010 16:23:58 -0500
Message-ID: <20100224212358.GH16665@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41338 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758157Ab0BXVXE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Feb 2010 16:23:04 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_dns_ent_init() is trying to kstrndup() something, but it's called under a
spinlock.

Could refernce count that string instead, but other code I believe actually
just does something like:

	new->hostname = key->hostname;
	key->hostname = NULL;

--b.

BUG: sleeping function called from invalid context at mm/slab.c:3034
in_atomic(): 1, irqs_disabled(): 0, pid: 3300, name: nfs_cache_geten
2 locks held by nfs_cache_geten/3300:
 #0:  (&sb->s_type->i_mutex_key#4){+.+.+.}, at: [<c1795506>] cache_write+0x46/0x100
 #1:  (&cd->hash_lock){+++++.}, at: [<c17964a5>] sunrpc_cache_update+0x25/0x170
Pid: 3300, comm: nfs_cache_geten Not tainted 2.6.33-rc8-13669-g724e6d3 #156
Call Trace:
 [<c17db62e>] ? printk+0x1d/0x1f
 [<c1022c70>] __might_sleep+0x100/0x130
 [<c10bf849>] __kmalloc_track_caller+0x189/0x230
 [<c10be6d4>] ? kfree+0xd4/0x180
 [<c11f2796>] ? nfs_dns_ent_init+0x26/0x70
 [<c10a7f04>] kstrndup+0x34/0x60
 [<c11f2796>] nfs_dns_ent_init+0x26/0x70
 [<c17965b8>] sunrpc_cache_update+0x138/0x170
 [<c11f2a03>] ? nfs_dns_lookup+0x53/0x70
 [<c11f2bb4>] nfs_dns_parse+0x194/0x1e0
 [<c1058e90>] ? add_lock_to_list+0x40/0xc0
 [<c105bd7a>] ? __lock_acquire+0x109a/0x1890
 [<c1095375>] ? add_to_page_cache_locked+0x65/0x140
 [<c105c7f9>] ? lock_release_non_nested+0x59/0x2f0
 [<c1059dc2>] ? mark_held_locks+0x62/0x90
 [<c10ab662>] ? might_fault+0x62/0xb0
 [<c10ab662>] ? might_fault+0x62/0xb0
 [<c10ab6a8>] ? might_fault+0xa8/0xb0
 [<c10ab662>] ? might_fault+0x62/0xb0
 [<c17946ba>] cache_do_downcall+0x3a/0x50
 [<c1795560>] cache_write+0xa0/0x100
 [<c10c2fb2>] ? rw_verify_area+0x62/0xd0
 [<c17955e7>] cache_write_pipefs+0x27/0x30
 [<c10c3842>] vfs_write+0xa2/0x170
 [<c104e94b>] ? up_read+0x1b/0x30
 [<c17955c0>] ? cache_write_pipefs+0x0/0x30
 [<c17e1400>] ? do_page_fault+0x160/0x3f0
 [<c10c39d2>] sys_write+0x42/0x70
 [<c17df155>] syscall_call+0x7/0xb

