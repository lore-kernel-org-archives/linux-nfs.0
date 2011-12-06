Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33191 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945Ab1LFTgw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2011 14:36:52 -0500
Received: by eeaq14 with SMTP id q14so3277693eea.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2011 11:36:51 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 6 Dec 2011 11:36:51 -0800
Message-ID: <CANtneHKfm=GRev1Pfwi90VMJ3cn=huRgr6-G+9MH-w_LDW0t0Q@mail.gmail.com>
Subject: nfs client hangs after lazy unmount
From: Pete Holland <pholland27@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, I'm trying to debug a problem we are seeing in our systems and
was hoping to get some insight if possible.
We operate a fairly large (~500) cluster of linux VMs running a
modified version of OpenWRT 10.03 (linux kernel version 2.6.32.27)
These machines run Samba (version 3.5.11) that share files from an NFS
(over TCP) filesystem.  The SMB daemons (and backing mounts) are
brought up and down continuously throughout the day, and in order to
make sure the take-down is timely, we kill -TERM the parent SMB
process and lazily unmount (umount -l) the NFS share.  Most of the
time, this works just fine.  On occasion (usually about once or twice
per day) we end up with an SMB process that is stuck in (as best as I
can tell) nfs_getattr.  At this point the CPU is 100% in io_wait.  Our
only recourse appears to be rebooting the system when this happens.

Other relavent facts:
1.  I backported the -local_lock=flock patches into this kernel.
2.  The mount options of the NFS mount are
rw,noatime,noexec,fg,hard,intr,tcp,rsize=32768,wsize=32768,local_lock=flock
3.  This behavior seems like it may be new (or at least it is
definitely more exacerbated) since we upgraded from the 8.09 OpenWRT
release which was using the 2.6.25.20 kernel.
4.  nfsstat doesn't indicate any network issues with retransmits or the like

I can provide SysRq-T trace of the SMB process as well as a System.map
file of my kernel build if that helps.  I have a few of the systems
currently in this state so I may be able to perform some live
debugging.  Let me know if there is anything else I can provide.

Thank you for any help.

- Pete
