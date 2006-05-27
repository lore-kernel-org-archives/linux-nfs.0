From: Ramon van Alteren <ramon@vanalteren.nl>
Subject: Soft CPU Lockup on 2.6.15 with kernel nfsd
Date: Sat, 27 May 2006 22:39:57 +0200
Message-ID: <B5EB7762-BFC1-4CF0-B37B-E5589A941D6A@vanalteren.nl>
Mime-Version: 1.0 (Apple Message framework v750)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fk5ZG-0000Gq-Bk
	for nfs@lists.sourceforge.net; Sat, 27 May 2006 13:39:26 -0700
Received: from cust.92.104.adsl.cistron.nl ([195.64.92.104] helo=router.forgottenland.net)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fk5ZF-00006N-4h
	for nfs@lists.sourceforge.net; Sat, 27 May 2006 13:39:26 -0700
Received: from [192.168.1.30] (unknown [192.168.1.30])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	by router.forgottenland.net (Postfix) with ESMTP id E7DE439D40
	for <nfs@lists.sourceforge.net>; Sat, 27 May 2006 22:39:15 +0200 (CEST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi List,

I'm seeing several of these in my dmesg output on one of my NAS servers.
Any pointers on where to start looking for a cause would be highly  
appreciated.

Pid: 7122, comm:                 nfsd
EIP: 0060:[<c057fe43>] CPU: 0
EIP is at _read_lock_bh+0x12/0x1a
EFLAGS: 00000216    Not tainted  (2.6.15-gentoo-r1)
EAX: c069980c EBX: 00000000 ECX: f7ece000 EDX: f6100000
ESI: c06997e0 EDI: ef7b4020 EBP: c0785b80 DS: 007b ES: 007b
CR0: 8005003b CR2: 08056f98 CR3: 0073b000 CR4: 000006d0
[<c05101c6>] ipt_do_table+0x6a/0x326
[<c050a335>] ip_conntrack_in+0xd2/0x2c7
[<c04d1fde>] ip_rcv_finish+0x0/0x2ba
[<c051365b>] ipt_route_hook+0x37/0x3b
[<c04c90ef>] nf_iterate+0x6f/0x87
[<c04d1fde>] ip_rcv_finish+0x0/0x2ba
[<c04d1fde>] ip_rcv_finish+0x0/0x2ba
[<c04c9172>] nf_hook_slow+0x6b/0x10d
[<c04d1fde>] ip_rcv_finish+0x0/0x2ba
[<c04d1cc4>] ip_rcv+0x460/0x57e
[<c04d1fde>] ip_rcv_finish+0x0/0x2ba
[<c04b5c93>] netif_receive_skb+0x147/0x1c3
[<c03efd98>] tg3_rx+0x2ed/0x3d4
[<c03efede>] tg3_poll+0x5f/0x14e
[<c04b5e89>] net_rx_action+0x77/0xfe
[<c01249b7>] __do_softirq+0xbf/0xd1
[<c01249fb>] do_softirq+0x32/0x34
[<c0105242>] do_IRQ+0x1e/0x24
[<c010377e>] common_interrupt+0x1a/0x20
[<c057fe8f>] _spin_lock+0x3/0xf
[<c0177c23>] dput+0x33/0x1cb
[<c02217ee>] fh_put+0x113/0x186
[<c022e957>] nfs3svc_release_fhandle2+0x24/0x31
[<c05756ef>] svc_process+0x42e/0x643
[<c021ed92>] nfsd+0x1b4/0x345
[<c021ebde>] nfsd+0x0/0x345
[<c0101125>] kernel_thread_helper+0x5/0xb
RPC: bad TCP reclen 0x0ddc8af7 (large)
RPC: bad TCP reclen 0x272d2e25 (non-terminal)
RPC: bad TCP reclen 0x46c6f2c8 (large)
BUG: soft lockup detected on CPU#0!

Thanx Ramon

--
If to err is human, I'm most certainly human.





-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
