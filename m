Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54384 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752665AbaLGVFt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Dec 2014 16:05:49 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB7L5n27020885
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Sun, 7 Dec 2014 16:05:49 -0500
Received: from bcodding-csb.redhat.com (vpn-57-215.rdu2.redhat.com [10.10.57.215])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sB7L5nhg015057
	for <linux-nfs@vger.kernel.org>; Sun, 7 Dec 2014 16:05:49 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfsd4: fix xdr4 inclusion of escaped char
Date: Sun,  7 Dec 2014 16:05:47 -0500
Message-Id: <8ec7a52c7b6b5287e8bd87503834bae46377f3ef.1417985975.git.bcodding@redhat.com>
In-Reply-To: <cover.1417985975.git.bcodding@redhat.com>
References: <cover.1417985975.git.bcodding@redhat.com>
In-Reply-To: <cover.1417985975.git.bcodding@redhat.com>
References: <cover.1417985975.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a bug where nfsd4_encode_components_esc() includes the esc_end char as
an additional string encoding.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfsd/nfs4xdr.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index eeea7a9..6c92a53 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1795,6 +1795,9 @@ static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep,
 		}
 		else
 			end++;
+		if (found_esc)
+			end = next;
+
 		str = end;
 	}
 	pathlen = htonl(xdr->buf->len - pathlen_offset);
-- 
1.7.1

