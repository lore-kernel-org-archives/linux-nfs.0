Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50901 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854Ab1KDVmz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 17:42:55 -0400
Date: Fri, 4 Nov 2011 17:42:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Remove unnecessary whitespace
Message-ID: <20111104214254.GJ721@fieldses.org>
References: <1320171508-14028-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320171508-14028-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 01, 2011 at 02:18:28PM -0400, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> The close parenthesis was hard to find with it spaced so far over.

What kind of terminal was Kendrick working with, anyway?

If you don't mind the below as a friendly amendment, I'll queue it up
for 3.3.

--b.

commit 70aec307e110a2a488e10323b4d2bbd89a3f6485
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Tue Nov 1 14:18:28 2011 -0400

    NFSD: Remove unnecessary whitespace
    
    The close parenthesis was hard to find with it spaced so far over.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    [bfields@redhat.com: get all these lines under 80 chars while we're here]
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 4e2ee29..1d1e858 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -340,15 +340,15 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
 }
 
 /* These will return ERR_INVAL if specified in GETATTR or READDIR. */
-#define NFSD_WRITEONLY_ATTRS_WORD1							    \
-(FATTR4_WORD1_TIME_ACCESS_SET   | FATTR4_WORD1_TIME_MODIFY_SET)
+#define NFSD_WRITEONLY_ATTRS_WORD1 \
+	(FATTR4_WORD1_TIME_ACCESS_SET   | FATTR4_WORD1_TIME_MODIFY_SET)
 
 /* These are the only attrs allowed in CREATE/OPEN/SETATTR. */
-#define NFSD_WRITEABLE_ATTRS_WORD0                                                          \
-(FATTR4_WORD0_SIZE              | FATTR4_WORD0_ACL                                         )
-#define NFSD_WRITEABLE_ATTRS_WORD1                                                          \
-(FATTR4_WORD1_MODE              | FATTR4_WORD1_OWNER         | FATTR4_WORD1_OWNER_GROUP     \
- | FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
+#define NFSD_WRITEABLE_ATTRS_WORD0 \
+	(FATTR4_WORD0_SIZE | FATTR4_WORD0_ACL)
+#define NFSD_WRITEABLE_ATTRS_WORD1 \
+	(FATTR4_WORD1_MODE | FATTR4_WORD1_OWNER | FATTR4_WORD1_OWNER_GROUP \
+	| FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
 #define NFSD_WRITEABLE_ATTRS_WORD2 0
 
 #define NFSD_SUPPATTR_EXCLCREAT_WORD0 \
