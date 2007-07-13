From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: nfsd oops in current -git
Date: Fri, 13 Jul 2007 18:33:37 +0200
Message-ID: <20070713163337.GT5328@kernel.dk>
References: <469780BB.3070206@trash.net> <4697A7EC.6050006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net,
	Patrick McHardy <kaber@trash.net>,
	Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9O5g-0001TT-5D
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 09:34:00 -0700
Received: from brick.kernel.dk ([80.160.20.94] helo=kernel.dk)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9O5j-0002b7-80
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 09:34:03 -0700
In-Reply-To: <4697A7EC.6050006@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, Jul 13 2007, Chuck Ebbert wrote:
> On 07/13/2007 09:40 AM, Patrick McHardy wrote:
> > I get this oops with current -git:
> > 
> > [ 3437.018862] PGD 9acab067 PUD 9acaa067 PMD 0
> > [ 3437.018870] CPU 1
> > [ 3437.018872] Modules linked in: nfsd exportfs ppdev lp nfs lockd
> > nfs_acl sunrpc deflate zlib_deflate zlib_inflate twofish twofish_common
> > camellia serpent blowfish des cbc ecb blkcipher aes xcbc sha256
> > crypto_null af_key rfcomm l2cap fuse nfnetlink_queue nfnetlink_log
> > nf_conntrack_netlink nf_nat nf_conntrack_ipv6 nf_conntrack_ipv4
> > nf_conntrack nfnetlink ip6_tables ip_tables x_tables hangcheck_timer
> > cpufreq_ondemand powernow_k8 freq_table video backlight thermal
> > processor fan ide_generic ide_disk ide_cd cdrom generic hci_usb
> > bluetooth usbhid hid snd_via82xx snd_seq_dummy snd_seq_oss
> > snd_via82xx_modem snd_ac97_codec ac97_bus snd_seq_midi
> > snd_seq_midi_event snd_pcm_oss snd_mixer_oss snd_mpu401 snd_pcm
> > snd_mpu401_uart snd_seq snd_timer snd_rawmidi snd_seq_device parport_pc
> > snd psmouse parport via82cxxx serio_raw i2c_viapro evdev ehci_hcd sky2
> > snd_page_alloc uhci_hcd ide_core soundcore pcspkr
> > [ 3437.018923] Pid: 4432, comm: nfsd Not tainted 2.6.22 #5
> > [ 3437.018926] RIP: 0010:[<ffffffff81054eff>]  [<ffffffff81054eff>]
> > put_page+0x4/0xb3
> > [ 3437.018932] RSP: 0018:ffff8101335f5c40  EFLAGS: 00010203
> > [ 3437.018935] RAX: 0000000000000000 RBX: ffff810133576000 RCX:
> > ffff8100a0fa5ab8
> > [ 3437.018938] RDX: ffff810003754428 RSI: ffff8100a0fa5868 RDI:
> > 0000000000000000
> > [ 3437.018942] RBP: ffff810003754428 R08: ffff8100a1b7c5d8 R09:
> > ffff8101335f5c10
> > [ 3437.018946] R10: ffff810003739a78 R11: ffff81009ec61d40 R12:
> > ffff810133576570
> > [ 3437.018950] R13: ffff8100a0fa5868 R14: 0000000000001000 R15:
> > ffff810133576168
> > [ 3437.018954] FS:  00002ad8e9fab6f0(0000) GS:ffff81013fc72e40(0000)
> > knlGS:00000000f7e426c0
> > [ 3437.018957] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [ 3437.018959] CR2: 0000000000000000 CR3: 000000009a91a000 CR4:
> > 00000000000006e0
> > [ 3437.018963] Process nfsd (pid: 4432, threadinfo ffff8101335f4000,
> > task ffff81013f969040)
> > [ 3437.018965] Stack:  ffff810133576000 ffff810003754428
> > ffff810133576570 ffffffff8830e001
> > [ 3437.018973]  ffff810003747500 ffff8100a0fa5868 ffff8100a0fa5800
> > ffff8101335f5d80
> > [ 3437.018978]  0000000000000000 0000000000000000 ffffffff8122c440
> > ffffffff810892ac
> > [ 3437.018982] Call Trace:
> > [ 3437.019002]  [<ffffffff8830e001>] :nfsd:nfsd_splice_actor+0x71/0xea
> > [ 3437.019010]  [<ffffffff810892ac>] __splice_from_pipe+0x58/0x1bf
> > [ 3437.019023]  [<ffffffff8830df90>] :nfsd:nfsd_splice_actor+0x0/0xea
> > [ 3437.019040]  [<ffffffff8830d326>]
> > :nfsd:nfsd_direct_splice_actor+0x10/0x12
> > [ 3437.019044]  [<ffffffff81088efc>] splice_direct_to_actor+0xfd/0x19d
> > [ 3437.019058]  [<ffffffff8830d316>] :nfsd:nfsd_direct_splice_actor+0x0/0x12
> > [ 3437.019076]  [<ffffffff8830d1f4>] :nfsd:nfsd_vfs_read+0x22b/0x34d
> > [ 3437.019098]  [<ffffffff8830d715>] :nfsd:nfsd_read+0xa7/0xc4
> > [ 3437.019117]  [<ffffffff88314539>] :nfsd:nfsd3_proc_read+0x117/0x15a
> > [ 3437.019133]  [<ffffffff8830924d>] :nfsd:nfsd_dispatch+0xdd/0x19e
> > [ 3437.019156]  [<ffffffff88280194>] :sunrpc:svc_process+0x3f3/0x703
> > [ 3437.019164]  [<ffffffff81212423>] __lock_text_start+0x23/0x7e
> > [ 3437.019180]  [<ffffffff88309817>] :nfsd:nfsd+0x193/0x2b0
> > [ 3437.019188]  [<ffffffff8100a9c8>] child_rip+0xa/0x12
> > [ 3437.019207]  [<ffffffff88309684>] :nfsd:nfsd+0x0/0x2b0
> > [ 3437.019212]  [<ffffffff8100a9be>] child_rip+0x0/0x12
> 
> Does Jens's patch fix it?
> 
> http://marc.info/?l=linux-netdev&m=118432481101579&q=raw

Probably not, that's for another bug. I'll try and see if I can take a
look tonight.

-- 
Jens Axboe


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
