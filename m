Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60504 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753301Ab0EQUp5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 May 2010 16:45:57 -0400
Received: by wyb39 with SMTP id 39so816773wyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 17 May 2010 13:45:55 -0700 (PDT)
Message-ID: <4BF1AAFC.7000308@panasas.com>
Date: Mon, 17 May 2010 23:45:48 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
CC: Steve Dickson <steved@redhat.com>, Andy Adamson <andros@netapp.com>
Subject: pnfs git tree status pnfs-all-2.6.34-2010-05-17
References: <4BD9BF01.2000508@panasas.com> <4BE330E6.70707@panasas.com> <4BE3315C.9090908@panasas.com>
In-Reply-To: <4BE3315C.9090908@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

The pnfs tree is now rebased onto the fresh Linux 2.6.34.
Many thanks to Andy's for squashing many cleanup patches in pnfs-submit
and to the contributors listed below of course!

I released the following today:

pnfs-all-2.6.34-2010-05-17

As usual, cumulative patches can be generated from
git://linux-nfs.org/~bhalevy/linux-pnfs.git
using
git diff v2.6.34 pnfs-all-2.6.34-2010-05-17

Or, they can be downloaded from the wiki at:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

Latest patches (since 2010-05-06):

pnfs-submit:
Andy Adamson (14):
      SQUASHME pnfs_submit: move unmount_pnfs_layoutdriver call
      SQUASHME pnfs_submit: remove filelayout get threshold
      SQUASHME pnfs_submit: don't use pnfs_use_read
      SQUASHME pnfs_submit: don't use pnfs_use_write
      SQUASHME pnfs_submit: don't use pnfs_use_write for commit
      SQUASHME pnfs_submit: don't use pg_threshold
      SQUASHME pnfs_submit: remove pg_threshold
      SQUASHME pnfs_submit: don't use below_threshold in read
      SQUASHME pnfs_submit: don't use below_threshold in direct io
      SQUASHME pnfs_submit: remove unused threshold calculations
      SQUASHME pnfs_submit: cleanup filelayout pg_test
      SQUASHME pnfs_submit: use MDS session for dual MDS/DS
      SQUASHME pnfs_submit: update DS nfs4_set_client
      SQUASHME pnfs_submit: cleanup DS exchange flag processing

Benny Halevy (2):
      pnfs: async layout return
      SQUASHME: pnfs-submit: check for NULL nfs_client in nfs4_init_pnfs

Zhang Jingwang (3):
      SQUASHME: pnfs-submit: set pnfs_curr_ld before calling initialize_mountpoint
      SQUASHME: pnfs-submit: send layoutcommit until IO completed when return layout
      pnfs: devide put_lseg and return_layout_barrier into different workqueue

pnfs-block:
Benny Halevy (1):
      SQUASHME: pnfs-block: get rid of threshold policy ops

Tao Guo (2):
      pnfsblock: expose block_class interface
      pnfsblock: iterating all local block disks instead of only scsi disks when initializing mount point.

Zhang Jingwang (3):
      SQAUSHME: blocklayoutdriver: NULL pointer reference when committing too many extents
      pnfsblock: Lookup list entry of layouts and tags in reverse order
      SQUASHME: pnfs-block: set pnfs_blksize before calling set_pnfs_layoutdriver

pnfs-obj-all:
Benny Halevy (1):
      SQUASHME: pnfs-obj: get rid of threshold policy ops

