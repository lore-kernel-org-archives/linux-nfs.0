From: Olaf Kirch <okir@suse.de>
Subject: Re: Marking inodes as stale can be wrong
Date: Fri, 30 Apr 2004 10:34:45 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040430083445.GB29672@suse.de>
References: <20040429144012.GA15361@suse.de> <1083257096.3686.27.camel@lade.trondhjem.org> <20040429165802.GA18748@suse.de> <1083258570.3686.38.camel@lade.trondhjem.org> <20040429235018.GC4843@sgi.com> <1083285820.14910.77.camel@lade.trondhjem.org> <4091B12C.FBB1FF34@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PEIAKu/WMn1b1Hv9"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJTTs-0006QS-B0
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 01:34:48 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BJTTr-0004OW-T1
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 01:34:48 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <4091B12C.FBB1FF34@melbourne.sgi.com>
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


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Here's a minimalistic fix. It may be better to change nfsd_acceptable
to return 0 on success and negative error code on error, but I'm not
sure this is really needed as long as the only acceptance test
in nfsd_acceptable is the subtree check.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="subtreecheck-nostale.patch"

--- linux-2.6.5/fs/exportfs/expfs.c.nostale	2004-04-04 05:37:44.000000000 +0200
+++ linux-2.6.5/fs/exportfs/expfs.c	2004-04-30 10:32:19.000000000 +0200
@@ -278,7 +278,15 @@
 
 	/* drat - I just cannot find anything acceptable */
 	dput(result);
-	return ERR_PTR(-ESTALE);
+
+	/* Originally, we would return ESTALE here. This is not
+	 * correct, however, as the file handle is valid; it just
+	 * failed our acceptance test.
+	 * This will lead to unexpected results in the client if
+	 * there are two processes accessing the same file; one
+	 * with proper permissions and one without.
+	 */
+	return ERR_PTR(-EACCES);
 
  err_target:
 	dput(target_dir);

--PEIAKu/WMn1b1Hv9--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
