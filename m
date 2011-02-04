Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753051Ab1BDVeJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:09 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/40] Wave3: For pNFS team review, not for kernel submission 
Date: Fri,  4 Feb 2011 16:33:22 -0500
Message-Id: <1296855242-2592-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


The wave3 code addresses pNFS file layout data server connection, data server
READ I/O and recovery of failed data server READs through the MDS.

I did not see the pnfs-submit-wave3 branch on benny's tree, so I created my
own for the meantime.
I cloned the nfsd41-all from git://linux-nfs.org/~bhalevy/linux-pnfs.git
which is the base for the pnfs-submit branch.
I then applied the wave3 patches from benny's pnfs-submit branch,
and then the changes.

git://linux-nfs.org/projects/andros/benny-linux-pnfs.git
branch andros-pnfs-submit-wave3 contains the result.

========================================================================
Please review the changes - I want to submit to Trond/Christoph next week.
========================================================================

These patches are in the first 12 in the pnfs-submit tree and are the original
"wave3" patches.

0001-pnfs-submit-wave3-lseg-refcounting.patch
0002-pnfs_submit-add-data-server-session-to-nfs4_setup_se.patch
0003-pnfs_submit-update-nfs4_async_handle_error-for-data-.patch
0004-pnfs_submit-update-state-renewal-for-data-servers.patch
0005-pnfs_submit-wave3-pageio-helpers.patch
0006-pnfs_submit-wave3-associate-layout-segment-with-nfs_.patch
0007-pnfs_submit-filelayout-policy-operations.patch
0008-pnfs_submit-filelayout-i-o-helpers.patch
0009-pnfs_submit-wave3-generic-read.patch
0010-pnfs_submit-filelayout-read.patch
0011-pnfs_submit-increase-NFS_MAX_FILE_IO_SIZE.patch
0012-pnfs_submit-enforce-requested-DS-only-pNFS-role.patch

The rest are the wave3 changes.

Summary of changes;
-------------------

1) The file layoutdriver now specifies it's own rpc_call_prepare and
rpc_call_done callbacks for READ.

filelayout_read_prepare:
- Uses nfs41_setup_sequence so we do not need to change nfs4_setup_sequence().

filelayout_read_done
- Add a read_done_cb function to nfs_read_data that calls nfs_read_done_cb for
NFS READs and filelayout_read_done_cb for data server READs.
- filelayout_read_done_cb has its own async error handler so we do not need to change nfs4_async_handle_error()

2) DS/MDS dual role now allows for sessions used as a data server to be reused
as an MDS or NFSv41 mount.
- We don't ask for the DS role on data server EXCHANGE_ID
- We don't strip any roles returned by the server.
- If a session is in use as a DS role, and the client subsequently mounts the
same server as either an MDS or NON_PNFS mount, the same session can be used
provided the existing exchange flags allow it.

3) We always send a zero READ/WRITE stateid seqid. This is required for
data servers, and there is no advantage to not doing it for MDS or NON_PNFS
mounts.

4) We mark the deviceid as invalid upon any data server connection failure
and print out a kernel message.
This in turn marks any layout that tries to use the devicid as failed for
both IOMODE_READ and IOMODE_RW. Inodes without layouts will still send
a layoutget. If the resultant layout uses the marked deviceid, it will be
marked as failed for both iomodes. All I/O will go through the MDS until
a client reboot or a CB_LAYOUTRECALL ALL or FSID removes all layouts that
refer to the deviceid, which removes the deviceid.

5) Our new file layout async error handler only recovers from session
related errors, or grace/delay errors. All other errors including
NFS4ERR_EXPIRED or NFS4ERR_STALE_CLIENTID result in marking the layout as
failed for IOMODE_READ and I/O is retried through the MDS.

6) Fred's lock inversion patches, and the request by Trond to not reference
a layout segment on dirty pages held in the cache changed the layout
segment reference counting.

There are a couple of small issues I'm still investigating. Trond and Fred
have done an initial review.

-->Andy

