Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:48901 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751020Ab1ALQLZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jan 2011 11:11:25 -0500
Date: Wed, 12 Jan 2011 11:10:54 -0500
From: Nick Bowler <nbowler@elliptictech.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Regression, bisected: NFS O_EXCL breakage in 2.6.37 client.
Message-ID: <20110112161054.GA3431@elliptictech.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

With 2.6.37 (client), opens on NFS with O_CREAT | O_EXCL are
occasionally succeeding when the file already exists, apparently
depending on the state of the filesystem cache.  The issue was observed
because mplayer would randomly overwrite its config file...

Using the test program (./nfsbreak) included in this mail, I can
reproduce it as follows (/home/nbowler is the NFS mount point).  No
interesting kernel messages appear on either the client or server
machines during the test:

  % mkdir /home/nbowler/nfsexcl
  % ./nfsbreak
  nfsbreak: File opened <<< This is OK
  % ./nfsbreak
  nfsbreak: File exists
  % ./nfsbreak
  nfsbreak: File exists
  % su -c 'echo 2 > /proc/sys/vm/drop_caches'
  % ./nfsbreak
  nfsbreak: File opened <<< Uhoh!
  % ./nfsbreak
  nfsbreak: File exists

Here's the nfsbreak C source:

  #include <stdio.h>
  #include <stdlib.h>
  #include <fcntl.h>

  int main(void)
  {
    int fd;

    /* /home/nbowler is the NFS mount point */
    fd = open("/home/nbowler/nfsexcl/nfsexcl", O_WRONLY|O_CREAT|O_EXCL);
    if (fd == -1) {
      perror("nfsbreak");
      return EXIT_FAILURE;
    }

    puts("nfsbreak: File opened");
    return 0;
  }

This is a regression from 2.6.36; bisection implicates the following,
which unfortunately does not revert cleanly.

c0204fd2b8fe047b18b67e07e1bf2a03691240cd is the first bad commit
commit c0204fd2b8fe047b18b67e07e1bf2a03691240cd
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Sep 17 10:56:51 2010 -0400

    NFS: Clean up nfs4_proc_create()
    
    Remove all remaining references to the struct nameidata from the low level
    NFS layers. Again pass down a partially initialised struct nfs_open_context
    when we want to do atomic open+create.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

:040000 040000 af226059a91451ab62dcf656aa54a286be936680 8120870745a8349f6bd8a7c27ca9e713bd4d550a M	fs
:040000 040000 079f1db66b63424d8eb6e387342b95a777b12927 169d68ef93e49737c400866ff0c75708013dc68f M	include

git bisect start
# good: [f6f94e2ab1b33f0082ac22d71f66385a60d8157f] Linux 2.6.36
git bisect good f6f94e2ab1b33f0082ac22d71f66385a60d8157f
# bad: [3c0eee3fe6a3a1c745379547c7e7c904aa64f6d5] Linux 2.6.37
git bisect bad 3c0eee3fe6a3a1c745379547c7e7c904aa64f6d5
# bad: [474829e875ab93512dbe0a713f564d3cd3874bc9] Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel/git/lenb/linux-acpi-2.6
git bisect bad 474829e875ab93512dbe0a713f564d3cd3874bc9
# good: [02f36038c568111ad4fc433f6fa760ff5e38fab4] Merge branches 'softirq-for-linus', 'x86-debug-for-linus', 'x86-numa-for-linus', 'x86-quirks-for-linus', 'x86-setup-for-linus', 'x86-uv-for-linus' and 'x86-vm86-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip
git bisect good 02f36038c568111ad4fc433f6fa760ff5e38fab4
# good: [bdaf12b41235b0c59949914de022341e77907461] Merge branch 'i2c-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jdelvare/staging
git bisect good bdaf12b41235b0c59949914de022341e77907461
# good: [33081adf8b89d5a716d7e1c60171768d39795b39] Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound-2.6
git bisect good 33081adf8b89d5a716d7e1c60171768d39795b39
# bad: [a4dd8dce14014665862ce7911b38cb2c69e366dd] Merge branch 'nfs-for-2.6.37' of git://git.linux-nfs.org/projects/trondmy/nfs-2.6
git bisect bad a4dd8dce14014665862ce7911b38cb2c69e366dd
# good: [bc487fb341af05120bccb9f59ce76302391dcc77] omap: complete removal of machine_desc.io_pg_offst and .phys_io
git bisect good bc487fb341af05120bccb9f59ce76302391dcc77
# bad: [9a84d38031c258a17bb39beed1e500eadee67407] SUNRPC: Cleanup duplicate assignment in rpcauth_refreshcred
git bisect bad 9a84d38031c258a17bb39beed1e500eadee67407
# good: [2bfc96a127bc1cc94d26bfaa40159966064f9c8c] Linux 2.6.36-rc3
git bisect good 2bfc96a127bc1cc94d26bfaa40159966064f9c8c
# bad: [dfb4f309830359352539919f23accc59a20a3758] NFSv4.1: keep seq_res.sr_slot as pointer rather than an index
git bisect bad dfb4f309830359352539919f23accc59a20a3758
# bad: [c0204fd2b8fe047b18b67e07e1bf2a03691240cd] NFS: Clean up nfs4_proc_create()
git bisect bad c0204fd2b8fe047b18b67e07e1bf2a03691240cd
# good: [56463e50d1fc3f070492434cea6303b35ea000de] NFS: Use super.c for NFSROOT mount option parsing
git bisect good 56463e50d1fc3f070492434cea6303b35ea000de
# good: [cd9a1c0e5ac681871d64804f82291649e2a0accb] NFSv4: Clean up nfs4_atomic_open
git bisect good cd9a1c0e5ac681871d64804f82291649e2a0accb
# good: [b8d4caddd871758ffa156be51b4c8be82fea470d] NFSv4: Clean up nfs4_open_revalidate
git bisect good b8d4caddd871758ffa156be51b4c8be82fea470d
# good: [535918f14176396646b5547b7d1353c932f24f5e] NFSv4: Further cleanups for nfs4_open_revalidate()
git bisect good 535918f14176396646b5547b7d1353c932f24f5e

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
