From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Do not cache NFSv2 readdir replies
Date: Mon, 7 Feb 2005 14:15:47 +0100
Message-ID: <20050207131547.GE5275@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="LZvS9be/3tNcYl/X"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cy8k8-0005Wv-7v
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 05:15:56 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1Cy8k6-0008HE-Ms
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 05:15:56 -0800
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id AD5AB14271E3
	for <nfs@lists.sourceforge.net>; Mon,  7 Feb 2005 14:15:47 +0100 (CET)
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


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

we're currently caching NFSv2 readdir replies, even though the code uses
xdr pages to store the directories entries. As a result, we only cache
the NFS status and none of the entries, the cookie or the EOF flag.
Retransmitted NFSv2 readdir calls will see garbage replies.

(In case you're wondering why, I just had the pleasure of diagnosing a
rather interesting NFS problem with a POS system that used a homebrew
NFSv2 client that reused XIDs quite liberally and fell over when they
ran into this. Hard to believe, but there are NFS clients more bizarre
than zOS :-)

Please find attached the patch against 2.6.11-rc

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=nfsd-no-cache-readdir

From: Olaf Kirch <okir@suse.de>
Subject: Do not cache NFSv2 readdir replies

nfsd would put incomplete readdir replies in the reply cache,
so that incomplete replies are returned in response to retransmitted
READDIR calls.

Signed-off-by: okir@suse.de

Index: linux-2.6.5/fs/nfsd/nfsproc.c
===================================================================
--- linux-2.6.5.orig/fs/nfsd/nfsproc.c	2005-01-27 17:32:42.000000000 +0100
+++ linux-2.6.5/fs/nfsd/nfsproc.c	2005-02-07 13:41:36.000000000 +0100
@@ -539,7 +539,7 @@ static struct svc_procedure		nfsd_proced
   PROC(symlink,	 symlinkargs,	void,		none,		RC_REPLSTAT, ST),
   PROC(mkdir,	 createargs,	diropres,	fhandle,	RC_REPLBUFF, ST+FH+AT),
   PROC(rmdir,	 diropargs,	void,		none,		RC_REPLSTAT, ST),
-  PROC(readdir,	 readdirargs,	readdirres,	none,		RC_REPLBUFF, 0),
+  PROC(readdir,	 readdirargs,	readdirres,	none,		RC_NOCACHE, 0),
   PROC(statfs,	 fhandle,	statfsres,	none,		RC_NOCACHE, ST+5),
 };
 

--LZvS9be/3tNcYl/X--


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
