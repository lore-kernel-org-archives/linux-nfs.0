From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 4] knfsd: Allow nfsd READDIR to return 64bit
	cookies
Date: Fri, 23 Mar 2007 11:46:48 +1100
Message-ID: <1070323004648.28943@suse.de>
References: <20070323114512.28822.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUXvk-00014i-O2
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 17:46:56 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HUXvl-0002AG-Ho
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 17:46:59 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


->readdir passes lofft_t offsets (used as nfs cookies) to
nfs3svc_encode_entry{,_plus}, but when they pass it on to
encode_entry it becomes an 'off_t', which isn't good.

So filesystems that returned 64bit offsets would lose.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs3xdr.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff .prev/fs/nfsd/nfs3xdr.c ./fs/nfsd/nfs3xdr.c
--- .prev/fs/nfsd/nfs3xdr.c	2007-03-23 11:13:15.000000000 +1100
+++ ./fs/nfsd/nfs3xdr.c	2007-03-23 11:13:15.000000000 +1100
@@ -887,8 +887,8 @@ compose_entry_fh(struct nfsd3_readdirres
 #define NFS3_ENTRY_BAGGAGE	(2 + 1 + 2 + 1)
 #define NFS3_ENTRYPLUS_BAGGAGE	(1 + 21 + 1 + (NFS3_FHSIZE >> 2))
 static int
-encode_entry(struct readdir_cd *ccd, const char *name,
-	     int namlen, off_t offset, ino_t ino, unsigned int d_type, int plus)
+encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
+	     loff_t offset, ino_t ino, unsigned int d_type, int plus)
 {
 	struct nfsd3_readdirres *cd = container_of(ccd, struct nfsd3_readdirres,
 		       					common);
@@ -908,7 +908,7 @@ encode_entry(struct readdir_cd *ccd, con
 			*cd->offset1 = htonl(offset64 & 0xffffffff);
 			cd->offset1 = NULL;
 		} else {
-			xdr_encode_hyper(cd->offset, (u64) offset);
+			xdr_encode_hyper(cd->offset, offset64);
 		}
 	}
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
