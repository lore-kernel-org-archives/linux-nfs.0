From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 009 of 20] knfsd: nfsd: use ip-address-based
	domain in	secinfo case
Date: Tue, 10 Jul 2007 12:06:53 -0400
Message-ID: <20070710160653.GF17368@fieldses.org>
References: <20070710121949.12548.patches@notabene>
	<1070710022517.13262@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8IEr-0001uh-WB
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 09:06:59 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I8IEu-0002wv-9y
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 09:07:01 -0700
In-Reply-To: <1070710022517.13262@suse.de>
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

Could you fold the below into this patch?  Without this the server can
oops on attempts to access a filesystem not exported to the request's
source address!  Thanks to Olga Kornievskaia for the testing that found
this.

--b.

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 333e5cf..582b494 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1261,7 +1261,7 @@ gss:
 						&rqstp->rq_chandle);
 	if (PTR_ERR(gssexp) == -ENOENT)
 		return exp;
-	if (exp)
+	if (exp && !IS_ERR(exp))
 		exp_put(exp);
 	return gssexp;
 }
@@ -1291,7 +1291,7 @@ gss:
 						&rqstp->rq_chandle);
 	if (PTR_ERR(gssexp) == -ENOENT)
 		return exp;
-	if (exp)
+	if (exp && !IS_ERR(exp))
 		exp_put(exp);
 	return gssexp;
 }

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
