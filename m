From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 008/100] NFSD: Use unsigned length argument for decode_filename
Date: Fri, 25 Jan 2008 18:15:48 -0500
Message-ID: <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47315 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761861AbYAYXRX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:23 -0500
In-Reply-To: <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: file name lengths are unsigned on the wire, negative lengths
are not meaningful natively either.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-By: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs3xdr.c |    4 ++--
 fs/nfsd/nfsxdr.c  |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index f917fd2..c02b8d6 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -88,10 +88,10 @@ encode_fh(__be32 *p, struct svc_fh *fhp)
  * no slashes or null bytes.
  */
 static __be32 *
-decode_filename(__be32 *p, char **namp, int *lenp)
+decode_filename(__be32 *p, char **namp, unsigned int *lenp)
 {
 	char		*name;
-	int		i;
+	unsigned int	i;
 
 	if ((p = xdr_decode_string_inplace(p, namp, lenp, NFS3_MAXNAMLEN)) != NULL) {
 		for (i = 0, name = *namp; i < *lenp; i++, name++) {
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index b86e365..50bd618 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -62,10 +62,10 @@ encode_fh(__be32 *p, struct svc_fh *fhp)
  * no slashes or null bytes.
  */
 static __be32 *
-decode_filename(__be32 *p, char **namp, int *lenp)
+decode_filename(__be32 *p, char **namp, unsigned int *lenp)
 {
 	char		*name;
-	int		i;
+	unsigned int	i;
 
 	if ((p = xdr_decode_string_inplace(p, namp, lenp, NFS_MAXNAMLEN)) != NULL) {
 		for (i = 0, name = *namp; i < *lenp; i++, name++) {
-- 
1.5.4.rc2.60.gb2e62

