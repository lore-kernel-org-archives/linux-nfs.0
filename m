Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:15503 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752298Ab0I2LGq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:06:46 -0400
Message-ID: <4CA31DC3.8070300@panasas.com>
Date: Wed, 29 Sep 2010 13:06:43 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.36-rc6-2010-09-29
References: <4C7BDD8C.40509@panasas.com>
In-Reply-To: <4C7BDD8C.40509@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This version includes Fred's pnfs-submit RFC patches (v5).
and is rebased onto v2.6.36-rc6

Cumulative patches can be generated from
git://linux-nfs.org/~bhalevy/linux-pnfs.git
using
git diff v2.6.36-rc6 pnfs-all-2.6.36-rc6-2010-09-29

Or, they can be downloaded from the wiki at:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

Latest patches (since pnfs-all-2.6.36-rc3-2010-08-30):

upstream:
  Boaz Harrosh     cc59b6a um: Proper Fix for f25c80a4: remove duplicate structure field initialization

pnfs-submit:
  The pNFS Team    1851dbc RFC: pnfsd, pnfs: protocol level pnfs constants
  The pNFS Team    a1b60af RFC: nfs: change stateid to be a union
  The pNFS Team    ff38ee4 RFC: nfs: ask for layouttypes during fsinfo call
  The pNFS Team    01f09aa RFC: nfs: set layout driver
  The pNFS Team    f7893b6 RFC: pnfs: full mount/umount infrastructure
  The pNFS Team    1cef5e0 RFC: pnfs: filelayout: introduce minimal file layout driver
  The pNFS Team    b7e2a3d RFC: nfs: create and destroy inode's layout cache
  The pNFS Team    34d2802 RFC: nfs: client needs to maintain list of inodes with active layouts
  The pNFS Team    292b90e RFC: pnfs: add LAYOUTGET and GETDEVICEINFO infrastructure
  The pNFS Team    bf610f6 RFC: pnfs: filelayout: add driver's LAYOUTGET and GETDEVICEINFO infrastructure
  Fred Isaman      068e761 pnfs-submit: revert range simplifications made by submission patches
  Benny Halevy     7c58c3d SQUASHME: pnfs-submit: add missing include file in nfs4filelayoutdev.c
  Benny Halevy     9a5956f SQUASHME: move nfs4_deviceid definitions to include/linux/nfs4.h
  Benny Halevy     bb2afce SQUASHME: pnfs-submit: handle non-pnfs case in set_pnfs_layoutdriver
  Benny Halevy     998fe4a pnfs-submit: file needs layout commit, server attributes may be stale
  Benny Halevy     f18cdf8 NFS: clear fsinfo before sendign rpc

pnfs:
  Benny Halevy     52a6277 pnfs: alloc and free layout_hdr layoutdriver methods
  Benny Halevy     6dd521e pnfs: allow nfs4_proc_layoutget to sleep on invalid lsegs
  Benny Halevy     ba1dd5b SQUASHME: pnfs: refactor put_lseg{_locked}
  Benny Halevy     bb03ecf SQUASHME: pnfs: get rid of lo_waitq

pnfs-block:
  Benny Halevy     73b1db9 SQUASHME: pnfsblock: remove obsolete include file from blocklayout.h
  Benny Halevy     d9ebc26 SQUASHME: pnfsblock: use nfs4_deviceid
  Benny Halevy     90e2af1 SQUASHME: pnfsblock: no callback ops
  Benny Halevy     0953b90 SQAUSHME: pnfsblock: no PNFS_NFS_SERVER
  Benny Halevy     7ab3774 SQUASHME: pnfsblock: no dev_notify_types
  Benny Halevy     f08f966 SQUASHME: pnfsblock: use new struct pnfs_layout_hdr

pnfs-obj-all:
  Benny Halevy     41a70b7 SQUASHME: pnfs-obj: fix REQ flags usage
  Benny Halevy     6057701 SQUASHME: pnfs-obj: convert to new pnfs-submit changes

pnfs-exofs-all:
  Benny Halevy     10d8e6e SQUASHME: pnfsd-exofs: convert to new pnfs-submit changes

