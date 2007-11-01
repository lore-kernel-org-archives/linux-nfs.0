From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] NFSD: Use unsigned length argument for
	decode_filename
Date: Thu, 01 Nov 2007 16:56:58 -0400
Message-ID: <20071101205658.5503.87424.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no, neilb@suse.de, bfields@fieldses.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Inh7K-0007oY-Tv
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:58:18 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Inh7O-0005fs-HB
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:58:24 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Clean up: file name lengths are unsigned on the wire, negative lengths
are not meaningful natively either.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfs3xdr.c |    4 ++--
 fs/nfsd/nfsxdr.c  |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 2d116d2..6fed3f9 100644
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
index 986f9b3..bc6fa20 100644
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


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
