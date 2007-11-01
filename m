From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/8] NFSD: Use unsigned length argument for
	decode_pathname
Date: Thu, 01 Nov 2007 16:57:14 -0400
Message-ID: <20071101205714.5503.55433.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no, neilb@suse.de, bfields@fieldses.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Inh79-0007nz-Di
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:58:07 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Inh7E-0002BT-Vw
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:58:13 -0700
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

Clean up: path name lengths are unsigned on the wire, negative lengths
are not meaningful natively either.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsxdr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index bc6fa20..1c16885 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -78,10 +78,10 @@ decode_filename(__be32 *p, char **namp, unsigned int *lenp)
 }
 
 static __be32 *
-decode_pathname(__be32 *p, char **namp, int *lenp)
+decode_pathname(__be32 *p, char **namp, unsigned int *lenp)
 {
 	char		*name;
-	int		i;
+	unsigned int	i;
 
 	if ((p = xdr_decode_string_inplace(p, namp, lenp, NFS_MAXPATHLEN)) != NULL) {
 		for (i = 0, name = *namp; i < *lenp; i++, name++) {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
