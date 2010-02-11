Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:58641 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756537Ab0BKTKU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Feb 2010 14:10:20 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Reduce GETATTRs during direct I/O
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 11 Feb 2010 14:08:58 -0500
Message-ID: <20100211185757.2666.90001.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond-

I mentioned this one to you last week.  I found that the NFS direct
I/O engine appears to be missing calls to nfs_fattr_init().  Please
take a look at these two patches and let me know if they look
reasonable for 2.6.34.

The problem also appears in the enterprise linux kernels.  We're still
testing this on EL4 and EL5 in specific.  We haven't found evidence so
far of incorrect behavior after applying the direct.c fix.  A bugzilla
report is forthcoming.

I haven't convinced myself that the extra GETATTR when opening an
O_DIRECT file is ever necessary.  But, I coded up a patch to your
specifications that changes O_DIRECT opens to avoid a GETATTR when
possible.

---

Chuck Lever (2):
      NFS: Don't generate a GETATTR when opening an O_DIRECT file
      NFS: Too many GETATTR and ACCESS calls after direct I/O


 fs/nfs/dir.c    |   20 ++++++++++++++++----
 fs/nfs/direct.c |    3 +++
 2 files changed, 19 insertions(+), 4 deletions(-)

-- 
Chuck Lever
