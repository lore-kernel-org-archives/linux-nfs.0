Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26933 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314Ab1BPSjA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Feb 2011 13:39:00 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/18] pNFS wave 3 submission Version 2 
Date: Tue, 15 Feb 2011 03:38:45 -0500
Message-Id: <1297759143-2045-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


These patches implement wave 3 of the pNFS submission, which encompasses file
layout data server connection, READ I/O, and recovery through the MDS.

Responded to all Version 1 comments.

-->Andy

Changes since Version 1:
Renamed patches from "pnfs: wave3:XXX" to NFSv4.1:XXX

0001-NFSv4-remove-CONFIG_NFS_V4-from-nfs_read_data.patch
Patch comment and title adjusted

0002-NFSv4.1-put_layout_hdr-can-remove-nfsi-layout.patch
Unchanged

0003-NFS-move-nfs_client-initialization-into-nfs_get_clie.patch
added init_client rpc_ops

0004-NFSv4.1-send-zero-stateid-seqid-on-v4.1-i-o.patch
0005-NFSv4.1-new-flag-for-state-renewal-check.patch
0006-NFSv4.1-new-flag-for-lease-time-check.patch
0007-NFSv4.1-add-MDS-mount-DS-only-check.patch
Unchanged

0008-NFSv4.1-lseg-refcounting.patch
Changed parameter name ino=>inode
Changed function name put_lseg_common
inlined put_lseg_locked

0009-NFSv4.1-coelesce-across-layout-stripes.patch
0010-NFSv4.1-shift-pnfs_update_layout-locations.patch
Switched the order of the above two patches
Moved pnfs_update_layout to pg_doio/pg_test
switched put_lseg/put_nfs_open_context

0011-NFSv4.1-generic-read.patch
Keep nfs_initiate_read static, don't EXPORT here
Removed bfields Signed-off-by;
Removed Reported-by: Alexandros

0012-NFSv4.1-data-server-connection.patch
Unchanged

0013-NFSv4.1-filelayout-i-o-helpers.patch
Added dense stripe helper function

0014-NFSv4.1-filelayout-read.patch
Declare nfs_initiate_read non-static and EXPORT_SYMBOL_GPL

0015-NFSv4.1-filelayout-async-error-handler.patch
Unchanged

0016-NFSv4.1-move-deviceid-cache-to-filelayout-driver.patch
New patch from Christoph

0017-NFSv4.1-turn-off-pNFS-on-ds-connection-failure.patch
Modified to use filelayout driver deviceid cache

0018-NFSv4.1-lseg-documentation.patch
New patch from Fred.

