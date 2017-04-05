Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zarb.ucsf.edu ([169.230.90.57]:48426 "EHLO zarb.ucsf.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754913AbdDETZr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Apr 2017 15:25:47 -0400
Received: from localhost (localhost [127.0.0.1])
        by zarb.ucsf.edu (Postfix) with ESMTP id 39539127
        for <linux-nfs@vger.kernel.org>; Wed,  5 Apr 2017 12:19:40 -0700 (PDT)
Date: Wed, 5 Apr 2017 12:19:40 -0700 (PDT)
From: Joshua Baker-LePain <jlb@salilab.org>
To: linux-nfs@vger.kernel.org
Subject: Double listing and duplicate cookie errors
Message-ID: <alpine.LFD.2.20.1704051200210.30494@zarb.ucsf.edu>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm seeing some odd issues mounting a GFS2 filesystem exported via NFS 
from a CentOS-7 cluster.  The main clients are CentOS-6, but I've also 
tested from CentOS-7.  There are several filesystem exported from this 
host, and not all of them show the problem.  At the initial report, these 
were the symptoms:

  o NFSv4
$ mount -t nfs -o hard,intr $SERVER:/home/socr/a /mnt
$ ls -la /mnt
ls: reading directory /mnt: Too many levels of symbolic links
total 460
drwxr-xr-x.  32 root    root   3864 Sep 27  2016 ./
dr-xr-xr-x.  43 root    root   4096 Feb 24 10:08 ../
dr-xr-xr-x.  43 root    root   4096 Feb 24 10:08 ../
drwxr-xr-x.  59   20383 wheel  2048 Mar 23 12:29 al/
drwxr-xr-x.  59   20383 wheel  2048 Mar 23 12:29 al/
.
.
.
$ dmesg | tail -1
NFS: directory / contains a readdir loop.Please contact your server vendor.  The file: .. has duplicate cookie 1

Note that there are *no* symbolic links in that directory or any of the 
others that show the issue.

  o NFSv3
$ mount -t nfs -o hard,intr,tcp,nfsvers=3 $SERVER:/nfsexports/home/socr/a /mnt
$ ls -la /mnt
.
Here ls hangs, eating up all of a CPU and ever more memory until finally 
dying with the message "ls: memory exhausted".

The folks running the server took some of the FSes off line and fsck'd 
them.  Afterwards, NFSv4 has the same problem (double listing, readdir 
loop error in client logs) but NFSv3 doesn't -- ls works, doesn't report 
any errors and doesn't double list files and directories.

Our current workaround, obviously, is to fsck the filesystem and use 
NFSv3.  But that doesn't give me a warm fuzzy feeling.  Does this 
constellation of symptoms ring any bells?  Thanks.

-- 
Joshua Baker-LePain
QB3 Shared Cluster Sysadmin
UCSF
