From: Steve Dickson <SteveD@redhat.com>
Subject: NFS cache consistancy appears to be broken...
Date: Tue, 29 Nov 2005 21:29:20 -0500
Message-ID: <438D0E80.2020905@RedHat.com>
References: <200510281607.j9SG7Tll024133@hera.kernel.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080001010602040408050202"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EhHiz-0006m8-9u
	for nfs@lists.sourceforge.net; Tue, 29 Nov 2005 18:29:37 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EhHix-0003HU-TC
	for nfs@lists.sourceforge.net; Tue, 29 Nov 2005 18:29:37 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <200510281607.j9SG7Tll024133@hera.kernel.org>
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

This is a multi-part message in MIME format.
--------------080001010602040408050202
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hey Trond,

The attached patch seems to break cache consistence in a big way....
Doing the following:
1. On server:
$ mkdir ~/t
$ echo Hello > ~/t/tmp

2. On client, wait for a string to appear in this file:
$ until grep -q foo t/tmp ; do echo -n . ; sleep 1 ; done

3. On server, create a *new* file with the same name containing that string:
$ mv ~/t/tmp ~/t/tmp.old; echo foo > ~/t/tmp

will shows how the client will never (and I mean never ;-) ) see
the updated file. I reverted this patch and everything started
work as expected... so it appears using a jiffy-based cache
verifiers may not be such a good idea....

Note: I am using 2.6.15-rc2 kernel.

steved.




--------------080001010602040408050202
Content-Type: text/plain;
 name="NFS_cache_change_attribute_jiffy_based.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="NFS_cache_change_attribute_jiffy_based.txt"

Subject:
NFS: Convert cache_change_attribute into a jiffy-based value
From:
Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Date:
Fri, 28 Oct 2005 09:07:29 -0700
To:
git-commits-head@vger.kernel.org

tree 1f3d5db26462d02ecca383794b3061a5eae8d9cc
parent 0e574af1be5f569a5d7f2800333b0bfb358a5e34
author Trond Myklebust <Trond.Myklebust@netapp.com> Fri, 28 Oct 2005 06:12:38 -0400
committer Trond Myklebust <Trond.Myklebust@netapp.com> Fri, 28 Oct 2005 06:12:38 -0400

NFS: Convert cache_change_attribute into a jiffy-based value

 Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

 fs/nfs/inode.c         |    8 ++++----
 include/linux/nfs_fs.h |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1135,7 +1135,7 @@ __nfs_revalidate_inode(struct nfs_server
 	 * We may need to keep the attributes marked as invalid if
 	 * we raced with nfs_end_attr_update().
 	 */
-	if (verifier == nfsi->cache_change_attribute)
+	if (time_after_eq(verifier, nfsi->cache_change_attribute))
 		nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ATIME);
 	spin_unlock(&inode->i_lock);
 
@@ -1202,7 +1202,7 @@ void nfs_revalidate_mapping(struct inode
 		if (S_ISDIR(inode->i_mode)) {
 			memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
 			/* This ensures we revalidate child dentries */
-			nfsi->cache_change_attribute++;
+			nfsi->cache_change_attribute = jiffies;
 		}
 		spin_unlock(&inode->i_lock);
 
@@ -1242,7 +1242,7 @@ void nfs_end_data_update(struct inode *i
 			nfsi->cache_validity |= NFS_INO_INVALID_DATA;
 		spin_unlock(&inode->i_lock);
 	}
-	nfsi->cache_change_attribute ++;
+	nfsi->cache_change_attribute = jiffies;
 	atomic_dec(&nfsi->data_updates);
 }
 
@@ -1391,7 +1391,7 @@ static int nfs_update_inode(struct inode
 		/* Do we perhaps have any outstanding writes? */
 		if (nfsi->npages == 0) {
 			/* No, but did we race with nfs_end_data_update()? */
-			if (verifier  ==  nfsi->cache_change_attribute) {
+			if (time_after_eq(verifier,  nfsi->cache_change_attribute)) {
 				inode->i_size = new_isize;
 				invalid |= NFS_INO_INVALID_DATA;
 			}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -280,7 +280,7 @@ static inline long nfs_save_change_attri
 static inline int nfs_verify_change_attribute(struct inode *inode, unsigned long chattr)
 {
 	return !nfs_caches_unstable(inode)
-		&& chattr == NFS_I(inode)->cache_change_attribute;
+		&& time_after_eq(chattr, NFS_I(inode)->cache_change_attribute);
 }
 
 /*
-
To unsubscribe from this list: send the line "unsubscribe git-commits-head" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

--------------080001010602040408050202--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
