From: Olaf Kirch <okir@suse.de>
Subject: Re: #255931 NFS fh_verify causes lost output
Date: Thu, 19 Aug 2004 10:30:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040819083014.GA4739@suse.de>
References: <20040818210041.A2223@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Dxnq1zWXvFF0Q93v"
Cc: nfs@lists.sourceforge.net, Paul Szabo <psz@maths.usyd.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BxiJe-0004Jc-Qt
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 01:30:34 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BxiJd-0006Yc-HP
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 01:30:34 -0700
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20040818210041.A2223@infradead.org>
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


--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Aug 18, 2004 at 09:00:41PM +0100, Christoph Hellwig wrote:
> We have the following report from Paul Szabo in the Debian bugtracking system,
> any chance someone could look into it?  The RedHat bugzilla reference is quite
> interesting aswell.

I reported exactly this problem here a few months ago; the fix I proposed
was to return EACCES rather than ESTALE in find_exported_dentry()
(fs/exportfs/expfs.c). Not sure what happened to this patch; seems it
fell through the cracks.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--Dxnq1zWXvFF0Q93v
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

--Dxnq1zWXvFF0Q93v--


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
