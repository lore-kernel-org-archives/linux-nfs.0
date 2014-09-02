Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:15461 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754033AbaIBRan (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Sep 2014 13:30:43 -0400
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 0/2] NFSD: Add v4.2 SEEK support
Date: Tue, 2 Sep 2014 13:30:36 -0400
Message-ID: <1409679038-32179-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

These patches add server support for the NFS v4.2 operation SEEK.  The first
patch adds basic NFS v4.2 infrastructure that all future operations will rely
on.  The second patch adds the SEEK operation.

Changes in v2:
- Remove CONFIG_NFSD_V4_2_SEEK.
- Change the call to preprocess_stateid_op() to only use RD_STATE instead of
  RD_STATE | WR_STATE.

These patches and the corresponding client patch are avaliable in the [seek]
branch of:

	git://git.linux-nfs.org/projects/anna/linux-nfs.git


Questions?  Comments?  Thoughts?

Anna


Anna Schumaker (2):
  NFSD: Add generic v4.2 infrastructure
  NFSD: Implement SEEK

 fs/nfsd/nfs4proc.c   | 43 +++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c    | 60 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/xdr4.h       | 14 ++++++++++++
 include/linux/nfs4.h | 23 ++++++++++++++++++--
 4 files changed, 138 insertions(+), 2 deletions(-)

-- 
2.1.0

