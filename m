Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55065 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754691Ab0FCQZ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jun 2010 12:25:29 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] pnfs-submit: cleanup layoutcommit verison 2 
Date: Thu,  3 Jun 2010 12:25:23 -0400
Message-Id: <1275582327-9285-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Responded to comments.

This is against the pnfs-submit branch of the 2.6.34 tree. They will need to be
applied against the 2.6.35-rc1 tree which I can do after comments.

A cleanup, and call the async error handler.
0001-SQUASHME-pnfs-submit-cleanup-layoutcommit-call.patch
0002-SQUASHME-pnfs-submit-handle-async-layoutcommit-erro.patch

These next two patches moves the pnfs_layoutcommit_inode call to
nfs_write_inode, and it is the only call other than in layoutreturn.
(removed calls in __nfs4_close, nfs_commit_inode, nfs_wb_sync).

0003-SQUASHME-pnfs-remove-ifdef-around-layoutcommit_neede.patch
0004-SQUASHME-pnfs-submit-move-layoutcommit-to-nfs_write.patch

pnfs_layoutcommit_inode is called after nfs_commit_unstable_pages() so that
if LAYOUTCOMMIT fails, the unstable pages have been processed..

The error handlers (sync and async) call nfs4_map_errors, so unhandled
errors (such as NFS4ERR_BADLAYOUT) get returned to nfs_write_ioode as -EIO.

We will add code to the error handlers for errors such as NFS4ERR_BADLAYOUT
that require us to stop using and free the layout, and redo the I/O through
the MDS.

Testing:
With CONFIG_NFS_V4_1 set
NFSv4.1/pnfs passed Connectathon against write enabled GFS2/pNFS. Note: there
were exactly the same number of LAYOUTCOMMITS sent as were sent with
pnfs_layoutcommit_inode being called from __nfs4_close (never happened),
nfs_commit_inode and nfs_wb_sync.

V4.0 mount passes Connectathon tests

With CONFIG_NFS_V4_1 not set

V4.0 mount passes Connectathon tests

-->Andy

