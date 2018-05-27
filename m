Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dschgrazlin2.univ.trieste.it ([140.105.55.81]:32996 "EHLO
        dschgrazlin2.units.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032818AbeE0QeB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 May 2018 12:34:01 -0400
Received: from dschgrazlin2.units.it (loopback [127.0.0.1])
        by dschgrazlin2.units.it (8.15.2/8.15.2) with ESMTP id w4RGQ0fO011746
        for <linux-nfs@vger.kernel.org>; Sun, 27 May 2018 18:26:00 +0200
From: gabriele balducci <balducci@units.it>
To: linux-nfs@vger.kernel.org
Subject: nfs-utils-2.3.2: glitch crashes build
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sun, 27 May 2018 18:26:00 +0200
Message-ID: <11745.1527438384@dschgrazlin2.units.it>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hello

building 2.3.2 fails with:

  mountd.c:706:3: note: 'sprintf' output between 6 and 16 bytes into a destination of size 10
     sprintf(tag, "vers%d", vers);
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
  cc1: some warnings being treated as errors

and

  nfsd.c:102:3: note: 'sprintf' output between 6 and 16 bytes into a destination of size 10
     sprintf(tag, "vers%d", i);
     ^~~~~~~~~~~~~~~~~~~~~~~~~
  cc1: some warnings being treated as errors

I guess the reason is (https://marc.info/?l=linux-nfs&m=152718306728854&w=2):

    * Most compile warnings are now fatal errors.

and (configure):

  checking whether CC supports -Werror=format-overflow=2... yes

This fixes everything for me:

  diff -c utils/mountd/mountd.c.FIX_VAR_DIM utils/mountd/mountd.c
  *** utils/mountd/mountd.c.FIX_VAR_DIM	Sun May 27 18:16:46 2018
  --- utils/mountd/mountd.c	Sun May 27 18:16:46 2018
  ***************
  *** 702,708 ****
          else
                  NFSCTL_TCPUNSET(_rpcprotobits);
          for (vers = 2; vers <= 4; vers++) {
  ! 		char tag[10];
                  sprintf(tag, "vers%d", vers);
                  if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(nfs_version, vers)))
                          NFSCTL_VERSET(nfs_version, vers);
  --- 702,708 ----
          else
                  NFSCTL_TCPUNSET(_rpcprotobits);
          for (vers = 2; vers <= 4; vers++) {
  ! 		char tag[20];
                  sprintf(tag, "vers%d", vers);
                  if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(nfs_version, vers)))
                          NFSCTL_VERSET(nfs_version, vers);



  diff -c utils/nfsd/nfsd.c.FIX_VAR_DIM utils/nfsd/nfsd.c
  *** utils/nfsd/nfsd.c.FIX_VAR_DIM	Sun May 27 18:16:46 2018
  --- utils/nfsd/nfsd.c	Sun May 27 18:16:46 2018
  ***************
  *** 98,104 ****
          else
                  NFSCTL_TCPUNSET(protobits);
          for (i = 2; i <= 4; i++) {
  ! 		char tag[10];
                  sprintf(tag, "vers%d", i);
                  if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(versbits, i)))
                          NFSCTL_VERSET(versbits, i);
  --- 98,104 ----
          else
                  NFSCTL_TCPUNSET(protobits);
          for (i = 2; i <= 4; i++) {
  ! 		char tag[20];
                  sprintf(tag, "vers%d", i);
                  if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(versbits, i)))
                          NFSCTL_VERSET(versbits, i);


I thought the maintainers might be interested in fixing upstream

ciao
gabriele
