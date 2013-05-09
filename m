Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58434 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754852Ab3EIPlG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 May 2013 11:41:06 -0400
Date: Thu, 9 May 2013 11:41:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: James Morris <james.l.morris@oracle.com>
Cc: Serge Hallyn <serge.hallyn@canonical.com>,
        linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] security: clarify cap_inode_getsecctx description
Message-ID: <20130509154104.GD9316@fieldses.org>
References: <20130509014329.GH23747@fieldses.org>
 <20130509054926.GA31134@tp>
 <20130509140820.GB9316@fieldses.org>
 <20130509151333.GA2211@tp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130509151333.GA2211@tp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Make it clear that cap_inode_getsecctx shouldn't return success without
filling in the context data.

Acked-by: Serge E. Hallyn <serge.hallyn@ubuntu.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/security.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 4686491..40560f4 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1392,7 +1392,8 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  * 	@ctxlen contains the length of @ctx.
  *
  * @inode_getsecctx:
- *	Returns a string containing all relevant security context information
+ *	On success, returns 0 and fills out @ctx and @ctxlen with the security
+ *	context for the given @inode.
  *
  * 	@inode we wish to get the security context of.
  *	@ctx is a pointer in which to place the allocated security context.
-- 
1.7.9.5

