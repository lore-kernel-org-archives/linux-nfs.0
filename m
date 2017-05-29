Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f178.google.com ([209.85.217.178]:34782 "EHLO
        mail-ua0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750864AbdE2UhU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 May 2017 16:37:20 -0400
Received: by mail-ua0-f178.google.com with SMTP id u10so41016696uaf.1
        for <linux-nfs@vger.kernel.org>; Mon, 29 May 2017 13:37:19 -0700 (PDT)
MIME-Version: 1.0
From: Jason Vas Dias <jason.vas.dias@gmail.com>
Date: Mon, 29 May 2017 20:37:18 +0000
Message-ID: <CALyZvKwXQew+t69BiQ4UXX+7=bYMPWxXdUbFepzWmrX_9_d=Qw@mail.gmail.com>
Subject: mount.nfs needs to accept 'addr' option / parse its target string better
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Good day -

I just built & installed the latest nfs-utils-2.1.1 , and noticed a
number of issues
with mount.nfs .


1. It does not seem to be possible to specify a literal IPv6 address in a target
    (not "URL"! ) <host>:<share> string:

    $ mount -t nfs4 ::1:/mnt/disk /mnt/disk2
    mount.nfs4: Failed to resolve server : Name or service not known
    ( so it does not work for the loopback IPv6 address; try link local
      IPv6 address:
     $ strace -f -s8192 -v -e trace=mount mount -t nfs4  \
        fe80::fa16:54ff:fef7:d66d:/mnt/disk /mnt/disk2
     mount.nfs4: Failed to resolve server fe80: Name or service not known
   )

  Yet it DOES work for the literal IPv4 loopback address:
     $  mount -t nfs4 127.0.0.1:/mnt/disk /mnt/disk2
     $ echo $?
     0
   But not if a port is specified :
   $ strace -f -s8192 -v -e trace=mount mount -t nfs4 \
      127.0.0.1:2049:/mnt/disk /mnt/disk2
     strace: Process 2265 attached
[pid  2265] mount("127.0.0.1:2049:/mnt/disk", "/mnt/disk2", "nfs4", 0,
"vers=4.2,addr=127.0.0.1,clientaddr=127.0.0.1"May 29 20:16:13 jvdlux
kernel: [40029.874234] device: '0:43': device_add
May 29 20:16:13 jvdlux kernel: [40029.874283] PM: Adding info for No Bus:0:43
) = -1 ENOENT (No such file or directory)
May 29 20:16:13 jvdlux kernel: [40029.922459] device: '0:43': device_unregister
May 29 20:16:13 jvdlux kernel: [40029.922496] PM: Removing info for No Bus:0:43
May 29 20:16:13 jvdlux kernel: [40029.922533] device: '0:43':
device_create_release
[pid  2265] mount("127.0.0.1:2049:/mnt/disk", "/mnt/disk2", "nfs4", 0,
"addr=127.0.0.1,vers=3,proto=tcp,mountvers=3,mountproto=udp,mountport=49831"May
29 20:16:13 jvdlux rpc.mountd[1001]: Bad path in mount request from
127.0.0.1: "2049:/mnt/disk"
) = -1 EACCES (Permission denied)
mount.nfs4: access denied by server while mounting 127.0.0.1:2049:/mnt/disk

(the above output includes the syslog messages from a 'tail -f
/var/log/messages'
 running in the background ).  It is strange that the mount is tried
twice here ,
once with version 4, and once with version 3, even though I had requested
a filesystem type of 'nfs4' , not 'nfs3' .

So it seems that mount.nfs is treating the FIRST colon as unconditionally
starting the 'share name' portion of the URL . I think it would make more
sense to make it find the LAST colon (use rindex(3) instead of index(3)) -
then it should check if what follows is a number - then it has found the
port , or the last octet of an IPv6 address .

And why doesn't mount.nfs support NFS URLs ? :
  $ mount.nfs4 nfs://127.0.0.1/mnt/disk /mnt/disk2
  mount.nfs4: NFS URLs are not supported

Then at least it would be simpler to separate out the host name,
regardless of whether a literal IPv6 address is used or not.

And it appears to be really impossible to specify a literal IPv6 address
in the colon-separated octet ASCII format in the 'target' string.

Why doesn't mount.nfs support parsing the 'addr' option ?  :

  $ mount -t nfs4 -o 'addr=fe80::fa16:54ff:fef7:d66d' /mnt/disk /mnt/disk2
  mount.nfs4: remote share not in 'host:dir' format

If mount.nfs supports literal IPv4 addresses, it should support
literal IPv6 addresses.

I think mount.nfs should support NFS URLs, including ones with a
':<port>' suffix
( or a '#<port>' suffix for IPv6 addresses) ,  and that it should also
support specifying the 'addr=' option directly, and then not require
the address to be
prefixed to the share name with a separating colon .

Just my two cents worth / some observations ...

Regards,
Jason
