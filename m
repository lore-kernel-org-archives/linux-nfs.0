Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:47372 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933852AbaH0PSD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Aug 2014 11:18:03 -0400
From: <bjschuma@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] NFSD: Add v4.2 SEEK support
Date: Wed, 27 Aug 2014 11:17:55 -0400
Message-ID: <1409152678-7806-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

These patches add server support for the NFS v4.2 operation SEEK.  The first
two patches are error cleanups and infrastructure setup to prepare for the
addition of new operations.

My biggest concern is that these patches freeze the v4.2 opcodes to their
current values, which makes any future spec changes to add or remove
operations more difficult to accomidate.

Questions?  Comments?  Thoughts?

Anna


Anna Schumaker (3):
  NFSD: Update error codes
  NFSD: Create nfs v4.2 decode ops
  NFSD: Implement SEEK

 fs/nfsd/Kconfig      | 12 +++++++++
 fs/nfsd/nfs4proc.c   | 47 +++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c    | 73 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsd.h       |  2 +-
 fs/nfsd/xdr4.h       | 14 ++++++++++
 include/linux/nfs4.h | 26 ++++++++++++++++---
 6 files changed, 170 insertions(+), 4 deletions(-)

-- 
2.1.0

