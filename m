From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] NFS: remove an unused function
Date: Fri, 29 Oct 2004 02:23:38 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20041029002338.GT29142@stusta.de>
References: <20041028230948.GA3207@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263194AbUJ2Amn@vger.kernel.org>
To: neilb@cse.unsw.edu.au
In-Reply-To: <20041028230948.GA3207@stusta.de>
List-ID: <nfs.lists.sourceforge.net>

[ this time without the problems due to a digital signature... ]

The patch below removes an unused function from fs/nfsd/nfs3xdr.c


diffstat output:
 fs/nfsd/nfs3xdr.c |   16 ----------------
 1 files changed, 16 deletions(-)


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc1-mm1-full/fs/nfsd/nfs3xdr.c.old	2004-10-28 22:42:11.000000000 +0200
+++ linux-2.6.10-rc1-mm1-full/fs/nfsd/nfs3xdr.c	2004-10-28 22:42:25.000000000 +0200
@@ -102,22 +102,6 @@
 }
 
 static inline u32 *
-decode_pathname(u32 *p, char **namp, int *lenp)
-{
-	char		*name;
-	int		i;
-
-	if ((p = xdr_decode_string_inplace(p, namp, lenp, NFS3_MAXPATHLEN)) != NULL) {
-		for (i = 0, name = *namp; i < *lenp; i++, name++) {
-			if (*name == '\0')
-				return NULL;
-		}
-	}
-
-	return p;
-}
-
-static inline u32 *
 decode_sattr3(u32 *p, struct iattr *iap)
 {
 	u32	tmp;
