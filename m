From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] nfsv4: avoid checking nd.dentry in svc_export_parse after path_lookup on failure.
Date: Mon, 13 Mar 2006 14:43:06 -0500
Message-ID: <20060313194306.GB27685@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FIswq-0004GQ-Rv
	for nfs@lists.sourceforge.net; Mon, 13 Mar 2006 11:43:20 -0800
Received: from ra.tuxdriver.com ([24.172.12.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FIswo-0000ph-Bh
	for nfs@lists.sourceforge.net; Mon, 13 Mar 2006 11:43:20 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hey all-
	This problem was also reported to me today, along with this supplied
patch.  If path_return fails, there is no guarantee that the dentry pointer in
the passed nameidata strucutre will be valid, or for that matter, NULL.  As such
the if (nd.dentry) check at the out: label in svc_export_parse, may attempt to
do a path_release using an invalid nameidata strucutre, leading to an oops.
This patch provided to me skips the path_release code in the event that
path_lookup fails.

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 export.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)


diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 417ec02..4fd8b73 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -377,7 +377,7 @@ static int svc_export_parse(struct cache
 	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) <= 0)
 		goto out;
 	err = path_lookup(buf, 0, &nd);
-	if (err) goto out;
+	if (err) goto out_no_path;
 
 	exp.h.flags = 0;
 	exp.ex_client = dom;
@@ -425,6 +425,7 @@ static int svc_export_parse(struct cache
  out:
 	if (nd.dentry)
 		path_release(&nd);
+ out_no_path:
 	if (dom)
 		auth_domain_put(dom);
 	kfree(buf);
-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *gpg keyid: 1024D / 0x92A74FA1 - http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
