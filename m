Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39741 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752853AbaLGVFt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Dec 2014 16:05:49 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB7L5nFM020017
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Sun, 7 Dec 2014 16:05:49 -0500
Received: from bcodding-csb.redhat.com (vpn-57-215.rdu2.redhat.com [10.10.57.215])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sB7L5n04030338
	for <linux-nfs@vger.kernel.org>; Sun, 7 Dec 2014 16:05:49 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfsd4: fix xdr4 count of server in fs_location4
Date: Sun,  7 Dec 2014 16:05:48 -0500
Message-Id: <d602d4a37d02801659ddf5e6f012453b89169f70.1417985975.git.bcodding@redhat.com>
In-Reply-To: <cover.1417985975.git.bcodding@redhat.com>
References: <cover.1417985975.git.bcodding@redhat.com>
In-Reply-To: <cover.1417985975.git.bcodding@redhat.com>
References: <cover.1417985975.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a bug where nfsd4_encode_components_esc() incorrectly calculates the
length of server array in fs_location4.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfsd/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6c92a53..2a77603 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1800,7 +1800,7 @@ static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep,
 
 		str = end;
 	}
-	pathlen = htonl(xdr->buf->len - pathlen_offset);
+	pathlen = htonl(count);
 	write_bytes_to_xdr_buf(xdr->buf, pathlen_offset, &pathlen, 4);
 	return 0;
 }
-- 
1.7.1

