Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44110 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932420Ab2GBGMA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jul 2012 02:12:00 -0400
Received: by bkwj10 with SMTP id j10so363477bkw.19
        for <linux-nfs@vger.kernel.org>; Sun, 01 Jul 2012 23:11:59 -0700 (PDT)
MIME-Version: 1.0
From: Song Gao <song.gao.beta@gmail.com>
Date: Mon, 2 Jul 2012 01:11:39 -0500
Message-ID: <CAKeNtnQK5QEgRZKXHnmMQK6R+L1nXQNX0M4y1ZWuKo7GbEingA@mail.gmail.com>
Subject: Possible bug in NFSv4 server regarding to looking for right path for
 clients to mount
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

There's possibly a bug related NFSv4 server's behavior on looking for
path on /export .

I have a 32 nodes KVM cluster. NFS, host filesystem, KVM storage pool,
are all placed on SSD. KVM guests are connected to host through virtio
drived GB ethernet.

I followed this guide to configure NFS:
https://help.ubuntu.com/community/SettingUpNFSHowTo

The problem was that, when I execute a program simultaneously (through
cssh) on 32 nodes, there were always a number of nodes that
encountered "input/output error". The /var/log/messages on client
shows "state manager failed on NFSv4 server with error 10022".

I tried different options in client /etc/fstab as well as export
settings in server but nothing helps. Interestingly, by changing the
item in /etc/fstab from:
    some-host:/tigers  nfs    rw,bg,hard,intr    0    0
into:
    some-host:/export/tigers    /nfs    nfs    rw,bg,hard,intr    0    0
fixed the problem.

I'm not familiar with it but I guess that it's probably caused by some
problem in NFS server when it tries to find the right path when all 32
clients are trying to mount NFS at the same time.

Here's some more information:
client: debian "squeeze", 2.6.32-5-amd64
server: Ubuntu Server 12.04, 3.2.0-23-generic
nfs version: NFSv4
no security option
results of `exports -v`:
    /export 192.168.100.0/24(rw,wdelay,insecure,root_squash,no_subtree_check,fsid=0)
    /export/tigers
192.168.100.0/24(rw,wdelay,nohide,insecure,root_squash,no_subtree_check)

Please let me know if there's any other information I need to provide.

Thanks!


Kind regards,
-- 
Song Gao
https://profiles.google.com/song.gao.beta/about
