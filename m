From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Why is remount necessary after rebooting server?
Date: Fri, 16 Apr 2010 10:12:31 +0400
Message-ID: <4BC7FFCF.8030003@msgid.tls.msk.ru>
Reply-To: linux-nfs@vger.kernel.org, Michael Tokarev <mjt@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:43014 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753695Ab0DPGOm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 02:14:42 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello.

It has been a while since I've seen.. issues with nfs for the
last time.  Now I hit a limitation of number of groups in nfs3,
and had to switch to nfs4.  And immediately hit another problem,
which makes the whole thing almost unusable for us.

The problem is that each time the nfs server is rebooted, I have
to - it boils down to - forcibly REBOOT each client which has
some mounts from the said server.  Because, well, remount - in
theory - should be sufficient, but I can't perform remount because
the filesystem(s) in question are busy.

Here's a typical situation (after reboot):

# ls /net/gnome/home
ls: cannot access /net/gnome/home: Stale NFS file handle

# mount | tail -n2
gnome:/ on /net/gnome type nfs4 (rw,nosuid,nodev,relatime,vers=4,rsize=262144,wsize=262144,namlen=255,soft,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.88.2,addr=192.168.88.4)
gnome:/home on /net/gnome/home type nfs4 (rw,nosuid,nodev,relatime,vers=4,rsize=262144,wsize=262144,namlen=255,soft,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.88.2,addr=192.168.88.4)

# umount /net/gnome/home
umount.nfs4: /net/gnome/home: device is busy
umount.nfs4: /net/gnome/home: device is busy

# umount -f /net/gnome/home
umount2: Device or resource busy
umount.nfs4: /net/gnome/home: device is busy
umount2: Device or resource busy
umount.nfs4: /net/gnome/home: device is busy

# umount -f /net/gnome
umount2: Device or resource busy
umount.nfs4: /net/gnome: device is busy
umount2: Device or resource busy
umount.nfs4: /net/gnome: device is busy


At this point, there are two ways:

  1.  try to find and kill all processes which are using
    the mountpoint.  But in almost all cases it is not
    possible since there is at least one process which is
    in D state and unkillable, so we proceed to variant 2:

  2. echo b > /proc/sysrq-trigger
    or something of this sort, since it will not be able
    umount / anyway.

Note that even if 1. succeed, the system is unusable anyway,
since it is here to service users.  So it is simpler and
faster to proceed to 2. stright away.

What can be done to stop the "Stale NFS handle" situation
from happening -- except of stopping rebooting the server?
At least with nfs3 it has been almost solved (almost, because
from time to time it still happens even with nfs3, leading
to the same issue).

Thanks!

/mjt
