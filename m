Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8992 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753039Ab0LWMry (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Dec 2010 07:47:54 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/15] pnfs wave 2 submission, try 3
Date: Thu, 23 Dec 2010 07:47:31 -0500
Message-Id: <1293108466-31768-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Version 3 of the wave 2 submission.

changes from version 2:
- added list_del before each call to free_lseg in pnfs_free_lseg_list
- removed some BUG_ONs
- moved rpc_waitq from nfs_inode to nfs_server


These patches implement wave 2 of the pnfs submission, which
encompasses CB_LAYOUTRECALL and its serialization with LAYOUTGET,
as well as the "forgetful model" in which LAYOUTRETURNs are never
sent, but instead merely discarded by the client.

Fred

[PATCH 01/15] pnfs: fix incorrect comment in destroy_lseg
[PATCH 02/15] pnfs: remove unnecessary field lgp->status
[PATCH 03/15] pnfs: add prefix to struct pnfs_layout_segment fields
[PATCH 04/15] pnfs: add prefix to struct pnfs_layout_hdr fields
[PATCH 05/15] pnfs: change layout state seqlock to a spinlock
[PATCH 06/15] pnfs: change how lsegs are removed from layout list
[PATCH 07/15] pnfs: layoutget rpc code cleanup
[PATCH 08/15] pnfs: serialize LAYOUTGET(openstateid)
[PATCH 09/15] pnfs: add layout to client list before sending rpc
[PATCH 10/15] pnfs: check that partial LAYOUTGET return is ignored
[PATCH 11/15] pnfs: change lo refcounting to atomic_t
[PATCH 12/15] pnfs: CB_LAYOUTRECALL xdr code
[PATCH 13/15] pnfs: add CB_LAYOUTRECALL handling
[PATCH 14/15] pnfs: update nfs4_callback_recallany to handle layouts
[PATCH 15/15] pnfs: layout roc code
