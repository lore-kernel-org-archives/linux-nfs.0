Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35370 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964833AbbJVVTa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Oct 2015 17:19:30 -0400
Date: Thu, 22 Oct 2015 17:19:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v6 00/19] nfsd: open file caching
Message-ID: <20151022211928.GF5205@fieldses.org>
References: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks like there's a leak--is this something you've seen already?

This is on my current nfsd-next, which has some other stuff too.

--b.

[  819.980697] kmem_cache_destroy nfsd_file_mark: Slab cache still has objects
[  819.981326] CPU: 0 PID: 4360 Comm: nfsd Not tainted 4.3.0-rc3-00040-ga6bca98 #360
[  819.981969] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
[  819.982805]  ffff8800738d7d30 ffff8800738d7d20 ffffffff816053ac ffff880051ee5540
[  819.983803]  ffff8800738d7d58 ffffffff811813df ffff8800738d7d30 ffff8800738d7d30
[  819.984782]  ffff880074fd5e00 ffffffff822f9c80 ffff88007c64cf80 ffff8800738d7d68
[  819.985751] Call Trace:
[  819.985940]  [<ffffffff816053ac>] dump_stack+0x4e/0x82
[  819.986369]  [<ffffffff811813df>] kmem_cache_destroy+0xef/0x100
[  819.986899]  [<ffffffffa00c2198>] nfsd_file_cache_shutdown+0x78/0xa0 [nfsd]
[  819.987513]  [<ffffffffa00b2c4d>] nfsd_shutdown_generic+0x1d/0x20 [nfsd]
[  819.988100]  [<ffffffffa00b2d2d>] nfsd_shutdown_net+0xdd/0x180 [nfsd]
[  819.988656]  [<ffffffffa00b2c55>] ? nfsd_shutdown_net+0x5/0x180 [nfsd]
[  819.989218]  [<ffffffffa00b2f34>] nfsd_last_thread+0x164/0x190 [nfsd]
[  819.989770]  [<ffffffffa00b2dd5>] ? nfsd_last_thread+0x5/0x190 [nfsd]
[  819.990328]  [<ffffffffa001463e>] svc_shutdown_net+0x2e/0x40 [sunrpc]
[  819.990996]  [<ffffffffa00b3936>] nfsd_destroy+0xd6/0x190 [nfsd]
[  819.991719]  [<ffffffffa00b3865>] ? nfsd_destroy+0x5/0x190 [nfsd]
[  819.992373]  [<ffffffffa00b3bb1>] nfsd+0x1c1/0x280 [nfsd]
[  819.992960]  [<ffffffffa00b39f5>] ? nfsd+0x5/0x280 [nfsd]
[  819.993537]  [<ffffffffa00b39f0>] ? nfsd_destroy+0x190/0x190 [nfsd]
[  819.994195]  [<ffffffff81098d6f>] kthread+0xef/0x110
[  819.994734]  [<ffffffff81a7677c>] ? _raw_spin_unlock_irq+0x2c/0x50
[  819.995439]  [<ffffffff81098c80>] ?  kthread_create_on_node+0x200/0x200
[  819.996129]  [<ffffffff81a7744f>] ret_from_fork+0x3f/0x70
[  819.996706]  [<ffffffff81098c80>] ?  kthread_create_on_node+0x200/0x200
[  819.998854] nfsd: last server has exited, flushing export cache
[  820.195957] NFSD: starting 20-second grace period (net ffffffff822f9c80)

