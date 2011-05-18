Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58647 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932679Ab1ERCK2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2011 22:10:28 -0400
Message-ID: <4DD32B1B.8090709@cn.fujitsu.com>
Date: Wed, 18 May 2011 10:12:43 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd41: error out when client sets maxreq_sz or maxresp_sz
 too small
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

According to RFC5661, 18.36.3, 

 "if the client selects a value for ca_maxresponsesize such that
  a replier on a channel could never send a response,the server
  SHOULD return NFS4ERR_TOOSMALL in the CREATE_SESSION reply."

This patch let server error out when client sets maxreq_sz less than
SEQUENCE request size, and maxresp_sz less than a SEQUENCE reply size.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4xdr.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c6766af..8983d03 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -131,6 +131,14 @@ xdr_error:					\
 	}					\
 } while (0)
 
+#define op_decode_hdr_size	(1)
+#define op_encode_hdr_size	(2)
+
+#define decode_sequence_size	(op_decode_hdr_size + \
+				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 4)
+#define encode_sequence_size	(op_encode_hdr_size + \
+				XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
+
 static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
 {
 	/* We want more bytes than seem to be available.
@@ -1154,7 +1162,17 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
 	READ_BUF(28);
 	READ32(dummy); /* headerpadsz is always 0 */
 	READ32(sess->fore_channel.maxreq_sz);
+	if (sess->fore_channel.maxreq_sz < decode_sequence_size) {
+		status = nfserr_toosmall;
+		goto out;
+	}
+
 	READ32(sess->fore_channel.maxresp_sz);
+	if (sess->fore_channel.maxresp_sz < encode_sequence_size) {
+		status = nfserr_toosmall;
+		goto out;
+	}
+
 	READ32(sess->fore_channel.maxresp_cached);
 	READ32(sess->fore_channel.maxops);
 	READ32(sess->fore_channel.maxreqs);
-- 
1.7.4.5



