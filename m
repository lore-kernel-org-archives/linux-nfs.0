From: "Martin Guy" <martinwguy@yahoo.it>
Subject: PROBLEM: kernel nfsd does not log disk reads in system stats
Date: Tue, 13 Mar 2007 16:01:54 +0000
Message-ID: <56d259a00703130901v3cf27269sf37c3e352eb6e9d7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HR9Ri-0006Hw-EG
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 09:01:54 -0700
Received: from nf-out-0910.google.com ([64.233.182.186])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HR9Rk-0001bW-2c
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 09:01:56 -0700
Received: by nf-out-0910.google.com with SMTP id c31so4769080nfb
	for <nfs@lists.sourceforge.net>; Tue, 13 Mar 2007 09:01:55 -0700 (PDT)
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

[1.] kernel nfsd does not log disk reads in system stats
[2.] When intensive reads are happening on an NFS-mounted volume, the
system activity stats for disk reads remain zero.
[3.] NFS stat
[4.] Linux version 2.6.18-3-686 (Debian 2.6.18-7) (waldi@debian.org)
(gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-20)) #1 SMP Mon
Dec 4 16:41:14 UTC 2006
[5.] Compiling a source tree in an nfs-mounted volume, the output of
"vmstat" shows zero disk reads, though a high number of disk writes is
registered, and gkrellm system monitor shows the same info
[6.]
[7.] Debian etch i386 on pentiums over 100MB ethernet
[7.1.]
Linux elite 2.6.18-3-686 #1 SMP Mon Dec 4 16:41:14 UTC 2006 i686 GNU/Linux

Gnu C                  4.1.2
Gnu make               3.81
binutils               2.17
util-linux             2.12r
mount                  2.12r
module-init-tools      3.3-pre2
e2fsprogs              1.40-WIP
reiserfsprogs          3.6.19
Linux C Library        2.3.6
Dynamic linker (ldd)   2.3.6
Procps                 3.2.7
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               5.97
udev                   105
Modules Loaded         nls_iso8859_1 nls_cp437 vfat fat sd_mod usb_storage scsi_
mod radeon drm iptable_nat ip_nat ip_conntrack nfnetlink ip_tables x_tables nfs
nfsd exportfs lockd nfs_acl sunrpc ipv6 dm_snapshot dm_mirror dm_mod joydev snd_
intel8x0m snd_intel8x0 pcmcia firmware_class parport_pc parport snd_ac97_codec f
loppy irda crc_ccitt snd_ac97_bus yenta_socket rsrc_nonstatic pcmcia_core rtc sn
d_pcm_oss snd_mixer_oss snd_pcm intel_agp agpgart snd_timer snd cdc_ether usbnet
 eth1394 soundcore i2c_i801 i2c_core snd_page_alloc shpchp pci_hotplug pcspkr ps
mouse serio_raw tsdev evdev reiserfs ide_cd cdrom ide_disk usbhid piix generic o
hci1394 ieee1394 e100 mii ide_core uhci_hcd usbcore thermal processor fan

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
