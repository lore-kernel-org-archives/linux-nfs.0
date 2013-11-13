Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:34124 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504Ab3KMTbB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 14:31:01 -0500
From: Anna Schumaker <bjschuma@netapp.com>
To: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 0/3] NFSD: Implement SEEK
Date: Wed, 13 Nov 2013 14:30:54 -0500
Message-ID: <1384371057-16454-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches implement just the SEEK NFS v4.2 operation.  WRITE_PLUS is
still under discussion with the IETF after my last series of patches, so I
am holding off on resubmitting until after spec discussion dies down.

Questions?  Comments?  Thoughts?
Anna

Anna Schumaker (3):
  NFSD: Update error codes
  NFSD: Create nfs v4.2 decode ops
  NFSD: Implement SEEK

 fs/nfsd/Kconfig      | 12 +++++++++
 fs/nfsd/nfs4proc.c   | 60 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c    | 70 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsd.h       |  2 +-
 fs/nfsd/xdr4.h       | 16 ++++++++++++
 include/linux/nfs4.h | 23 ++++++++++++++---
 6 files changed, 179 insertions(+), 4 deletions(-)

-- 
1.8.4.2

