From: Ben DJ <bendj095124367913213465@gmail.com>
Subject: Re: NFSv4 Kernel-server requires 2x manual restart after reboot?
	Maybe a timing problem?
Date: Fri, 23 Oct 2009 12:12:48 -0700
Message-ID: <babafd2f0910231212s12bfbf5dsa1318b9d898d8608@mail.gmail.com>
References: <babafd2f0910231007h329e75b7raa7207d0b816a72a@mail.gmail.com>
	<20091023172719.GB31133@fieldses.org> <babafd2f0910231057o4898c643n4605ef9b0e4686d8@mail.gmail.com>
	<20091023182413.GA32155@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:61530 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936AbZJWTNE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Oct 2009 15:13:04 -0400
Received: by pwj9 with SMTP id 9so322015pwj.21
        for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2009 12:13:08 -0700 (PDT)
In-Reply-To: <20091023182413.GA32155@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

On Fri, Oct 23, 2009 at 11:24 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

I'm getting closer to "works". At least the way I think it should :-/.

With,

cat /etc/auto.master
	/mnt.dev /etc/auto.device
	/mnt.nfs /etc/auto.nfsv4

cat /etc/auto.device
	cd          -fstype=iso9660,ro,nosuid,nodev :/dev/cdrom

cat /etc/auto.nfsv4
	test -fstype=nfs4,rw server.bendj.loc:/

After reboot,

mount
	/dev/dm-1 on / type ext3 (rw,acl,user_xattr)
	proc on /proc type proc (rw)
	sysfs on /sys type sysfs (rw)
	debugfs on /sys/kernel/debug type debugfs (rw)
	udev on /dev type tmpfs (rw)
	devpts on /dev/pts type devpts (rw,mode=0620,gid=5)
	/dev/md0 on /boot type ext3 (rw,acl,user_xattr)
	/dev/dm-0 on /home type ext3 (rw,acl,user_xattr)
	fusectl on /sys/fs/fuse/connections type fusectl (rw)
	nfsd on /proc/fs/nfsd type nfsd (rw)
	rpc_pipefs on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)

exportfs -v
	/nfs 192.168.1.0/24(ro,wdelay,root_squash,no_subtree_check,fsid=0)

and the mounts ARE automounted,

ls /mnt.nfs/test /mnt.dev
	/mnt.dev:
		cd/

	/mnt.nfs/test:
		bin/  boot/  dev/  etc/  home/  lib/  lib64/  lost+found/  media/
mnt/  mnt.auto/  mnt.dev/  mnt.nfs/  nfs/  opt/  proc/  root/  sbin/
selinux/  srv/  sys/  tmp/  usr/  var/

Looks like autofs mounting rahter than /etc/fstab is the way-to-go.  I
don't know if this means there IS a timing problem with the /etc/fstab
way of doing things.

Also, the /mnt.nfs/test still shows the actual SERVER root, rather
than the specified NFS (ch)root.  That shouldn't be happening, right?

And just to check,

	service nfsserver restart
		Shutting down kernel based NFS server: nfsd statd mountd


                       done
		Starting kernel based NFS server: idmapd mountd statd nfsd sm-notify


                       done

works the 1st time around.

BenDJ
