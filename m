From: f3ar007 <f3ar007@gmail.com>
Subject: two exports on server, only one directory appears on client
Date: Sun, 20 Dec 2009 20:33:24 -0800
Message-ID: <94de02aa0912202033g1002f945o5a752606fead7215@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f171.google.com ([209.85.223.171]:56336 "EHLO
	mail-iw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbZLUEdZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Dec 2009 23:33:25 -0500
Received: by iwn1 with SMTP id 1so3443728iwn.33
        for <linux-nfs@vger.kernel.org>; Sun, 20 Dec 2009 20:33:24 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi,

i have a problem mounting two separate directories on the client.  the
exports, on the server, are defined as two different directories.  and
exportfs -rav outputs the correct ipaddr:/path/to/mount on the server.
 when i mount the separate directories on the client "mount -t nfs
ipaddr:/full/path /mnt/hd1" and "mount -t nfs ipaddr:/full/path
/mnt/hd2" both directories on the client /mnt/hd1 and /mnt/hd2 list
the contents of only hd2.  for example, on the client, ls /mnt/hd1
outputs the same directories as ls /mnt/hd2.  the server has the
correct mount points /dev/sda1 as /mnt/1tb and /dev/sdb1 as
/mnt/320gb.

here is the code to clarify:

# server output of `mount | grep /dev/sd`
/dev/sda1  on  /mnt/1tb      type vfat  (rw,noexec,nosuid,nodev,umask=000)
/dev/sdb1  on  /mnt/320gb  type vfat  (rw,noexec,nosuid,nodev,umask=000)
# notes two different harddrives here, so the directories in each are different.

# server output of `cat /etc/exports`
/mnt/1tb     client-ipaddress(rw,fsid=0,subtree_check,no_root_squash,crossmnt,async)
/mnt/320gb client-ipaddress(rw,fsid=0,subtree_check,no_root_squash,crossmnt,async)

# server output of `exportfs -rav`
exporting client-ipaddress:/mnt/1tb
exporting client-ipaddress:/mnt/320gb

### end of server ###

### client ###

# client commands
mount -t nfs server-ip:/mnt/1tb /mnt/nfs-1tb
mount -t nfs server-ip:/mnt/320gb /mnt/nfs-320gb

# client output of `mount | grep server-ip`
server-ip:/mnt/1tb  on  /mnt/nfs-1tb  (rw,addr=server-ip)
server-ip:/mnt/320gb  on  /mnt/nfs-320gb  (rw,addr=server-ip)

# client output of `ls /mnt/nfs-1tb` == `ls /mnt/nfs-320gb`
# note the client output of these two commands should be the contents
of server /dev/sda1 then server /dev/sdb1

my question is: how do i mount the two directories separately in order
to list contents of both harddrives? is there a separator in
/etc/exports that i am missing, causing it to read only the second
export?
is there anything i am missing here?
