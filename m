From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Hanging udev process on nfs-mounted /dev
Date: Tue, 28 Sep 2004 10:48:16 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41592550.5060006@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CCDes-0003y7-4S
	for nfs@lists.sourceforge.net; Tue, 28 Sep 2004 01:48:26 -0700
To: NFS NFS <nfs@lists.sourceforge.net>,
	USB users list <linux-usb-users@lists.sourceforge.net>
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

Hi,

I cross-post this to the usb and the nfs list, because I'm not
sure if it is an udev or a nfs issue. I hope this is ok.

I got two logs of the hanging udev process which consumes 90%
of the CPU. It seems to be independent from the card reader, in
contrast to what I wrote in the other mail on the usb list, so
I started a new thread about this topic.

The issue:
==========
 From time to time some udev process goes mad and comsumes allmost all
the CPU power, making the whole system terribly slow.

The software:
=============
SuSE 9.1, kernel 2.6.8.1, udev 032, klibc 0.179, sysfsutils 1.1.0,
hotplug 0.44 (SuSE hotplug package, the rest (udev, klibc, sysfsutils,
kernel) has been replaced by newer versions).

My guess:
=========
Maybe sth. related to nfs? The udev process hangs at/after calling
F_SETLKW, see traces below.

We have diskless clients which mount their own /dev over NFS from a
server (not shared with other clients, each has its own /dev). Since
the clients don't have local hard disks, I guess this cannot be done
without NFS because we maintain some permanent links like
/dev/cdrecorder -> /dev/hdd, so we need some permanent filesystem.
I though about using a ramdisk for /dev on the clients and make udev
setup such links, but I'm not sure if a ramdisk for /dev is better
than a NFS mount. Would that be worth a try?

/dev is mounted in /etc/init.d/boot, before any other start script
runs. Thus, it is mounted with "nolock" because at this time no lockd
etc. is running.

How I got the logs:
===================

I moved /sbin/udev[start] to /sbin/utest/ and
created a script /sbin/udev with

   #!/bin/bash
   strace -o /var/log/udev.log.`uname -n`.${$} -f /sbin/utest/`basename $0` $@

The first two logs are from the /sbin/udevstart call which is initiated
from /etc/init.d/boot.udev. The .hangs log is from the hanging udev process.
It was not killed manually, because we did not have a shell at this point,
so after some time we hard-rebooted the computer.
The second "succeed" is from the same computer, 5 boots later. So the error
does not occur every time.

The other two logs are from a call "/sbin/udev block" initiated by
/etc/hotplug/block.agent when calling "pktsetup mycd /dev/cdrecorder"
manually. Here we killed the process after 15 minutes as you can see.

The logs are almost identical, just some difference w.r.t to locking.
E.g., the hanging pktsetup process issues some
   fcntl64(0, F_SETLK, {type=F_WRLCK, whence=SEEK_SET, start=4, len=1}) = -1 EAGAIN (Resource temporarily unavailable).

The main difference is at the end: The hanging process hang after some F_SETLKW command:

udevstart.hangs:
================
1073  unlink("/dev/mapper/control")     = 0
1073  symlink("../device-mapper", "/dev/mapper/control") = 0
1073  fcntl64(0, F_SETLKW, {type=F_WRLCK, whence=SEEK_SET, start=332, len=1}) = 0
1073  fcntl64(0, F_SETLKW, {type=F_WRLCK, whence=SEEK_SET, start=164, len=1}) = 0
<hangs forever>

udevstart.succeeds:
===================
1073  unlink("/dev/mapper/control")     = 0
1073  symlink("../device-mapper", "/dev/mapper/control") = 0
1073  fcntl64(0, F_SETLKW, {type=F_WRLCK, whence=SEEK_SET, start=332, len=1}) = 0
1073  fcntl64(0, F_SETLKW, {type=F_UNLCK, whence=SEEK_SET, start=332, len=1}) = 0
1073  open("/etc/dev.d/device-mapper", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = -1 ENOENT (No such file or directory)
1073  open("/etc/dev.d/misc", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = -1 ENOENT (No such file or directory)
1073  open("/etc/dev.d/default", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = -1 ENOENT (No such file or directory)
1073  munmap(0x4001a000, 16384)         = 0
1073  close(0)                          = 0
1073  exit_group(0)                     = ?

udev.pktsetup.hangs:
====================
lstat64("/sys/block/pktcdvd0/device", 0xbffff37c) = -1 ENOENT (No such file or directory)
time(NULL)                              = 1095859917
fcntl64(0, F_SETLKW, {type=F_WRLCK, whence=SEEK_SET, start=424, len=1}) = 0
fcntl64(0, F_SETLKW, {type=F_WRLCK, whence=SEEK_SET, start=164, len=1}) = ? ERESTARTSYS (To be restarted)
--- SIGTERM (Terminated) @ 0 (0) --- < we killed it here >
munmap(0x4001a000, 114688)              = 0
close(0)                                = 0
exit_group(35)                          = ?


udev.pktsetup.succeds:
======================
3161  chmod("/dev/pktcdvd0", 060600)    = 0
3161  fcntl64(0, F_SETLKW, {type=F_WRLCK, whence=SEEK_SET, start=424, len=1}) = 0
3161  fcntl64(0, F_SETLKW, {type=F_WRLCK, whence=SEEK_SET, start=164, len=1}) = 0
3161  fcntl64(0, F_SETLKW, {type=F_UNLCK, whence=SEEK_SET, start=164, len=1}) = 0
3161  fcntl64(0, F_SETLKW, {type=F_UNLCK, whence=SEEK_SET, start=424, len=1}) = 0
3161  open("/etc/dev.d/pktcdvd0", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = -1 ENOENT (No such file or directory)
3161  open("/etc/dev.d/block", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = -1 ENOENT (No such file or directory)
3161  open("/etc/dev.d/default", O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = -1 ENOENT (No such file or directory)
3161  munmap(0x4001a000, 32768)         = 0
3161  close(0)                          = 0
3161  exit_group(0)                     = ?

Could that be a problem related to /dev mounted with "nolock" via NFS,
or just some bug in NFS?

I didn't send the full logs, they are quite long. They are here it
someone needs to take a look:
http://www.bio.ifi.lmu.de/~steiner/udevstart.hangs
http://www.bio.ifi.lmu.de/~steiner/udevstart.succeeds
http://www.bio.ifi.lmu.de/~steiner/udev.pktsetup.hangs
http://www.bio.ifi.lmu.de/~steiner/udev.pktsetup.succeeds

I greatly appreciate any hints, because this problem hits our hosts
quite often and users cannot kill this udev process, so they have
to find some admin to kill it :-(

cu,
Frank


-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
