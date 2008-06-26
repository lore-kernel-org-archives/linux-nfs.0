From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] missing patches in the devel branch?
Date: Thu, 26 Jun 2008 17:46:48 -0400
Message-ID: <20080626214451.3129.85650.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:23522 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195AbYFZVr6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2008 17:47:58 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

I sent these three patches recently, but they seem to be missing from your
devel branch.

---

Chuck Lever (3):
      NFS: use documenting macro constants for initializing ac{reg,dir}{min,max}
      NFS: Move the nfs_set_port() call out of nfs_parse_mount_options()
      NFS: set transport defaults after mount option parsing is finished


 fs/nfs/nfsroot.c       |    8 ++--
 fs/nfs/super.c         |   94 +++++++++++++++++++++++++++++++-----------------
 include/linux/nfs_fs.h |   10 +++++
 3 files changed, 74 insertions(+), 38 deletions(-)

-- 
Chuck Lever
chu ckl eve rat ora cle dot com
