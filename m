From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: list of patches between 2.6.9 and 2.6.11-rc4
Date: Mon, 21 Feb 2005 21:16:59 -0500
Message-ID: <1109038619.22895.74.camel@lade.trondhjem.org>
References: <200502212335.25502.bernd-schubert@web.de>
	 <1109030592.22895.57.camel@lade.trondhjem.org>
	 <1109030738.22895.59.camel@lade.trondhjem.org>
	 <200502220200.13774.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-v2FR6xymqfUtaKrb0+jf"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D3Pbz-0002ZD-9l
	for nfs@lists.sourceforge.net; Mon, 21 Feb 2005 18:17:19 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D3Pbx-00023o-Ff
	for nfs@lists.sourceforge.net; Mon, 21 Feb 2005 18:17:19 -0800
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200502220200.13774.bernd-schubert@web.de>
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


--=-v2FR6xymqfUtaKrb0+jf
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

ty den 22.02.2005 Klokka 02:00 (+0100) skreiv Bernd Schubert:

> To make it easier to understand I isolated the code and testing it as own 
> program.
> 

Thanks. Does the following patch fix things for you?

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-v2FR6xymqfUtaKrb0+jf
Content-Disposition: inline; filename=linux-2.6.11-00-fix_nolock_getlk.dif
Content-Type: text/plain; name=linux-2.6.11-00-fix_nolock_getlk.dif; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

NFS: Further fixes for the -onolock case.

 Duh... GETLK returns F_UNLCK if and only if the lock could be placed.

 Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 file.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6.11-rc4/fs/nfs/file.c
===================================================================
--- linux-2.6.11-rc4.orig/fs/nfs/file.c
+++ linux-2.6.11-rc4/fs/nfs/file.c
@@ -320,10 +320,10 @@ static int do_getlk(struct file *filp, i
 		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
 	else {
 		struct file_lock *cfl = posix_test_lock(filp, fl);
-		if (cfl != NULL) {
+
+		fl->fl_type = F_UNLCK;
+		if (cfl != NULL)
 			memcpy(fl, cfl, sizeof(*fl));
-			fl->fl_type = F_UNLCK;
-		}
 	}
 	unlock_kernel();
 	return status;

--=-v2FR6xymqfUtaKrb0+jf--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
