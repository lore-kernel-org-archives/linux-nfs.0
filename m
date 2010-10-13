Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44715 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab0JMBzv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 21:55:51 -0400
Received: by bwz15 with SMTP id 15so2877258bwz.19
        for <linux-nfs@vger.kernel.org>; Tue, 12 Oct 2010 18:55:50 -0700 (PDT)
Date: Tue, 12 Oct 2010 22:55:49 -0300
Message-ID: <AANLkTi=rzJXAPc17ggmw0LPS_Hn9HG15syLOtSN=nWdp@mail.gmail.com>
Subject: nfs4 all_squash: does it work at all?
From: zoolook <nbensa@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello list!

I'm struggling with NFS4 and all_squash but I cannot get it working.

We have a file server exporting shares using nfs4 (and samba, but it's
not important)

We don't use kerberos. We use NFS4 only because we found it was more
stable and faster with KDE.

We have some shared directories that need to be owned by
nobody:somegroup (for quota purposes)

server:

$ cat /etc/exports

/NFSROOT			*(rw,sync,no_subtree_check,fsid=root)
/NFSROOT/home			*(rw,sync,no_subtree_check)
/NFSROOT/shares/Sistemas	*(rw,sync,no_subtree_check,all_squash,anongid=1002)

$ ls -l /NFSROOT/shares/
drwxrws--- 2 nobody sistemas    4096 2010-10-12 22:44 Sistemas


client:
$ mount | grep nfsserver
nfsserver:/shares/Sistemas on /compartidos/sistemas type nfs4
(rw,clientaddr=10.11.101.124,addr=10.11.101.126)

$ touch /compartidos/sistemas/pepepe
$ ls -ln /compartidos/sistemas/
total 0
-rw-r--r-- 1 1000 1002 0 2010-10-12 22:45 pepepe


If I use nfs3:

$ sudo umount /compartidos/sistemas
$ sudo mount -t nfs nfsserver:/NFSROOT/shares/Sistemas sistemas/
$ touch /compartidos/sistemas/qwerwer
$ ls -ln /compartidos/sistemas/
total 0
-rw-r--r-- 1  1000 1002 0 2010-10-12 22:45 pepepe
-rw-r--r-- 1 65534 1002 0 2010-10-12 22:48 qwerwer


Why uid:1000 with nfs4 and uid:65534 with nfs3? What am I missing?
Note that I would like nfs4 behave like nfs3.

Many thanks in advance,
Norberto
