From: Olaf Hering <olh@suse.de>
Subject: 2.6.0-test10, oops in nfs_kill_super
Date: Thu, 27 Nov 2003 17:25:11 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031127162511.GA15901@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linuxppc64-dev@lists.linuxppc.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APP2K-0001xe-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Nov 2003 08:30:36 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1APP2J-0003Qg-Mo
	for nfs@lists.sourceforge.net; Thu, 27 Nov 2003 08:30:36 -0800
To: nfs@lists.sourceforge.net
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

I got this oops on ppc64 with 2.6.0-test10.
System is a p660, 6 cpus, 6 gig.

autofs is in use, which triggered the umount.

Please cc me, I'm not subscribed to the nfs list.


cpu 2: Vector: 300 (Data Access) at [c00000004b20b610]
    pc: c0000000000cd71c (.invalidate_list+0x60/0x160)
    lr: c0000000000cd8ec (.invalidate_inodes+0xd0/0x1b0)
    sp: c00000004b20b890
   msr: a000000000009032
   dar: 16400000450
 dsisr: 40000000
  current = 0xc00000011aa46080
  paca    = 0xc0000000005aa000
    pid   = 6843, comm = umount

2:mon> t
c00000004b20b890  0000000000000000
c00000004b20b950  c0000000000cd8ec  .invalidate_inodes+0xd0/0x1b0
c00000004b20ba00  c0000000000b21d8  .generic_shutdown_super+0x12c/0x354
c00000004b20baa0  c0000000000b36e0  .kill_anon_super+0x20/0xe0
c00000004b20bb30  c0000000001498b4  .nfs_kill_super+0x18/0x48
c00000004b20bbc0  c0000000000b1d9c  .deactivate_super+0xbc/0x190
c00000004b20bc60  c0000000000d219c  .__mntput+0x38/0x60
c00000004b20bcf0  c0000000000bcf9c  .path_release+0x6c/0x80
c00000004b20bd80  c0000000000d2df8  .sys_umount+0x58/0xc8
c00000004b20be30  c0000000000118d4  ret_from_syscall_1
exception: c00 (System Call) regs c00000004b20bea0
                  000000000ff88574
<Stack drops into userspace 00000000ffffe670>

2:mon> r
R00 = 000000040000000c   R16 = 0000000000000000
R01 = c00000004b20b890   R17 = 0000000000000000
R02 = c000000000639000   R18 = 0000000000000000
R03 = c00000010a0b8528   R19 = 0000000000000000
R04 = c000000146006c00   R20 = 0000000000000001
R05 = c00000004b20b9c0   R21 = c0000000005aaec0
R06 = c000000000636008   R22 = 0000000000000000
R07 = 0000000000000000   R23 = 0000000000000000
R08 = c000000146006ce0   R24 = c00000004b20b9c0
R09 = 0000000000000000   R25 = 0000000000000000
R10 = 0000000000000000   R26 = c000000146006c00
R11 = c00000011aa46080   R27 = c000000000536148
R12 = c00000014ec00d80   R28 = 0000016400000450
R13 = c0000000005aa000   R29 = 0000016400000440
R14 = 0000000000000000   R30 = c00000000056a7d8
R15 = 0000000000000000   R31 = 0000016400000450
pc  = c0000000000cd71c   msr = a000000000009032
lr  = c0000000000cd8ec   cr  = 0000000040000844
ctr = 0000000000000000   xer = 0000000020000000   trap =      300

the function looks like that:
c0000000000cd6bc <.invalidate_list>:
c0000000000cd6bc:       7c 08 02 a6     mflr    r0
c0000000000cd6c0:       fa c1 ff b0     std     r22,-80(r1)
c0000000000cd6c4:       fa e1 ff b8     std     r23,-72(r1)
c0000000000cd6c8:       3a c0 00 00     li      r22,0
c0000000000cd6cc:       fb 01 ff c0     std     r24,-64(r1)
c0000000000cd6d0:       fb 21 ff c8     std     r25,-56(r1)
c0000000000cd6d4:       3a e0 00 00     li      r23,0
c0000000000cd6d8:       7c b8 2b 78     mr      r24,r5
c0000000000cd6dc:       fb 41 ff d0     std     r26,-48(r1)
c0000000000cd6e0:       fb 61 ff d8     std     r27,-40(r1)
c0000000000cd6e4:       3b 20 00 00     li      r25,0
c0000000000cd6e8:       7c 9a 23 78     mr      r26,r4
c0000000000cd6ec:       fb c1 ff f0     std     r30,-16(r1)
c0000000000cd6f0:       fb 81 ff e0     std     r28,-32(r1)
c0000000000cd6f4:       7c 7b 1b 78     mr      r27,r3
c0000000000cd6f8:       fb a1 ff e8     std     r29,-24(r1)
c0000000000cd6fc:       fb e1 ff f8     std     r31,-8(r1)
c0000000000cd700:       f8 01 00 10     std     r0,16(r1)
c0000000000cd704:       eb c2 bb 18     ld      r30,-17640(r2)
c0000000000cd708:       f8 21 ff 41     stdu    r1,-192(r1)
c0000000000cd70c:       eb 83 00 00     ld      r28,0(r3)
c0000000000cd710:       7c 3c d8 00     cmpd    r28,r27
c0000000000cd714:       3b bc ff f0     addi    r29,r28,-16
c0000000000cd718:       7f 9f e3 78     mr      r31,r28
c0000000000cd71c:       eb 9c 00 00     ld      r28,0(r28)

It dies in invalidate_list()
                next = next->next;

However, why does r3 and r27 differ even if they should be the same?

-- 
USB is for mice, FireWire is for men!

sUse lINUX ag, nÜRNBERG


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
