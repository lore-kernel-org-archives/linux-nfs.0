Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:41026 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461Ab2FSWIS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jun 2012 18:08:18 -0400
Received: by lbbgm6 with SMTP id gm6so6364482lbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 19 Jun 2012 15:08:16 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 19 Jun 2012 23:08:16 +0100
Message-ID: <CAF_AkYkQBV4_w1wMzCX_5qTkmd2xJ8Vgd75FuUke25KGkOxZ7A@mail.gmail.com>
Subject: persistent bad/stale dentry
From: Richard P <richardp345@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We had an issue where ls on a directory one NFS client returned a
different result from every other client on the network:

bad client:

-1-0- ti107c1n2: ~ $ cd
/u/cnd/ets/log/2012/06/nxpxbow1.ms.com/pnseom/om2/20120615
-1-0- ti107c1n2:
/u/cnd/ets/log/2012/06/nxpxbow1.ms.com/pnseom/om2/20120615 $ df .
Filesystem           1K-blocks      Used Available Use% Mounted on
byn5f1:/vol/byn5f1v2/r_ied_cnd_2012_new
                     1048576000 925610112 122965888  89%
/a/byn5f1/vol/byn5f1v2/r_ied_cnd_2012_new
-1-0- ti107c1n2: /u/cnd/ets/log/2012/06/nxpxbow1.ms.com/pnseom/om2/20120615 $ ll
total 4.0K
drwxr-xr-x  2 pasg iedg 4.0K Jun 16 00:30 EtsLimitsTimed
-1-0- ti107c1n2:
/u/cnd/ets/log/2012/06/nxpxbow1.ms.com/pnseom/om2/20120615 $ ll
etscfg.xml.gz
-rw-r--r--  1 pasg iedg 1.3K Jun 15 03:00 etscfg.xml.gz
-1-0- ti107c1n2: /u/cnd/ets/log/2012/06/nxpxbow1.ms.com/pnseom/om2/20120615 $
-1-0- ti107c1n2:
/u/cnd/ets/log/2012/06/nxpxbow1.ms.com/pnseom/om2/20120615 $ stat .
.
   st_dev:     1b
   st_ino:     19651443
   st_mode:    0040755  directory rwxr-xr-x
   st_nlink:   3
   st_uid:     85660   [pasg]
   st_gid:     14208   [iedg]
   st_rdev:    0
   st_size:    4096
   st_atime:   Tue Jun 19 07:13:54 2012
   st_mtime:   Sat Jun 16 00:35:23 2012
   st_ctime:   Mon Jun 18 18:16:58 2012
   st_blksize: 32768
   st_blocks:  8

good client:

-1-0- ti107c1n3: ~ $ cd
/u/cnd/ets/log/2012/06/nxpxbow1.ms.com/pnseom/om2/20120615
-1-0- ti107c1n3:
/u/cnd/ets/log/2012/06/nxpxbow1.ms.com/pnseom/om2/20120615 $ df .
Filesystem           1K-blocks      Used Available Use% Mounted on
byn5f1:/vol/byn5f1v2/r_ied_cnd_2012_new
                     1048576000 925610112 122965888  89%
/a/byn5f1/vol/byn5f1v2/r_ied_cnd_2012_new
-1-0- ti107c1n3: /u/cnd/ets/log/2012/06/nxpxbow1.ms.com/pnseom/om2/20120615 $ ll
total 585M
drwxr-xr-x  2 pasg iedg 4.0K Jun 16 00:30 EtsLimitsTimed
-rw-r--r--  1 pasg iedg 1.3K Jun 15 03:00 etscfg.xml.gz
-rw-r--r--  1 pasg iedg 116M Jun 15 23:50 om2.log.gz
-rw-r--r--  1 pasg iedg 116M Jun 15 10:36 om2_2012_06_15_10_36_34.log.gz
-rw-r--r--  1 pasg iedg 115M Jun 15 11:59 om2_2012_06_15_11_59_55.log.gz
-rw-r--r--  1 pasg iedg 120M Jun 15 13:12 om2_2012_06_15_13_12_51.log.gz
-rw-r--r--  1 pasg iedg 120M Jun 15 14:27 om2_2012_06_15_14_27_51.log.gz
-rw-r--r--  1 pasg iedg  46K Jun 15 23:50 output.20120615.030000.gz
-1-0- ti107c1n3:
/u/cnd/ets/log/2012/06/nxpxbow1.ms.com/pnseom/om2/20120615 $ stat .
.
   st_dev:     17
   st_ino:     19651443
   st_mode:    0040755  directory rwxr-xr-x
   st_nlink:   3
   st_uid:     85660   [pasg]
   st_gid:     14208   [iedg]
   st_rdev:    0
   st_size:    4096
   st_atime:   Tue Jun 19 07:21:33 2012
   st_mtime:   Sat Jun 16 00:35:23 2012
   st_ctime:   Mon Jun 18 18:16:58 2012
   st_blksize: 32768
   st_blocks:  8

tshark showed the bad client running getattr on the file handle but
because the ctime and mtime returned by the server were identical to
what the client already had it never called readdir.

Note that on both machines the inode, mtime and ctime are identical.
And you can access one of the unseen files directly, so this isn't the
stale negative dentry issue I've seen reported -
https://bugzilla.redhat.com/show_bug.cgi?id=228801

Touching the directory fixed the problem on the bad client.

All the clients are RHEL Update 8 2.6.9-103.  The server is ONTAP 7.3.3P1.

Are there any known issues that might cause this?
