From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/7] Second series of patches for 2.6.27
Date: Tue, 27 May 2008 16:28:59 -0400
Message-ID: <20080527202347.6651.54668.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:32203 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757485AbYE0U3m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 May 2008 16:29:42 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Here's the next series of patches for 2.6.27.  These straightforward patches
clean up trace debugging in the NFS and RPC clients.

---

Chuck Lever (7):
      SUNRPC: Remove obsolete messages during transport connect
      NFS: Fix trace debugging nits in write.c
      NFS: Use NFSDBG_FILE for all fops
      NFS: Add debugging facility for NFS aops
      NFS: Make nfs_open methods consistent
      NFS: Make nfs_llseek methods consistent
      NFS: Make nfs_fsync methods consistent


 fs/nfs/dir.c      |   27 ++++++++++---
 fs/nfs/direct.c   |    4 +-
 fs/nfs/file.c     |  107 +++++++++++++++++++++++++++++++++++++++++------------
 fs/nfs/write.c    |   18 +++++----
 net/sunrpc/xprt.c |    8 ----
 5 files changed, 115 insertions(+), 49 deletions(-)

-- 
Chuck Lever
chuck[dot]level[at]oracle[dot]com
