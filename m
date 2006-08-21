From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] connectathon special test failure in recent kernels
Date: Sun, 20 Aug 2006 22:05:20 -0400
Message-ID: <44E914E0.5030907@RedHat.com>
References: <76bd70e30608081220q75c6c0f2v18e5ebb309b1c201@mail.gmail.com>	<1155079971.5731.22.camel@localhost>	<76bd70e30608081959g6a76d7bcr1d78323630462f7c@mail.gmail.com>
	<44E486F3.2020600@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000801020606040603010406"
Cc: linux-fsdevel@vger.kernel.org,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GEzAZ-0007Ii-H5
	for nfs@lists.sourceforge.net; Sun, 20 Aug 2006 19:05:39 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GEzAX-0007Yf-Oc
	for nfs@lists.sourceforge.net; Sun, 20 Aug 2006 19:05:40 -0700
To: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <44E486F3.2020600@RedHat.com>
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

This is a multi-part message in MIME format.
--------------000801020606040603010406
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:
> Well the patch in question is:
> 
> commit 1de3fc12ea085690547a54b6efa01c7348f1cebd
> tree ea865786120cfcefac563c54693fef8d3d718f10
> parent 128e6ced247cda88f96fa9f2e4ba8b2c4a681560
> author Trond Myklebust <Trond.Myklebust@netapp.com> Thu, 25 May 2006
> 09:40:44 -0400
> committer Trond Myklebust <Trond.Myklebust@netapp.com> Fri, 09 Jun 2006
> 17:34:03 -0400
> 
> NFS: Clean up and fix page zeroing when we have short reads

Attached is that patch that fixes the regression caused by
the above patch... I've tested with both the connectathon test suite
and the fsx test suite.

The patch is based on the 2.6.18-rc4 kernel tree.

steved.

--------------000801020606040603010406
Content-Type: text/x-patch;
 name="linux-2.6.18-rc4-nfs-holey.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.18-rc4-nfs-holey.patch"

The patch fixes a regression that causes the special tests
of the Connectation tests suite to fail. When a hole in a 
file is created (like the holey test does), the page will
be allocated but there will be nothing read into it. The
means the number of byte read from the server will be
zero (i.e.  data->res.count). In the case, the page
still has PageUptodate-ed which is what this patch
does.

Signed-off-by: Steve Dickson <steved@redhat.com>

--- linux-2.6.18-rc4/fs/nfs/read.c.orig	2006-08-20 13:49:22.000000000 -0400
+++ linux-2.6.18-rc4/fs/nfs/read.c	2006-08-20 13:58:59.000000000 -0400
@@ -476,13 +476,14 @@
 	unsigned int base = data->args.pgbase;
 	struct page **pages;
 
-	if (unlikely(count == 0))
-		return;
 	pages = &data->args.pages[base >> PAGE_CACHE_SHIFT];
 	base &= ~PAGE_CACHE_MASK;
 	count += base;
-	for (;count >= PAGE_CACHE_SIZE; count -= PAGE_CACHE_SIZE, pages++)
+	if (count == 0) 
 		SetPageUptodate(*pages);
+	else 
+		for (;count >= PAGE_CACHE_SIZE; count -= PAGE_CACHE_SIZE, pages++)
+			SetPageUptodate(*pages);
 	/*
 	 * Was this an eof or a short read? If the latter, don't mark the page
 	 * as uptodate yet.

--------------000801020606040603010406
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------000801020606040603010406
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000801020606040603010406--
