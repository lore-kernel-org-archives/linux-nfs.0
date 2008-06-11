From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/7] dprintk clean-ups [resend]
Date: Wed, 11 Jun 2008 17:55:18 -0400
Message-ID: <20080611215018.7068.71737.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:33941 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbYFKVzu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jun 2008 17:55:50 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Resending the patches that clean up various minor problems with dprintk
debugging messages in the NFS and RPC clients.  Building without SYSCTL
should be quieter now.

---

Chuck Lever (7):
      SUNRPC: Remove obsolete messages during transport connect
      NFS: Fix trace debugging nits in write.c
      NFS: Use NFSDBG_FILE for all fops
      NFS: Add debugging facility for NFS aops
      NFS: Make nfs_open methods consistent
      NFS: Make nfs_llseek methods consistent
      NFS: Make nfs_fsync methods consistent


 fs/nfs/dir.c      |   26 ++++++++++---
 fs/nfs/direct.c   |    4 +-
 fs/nfs/file.c     |  103 +++++++++++++++++++++++++++++++++++++++--------------
 fs/nfs/write.c    |   27 +++++++-------
 net/sunrpc/xprt.c |    8 +---
 5 files changed, 112 insertions(+), 56 deletions(-)

-- 
Chuck Lever
chu ckd otl eve rat ora cle dot com
