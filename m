Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm11-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.240]:21976 "HELO
	nm11-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751052Ab1DYF0O convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Apr 2011 01:26:14 -0400
Message-ID: <669423.65679.qm@web111713.mail.gq1.yahoo.com>
Date: Sun, 24 Apr 2011 22:26:13 -0700 (PDT)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: NFS over TCP not available
To: nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,
A week ago I sent a post to nfs-linux, however bacause of my subscribe problem I don't know whether you received my post or not.
 
Sorry if it is a double post.... Here is the problem.
 
I am trying to boot a node from network via nfs and pxe. Here are the assumptions on the server:
 
auto lo
iface lo inet loopback
# The primary network interface
auto eth3
iface eth3 inet static
    address 196.25.69.15
    netmask 255.255.255.128
    network 196.25.69.0
    broadcast 196.25.69.127
    gateway 196.25.69.1
auto eth2
iface eth2 inet static
    address 192.168.1.1
    netmask 255.255.255.0
    broadcast 192.168.1.255
 
and the content of /etc/exports is:
 
/home/nfsroot 192.168.1.0/255.255.255.0(rw,no_subtree_check,async,no_root_squash)
 
where /home/nfsroot contains the linux image for client. The content of /home/nfsroot/etc/fstab is:

# UNCONFIGURED FSTAB FOR BASE SYSTEM
proc            /proc         proc   defaults       0      0
/dev/nfs        /             nfs    defaults       0      0
I see no terminal prompt (e.g bash, sh, ...). After some minutes I see these messages on the node:
 
connect: connection timed out
NFS over TCP not available from 192.168.1.1
Done.
Begin: Retrying nfs mount ...
Begin: Running /scripts/nfs-permanent ...
Done.
connect: connection timed out
....
Begin: Running /scripts/init-bottom...
mount: mounting /dev on /root/dev failed: no such file or directory
Done.
mount: mounting /sys on /root/sys failed: no such file or directory
mount: mounting /proc on /root/proc failed: no such file or directory
Taget filesystem doesn't have /sbin/init
No init found. Try passing init= bootarg
 
 
 
What is wrong with NFS? appreciate any idea and comment.
Thanks
 
// Naderan *Mahmood;
