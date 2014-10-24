Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16364 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756654AbaJXOls (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Oct 2014 10:41:48 -0400
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 0/2] NFSD: Add ALLOCATE and DEALLOCATE support
Date: Fri, 24 Oct 2014 10:41:43 -0400
Message-ID: <1414161705-26617-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

These patches add server support for the ALLOCATE and DEALLOCATE operations
part of NFS v4.2.

I submitted my do_fallocate() -> vfs_fallocate() change as a separate patch,
so it has been removed from this submission.  However, this code still depends
on this patch being applied first.

Changes in v2:
- ALLOCATE and DEALLOCATE can call a common nfsd4_fallocate() to check the
  stateids, look up the file, and eventually call nfsd4_vfs_fallocate().
- I return NFS4ERR_INVAL in the case that vfs_fallocate() returns -ENODEV.
  Please let me know if there is a better error to return instead!

These patches and the corresponding client changes are available in the
[fallocate] branch of:

	git://git.linux-nfs.org/projects/anna/linux-nfs.git


Questions?  Comments?  Thoughts?

Anna


Anna Schumaker (2):
  nfsd: Add ALLOCATE support
  nfsd: Add DEALLOCATE support

 fs/nfsd/nfs4proc.c | 51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c  | 21 +++++++++++++++++++--
 fs/nfsd/vfs.c      | 19 +++++++++++++++++++
 fs/nfsd/vfs.h      |  2 ++
 fs/nfsd/xdr4.h     |  9 +++++++++
 5 files changed, 100 insertions(+), 2 deletions(-)

-- 
2.1.2

