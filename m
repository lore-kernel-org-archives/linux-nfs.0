Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753212Ab0GGWeW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 18:34:22 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/16] pnfs-submit fix layout allocation and reference counting 
Date: Wed,  7 Jul 2010 18:34:07 -0400
Message-Id: <1278542063-4009-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0



The current nfs_inode has an embedded pnfs_layout_type structure, with per
layout type private data allocated. Change nfs_inode->layout to be a pointer
to a pnfs_layout_type structure, embed the pnfs_layout_type in the per
layout type structure, and allocate both.

The current pnfs_layout_type allocation waits on a bit lock to handle
concurrent allocation attempts. Replace this with the normal form.

The current pnfs_layout_type reference counting is very un-clear, and one
instance of put_layout was called outside the i_lock which probably was
causing the intermittant pnfs_layout_type refcount bug we've been seeing.

Replace the nfs_inode->layout reference counting with the following scheme:

As in the current code, the pnfs_layout_type reference counting is always done
with the inode->i_lock held.

The nfs_inode->layout comes into existence when the first layout_segment is
cached and stays until inode is destroyed.

1) alloc nfs_inode->layout:
        - Initialized to 1. This holds it around for the clp->cl_layouts
        (layout->lo_layouts) list.

2) Each layoutget
   layoutget    GET
   layoutget release PUT

3) insert lseg into nfs_inode->layout->segs GET
   remove lseg from nfs_inode->layout->segs  PUT

I/O - no reference (except the lseg is used and referenced in 3)

4) Each layoutcommit references the layout which keeps it around while in use
   by the call which could race with layoutreturn

   layoutcommit GET
   layoutcommit release PUT

5) Each layoutreturn references the layout which keeps it around while in use
   by the call.

   layoutreturn  GET
   layoutreturn release  PUT

6) inode destruction (usually umount)

   Destroy_layout PUT to balance initial allocation where it is set to 1.

When the reference moves from 1->0 the layout is removed from the nfs_client
cl_layouts list and freed.


Change nfs_inode->layout to be a pointer to a pnfs_layout_type strucure.

0001-SQUASHME-pnfs-submit-add-state-flag-for-layoutcommit.patch
0002-SQUASHME-pnfs-submit-move-pnfs_layout_suspend-back-t.patch
0003-SQUASHME-pnfs-submit-embed-pnfs_layout_type.patch
0004-SQUASHME-pnfs-submit-filelayout-use-new-alloc-free_l.patch

Rewrite the pnfs_layout_type allocation and reference counting

0005-SQUASHME-pnfs-submit-rewrite-layout-allocation.patch
0006-SQUASHME-pnfs-submit-fix-pnfs_update_layout-referenc.patch
0007-SQUASHME-pnfs_submit-don-t-get-a-reference-on-bounda.patch
0008-SQUASHME-pnfs-submit-don-t-reference-the-layout-in-i.patch
0009-SQUASHME-pnfs-submit-pnfs_update_layout-always-refer.patch
0010-SQUASHME-pnfs-submit-reference-the-layout-when-inser.patch
0011-SQUASHME-pnfs-submit-rename-put_layout-to-put_layout.patch
0012-SQUASHME-pnfs-submit-reference-layout-across-layoutc.patch
0013-SQUASHME-pnfs-submit-reference-layout-for-layoutretu.patch
0014-SQUASHME-pnfs-submit-remove-put_layout-from-pnfs_fre.patch
0015-SQUASHME-pnfs-submit-do-not-reference-a-layout-in-de.patch
0016-SQUASHME-pnfs-submit-remove-grab_current_layout.patch

Testing;

CONFIG_NFS_V4_1 set:
Connectathon tests pass against GFS2/pNFS and pyNFS file layout server. Tested
with layout return-on-close off and on.

CONFIG_NFS_V4_1 not set;
NFSv4.0 mount passes Connectation tests.

-->Andy


