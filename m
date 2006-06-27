From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 14] knfsd: Fixing missing 'expkey' support for
	fsid type 3
Date: Tue, 27 Jun 2006 17:19:45 +1000
Message-ID: <1060627071945.26612@suse.de>
References: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Filz <ffilzlnx@us.ibm.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7rZ-0006Er-HO
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:19:57 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7rZ-00079F-5I
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:19:57 -0700
To: Andrew Morton <akpm@osdl.org>
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


From: Frank Filz <ffilzlnx@us.ibm.com>

Type '3' is used for the fsid in filehandles when the device number
of the device holding the filesystem has more than 8 bits in either
major or minor.
Unfortunately expkey_parse doesn't recognise type 3.  Fix this.

(Slighty modified from Frank's original)

Signed-Off-By: Frank Filz <ffilzlnx@us.ibm.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2006-06-27 12:15:18.000000000 +1000
+++ ./fs/nfsd/export.c	2006-06-27 12:15:55.000000000 +1000
@@ -126,7 +126,7 @@ static int expkey_parse(struct cache_det
 	if (*ep)
 		goto out;
 	dprintk("found fsidtype %d\n", fsidtype);
-	if (fsidtype > 2)
+	if (key_len(fsidtype)==0) /* invalid type */
 		goto out;
 	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) <= 0)
 		goto out;

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
