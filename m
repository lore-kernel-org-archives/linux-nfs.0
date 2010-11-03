Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og110.obsmtp.com ([64.18.0.20]:44066 "HELO
	exprod5og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755792Ab0KCP3K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Nov 2010 11:29:10 -0400
Message-ID: <4CD17FC4.6090906@panasas.com>
Date: Wed, 03 Nov 2010 17:29:08 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.37-rc1-2010-11-03
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

After merging a fix from Trond to the new readdir(plus) implementation
I've released the rebased tree, based on 2.6.37-rc1 and pulled Jim's
fix to bl_initialize_mountpoint (now bl_set_layoutdriver) also to pnfs-all-2.6.36.

Cumulative patches can be generated from
git://linux-nfs.org/~bhalevy/linux-pnfs.git
using
git diff v2.6.37-rc1 pnfs-all-2.6.37-rc1-2010-11-03
and
git diff v2.6.36 pnfs-all-2.6.36-2010-11-03

Or, they can be downloaded from the wiki at:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

Latest patches that went in since pnfs-all-2.6.36-2010-10-28:

nfs-upstream:
  Trond Myklebust  5bb2ab8 NFS: Fix a couple of regressions in readdir.

pnfs-block:
  Jim Rees         2f6f3c2 SQUASHME: pnfs-block: Return failure from bl_initialize_mountpoint

pnfs-all-2.6.36:
  Jim Rees         065733b pnfs-block: Return failure from bl_initialize_mountpoint
