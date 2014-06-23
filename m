Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:36132 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbaFWKHX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 06:07:23 -0400
Received: by mail-qa0-f49.google.com with SMTP id w8so5310546qac.22
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 03:07:22 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 23 Jun 2014 12:07:22 +0200
Message-ID: <CALtMJECmW-yYgD3W5FUxQZJVZkb5NSJpQ5V9Q3ZE=1NKeCDtOA@mail.gmail.com>
Subject: `ls` shows no files in mounted nfs folder, but ls 'file' works
From: Andreas Fenkart <afenkart@gmail.com>
To: rond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Cc: Daniel Mack <zonque@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Found regression introduced by this patch

311324ad NFS: Be more aggressive in using readdirplus for 'ls -l' situations"

# cd /bin
-sh: cd: /bin: Not a directory
root@192:/# pwd
/
root@192:/# ls /bin
ls: /bin
root@192:/# ls -l /bin/sh
lrwxrwxrwx    1 root     root             9 Jun 16 13:59 /bin/sh -> /bin/bash

the mount options of the client, an embedded system, mounting nfsroot:
nfs(rw,relatime,vers=2,rsize=4096,wsize=4096,namlen=255,hard,nolock,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.xx.xx,mountvers=1,mountproto=udp,local_lock=all,addr=192.168.xx.xx)
vers: 3.16.0-rc1

the server exports:
/exports/rootfs 192.168.xx.xx(rw,no_root_squash,subtree_check)
vers: 3.14-1-amd64 #1 SMP Debian 3.14.4-1 (2014-05-13) x86_64 GNU/Linux

reverting above patch, dirlisting with 'ls /' works again

/Andreas
