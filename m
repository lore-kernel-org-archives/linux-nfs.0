From: Jeff Layton <jlayton@redhat.com>
Subject: Should truncated READDIR replies return -EIO?
Date: Fri,  8 Feb 2008 10:04:42 -0500
Message-ID: <1202483082-5334-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59367 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757542AbYBHPEq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2008 10:04:46 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m18F4h73029356
	for <linux-nfs@vger.kernel.org>; Fri, 8 Feb 2008 10:04:45 -0500
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m18F4hrR009917
	for <linux-nfs@vger.kernel.org>; Fri, 8 Feb 2008 10:04:43 -0500
Received: from localhost.localdomain (vpn-14-19.rdu.redhat.com [10.11.14.19])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m18F4gTG025886
	for <linux-nfs@vger.kernel.org>; Fri, 8 Feb 2008 10:04:42 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently, I ran across a server-side bug that caused the server to send
truncated READDIR replies. The server would send a valid RPC response to
a READDIR call, but the contents of it were basically missing
(everything after the status).

The server problem had long been patched in mainline kernels, but the
interesting bit was that clients didn't return an error in this
situation. The XDR decoders for readdir calls are supposed to check the
validity of the response, but in this situation it just fudges the
contents of the pagecache to make it look like a completely empty
directory.

Shouldn't the client return an error in this situation? The response
obviously isn't valid so it seems like it shouldn't pretend that it is.
If so, would something like the following patch make sense?

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs2xdr.c |    1 +
 fs/nfs/nfs3xdr.c |    1 +
 fs/nfs/nfs4xdr.c |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 1f7ea67..aa6966a 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -478,6 +478,7 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	if (!nr) {
 		dprintk("NFS: readdir reply truncated!\n");
 		entry[1] = 1;
+		nr = -errno_NFSERR_IO;
 	}
 	goto out;
 err_unmap:
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 3917e2f..04ba525 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -592,6 +592,7 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
 	if (!nr) {
 		dprintk("NFS: readdir reply truncated!\n");
 		entry[1] = 1;
+		nr = -errno_NFSERR_IO;
 	}
 	goto out;
 err_unmap:
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index db1ed9c..139c9e1 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3544,6 +3544,7 @@ short_pkt:
 	if (!nr) {
 		dprintk("NFS: readdir reply truncated!\n");
 		entry[1] = 1;
+		nr = -errno_NFSERR_IO;
 	}
 	goto out;
 err_unmap:
-- 
1.5.3.8

