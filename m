Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50320 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753992Ab3LJP1E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Dec 2013 10:27:04 -0500
Subject: [PATCH 7/9] Use %pd in NFSD
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date: Tue, 10 Dec 2013 15:27:02 +0000
Message-ID: <20131210152702.4916.32615.stgit@warthog.procyon.org.uk>
In-Reply-To: <20131210152612.4916.80435.stgit@warthog.procyon.org.uk>
References: <20131210152612.4916.80435.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the new %pd printk() specifier in NFSD to replace passing of dentry name or
dentry name and name length * 2 with just passing the dentry.

Signed-off-by: David Howells <dhowells@redhat.com>
cc "J. Bruce Fields" <bfields@fieldses.org>
cc: linux-nfs@vger.kernel.org
---

 fs/nfsd/nfs4xdr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index ee7237f99f54..34342c9bc09b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1884,7 +1884,7 @@ static __be32 nfsd4_encode_path(const struct path *root,
 		}
 		WRITE32(len);
 		WRITEMEM(dentry->d_name.name, len);
-		dprintk("/%s", dentry->d_name.name);
+		dprintk("/%pd", dentry);
 		spin_unlock(&dentry->d_lock);
 		dput(dentry);
 		ncomponents--;

