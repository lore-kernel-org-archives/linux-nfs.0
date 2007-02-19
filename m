From: Chuck Ebbert <cebbert@redhat.com>
Subject: sunrpc oops in cache_clean(), kernel 2.6.19.3
Date: Mon, 19 Feb 2007 11:42:16 -0500
Message-ID: <45D9D368.5010900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-kernel <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJBau-00087q-5R
	for nfs@lists.sourceforge.net; Mon, 19 Feb 2007 08:42:28 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HJBav-0004v5-TW
	for nfs@lists.sourceforge.net; Mon, 19 Feb 2007 08:42:30 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is happening at line 443 in cache_clean() -- "ch" (in ebx)
points into userspace data addresses:


420 /* find a cleanable entry in the bucket and clean it, or set to next bucket */
421
422 if (current_detail && current_index < current_detail->hash_size) {
423 	struct cache_head *ch, **cp;
424 	struct cache_detail *d;
425
426 	write_lock(&current_detail->hash_lock);
427
428 	/* Ok, now to clean this strand */
429
430 	cp = & current_detail->hash_table[current_index];
431 	ch = *cp;
432 	for (; ch; cp= & ch->next, ch= *cp) {
433 		if (current_detail->nextcheck > ch->expiry_time)
434 			current_detail->nextcheck = ch->expiry_time+1;
435 		if (ch->expiry_time >= get_seconds()
436 		    && ch->last_refresh >= current_detail->flush_time
437 			)
438 			continue;
439 		if (test_and_clear_bit(CACHE_PENDING, &ch->flags))
440 			queue_loose(current_detail, ch);
441
442 		if (atomic_read(&ch->ref.refcount) == 1)
443 			break;
444 	}


BUG: unable to handle kernel paging request at virtual address 51c503f6
 printing eip:
f0b973d9
*pde = 00000000
Oops: 0000 [#1]
SMP
last sysfs file: /devices/pci0000:00/0000:00:01.0/irq
Modules linked in: nfsd exportfs lockd nfs_acl sunrpc ipv6 ipt_REJECT xt_state
ip_conntrack nfnetlink xt_tcpudp iptable_filter ip_tables x_tables video sbs
i2c_ec button battery asus_acpi ac lp sg scb2_flash floppy mtdcore chipreg
map_funcs 3c59x i2c_piix4 mii pcspkr i2c_core tg3 parport_pc parport serio_raw
ide_cd cdrom dm_snapshot dm_zero dm_mirror dm_mod mptspi mptscsih mptbase
scsi_transport_spi sd_mod scsi_mod raid456 xor ext3 jbd ehci_hcd ohci_hcd uhci_hcd
   1
   0060:[<f0b973d9>]    Not tainted VLI
EFLAGS: 00010202   (2.6.19-1.2911.fc6 #1)
EIP is at cache_clean+0xb5/0x194 [sunrpc]
eax: ffffffff   ebx: 51c503f2   ecx: f0bae840   edx: f0bae840
cce9dc80   edi: efd811c0   ebp: 00000282   esp: c17d9f58
ds: 007b   es: 007b   ss: 0068
Process events/1 (pid: 9, ti=c17d9000 task=eff45630 task.ti=c17d9000)
Stack: f0baea00 f0baea04 f0b97cd4 c043692f 00000282 efd811c0 efd811e0 f0b97ccf
       00000000 efd811e0 efd811c0 efd811d8 00000000 c04372ec 00000001 00000000
       00000001 00010000 00000000 00000000 eff45630 c04215f1 00100100 00200200
Call Trace:
 [<f0b97cd4>] do_cache_clean+0x5/0x2e [sunrpc]
 [<c043692f>] run_workqueue+0x97/0xdd
 [<c04372ec>] worker_thread+0xd9/0x10d
 [<c0439878>] kthread+0xc0/0xec
 [<c0404c03>] kernel_thread_helper+0x7/0x10
 =======================
Code: 8d f6 00 00 00 8d 41 0c e8 37 e5 a8 cf a1 64 08 bb f0 8d 34 85 00 00 00 00
a1 60 08 bb f0 03 70 08 8b 1e eb 47 8b 15 60 08 bb f0 <8b> 43 04 39 42 50 7e 04
40 89 42 50 8b 43 04 3b 05 00 60 85 c0
[<f0b973d9>] cache_clean+0xb5/0x194 [sunrpc] SS:ESP 0068:c17d9f58


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
