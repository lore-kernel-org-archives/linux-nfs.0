Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:6544 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753582AbdCTWHH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Mar 2017 18:07:07 -0400
From: <andros@netapp.com>
To: <trondmy@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 0/3] NFS filelayout fix a GETDEVINO hang`
Date: Mon, 20 Mar 2017 18:06:59 -0400
Message-ID: <1490047622-35305-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

NOTE: this change can result in two GETDEVINFO calls on the wire to
resolve a layout deviceid when there are multiple async I/O calls as
the initial nfs4_find_get_deviceid() GETDEVINFO call may not have
returned and inserted the new deviceid prior to a subsequent
nfs4_find_get_deviceid() searches for the deviceid.

Fix a filelayout GETDEVICEINFO call hang triggered from the LAYOUTGET
pnfs_layout_process where the GETDEVICEINFO call is waiting for a
session slot, and the LAYOUGET call is waiting for pnfs_layout_process
to complete before freeing the slot GETDEVICEINFO is waiting for..

This occurs in testing against the pynfs pNFS server where the
the on-wire reply highest_slotid and slot id are zero, and the
target high slot id is 8 (negotiated in CREATE_SESSION).

The internal fore channel slot table max_slotid, the maximum allowed
table slotid value, has been reduced via nfs41_set_max_slotid_locked
 from 8 to 1.  Thus there is one slot (slotid 0) available for use but
it has not been freed by LAYOUTGET  proir to the GETDEVICEINFO request.

In order to ensure that layoutrecall callbacks are processed in the
correct order, nfs4_proc_layoutget processing needs to be finished
e.g. pnfs_layout_process) before giving up the slot that identifies
the layoutget (see referring_call_exists).

Move the filelayout_check_layout nfs4_find_get_device call outside of
the pnfs_layout_process call tree.


Andy Adamson (3):
  NFS cleanup struct nfs4_filelayout_segment
  NFS store nfs4_deviceid in struct nfs4_filelayout_segment
  NFS filelayout:call GETDEVICEINFO after pnfs_layout_process completes

 fs/nfs/filelayout/filelayout.c | 149 ++++++++++++++++++++++++++---------------
 fs/nfs/filelayout/filelayout.h |  19 +++---
 2 files changed, 105 insertions(+), 63 deletions(-)

-- 
1.8.3.1

