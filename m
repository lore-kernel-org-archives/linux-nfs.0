Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:2209 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755222AbaIZR6b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2014 13:58:31 -0400
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 0/2] NFSD: Add v4.2 SEEK support
Date: Fri, 26 Sep 2014 13:58:25 -0400
Message-ID: <1411754307-18457-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

These patches add server support for the NFS v4.2 operation SEEK.  The first
patch adds basic NFS v4.2 infrastructure that all future operations will rely
on.  The second patch adds the SEEK operation.

Changes in v3:
- Rework the switch statement in nfsd4_seek() so we only call vfs_llseek()
  from one place.
- Change XDR encode and decode functions to A + B notation for calculating
  byte counts.

These patches and the corresponding client patch are avaliable in the [seek]
branch of:

	git://git.linux-nfs.org/projects/anna/linux-nfs.git


Questions?  Comments?  Thoughts?

Anna


Anna Schumaker (2):
  NFSD: Add generic v4.2 infrastructure
  NFSD: Implement SEEK

 fs/nfsd/nfs4proc.c   | 49 ++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c    | 60 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/xdr4.h       | 14 ++++++++++++
 include/linux/nfs4.h | 23 ++++++++++++++++++--
 4 files changed, 144 insertions(+), 2 deletions(-)

-- 
2.1.0

