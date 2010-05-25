From: "Arce, Abraham" <x0066660@ti.com>
Subject: NULL Pointer Deference: NFS & Telnet
Date: Mon, 24 May 2010 21:19:50 -0500
Message-ID: <27F9C60D11D683428E133F85D2BB4A53043E33A997@dlee03.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:46867 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755662Ab0EYCTz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 22:19:55 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have 2 scenarios in which I am getting a NULL pointer dereference:

1) root filesystem over nfs
2) telnet connection

The issue appeared on this commit

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=f8965467f366fd18f01feafb5db10512d7b4422c

The driver I am working with is drivers/net/ks8851.c
Any help will be highly appreciated...

---

Scenario 1 | root filesystem over nfs

Looking up port of RPC 100005/1 on 10.87.231.229
VFS: Mounted root (nfs filesystem) on device 0:10.
Freeing init memory: 128K
Unable to handle kernel NULL pointer dereference at virtual address 00000000
[..]
PC is at put_page+0xc/0x120
LR is at skb_release_data+0x74/0xb8
[..]
Backtrace:
[<c0086dd0>] (put_page+0x0/0x120)
[<c01d0a48>] (skb_release_data+0x0/0xb8)
[<c01d1044>] (skb_release_all+0x0/0x20)
[<c01d075c>] (__kfree_skb+0x0/0xbc)
[<c01d0818>] (consume_skb+0x0/0x58)
[<c01d39cc>] (skb_free_datagram+0x0/0x40)
[<c023ff74>] (xs_udp_data_ready+0x0/0x1e8)
[<c01ce034>] (sock_queue_rcv_skb+0x0/0x1c0)
[<c01fbba8>] (ip_queue_rcv_skb+0x0/0x58)
[<c02176c0>] (__udp_queue_rcv_skb+0x0/0x18c)
[<c0218e28>] (udp_queue_rcv_skb+0x0/0x348)
[<c02195a4>] (__udp4_lib_rcv+0x0/0x564)
[<c0219b08>] (udp_rcv+0x0/0x20)
[<c01f5f34>] (ip_local_deliver+0x0/0x264)
[<c01f586c>] (ip_rcv+0x0/0x6c8)
[<c01d7ec0>] (__netif_receive_skb+0x0/0x2d0)
[<c01d8190>] (process_backlog+0x0/0x16c)
[<c01d8e14>] (net_rx_action+0x0/0x18c)
[<c00521a0>] (__do_softirq+0x0/0x12c)
[<c00522cc>] (irq_exit+0x0/0x70)
[<c0028000>] (asm_do_IRQ+0x0/0xc8)

Complete log at http://pastebin.mozilla.org/728027

---

Scenario 2

 1. Root filesystem booted in ram
 2. eth0 brought up
 3. telnetd daemon started
 4. tried to connect through telnet

# Unable to handle kernel NULL pointer dereference at virtual address 00000000
pgd = d98e8000
[..]
PC is at put_page+0xc/0x120
LR is at skb_release_data+0x74/0xb8
[..]
Backtrace:
[<c0086dd0>] (put_page+0x0/0x120)
[<c01d0a48>] (skb_release_data+0x0/0xb8)
[<c01d1044>] (skb_release_all+0x0/0x20)
[<c01d075c>] (__kfree_skb+0x0/0xbc)
[<c0202444>] (tcp_recvmsg+0x0/0x93c)
[<c02201e8>] (inet_recvmsg+0x0/0xec)
[<c01c7fd0>] (sock_aio_read+0x0/0xf8)
[<c00ab3ac>] (do_sync_read+0x0/0xec)
[<c00abfbc>] (vfs_read+0x0/0x164)
[<c00ac1a0>] (sys_read+0x0/0x70)
[<c0029100>] (ret_fast_syscall+0x0/0x30)

Complete log at http://pastebin.mozilla.org/728028

Best Regards
Abraham Arce
