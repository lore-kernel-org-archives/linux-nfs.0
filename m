Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:10105 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972Ab3KLTEM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 14:04:12 -0500
From: Anna Schumaker <bjschuma@netapp.com>
To: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 0/3] NFSD: Implement SEEK
Date: Tue, 12 Nov 2013 14:04:05 -0500
Message-ID: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
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

 fs/nfsd/nfs4proc.c   | 56 ++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c    | 58 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsd.h       |  2 +-
 fs/nfsd/xdr4.h       | 16 +++++++++++++++
 include/linux/nfs4.h | 23 ++++++++++++++++++---
 5 files changed, 151 insertions(+), 4 deletions(-)

-- 
1.8.4.2

