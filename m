Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37742 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754055Ab3EIBng (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 May 2013 21:43:36 -0400
Date: Wed, 8 May 2013 21:43:29 -0400
To: Serge Hallyn <serge.hallyn@canonical.com>
Cc: linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] security: cap_inode_getsecctx returning garbage
Message-ID: <20130509014329.GH23747@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We shouldn't be returning success from this function without also
filling in the return values ctx and ctxlen.

Note currently this doesn't appear to cause bugs since the only
inode_getsecctx caller I can find is fs/sysfs/inode.c, which only calls
this if security_inode_setsecurity succeeds.  Assuming
security_inode_setsecurity is set to cap_inode_setsecurity whenever
inode_getsecctx is set to cap_inode_getsecctx, this function can never
actually called.

So I noticed this only because the server labeled NFS patches add a real
caller.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 security/capability.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Also, assuming this is correct, would you be willing to apply it for
3.10?

If you'd prefer it wait till the next merge window: could you ACK it,
and let me merge it through the nfsd tree?  (It's a prerequisite for
the labeled NFS patches that I hope to merge for 3.11.)

diff --git a/security/capability.c b/security/capability.c
index d32e16e..32b5157 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -858,7 +858,7 @@ static int cap_inode_setsecctx(struct dentry *dentry, void *ctx, u32 ctxlen)
 
 static int cap_inode_getsecctx(struct inode *inode, void **ctx, u32 *ctxlen)
 {
-	return 0;
+	return -EOPNOTSUPP;
 }
 #ifdef CONFIG_KEYS
 static int cap_key_alloc(struct key *key, const struct cred *cred,
-- 
1.7.9.5

