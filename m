Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:20552 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754193AbbAETR2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2015 14:17:28 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] Remove function macros from nfs4_fs.h
Date: Mon, 5 Jan 2015 14:17:21 -0500
Message-ID: <1420485444-20101-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While reviewing Tom's flexfile patches I found a few places where
nfs4_state_protect() was being called inside the generic client, rather
than in the nfsv4 module.  These patches move the function calls into
the correct layer and then tidy up nfs4_fs.h once everything has been
moved.

Thoughts?

Anna


Anna Schumaker (3):
  nfs: Call nfs4_state_protect() from nfs4_proc_commit_setup()
  nfs: Call nfs4_state_protect_write() from nfs4_proc_write_setup()
  nfs: Remove unused v4 macros

 fs/nfs/nfs3proc.c       |  7 +++++--
 fs/nfs/nfs4_fs.h        |  7 -------
 fs/nfs/nfs4proc.c       |  9 +++++++--
 fs/nfs/proc.c           |  6 ++++--
 fs/nfs/write.c          | 10 ++--------
 include/linux/nfs_xdr.h |  6 ++++--
 6 files changed, 22 insertions(+), 23 deletions(-)

-- 
2.2.1

