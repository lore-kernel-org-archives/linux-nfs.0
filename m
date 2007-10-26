From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 27/27] NFS: Remove an unneeded check
	in	decode_compound_header_arg()
Date: Fri, 26 Oct 2007 13:33:01 -0400
Message-ID: <20071026173301.31475.98468.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT3p-0007LC-GV
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:33:29 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT3d-0000g0-Hd
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:33:18 -0700
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

Clean up:  The header tag length is unsigned, so checking that it is less
than zero is unnecessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/callback_xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 058ade7..97abd82 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -139,7 +139,7 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 	if (unlikely(status != 0))
 		return status;
 	/* We do not like overly long tags! */
-	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ-12 || hdr->taglen < 0) {
+	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ - 12) {
 		printk("NFSv4 CALLBACK %s: client sent tag of length %u\n",
 				__FUNCTION__, hdr->taglen);
 		return htonl(NFS4ERR_RESOURCE);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
