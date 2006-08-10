From: "Chuck Lever" <chucklever@gmail.com>
Subject: rpc.idmapd oops with latest NFS bits from your web site
Date: Thu, 10 Aug 2006 15:21:41 -0400
Message-ID: <76bd70e30608101221se9d6fb6l8bb50e93109c7a5b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GBG6B-0006Jr-OL
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 12:21:43 -0700
Received: from nf-out-0910.google.com ([64.233.182.189])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GBG6B-0004xf-Tu
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 12:21:44 -0700
Received: by nf-out-0910.google.com with SMTP id a27so628821nfc
	for <nfs@lists.sourceforge.net>; Thu, 10 Aug 2006 12:21:42 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

I ran connectathon basic tests 20 times against a Linux NFSv3 server.
At the end of the test I got this oops.  This is repeatable, but not
100% of the time.

My test client is a dual core 1.83GHz laptop running over GbE.  FC5 is
installed.  Mount options are "rw,intr,tcp,vers=3"

Aug 10 15:16:31 picasso kernel: BUG: unable to handle kernel paging
request at virtual address 6b6b6bc3
Aug 10 15:16:31 picasso kernel:  printing eip:
Aug 10 15:16:31 picasso kernel: c015a1dc
Aug 10 15:16:31 picasso kernel: *pde = 00000000
Aug 10 15:16:31 picasso kernel: Oops: 0000 [#1]
Aug 10 15:16:31 picasso kernel: SMP
Aug 10 15:16:31 picasso kernel: Modules linked in: nfs lockd nfs_acl
sunrpc ext3 jbd dm_mirror dm_mod parport_pc parport usbhid nvram
uhci_hcd ehci_hcd sr_mod snd_hda_intel snd_hda_codec snd_seq_dummy
snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss
snd_mixer_oss tg3 snd_pcm i2c_i801 snd_timer snd
soundcore intel_agp snd_page_alloc i2c_core agpgart rtc usbcore xfs
ata_piix libata sd_mod scsi_mod
Aug 10 15:16:31 picasso kernel: CPU:    1
Aug 10 15:16:31 picasso kernel: EIP:    0060:[<c015a1dc>]    Not tainted VLI
Aug 10 15:16:31 picasso kernel: EFLAGS: 00010202   (2.6.18-rc4 #2)
Aug 10 15:16:31 picasso kernel: EIP is at cdev_put+0x8/0x3d
Aug 10 15:16:31 picasso kernel: eax: 6b6b6b6b   ebx: 40000010   ecx:
00000000   edx: f6a26604
Aug 10 15:16:31 picasso kernel: esi: f6a26604   edi: f5532984   ebp:
f7f5df60   esp: f7f5df5c
Aug 10 15:16:31 picasso kernel: ds: 007b   es: 007b   ss: 0068
Aug 10 15:16:31 picasso kernel: Process rpc.idmapd (pid: 3203,
ti=f7f5d000 task=f711f4d0 task.ti=f7f5d000)
Aug 10 15:16:31 picasso kernel: Stack: 40000010 f7f5df80 c01538df
f5302124 f6e77370 f6a26604 f5532984 f7f56ca8
Aug 10 15:16:31 picasso kernel:        00000000 f7f5df88 c015398e
f7f5df9c c01512dd f7f56ca8 00000009 f7f56d28
Aug 10 15:16:31 picasso kernel:        f7f5dfb4 c0152544 f5532984
00000009 80014940 80013810 f7f5d000 c01028f1
Aug 10 15:16:31 picasso kernel: Call Trace:
Aug 10 15:16:31 picasso kernel:  [<c01538df>] __fput+0xc5/0x15d
Aug 10 15:16:31 picasso kernel:  [<c015398e>] fput+0x17/0x19
Aug 10 15:16:31 picasso kernel:  [<c01512dd>] filp_close+0x51/0x5b
Aug 10 15:16:31 picasso kernel:  [<c0152544>] sys_close+0x7b/0x8f
Aug 10 15:16:31 picasso kernel:  [<c01028f1>] sysenter_past_esp+0x56/0x8d
Aug 10 15:16:31 picasso kernel: DWARF2 unwinder stuck at
sysenter_past_esp+0x56/0x8d
Aug 10 15:16:31 picasso kernel: Leftover inexact backtrace:
Aug 10 15:16:31 picasso kernel:  [<c0103b98>] show_stack_log_lvl+0x8c/0x97
Aug 10 15:16:31 picasso kernel:  [<c0103ccf>] show_registers+0x12c/0x199
Aug 10 15:16:31 picasso kernel:  [<c0103ebd>] die+0x181/0x26d
Aug 10 15:16:31 picasso kernel:  [<c02d55ab>] do_page_fault+0x3e5/0x4ad
Aug 10 15:16:31 picasso kernel:  [<c01035a9>] error_code+0x39/0x40
Aug 10 15:16:31 picasso kernel:  [<c01538df>] __fput+0xc5/0x15d
Aug 10 15:16:31 picasso kernel:  [<c015398e>] fput+0x17/0x19
Aug 10 15:16:31 picasso kernel:  [<c01512dd>] filp_close+0x51/0x5b
Aug 10 15:16:31 picasso kernel:  [<c0152544>] sys_close+0x7b/0x8f
Aug 10 15:16:31 picasso kernel:  [<c01028f1>] sysenter_past_esp+0x56/0x8d
Aug 10 15:16:31 picasso kernel: Code: c3 55 89 e5 89 50 68 89 48 6c 50
68 79 a2 15 c0 68 24 a0 15 c0 6a 00 a1 20 58 61 c0 e8 69 ee 0b 00 c9
c3 55 89 e5 53 85
c0 74 32 <8b> 58 58 e8 ae f7 04 00 85 db 74 26 89 e0 25 00 f0 ff ff 8b 40
Aug 10 15:16:31 picasso kernel: EIP: [<c015a1dc>] cdev_put+0x8/0x3d
SS:ESP 0068:f7f5df5c

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
