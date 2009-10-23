From: Ben DJ <bendj095124367913213465@gmail.com>
Subject: Re: NFSv4 Kernel-server requires 2x manual restart after reboot?
	Maybe a timing problem?
Date: Fri, 23 Oct 2009 10:57:57 -0700
Message-ID: <babafd2f0910231057o4898c643n4605ef9b0e4686d8@mail.gmail.com>
References: <babafd2f0910231007h329e75b7raa7207d0b816a72a@mail.gmail.com>
	<20091023172719.GB31133@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:54457 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbZJWSGW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Oct 2009 14:06:22 -0400
Received: by pwj9 with SMTP id 9so296947pwj.21
        for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2009 11:06:26 -0700 (PDT)
In-Reply-To: <20091023172719.GB31133@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

On Fri, Oct 23, 2009 at 10:27 AM, J. Bruce Fields <bfields@fieldses.org=
> wrote:
> On Fri, Oct 23, 2009 at 10:07:23AM -0700, Ben DJ wrote:
>> I've installed NFSv4 as nfs-kernel-server.
>
> What distro and versions are you using?

I'm currently working on Opensuse 11.2 RC1.

At the moment,

kernel-default-base-2.6.31.3-1.1.x86_64
kernel-default-2.6.31.3-1.1.x86_64
kernel-default-devel-2.6.31.3-1.1.x86_64

quota-nfs-3.17-3.1.x86_64
nfsidmap-0.21-3.14.x86_64
nfs-doc-1.1.3-20.1.x86_64
nfs-client-1.1.3-20.1.x86_64
nfs-kernel-server-1.1.3-20.1.x86_64


> Huh. =A0What filesystem is at /nfs/test?

I'm not entirely sure what you're asking for.

/nfs/test is on my "/" volume, which is ext3 (someday, ext4 -- but not =
yet).

Is that what you mean?

Also I found that switching from mounts in /etc/fstab to using autofs
gets rid of the mount-after-boot issues

cat /etc/auto.master
	/test /etc/auto.misc
cat /etc/auto.misc
	cd -fstype=3Diso9660,ro,nosuid,nodev :/dev/cdrom
	nfs4_test -fstype=3Dnfs4,rw 192.168.1.2:/
chkconfig autofs on
reboot

But now, immediately after reboot,

ls /test/nfs4_test/
	bin/  boot/  dev/  etc/  home/  lib/  lib64/  lost+found/  media/
mnt/  mnt.auto/  nfs/  opt/  proc/  root/  sbin/  selinux/  srv/  sys/
 tmp/  usr/  var/

which is mounted, and feels like progress.

But the mount is of 192.168.1.2's "/" root.  I expected the NFSv4
exported-root @ /nfs, instead.

Thanks for your time.

BenDJ



Thanks.

BedDJ
