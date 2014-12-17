Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:7211 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949AbaLQWfL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2014 17:35:11 -0500
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/4] NFSD: Add support for encoding multiple segments
Date: Wed, 17 Dec 2014 17:35:04 -0500
Message-ID: <1418855704-14127-5-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1418855704-14127-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1418855704-14127-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

This patch lets us send an array of segments back to the client.  In
theory this will make v4.2 reads more efficient, but only if the client
is equipped to handle multiple segment reads.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4xdr.c | 36 ++++++++++++++++++++++--------------
 1 file changed, 22 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2ec9860..b678016 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3823,6 +3823,7 @@ nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp, struct nfsd4_read *r
 	*p++ = cpu_to_be32(maxcount);
 
 	read->rd_offset += maxcount;
+	read->rd_length -= maxcount;
 	return err;
 }
 
@@ -3839,6 +3840,10 @@ nfsd4_encode_read_plus_hole(struct nfsd4_compoundres *resp, struct nfsd4_read *r
 	p = xdr_encode_hyper(p, maxcount);
 
 	read->rd_offset += maxcount;
+	if (maxcount > read->rd_length)
+		read->rd_length = 0;
+	else
+		read->rd_length -= maxcount;
 	return nfs_ok;
 }
 
@@ -3871,23 +3876,26 @@ nfsd4_encode_read_plus(struct nfsd4_compoundres *resp, __be32 nfserr,
 			goto err_truncate;
 	}
 
-	hole_pos = vfs_llseek(read->rd_filp, read->rd_offset, SEEK_HOLE);
-	if (hole_pos == -ENXIO)
-		goto out_encode;
+	do {
+		hole_pos = vfs_llseek(read->rd_filp, read->rd_offset, SEEK_HOLE);
+		if (hole_pos == -ENXIO)
+			break;
 
-	data_pos = vfs_llseek(read->rd_filp, read->rd_offset, SEEK_DATA);
-	if (data_pos == -ENXIO)
-		data_pos = i_size_read(file_inode(file));
+		data_pos = vfs_llseek(read->rd_filp, read->rd_offset, SEEK_DATA);
+		if (data_pos == -ENXIO)
+			data_pos = i_size_read(file_inode(file));
 
-	if ((data_pos == read->rd_offset) && (hole_pos > data_pos))
-		err = nfsd4_encode_read_plus_data(resp, read, file, hole_pos);
-	else if ((hole_pos == read->rd_offset) && (data_pos > hole_pos))
-		err = nfsd4_encode_read_plus_hole(resp, read, file, data_pos);
-	else /* The file probably changed on us between seeks. */
-		err = nfsd4_encode_read_plus_data(resp, read, file, i_size_read(file_inode(file)));
-	segments++;
+		if ((data_pos == read->rd_offset) && (hole_pos > data_pos))
+			err = nfsd4_encode_read_plus_data(resp, read, file, hole_pos);
+		else if ((hole_pos == read->rd_offset) && (data_pos > hole_pos))
+			err = nfsd4_encode_read_plus_hole(resp, read, file, data_pos);
+		else /* The file probably changed on us between seeks. */
+			err = nfsd4_encode_read_plus_data(resp, read, file, i_size_read(file_inode(file)));
+		if (err)
+			break;
+		segments++;
+	} while (read->rd_length > 0);
 
-out_encode:
 	eof = (read->rd_offset >= i_size_read(file_inode(file)));
 	*p++ = cpu_to_be32(eof);
 	*p++ = cpu_to_be32(segments);
-- 
2.1.3

