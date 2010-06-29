Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15343 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932124Ab0F2Qly (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jun 2010 12:41:54 -0400
From: andros@netapp.com
To: benny@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] pnfs-submit: embed pnfs_layout_type in per layout structure 
Date: Tue, 29 Jun 2010 12:42:12 -0400
Message-Id: <1277829737-5465-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


A cleanup from Fred.
0001-SQUASHME-pnfs-submit-add-state-flag-for-layoutcommit.patch

These patches introduce the allocation of the pnfs_layout_type changing the
static declaration in struct nfs_inode to a pointer.

0002-SQUASHME-pnfs_submit-move-pnfs_layout_state-back-to-.patch
0003-SQUASHME-pnfs-submit-move-pnfs_layout_suspend-back-t.patch
0004-SQUASHME-pnfs-submit-embed-pnfs_layout_type.patch
0005-SQUASHME-pnfs-submit-filelayout-use-new-alloc_layout.patch

Testing

CONFIG_NFS_V4_1 set:
Connectathon passes on a VM SMP client against GFS2/pNFS with return_on_close
and write layouts turned on, and against the pyNFS file layout server without
return on close set.

CONFIG_NFS_V4_1 not set
NFSv4.0 Cthon tests pass


-->Andy

