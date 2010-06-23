Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5004 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426Ab0FWTW3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jun 2010 15:22:29 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/10] pnfs-submit add layoutget,layoutreturn error handling version 2
Date: Wed, 23 Jun 2010 15:21:08 -0400
Message-Id: <1277320878-3726-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0



Responded to comments, added a 2 cleanup patchses

Plus some code cleanup
0001-SQUASHME-pnfs-submit-remove-unused-filelayout_mount_.patch

and some bug fixes
0002-SQUASHME-pnfs-submit-pnfs_try_to_read-write-commit-u.patch

NOTE: this patch: 0003-SQUASHME-pnfs-submit-tell-commit-to-use-the-MDS.patch
was replaced by:
0003-SQUASHME-pnfs-submit-clear-page-lseg-on-partial-i-o.patch


Remove unused (by file layout) encode_layoutreturn io operation
0004-SQUASHME-pnfs-submit-remove-encode_layoutreturn.patch
0005-SQUASHME-pnfs-submit-add-error-handling-to-layout-re.patch

0006-SQUASHME-pnfs-submit-handle-assassinated-layoutcommi.patch

Note: pnfs4_proc_layoutget is only called by send_layout() which prints
the status.
0007-SQUASHME-pnfs-submit-add-error-handlers-to-layout-ge.patch

Add back encode_layoutreturn io operation
0008-pnfs-post-submit-restore-encode_layoutreturn.patch


New patches:
0009-SQUASHME-pnfs-submit-don-t-re-initialize-i_lock.patch

This gets rid of a frame stack warning;
0010-SQUASHME-pnfs-submit-remove-struct-nfs_server-from-s.patch

Testing:
---------

CONFIG_NFS_V4_1 set: NFSv4.0 NFSv4.1 pNFS
Passes Connectathon tests

Tested layoutget and layoutreturn recovery from NFS4ERR_DEAD_SESSION with the
pyNFS server and the testclient framework.

Still todo:

Recover from NFS4ERR_BAD_STATEID. Currently layoutreturn, layoutget, and
layoutcommit do not pass nfs_stste to the error handlers.

Handle NFS4ERR_BAD_LAYOUT.

CONFIG_NFS_V4_1 not set: NFSv4.o mount passes cthon tests.

-->Andy
