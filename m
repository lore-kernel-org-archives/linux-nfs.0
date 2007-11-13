From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: [PATCH] NFSD: fix wrong mnt_writer count in rename (MMOTM
	2007-11-10-19-05)
Date: Mon, 12 Nov 2007 20:15:11 -0500
Message-ID: <200711130115.lAD1FBfG015626@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: bfields@fieldses.org, Dave Hansen <haveblue@us.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IrkQ4-0003VG-7I
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 17:18:28 -0800
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IrkQ7-00042C-PQ
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 17:18:30 -0800
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

NFSD forgets to call mnt_drop_write after a successful rename.  Here's a
fix.  (Ah, the curse of a stackable file system developer: you have to debug
everyone else's too. :-)

One thing I wasn't sure is whether I could move the mnt_drop_write line a
little above, just after the call to vfs_rename.  If we can drop the ref
earlier, it could improve scalability/performance just a bit, no? (i.e.,
what are the ramifications of holding on to this mnt writer ref longer than
needed?)

Cheers,
Erez.



Signed-off-by: Erez Zadok <ezk@cs.sunysb.edu>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7dfde65..47aec49 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1693,6 +1693,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 		if (!host_err)
 			host_err = nfsd_sync_dir(fdentry);
 	}
+	mnt_drop_write(ffhp->fh_export->ex_path.mnt);
 
  out_dput_new:
 	dput(ndentry);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
