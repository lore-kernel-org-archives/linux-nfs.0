Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 8bytes.org ([85.214.48.195]:51829 "EHLO mail.8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754306Ab2HGOuW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 10:50:22 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id 3EC9812B085
	for <linux-nfs@vger.kernel.org>; Tue,  7 Aug 2012 16:50:21 +0200 (CEST)
Date: Tue, 7 Aug 2012 16:50:19 +0200
From: Joerg Roedel <joro@8bytes.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Joerg Roedel <joerg.roedel@amd.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        wdauchy@gmail.com
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
Message-ID: <20120807145019.GI1917@8bytes.org>
References: <20120807134156.GP1996@amd.com>
 <50211E42.6040808@netapp.com>
 <20120807141548.GG1917@8bytes.org>
 <5021237D.1010107@netapp.com>
 <20120807142707.GH1917@8bytes.org>
 <502127EF.3030209@netapp.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="Izn7cH1Com+I3R9J"
In-Reply-To: <502127EF.3030209@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Izn7cH1Com+I3R9J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 07, 2012 at 10:36:31AM -0400, Bryan Schumaker wrote:
> Your stack trace is showing v4 calls on the failing box, those
> definitely shouldn't be happening if you're using v3.  Can you double
> check /etc/fstab and /proc/mounts on a working kernel to be sure?

So the bug is probably (for whatever reason) that the nfs4 path is
called for an nfs3 mount :)
Anyway, I attach /proc/mounts and /etc/fstab from that box running a
v3.5-rc5 kernel (where it works).


	Joerg


--Izn7cH1Com+I3R9J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="proc-mounts-3.5"

rootfs / rootfs rw 0 0
sysfs /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
udev /dev devtmpfs rw,relatime,size=8201004k,nr_inodes=2050251,mode=755 0 0
devpts /dev/pts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
tmpfs /run tmpfs rw,nosuid,relatime,size=3297852k,mode=755 0 0
fusectl /sys/fs/fuse/connections fusectl rw,relatime 0 0
/dev/sda5 / ext4 rw,noatime,errors=remount-ro,data=ordered 0 0
none /sys/kernel/debug debugfs rw,relatime 0 0
none /sys/kernel/security securityfs rw,relatime 0 0
none /run/lock tmpfs rw,nosuid,nodev,noexec,relatime,size=5120k 0 0
none /run/shm tmpfs rw,nosuid,nodev,relatime 0 0
/dev/sda6 /data ext4 rw,noatime,data=ordered 0 0
lemmy:/data/repos/ /data/lemmy nfs rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=165.204.15.93,mountvers=3,mountport=52788,mountproto=udp,local_lock=none,addr=165.204.15.93 0 0

--Izn7cH1Com+I3R9J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=etc-fstab

# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
proc            /proc           proc    nodev,noexec,nosuid 0       0
# / was on /dev/sda5 during installation
UUID=791ccf4e-dfe7-468d-9f54-40eff9b60dcf /               ext4    noatime,errors=remount-ro 0       1
# /data was on /dev/sda6 during installation
UUID=f32d10da-0587-413f-beac-bc5197c5aa84 /data           ext4    noatime         0       2
# swap was on /dev/sda1 during installation
UUID=a7cdb974-794f-4972-a386-b0bd687c52de none            swap    sw              0       0
lemmy:/data/repos	/data/lemmy	nfs	defaults	0	0

--Izn7cH1Com+I3R9J--


