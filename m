Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34790 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751245AbeAGCPO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Jan 2018 21:15:14 -0500
Received: by mail-qk0-f181.google.com with SMTP id m193so2175188qke.1
        for <linux-nfs@vger.kernel.org>; Sat, 06 Jan 2018 18:15:14 -0800 (PST)
MIME-Version: 1.0
From: User Linux <user.kernel@gmail.com>
Date: Sat, 6 Jan 2018 18:15:13 -0800
Message-ID: <CAFO3HzVbAq-x8xHNEjdxvYbeoSPf=Jk7Ep26++uHgD2UFNXmnw@mail.gmail.com>
Subject: Need help with empty shares after Debian sid package upgrades.
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey guys.. I had a working Debian sid (server & client) nfs setup
until recent packages and kernel upgrades. After rebooting the boxes,
the client no longer sees any dirs or files in the shares. I booted
back into the previous kernel on both boxes but that didn't help. I
don't have a list of packages that were upgraded so I thought maybe
I'd just try to rebuild things from scratch but after tons of reading
and trying various things, its gotten me absolutely nowhere. I'm
hoping to find help getting even just a single share to work correctly
at this point. Based on everything I've read, the following should
work but doesn't. I'm not sure if the howtos and guides I followed
are outdated now, or something from the package upgrade is causing the
problem, or what.. Can someone knowledgable & experienced with nfs
please tell me if I've done something wrong in the steps below?

Any help is *greatly* appreciated!
-Derek

I have a harddrive in my server that contains a dir I want to share
called "media". "media", all subdirs, and all files are owned by UID
1000/GUID 1000. All dirs are chmod 0755. "media" looks something like
this:

media/homevideos/vacation2017/*.mkv
media/music/*.mp3
media/musicvideos/*.mp4

The mountpoint on my client is also owned by UID 1000/GUID 1000, chmod
0755. Server and client are running Debian sid with nfs v3 & v4
enabled in the kernel. I don't use/want auto-mounting. Both boxes have
identical hosts.allow and hosts.deny files:
--------------------
hosts.allow:
ALL: 192.168.1.*

hosts.deny:
ALL: *.*.*.*
ALL: PARANOID
--------------------

on the server I do:

$ sudo mkdir -p /testhd/hd0
$ sudo mkdir -p /testnfs/sharehd0
$ sudo chown -R 1000.1000 /testhd
$ sudo chown -R 1000.1000 /testnfs
$ sudo mount /dev/sde1 /testhd/hd0
$ sudo mount --bind /testhd/hd0/media /testnfs/sharehd0
$ mount |grep "/test"
/dev/sde1 on /testhd/hd0 type ext4 (rw,relatime,data=ordered)
/dev/sde1 on /testnfs/sharehd0 type ext4 (rw,relatime,data=ordered)

At this point I can `ls -la` and see that both /testhd/hd0/media/* and
/testnfs/sharehd0/* have the same contents and still everything owned
by UID 1000/GUID 1000. I then create /etc/export and start the server:

$ echo "/testnfs
*(ro,fsid=0,no_subtree_check,insecure,all_squash,anonuid=1000,anongid=1000)"
|sudo tee /etc/exports
$ echo "/testnfs/sharehd0
192.168.1.0/24(ro,no_subtree_check,insecure,all_squash,anonuid=1000,anongid=1000)"
|sudo tee -a /etc/exports
$ sudo /etc/init.d/nfs-kernel-server start

So far so good?:

$ sudo rpcinfo -t 192.168.1.11 nfs
program 100003 version 3 ready and waiting
program 100003 version 4 ready and waiting

$ sudo showmount -e 192.168.1.11
Export list for 192.168.1.11:
/testnfs          *
/testnfs/sharehd0 192.168.1.0/24

$ sudo rpcinfo -p
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100005    1   udp  35956  mountd
    100005    1   tcp  44325  mountd
    100005    2   udp  60782  mountd
    100005    2   tcp  52503  mountd
    100005    3   udp  43519  mountd
    100005    3   tcp  51029  mountd
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  41171  nlockmgr
    100021    3   udp  41171  nlockmgr
    100021    4   udp  41171  nlockmgr
    100021    1   tcp  33425  nlockmgr
    100021    3   tcp  33425  nlockmgr
    100021    4   tcp  33425  nlockmgr

Ok so now for the client-side:

$ sudo mkdir -p /testshare/share0
$ sudo chown -R 1000.1000 /testshare/share0
$ sudo showmount -e 192.168.1.11
Export list for 192.168.1.11:
/testnfs          *
/testnfs/sharehd0 192.168.1.0/24

$ sudo mount 192.168.1.11:/testnfs/sharehd0 /testshare/share0
$ mount |grep nfs
192.168.1.11:/testnfs/sharehd0 on /testshare/share0 type nfs
(rw,relatime,vers=3,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.1.11,mountvers=3,mountport=43519,mountproto=udp,local_lock=none,addr=192.168.1.11)
$ ls -la /testshare/share0
total 8
drwxr-xr-x 2 mru mru 4096 Jan  6 12:16 .
drwxr-xr-x 3 mru mru 4096 Jan  6 11:59 ..
