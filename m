From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 4] knfsd: Fix return value for writes to some
	files in 'nfsd' filesystem.
Date: Mon, 12 Feb 2007 16:49:41 +1100
Message-ID: <1070212054941.26775@suse.de>
References: <20070212164133.26352.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGU4x-0001sC-Ic
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 21:50:20 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HGU4x-0001oC-Ah
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 21:50:20 -0800
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


Most files in the 'nfsd' filesystem are transactional.
When you write, a reply is generated that can be read back
only on the same 'file'.
If the reply has zero length, the 'write' will incorrectly 
return a value of '0' instead of the length that was
written.  This causes 'rpc.nfsd' to give an annoying warning.

This patch fixes the test.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff .prev/fs/nfsd/nfsctl.c ./fs/nfsd/nfsctl.c
--- .prev/fs/nfsd/nfsctl.c	2007-02-12 16:39:20.000000000 +1100
+++ ./fs/nfsd/nfsctl.c	2007-02-12 16:39:33.000000000 +1100
@@ -123,7 +123,7 @@ static ssize_t nfsctl_transaction_write(
 		return PTR_ERR(data);
 
 	rv =  write_op[ino](file, data, size);
-	if (rv>0) {
+	if (rv >= 0) {
 		simple_transaction_set(file, rv);
 		rv = size;
 	}

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
