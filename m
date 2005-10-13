From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Cache invalidation bug in NFS v3 - trivially reproducible
Date: Thu, 13 Oct 2005 18:34:14 -0400
Message-ID: <1129242855.8435.32.camel@lade.trondhjem.org>
References: <m33bn8bet4.fsf@nammatj.nsc.liu.se>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-bH9UGqh3C0Y2Jitwr5pZ"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQBef-00041R-2E
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 15:34:29 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EQBee-00033e-AK
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 15:34:29 -0700
To: Jakob Oestergaard <jakob@unthought.net>,
	Leif Nixon <nixon@nsc.liu.se>
In-Reply-To: <m33bn8bet4.fsf@nammatj.nsc.liu.se>
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


--=-bH9UGqh3C0Y2Jitwr5pZ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

ty den 11.10.2005 Klokka 11:09 (+0200) skreiv Leif Nixon:
> Hi,
> 
> We have come across a bug where a NFS v3 client fails to invalidate
> its data cache for a file even though it realizes that the file
> attributes have changed. We have been able to recreate the bug on a
> range of kernel versions and different underlying file systems.
> 
> Here's a minimal way to reproduce the error (there seems to be some
> timing issues involved, but this has worked at least 90% of the time):
> 
>   NFS client n1                NFS client n2
> 
>   $ echo 1 > f
> 			       $ cat f
> 			       1
>   $ touch .
>   $ echo 2 > f
> 			       $ touch f
> 			       $ cat f
> 			       1
> 
> Now client n2 is stuck in a state where it uses its old cached data
> forever (or at least for several hours):
> 
>   NFS client n1                NFS client n2
> 
>   $ cat f
>   2
> 			       $ cat f
> 			       1
> 
> However, "stat f" gives the same output on both clients. "touch f" on
> either machine corrects the situation; n2 invalidates its data cache.
> 
> Interestingly, the second write to the file ("echo 2 > f") must
> not change the size of the file. If you do "echo foo > f" instead,
> the erroneous behaviour isn't triggered.
> 
> We have seen this on a range of kernels between 2.6.9 and 2.6.13.2 on
> Debian, CentOS, RHEL, Fedora and vanilla kernel.org, on both clients
> and server. We have *not* been able to reproduce the bug with Linux
> clients and a Solaris server, neither with Solaris clients and a Linux
> server. Underlying file systems have been ext3 and xfs (and Solaris
> ufs). We have tried varying mount options, but to no avail; the bug
> persists, even with "noac".

Does the attached patch help?

Cheers,
 Trond


--=-bH9UGqh3C0Y2Jitwr5pZ
Content-Disposition: inline; filename=linux-2.6.14-01-fix_attrcache.dif
Content-Type: text/plain; name=linux-2.6.14-01-fix_attrcache.dif; charset=UTF-8
Content-Transfer-Encoding: 7bit

NFS: Fix cache consistency races

 If the data cache has been marked as potentially invalid by nfs_refresh_inode,
 we should invalidate it rather than assume that changes are due to our own
 activity.

 Also ensure that we always start with a valid cache before declaring it
 to be protected by a delegation.

 Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 delegation.c |    4 ++++
 file.c       |    3 ++-
 inode.c      |    7 ++-----
 3 files changed, 8 insertions(+), 6 deletions(-)

Index: linux-2.6.14-rc4/fs/nfs/delegation.c
===================================================================
--- linux-2.6.14-rc4.orig/fs/nfs/delegation.c
+++ linux-2.6.14-rc4/fs/nfs/delegation.c
@@ -85,6 +85,10 @@ int nfs_inode_set_delegation(struct inod
 	struct nfs_delegation *delegation;
 	int status = 0;
 
+	/* Ensure we first revalidate the attributes and page cache! */
+	if ((nfsi->cache_validity & (NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_ATTR)))
+		__nfs_revalidate_inode(NFS_SERVER(inode), inode);
+
 	delegation = nfs_alloc_delegation();
 	if (delegation == NULL)
 		return -ENOMEM;
Index: linux-2.6.14-rc4/fs/nfs/file.c
===================================================================
--- linux-2.6.14-rc4.orig/fs/nfs/file.c
+++ linux-2.6.14-rc4/fs/nfs/file.c
@@ -137,7 +137,8 @@ static int nfs_revalidate_file(struct in
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int retval = 0;
 
-	if ((nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE) || nfs_attribute_timeout(inode))
+	if ((nfsi->cache_validity & (NFS_INO_REVAL_PAGECACHE|NFS_INO_INVALID_ATTR))
+			|| nfs_attribute_timeout(inode))
 		retval = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
 	nfs_revalidate_mapping(inode, filp->f_mapping);
 	return 0;
Index: linux-2.6.14-rc4/fs/nfs/inode.c
===================================================================
--- linux-2.6.14-rc4.orig/fs/nfs/inode.c
+++ linux-2.6.14-rc4/fs/nfs/inode.c
@@ -1226,10 +1226,6 @@ int nfs_refresh_inode(struct inode *inod
 	loff_t cur_size, new_isize;
 	int data_unstable;
 
-	/* Do we hold a delegation? */
-	if (nfs_have_delegation(inode, FMODE_READ))
-		return 0;
-
 	spin_lock(&inode->i_lock);
 
 	/* Are we in the process of updating data on the server? */
@@ -1350,7 +1346,8 @@ static int nfs_update_inode(struct inode
 	nfsi->read_cache_jiffies = fattr->timestamp;
 
 	/* Are we racing with known updates of the metadata on the server? */
-	data_unstable = ! nfs_verify_change_attribute(inode, verifier);
+	data_unstable = ! (nfs_verify_change_attribute(inode, verifier) ||
+		(nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE));
 
 	/* Check if our cached file size is stale */
  	new_isize = nfs_size_to_loff_t(fattr->size);

--=-bH9UGqh3C0Y2Jitwr5pZ--



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
