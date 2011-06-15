Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14943 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755905Ab1FPP1M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jun 2011 11:27:12 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@rhel6.dros.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Bakeathon 1/2] NFSv4.1: allow referral directories to be displayed by readdir
Date: Wed, 15 Jun 2011 17:52:39 -0400
Message-Id: <1308174760-22825-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@rhel6.dros.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
cc:stable@kernel.org [2.6.39]
---
 fs/nfs/nfs4xdr.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 11ad51e..9066f0c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4221,6 +4221,9 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		nfs_fixup_secinfo_attributes(fattr, fh);
 		status = 0;
 	}
+	/* Allow referrals to be displayed.*/
+	if (status == -NFS4ERR_MOVED)
+		status = 0;
 	if (status < 0)
 		goto xdr_error;
 
-- 
1.7.3.1

