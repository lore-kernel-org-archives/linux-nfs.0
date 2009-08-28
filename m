From: Toralf =?iso-8859-15?q?F=F6rster?= <toralf.foerster@gmx.de>
Subject: nfsv4 directory mount plays hard to get
Date: Fri, 28 Aug 2009 10:49:59 +0200
Message-ID: <200908281049.59781.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:55451 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752467AbZH1It7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Aug 2009 04:49:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'm wondering why a mount of a nfs4 directory exported by a user mode l=
inux image
(hostname n22_uml) at a mount point of the host (hostname n22) doesn't =
work simply.
Instead I've to specify the parameter "n22_uml:" oncy. After that all s=
ubsequent
umount/mounts of that particular file systems works w/o specifying "n22=
_uml:".

n22 ~ # mount /mnt/nfs/n22_uml
mount.nfs4: No such device
n22 ~ # mount -t nfs n22_uml: /mnt/nfs/n22_uml
mount.nfs: access denied by server while mounting n22_uml:
n22 ~ # mount -t nfs4 n22_uml: /mnt/nfs/n22_uml
n22 ~ # umount /mnt/nfs/n22_uml
n22 ~ # mount /mnt/nfs/n22_uml
n22 ~ # umount /mnt/nfs/n22_uml

The fstab entry at the host system :
n22 ~ # grep nfs /etc/fstab
n22_uml:        /mnt/nfs/n22_uml        nfs4    noauto

The exports file at the UML :
n22_uml ~ # cat /etc/exports=20
# /etc/exports: NFS file systems being exported.  See exports(5).

/tmp    n22*(rw,fsid=3D0,no_subtree_check,no_root_squash)

The host runs 2.6.30.5, the UML  2.6.31-rc8.

--=20
MfG/Sincerely

Toralf F=F6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

