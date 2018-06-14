Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55502 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754691AbeFNTVf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Jun 2018 15:21:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] nfsd: fix NFSv4 time_delta attribute
Date: Thu, 14 Jun 2018 15:21:32 -0400
Message-Id: <1529004093-5866-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1529004093-5866-1-git-send-email-bfields@redhat.com>
References: <1529004093-5866-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Currently we return the worst-case value of 1 second in the time delta
attribute.  That's not terribly useful.  Instead, return a value
calculated from the time granularity supported by the filesystem and the
system clock.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 29 ++++++++++++++++++++++++++---
 1 file changed, 26 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 59d471025949..4c5fa0ff2387 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2003,6 +2003,31 @@ static __be32 *encode_change(__be32 *p, struct kstat *stat, struct inode *inode,
 	return p;
 }
 
+/*
+ * ctime (in NFSv4, time_metadata) is not writeable, and the client
+ * doesn't really care what resolution could theoretically be stored by
+ * the filesystem.
+ *
+ * The client cares how close together changes can be while still
+ * guaranteeing ctime changes.  For most filesystems (which have
+ * timestamps with nanosecond fields) that is limited by the resolution
+ * of the time returned from current_time() (which I'm assuming to be
+ * 1/HZ).
+ */
+static __be32 *encode_time_delta(__be32 *p, struct inode *inode)
+{
+	struct timespec ts;
+	u32 ns;
+
+	ns = max(NSEC_PER_SEC/HZ, inode->i_sb->s_time_gran);
+	ts = ns_to_timespec(ns);
+
+	p = xdr_encode_hyper(p, ts.tv_sec);
+	*p++ = cpu_to_be32(ts.tv_nsec);
+
+	return p;
+}
+
 static __be32 *encode_cinfo(__be32 *p, struct nfsd4_change_info *c)
 {
 	*p++ = cpu_to_be32(c->atomic);
@@ -2794,9 +2819,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 		p = xdr_reserve_space(xdr, 12);
 		if (!p)
 			goto out_resource;
-		*p++ = cpu_to_be32(0);
-		*p++ = cpu_to_be32(1);
-		*p++ = cpu_to_be32(0);
+		p = encode_time_delta(p, d_inode(dentry));
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_METADATA) {
 		p = xdr_reserve_space(xdr, 12);
-- 
2.17.1

