From: Philipp Matthias Hahn <pmhahn@svs.Informatik.Uni-Oldenburg.de>
Subject: [Fwd: moradin 2006-08-02 11:02 System Events]
Date: Wed, 02 Aug 2006 12:50:25 +0200
Message-ID: <44D08371.9070607@svs.Informatik.Uni-Oldenburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8EJH-0000Fc-Nr
	for nfs@lists.sourceforge.net; Wed, 02 Aug 2006 03:50:43 -0700
Received: from ip-svs-1.informatik.uni-oldenburg.de ([134.106.12.126]
	helo=schlidder.svs.informatik.uni-oldenburg.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G8EJF-0001MZ-Kb
	for nfs@lists.sourceforge.net; Wed, 02 Aug 2006 03:50:44 -0700
To: nfs@lists.sourceforge.net, Neil Brown <neilb@cse.unsw.edu.au>
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

Hello!

Rebooting one of our NFS file servers with 2.6.17.7, I just got the
following OOPS:

BUG: unable to handle kernel NULL pointer dereference at virtual address
00000041
printing eip:
c01fe571
*pde = 00000000
Oops: 0000 [#1]
SMP
Modules linked in: parport_pc lp parport nfsd exportfs binfmt_misc
autofs4 thermal ipv6 8021q ide_cd 8250_pnp 8250 serial_core floppy
ohci_hcd usbcore i2c_piix4 i2c_core ipmi_si ipmi_watchdog ipmi_devintf
ipmi_msghandler
CPU:    1
EIP:    0060:[<c01fe571>]    Not tainted VLI
EFLAGS: 00010246   (2.6.17.7-station #1)
EIP is at _atomic_dec_and_lock+0x9/0x48
eax: 00000041   ebx: 00000041   ecx: 00000001   edx: c041b280
esi: c041b280   edi: f6f675c0   ebp: f7636dc0   esp: f7636db8
ds: 007b   es: 007b   ss: 0068
Process nfsd (pid: 1964, threadinfo=f7636000 task=f7e22a70)
Stack: 00000041 f8b8d958 f7636dcc c0351d77 f6f675c0 f7636dd8 f8b8d992
f6f675cc
f7636de8 c01ff767 f8bb1500 f8baf260 f7636e08 c0353df6 f6c42340 f8bb1500
f7636e2c 00000000 00000080 00000008 f7636e24 f8b8def2 00000008 f7636e2c
Call Trace:
<c01034a0> show_stack_log_lvl+0x88/0x90
<c01035fc> show_registers+0x115/0x17d
<c01037ed> die+0x115/0x1ee
<c0112644> do_page_fault+0x466/0x555
<c0103147> error_code+0x4f/0x54
<c0351d77> auth_domain_put+0x10/0x3f
<f8b8d992> expkey_put+0x3a/0x44 [nfsd]
<c01ff767> kref_put+0x66/0x77
<c0353df6> sunrpc_cache_lookup+0xbb/0xf5
<f8b8def2> svc_expkey_lookup+0xa1/0xaf [nfsd]
<f8b8e635> exp_find_key+0x5c/0x81 [nfsd
<f8b8efd1> exp_find+0x11/0x75 [nfsd]
<f8b89e6e> fh_verify+0x15d/0x470 [nfsd]
<f8b8b57c> nfsd_open+0x21/0x14d [nfsd]
<f8b8be1b> nfsd_read+0x6f/0xa9 [nfsd]
<f8b91c58> nfsd3_proc_read+0xdb/0x137 [nfsd]
<f8b8865a> nfsd_dispatch+0xca/0x190 [nfsd]
<c034f93f> svc_process+0x393/0x5c4
<f8b88437> nfsd+0x189/0x2e2 [nfsd]
<c0100e31> kernel_thread_helper+0x5/0xb
Code: 0f a3 0d 78 ae 48 c0 19 c0 85 c0 75 10 89 c8 89 da e8 8a ff ff ff
83 f8 03 89 c1 7e e3 5b 89 c8 5d c3 55 89 e5 56 89 d6 53 89 c3 <8b> 10
83 fa 01 74 11 8d 4a ff 89 d0 f0 0f b1 0b 39 d0 74 04 89
EIP: [<c01fe571>] _atomic_dec_and_lock+0x9/0x48 SS:ESP 0068:f7636db8

Doing a quick search did't reveal any similar reported bug. I'm not
subsribed to the nfs-ml, so please cc: me on replies.

BYtE
Philipp
-- 
      Dipl.-Inform. Philipp.Hahn@informatik.uni-oldenburg.de
      Abteilung Systemsoftware und verteilte Systeme, Fk. II
Carl von Ossietzky Universitaet Oldenburg, 26111 Oldenburg, Germany
    http://www.svs.informatik.uni-oldenburg.de/contact/pmhahn/
      Telefon: +49 441 798-2866    Telefax: +49 441 798-2756

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
