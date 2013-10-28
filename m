Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60903 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932188Ab3J1O5c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 10:57:32 -0400
From: Anna Schumaker <bjschuma@netapp.com>
To: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/4] NFSD: Add support for WRITE_PLUS and SEEK
Date: Mon, 28 Oct 2013 10:57:22 -0400
Message-ID: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series adds server support for the NFS v4.2 operations WRITE_PLUS
and SEEK.  The first few patches fix up error codes to match the current draft
of the spec and then add in the NFS v4.2 decode operations array so later
patches can focus on only adding in the new operations.

Patch 3 (Add WRITE_PLUS support for hole punches) exports the do_fallocate()
function from fs/open.c.  Should this be its own patch submitted somewhere
else?  Is there a better way to get into the VFS fallocate routines?

The final patch is not meant to be applied, and is only included as an example
of what I did to add offload handling to the client.

Questions, comments and thoughts are appreciated!

Anna

Anna Schumaker (4):
  NFSD: Update error codes
  NFSD: Create nfs v4.2 decode ops
  NFSD: Add WRITE_PLUS support for hole punches
  NFSD: Implement SEEK

 fs/nfsd/nfs4proc.c   |  89 +++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c    | 179 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfsd.h       |   2 +-
 fs/nfsd/vfs.c        |  14 ++++
 fs/nfsd/vfs.h        |   1 +
 fs/nfsd/xdr4.h       |  39 +++++++++++
 fs/open.c            |   1 +
 include/linux/nfs4.h |  21 +++++-
 8 files changed, 342 insertions(+), 4 deletions(-)

-- 
1.8.4.1

