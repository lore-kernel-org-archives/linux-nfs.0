From: Neil Brown <neilb@suse.de>
Subject: [PATCH nfs-utils 3/3] Fix bug in auto-exporting subordinate
	mounts.
Date: Thu,  1 Nov 2007 16:26:57 +1100
Message-ID: <1193894817-20622-4-git-send-email-neilb@suse.de>
References: <1193894817-20622-1-git-send-email-neilb@suse.de>
	<1193894817-20622-2-git-send-email-neilb@suse.de>
	<1193894817-20622-3-git-send-email-neilb@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InSaL-0004HQ-2h
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 22:27:17 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1InSaQ-00047d-9c
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 22:27:22 -0700
In-Reply-To: <1193894817-20622-3-git-send-email-neilb@suse.de>
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

When mountd gets a request to export a mountpoint which is not
explicitly exported, but is below an export point that is flagged as
"crossmnt", it passes the wrong path name to the kernel for the
  "filehandle -> directory"
mapping.
This can badly confuse the NFS client, and is certainly wrong.

So use the correct path names.

Signed-off-by: Neil Brown <neilb@suse.de>
---
 utils/mountd/cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ce1a5a9..fd317cd 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -508,7 +508,7 @@ void nfsd_fh(FILE *f)
 	 */
 	qword_printint(f, 0x7fffffff);
 	if (found)
-		qword_print(f, found->e_path);
+		qword_print(f, found_path);
 	qword_eol(f);
  out:
 	free(found_path);
-- 
1.5.3.4


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
