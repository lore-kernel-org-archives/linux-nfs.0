From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 11 - nfsd_exp_remove_null_check.patch
Date: Fri, 28 May 2004 14:37:30 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BTZ7a-0008ED-TQ@notabene.cse.unsw.edu.au>
References: <20040528143518.31534.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkWw-0006Nz-6j
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:00:34 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkWv-0002mx-Dc
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:00:33 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb) (ident-user Debian-exim)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 28 May 2004 14:37:31 +1000
To: Andrew Morton <akpm@osdl.org>
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


If ek = exp_find_key() is not an error, then ek->ek_export should be set; no
point in checking if it's NULL.



From: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

 ----------- Diffstat output ------------
 ./include/linux/nfsd/export.h |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff ./include/linux/nfsd/export.h~current~ ./include/linux/nfsd/export.h
--- ./include/linux/nfsd/export.h~current~	2004-05-28 14:20:00.000000000 +1000
+++ ./include/linux/nfsd/export.h	2004-05-28 14:20:16.000000000 +1000
@@ -124,8 +124,7 @@ exp_find(struct auth_domain *clp, int fs
 		int err;
 		exp_get(exp);
 		expkey_put(&ek->h, &svc_expkey_cache);
-		if (exp &&
-		    (err = cache_check(&svc_export_cache, &exp->h, reqp)))
+		if ((err = cache_check(&svc_export_cache, &exp->h, reqp)))
 			exp = ERR_PTR(err);
 		return exp;
 	} else


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
