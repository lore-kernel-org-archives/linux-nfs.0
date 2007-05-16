From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Kernel BUG at mm/slab.c:2380 on NFS server in nfsd
	(2.6.21.1)
Date: Wed, 16 May 2007 12:29:37 -0400
Message-ID: <20070516162937.GC9895@fieldses.org>
References: <464B0D47.6070509@atipa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS <nfs@lists.sourceforge.net>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
To: Roger Heflin <rheflin@atipa.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoMNc-0006yp-LJ
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 09:29:38 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HoMNf-0004T1-5g
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 09:29:39 -0700
In-Reply-To: <464B0D47.6070509@atipa.com>
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

On Wed, May 16, 2007 at 08:55:19AM -0500, Roger Heflin wrote:
> Running bonnie over nfs on a RHEL4.4 client against a 2.6.21.1 server
> got me this crash after about 4 hours of running on the server:
> 
> This was running lvm -> ext3 -> nfs ---- nfsclient (RHEL4.4).

Yipes.  Has this happened only once, or do you have a way to reliably
reproduce it?

Is it a new problem?  (And, if so, what changed?)

> May 15 21:10:31 vault1 kernel: ------------[ cut here ]------------
> May 15 21:10:31 vault1 kernel: kernel BUG at mm/slab.c:2380!

That's the check_spinlock_acquired() in cache_alloc_refill().  What
causes that to fail?

> May 15 21:10:31 vault1 kernel: invalid opcode: 0000 [1] SMP
> May 15 21:10:31 vault1 kernel: CPU 0
> May 15 21:10:31 vault1 kernel: Modules linked in: qla2xxx nfsd exportfs 
> lockd nfs_acl sunrpc hidp l2cap bluetooth ipv6 cpufreq_ondemand jfs 
> dm_mirror dm_multipath dm_mod video sbs i2c_ec dock button battery 
> asus_acpi ac lp snd_intel8x0 snd_ac97_codec ac97_bus snd_seq_dummy 
> snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device sg snd_pcm_oss 
> floppy snd_mixer_oss snd_pcm cfi_cmdset_0002 cfi_util mtdpart snd_timer 
> jedec_probe cfi_probe gen_probe snd ck804xrom sata_nv mtdcore chipreg 
> i2c_nforce2 soundcore map_funcs libata snd_page_alloc pcspkr i2c_core 
> k8temp hwmon forcedeth ohci1394 ieee1394 parport_pc ide_cd parport cdrom 
> serio_raw scsi_transport_fc shpchp megaraid_mbox sd_mod scsi_mod 
> megaraid_mm ext3 jbd ehci_hcd ohci_hcd uhci_hcd
> May 15 21:10:31 vault1 kernel: Pid: 4256, comm: nfsd Not tainted 2.6.21.1 #1
> May 15 21:10:31 vault1 kernel: RIP: 0010:[<ffffffff8025a710>] 
> [<ffffffff8025a710>] cache_alloc_refill+0xe6/0x1f3
> May 15 21:10:31 vault1 kernel: RSP: 0018:ffff81021dead6d0  EFLAGS: 00010002
> May 15 21:10:31 vault1 kernel: RAX: 0000000000000001 RBX: 
> ffff81012211d960 RCX: ffff810120013040
> May 15 21:10:31 vault1 kernel: RDX: 000000000000000e RSI: 
> ffff810139020000 RDI: ffff810120013040

There wasn't a backtrace?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
