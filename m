From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 10/15] knfsd: Validate filehandle type in fsid_source
Date: Mon, 27 Aug 2007 16:22:51 -0400
Message-ID: <11882461773221-git-send-email-bfields@fieldses.org>
References: <11882461763072-git-send-email-bfields@fieldses.org>
	<1188246176681-git-send-email-bfields@fieldses.org>
	<1188246176897-git-send-email-bfields@fieldses.org>
	<1188246177833-git-send-email-bfields@fieldses.org>
	<11882461773576-git-send-email-bfields@fieldses.org>
	<11882461771774-git-send-email-bfields@fieldses.org>
	<1188246177195-git-send-email-bfields@fieldses.org>
	<11882461773396-git-send-email-bfields@fieldses.org>
	<1188246177259-git-send-email-bfields@fieldses.org>
	<1188246177192-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"Luiz Fernando N. Capitulino" <lcapitulino@gmail.com>,
	nfs@lists.sourceforge.net, "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPl72-0004jb-6i
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:04 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPl74-0003Pj-SI
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:08 -0700
In-Reply-To: <1188246177192-git-send-email-bfields@fieldses.org>
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

From: Neil Brown <neilb@suse.de>

fsid_source decided where to get the 'fsid' number to
return for a GETATTR based on the type of filehandle.
It can be from the device, from the fsid, or from the
UUID.

It is possible for the filehandle to be inconsistent
with the export information, so make sure the export information
actually has the info implied by the value returned by
fsid_source.

Signed-off-by: Neil Brown <neilb@suse.de>
Cc: "Luiz Fernando N. Capitulino" <lcapitulino@gmail.com>
Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/nfsfh.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 0eb464a..7011d62 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -566,13 +566,23 @@ enum fsid_source fsid_source(struct svc_fh *fhp)
 	case FSID_DEV:
 	case FSID_ENCODE_DEV:
 	case FSID_MAJOR_MINOR:
-		return FSIDSOURCE_DEV;
+		if (fhp->fh_export->ex_dentry->d_inode->i_sb->s_type->fs_flags
+		    & FS_REQUIRES_DEV)
+			return FSIDSOURCE_DEV;
+		break;
 	case FSID_NUM:
-		return FSIDSOURCE_FSID;
-	default:
 		if (fhp->fh_export->ex_flags & NFSEXP_FSID)
 			return FSIDSOURCE_FSID;
-		else
-			return FSIDSOURCE_UUID;
+		break;
+	default:
+		break;
 	}
+	/* either a UUID type filehandle, or the filehandle doesn't
+	 * match the export.
+	 */
+	if (fhp->fh_export->ex_flags & NFSEXP_FSID)
+		return FSIDSOURCE_FSID;
+	if (fhp->fh_export->ex_uuid)
+		return FSIDSOURCE_UUID;
+	return FSIDSOURCE_DEV;
 }
-- 
1.5.3.rc5.19.g0734d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
