From: Ed L Cashin <ecashin@coraid.com>
Subject: block dev minor > 255 and exporting fs
Date: Wed, 05 Oct 2005 13:32:48 -0400
Message-ID: <87hdbvx41r.fsf@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ENEDV-0001K1-Dt
	for nfs@lists.sourceforge.net; Wed, 05 Oct 2005 11:42:13 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ENEDO-000233-RP
	for nfs@lists.sourceforge.net; Wed, 05 Oct 2005 11:42:13 -0700
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1ENEBl-00064E-2w
	for nfs@lists.sourceforge.net; Wed, 05 Oct 2005 20:40:25 +0200
Received: from adsl-19-26-13.asm.bellsouth.net ([68.19.26.13])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Wed, 05 Oct 2005 20:40:25 +0200
Received: from ecashin by adsl-19-26-13.asm.bellsouth.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Wed, 05 Oct 2005 20:40:25 +0200
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi.  I've noticed that an NFS mount times out when I export a
filesystem residing on a block device with a "large" minor number,
i.e. beyond the old limit of 255 from when there were only eight bits
for the minor number of devices.

If I use a block device with a lower minor number, things work as
expected, and if I "wrap" a high-numbered device in a trivial md set,
using /dev/md0 with its minor number of zero, things work as expected.

Without initial success I've looked at the kernel sources to see where
the nfs server might be using only eight of the twenty bits 2.6 uses
for minor numbers.  Does anyone know where that might be occuring?

The nfs server in my tests is a debian testing machine running
2.6.12-1-amd64-generic, and the client is a debian stable system
running a custom 2.6.13-rc6 kernel, but I've seen this problem on
other systems a while ago.  At that time I found out that 255 was the
magic minor number after which problems started occuring, if I recall
correctly.  If you don't have block devices with high minor numbers to
test with, you can replicate this problem using the vblade:

  http://sourceforge.net/projects/aoetools/

... and the aoe driver in any 2.6 kernel from 2.6.11.  Anyway, here
are the details for interested parties.  The nfs server is "makki" and
the client is "kokone".

  makki:/home/ecashin# modprobe aoe
  makki:/home/ecashin# ls -l /dev/etherd/e2.1
  brw-rw----  1 root disk 152, 336 2005-10-05 08:24 /dev/etherd/e2.1
  makki:/home/ecashin# mount /dev/etherd/e2.1 /mnt/aoe/e2.1 
  makki:/home/ecashin# grep aoe /etc/exports
  /mnt/aoe/e2.1 *.coraid.com(rw,sync)
  makki:/home/ecashin# 

On the client, mount times out.

  root@kokone root# mount -t nfs makki:/mnt/aoe/e2.1 /mnt/makki 
  mount: makki:/mnt/aoe/e2.1: can't read superblock
  root@kokone root# tail /var/log/everything
...
  Oct  5 12:27:16 kokone kernel: nfs: server makki not responding, timed out
  Oct  5 12:27:37 kokone last message repeated 2 times
  root@kokone root# 

I can use a trivial one-device linear software RAID on the nfs server
so that nfs doesn't see the high minor device number.  This is just
using a low-minor-number md device as a wrapper for the
high-minor-number aoe device.

  makki:/home/ecashin# /etc/init.d/nfs-kernel-server stop && /etc/init.d/nfs-common stop
  Stopping NFS kernel daemon: mountd nfsd.
  Unexporting directories for NFS kernel daemon...done.
  Stopping NFS common utilities: statd.
  makki:/home/ecashin# umount /mnt/aoe/e2.1
  makki:/home/ecashin# ls -l /dev/md0
  brw-rw----  1 root disk 9, 0 2005-10-05 08:40 /dev/md0
  makki:/home/ecashin# mdadm -B --auto=md --force -l linear -n 1 /dev/md0 /dev/etherd/e2.1
  mdadm: array /dev/md0 built and started.
  makki:/home/ecashin# mount /dev/md0 /mnt/aoe/e2.1
  makki:/home/ecashin# ls /mnt/aoe/e2.1
  screen
  makki:/home/ecashin# /etc/init.d/nfs-common start && /etc/init.d/nfs-kernel-server start
  Starting NFS common utilities: statd.
  Exporting directories for NFS kernel daemon...done.
  Starting NFS kernel daemon: nfsd mountd.
  makki:/home/ecashin# 

Then on the client, all goes well:

  root@kokone root# mount -t nfs makki:/mnt/aoe/e2.1 /mnt/makki
  root@kokone root# ls /mnt/makki
  screen
  root@kokone root# umount /mnt/makki

So I have a nice workaround, but I would rather not need it.  Things
go well *without* the md wrapper if the aoe device has a minor number
below 256.  What part of the nfs server doesn't use all twenty bits
that 2.6 uses for the device minor number?  I remember guessing that
it was a handle or tag used in the protocol, but that was a long time
ago.

  makki:/home/ecashin# /etc/init.d/nfs-kernel-server stop && /etc/init.d/nfs-common stop
  Stopping NFS kernel daemon: mountd nfsd.
  Unexporting directories for NFS kernel daemon...done.
  Stopping NFS common utilities: statd.
  makki:/home/ecashin# umount /mnt/aoe/e2.1 
  makki:/home/ecashin# mdadm -S /dev/md0
  makki:/home/ecashin# sync
  makki:/home/ecashin# ls -l /dev/etherd/e0.0
  brw-rw----  1 root disk 152, 0 2005-10-05 08:49 /dev/etherd/e0.0
  makki:/home/ecashin# mount /dev/etherd/e0.0 /mnt/aoe/e2.1
  makki:/home/ecashin# /etc/init.d/nfs-common start && /etc/init.d/nfs-kernel-server start
  Starting NFS common utilities: statd.
  Exporting directories for NFS kernel daemon...done.
  Starting NFS kernel daemon: nfsd mountd.
  makki:/home/ecashin# 

  root@kokone root# mount -t nfs makki:/mnt/aoe/e2.1 /mnt/makki
  root@kokone root# ls /mnt/makki
  screen
  root@kokone root# 

-- 
  Ed L Cashin <ecashin@coraid.com>



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
