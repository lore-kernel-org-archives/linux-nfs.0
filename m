From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 8] knfsd: nfsd4: fix NFSv4 filehandle size
	units confusion
Date: Thu, 21 Jun 2007 14:30:39 +1000
Message-ID: <1070621043039.1063@suse.de>
References: <20070621142604.727.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1EJi-0005lt-Th
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:30:47 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I1EJl-0008IM-Qi
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:30:50 -0700
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


From: "J. Bruce Fields" <bfields@fieldses.org>


NFS4_FHSIZE is measured in bytes, not 4-byte words, so much more space
than necessary is being allocated for struct nfs4_cb_recall.

I should have wondered why this structure was so much larger than it
needed to be!

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/nfsd/state.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff .prev/include/linux/nfsd/state.h ./include/linux/nfsd/state.h
--- .prev/include/linux/nfsd/state.h	2007-06-21 13:46:39.000000000 +1000
+++ ./include/linux/nfsd/state.h	2007-06-21 14:09:31.000000000 +1000
@@ -67,7 +67,7 @@ struct nfs4_cb_recall {
 	int			cbr_trunc;
 	stateid_t		cbr_stateid;
 	u32			cbr_fhlen;
-	u32			cbr_fhval[NFS4_FHSIZE];
+	char			cbr_fhval[NFS4_FHSIZE];
 	struct nfs4_delegation	*cbr_dp;
 };
 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
