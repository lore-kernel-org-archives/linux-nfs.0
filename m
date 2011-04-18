Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm24.bullet.mail.sp2.yahoo.com ([98.139.91.94]:42304 "HELO
	nm24.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751246Ab1DRHob convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Apr 2011 03:44:31 -0400
Message-ID: <355412.70771.qm@web111718.mail.gq1.yahoo.com>
Date: Mon, 18 Apr 2011 00:44:31 -0700 (PDT)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: NFS over TCP not available from ...
To: nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,
I am trying to boot a node from network via nfs and pxe. Here is the assumptions 
on the server:

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

and the content of  /etc/dnsmasq.conf, looks like:

dhcp-range=192.168.1.2,192.168.1.10,255.255.255.0,12h
dhcp-boot=pxelinux.0,server,192.168.1.1

and the content of /etx/exports is:

/home/nfsroot 
192.168.1.0/255.255.255.0(rw,no_subtree_check,async,no_root_squash)

Now when I turn on the node, I see that it finds the vmlinuz and init.rd images. 
So Seems that it properly accquired the IP address. After some minutes, it 
reaches to this message:

ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready

I see no terminal prompt (e.g bash, sh, ...). After some minutes I see these 
messages on the node:

connect: connection timed out
NFS over TCP not available from 192.168.1.1
Done.
Begin: Retrying nfs mount ...
Begin: Running /scripts/nfs-permanent ...
Done.
connect: connection timed out

What is wrong with NFS? Also I can not ping 192.168.1.2 from srver (192.168.1.1) 
either.

// Naderan *Mahmood;
