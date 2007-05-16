From: Roger Heflin <rheflin@atipa.com>
Subject: Kernel BUG at mm/slab.c:2380 on NFS server in nfsd (2.6.21.1)
Date: Wed, 16 May 2007 08:55:19 -0500
Message-ID: <464B0D47.6070509@atipa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: NFS <nfs@lists.sourceforge.net>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758591AbXEPNza@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Running bonnie over nfs on a RHEL4.4 client against a 2.6.21.1 server
got me this crash after about 4 hours of running on the server:

This was running lvm -> ext3 -> nfs ---- nfsclient (RHEL4.4).

	Ideas?

                       Roger

May 15 21:10:31 vault1 kernel: ------------[ cut here ]------------
May 15 21:10:31 vault1 kernel: kernel BUG at mm/slab.c:2380!
May 15 21:10:31 vault1 kernel: invalid opcode: 0000 [1] SMP
May 15 21:10:31 vault1 kernel: CPU 0
May 15 21:10:31 vault1 kernel: Modules linked in: qla2xxx nfsd exportfs 
lockd nfs_acl sunrpc hidp l2cap bluetooth ipv6 cpufreq_ondemand jfs 
dm_mirror dm_multipath dm_mod video sbs i2c_ec dock button battery 
asus_acpi ac lp snd_intel8x0 snd_ac97_codec ac97_bus snd_seq_dummy 
snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device sg snd_pcm_oss 
floppy snd_mixer_oss snd_pcm cfi_cmdset_0002 cfi_util mtdpart snd_timer 
jedec_probe cfi_probe gen_probe snd ck804xrom sata_nv mtdcore chipreg 
i2c_nforce2 soundcore map_funcs libata snd_page_alloc pcspkr i2c_core 
k8temp hwmon forcedeth ohci1394 ieee1394 parport_pc ide_cd parport cdrom 
serio_raw scsi_transport_fc shpchp megaraid_mbox sd_mod scsi_mod 
megaraid_mm ext3 jbd ehci_hcd ohci_hcd uhci_hcd
May 15 21:10:31 vault1 kernel: Pid: 4256, comm: nfsd Not tainted 2.6.21.1 #1
May 15 21:10:31 vault1 kernel: RIP: 0010:[<ffffffff8025a710>] 
[<ffffffff8025a710>] cache_alloc_refill+0xe6/0x1f3
May 15 21:10:31 vault1 kernel: RSP: 0018:ffff81021dead6d0  EFLAGS: 00010002
May 15 21:10:31 vault1 kernel: RAX: 0000000000000001 RBX: 
ffff81012211d960 RCX: ffff810120013040
May 15 21:10:31 vault1 kernel: RDX: 000000000000000e RSI: 
ffff810139020000 RDI: ffff810120013040
