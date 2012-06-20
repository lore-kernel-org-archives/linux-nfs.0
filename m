Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:52992 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757628Ab2FTTDt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:03:49 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 0/4] NFSv4.1 enable fencing of file layout data servers
Date: Wed, 20 Jun 2012 15:03:30 -0400
Message-Id: <1340219014-5749-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

When I/O sent to a file layout data server has a connection error,the I/O
is resent to the MDS. As with all mulipath I/O, we want to fence one path,
the DS I/O path, ASAP to prevent data corruption.  PNFS provides the
LAYOUTREURN call to fence file layout data servers.

The current implementation of _pnfs_return_layout does not take a layout range
but returns all layouts. It also does not wait for all layout segments to
be marked invalid prior to sending a LAYOUTRETURN. This works well for the
file layout driver. Other drives can address these issues if needed.

The first patch calls LAYOUTRETURN for each failed data server I/O.
The second patch blocks sending a LAYOUTCOMMIT on the returned layouts.

Because LAYOUTRETURN is called on each failed data server request, it can be
called multiple times. The third patch addresses this by setting a flag. The
flag is cleared on subsequent LAYOUTGETs.

The DS connection error also causes the deviceid using the DS to be marked
invalid. This prevents any new layouts from subsequent LAYOUTGETs that use the
invalid deviceid from being cached - but the layout hdr is not reaped,
resulting in a pnfs_layout_hdr with an empty plh_segs list.
New LAYOUTGETs are allowed because they can use a new valid deviceid, and in
fact, this is currently the only way an MDS can use pNFS again for files with
layouts referring to an invalid deviceid.

pnfs_layout_hdrs with empty plh_segs lists are prevented from sending a
LAYOUTRETURN (on evict inode) by the last patch.

Testing: Against the pynfs file layout server and network partioning the
client from the DS.


Andy Adamson (4):
  NFSv4.1 return the LAYOUT for each file with failed DS connection I/O
  NFSv4.1 don't send LAYOUTCOMMIT if data resent through MDS
  NFSv4.1 mark layout when already returned
  NFSv4.1 do not send LAYOUTRETURN on emtpy plh_segs list

 fs/nfs/nfs4filelayout.c |    4 ++--
 fs/nfs/pnfs.c           |   33 +++++++++++++++++++++++++++------
 fs/nfs/pnfs.h           |   19 +++++++++++++++++++
 3 files changed, 48 insertions(+), 8 deletions(-)

-- 
1.7.6.4

