From: Fabio Olive Leite <fleite@redhat.com>
Subject: [PATCH] Stale NFS negative dentries caused by u32 jiffy wrap
Date: Tue, 24 Apr 2007 13:26:45 -0300
Message-ID: <20070424162645.GD10449@sleipnir.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgNqi-0003CK-Qj
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 09:26:40 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgNql-0004UU-3e
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 09:26:43 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3OGQgnW006392
	for <nfs@lists.sourceforge.net>; Tue, 24 Apr 2007 12:26:42 -0400
Received: from pobox-2.corp.redhat.com (pobox-2.corp.redhat.com [10.11.255.15])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3OGQgRE006805
	for <nfs@lists.sourceforge.net>; Tue, 24 Apr 2007 12:26:42 -0400
Received: from sleipnir.redhat.com (vpn-14-146.rdu.redhat.com [10.11.14.146])
	by pobox-2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id
	l3OGQcBS002197
	for <nfs@lists.sourceforge.net>; Tue, 24 Apr 2007 12:26:39 -0400
Received: from sleipnir.redhat.com (localhost.localdomain [127.0.0.1])
	by sleipnir.redhat.com (8.13.8/8.13.7) with ESMTP id l3OGQk3S014672
	for <nfs@lists.sourceforge.net>; Tue, 24 Apr 2007 13:26:47 -0300
Received: (from fleite@localhost)
	by sleipnir.redhat.com (8.13.8/8.13.8/Submit) id l3OGQkIT014669
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 13:26:46 -0300
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

Hi nfs@,

This patch solves an issue found on 32bit architectures, where jiffies
wrap every 50 days. Since many NFS structures are very long lived and
the code uses jiffies everywhere for timestamp comparisons, there are
many places where old data can be considered newer than something
fresh from the server. This one deals with negative dentries, and I'd
like to have it discussed in the list for sanity checking.

    In 32bit architectures the NFS code uses 32bit jiffies for structures
    that can very easily remain allocated for several u32 jiffy wraps,
    fooling tests made only with time_after[_eq]. One such case is for
    negative dentries, that given the correct timing can be considered valid
    even after changing their parent dir's attributes.
    =

    This patch addresses that by using another unused struct dentry field to
    store the higher part of the u64 jiffies. It has more comments than code
    because the issue is subtle, and is made conditional on long being a
    32bit quantity (64bit arches won't exhibit this behavior).

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index cd34697..a21fb87 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -644,11 +644,26 @@ static int nfs_check_verifier(struct inode *dir, stru=
ct dentry *dentry)
 	if ((NFS_I(dir)->cache_validity & NFS_INO_INVALID_ATTR) !=3D 0
 			|| nfs_attribute_timeout(dir))
 		return 0;
+#if (BITS_PER_LONG < 64)
+	/* In 32bit architectures, also check the cached higher bits of
+	 * jiffies64. NFS dentries can sit idle across two sign flips of
+	 * 32bit jiffies and fool time_after[_eq].
+	 */
+	if ((u32)(dentry->d_cookie) !=3D (u32)(get_jiffies_64() >> 32))
+		return 0;
+#endif
 	return nfs_verify_change_attribute(dir, (unsigned long)dentry->d_fsdata);
 }
 =

 static inline void nfs_set_verifier(struct dentry * dentry, unsigned long =
verf)
 {
+#if (BITS_PER_LONG < 64)
+	/* In 32bit architectures we can have problems with dentries that sit
+	 * idle during two flips of the MSB of the u32 jiffies, so we keep
+	 * track of the higher bits in d_cookie.
+	 */
+	(u32)(dentry->d_cookie) =3D (u32)(get_jiffies_64() >> 32);
+#endif
 	dentry->d_fsdata =3D (void *)verf;
 }
 =

@@ -755,8 +770,17 @@ static int nfs_lookup_revalidate(struct dentry * dentr=
y, struct nameidata *nd)
 	inode =3D dentry->d_inode;
 =

 	if (!inode) {
-		if (nfs_neg_need_reval(dir, dentry, nd))
+		if (nfs_neg_need_reval(dir, dentry, nd)) {
+#if (BITS_PER_LONG < 64)
+			dfprintk(VFS, "nfs_lookup_revalidate: expiring neg dentry for %s\n",
+				dentry->d_name.name);
+			dfprintk(VFS, "  d_cookie %08x high_jiffies %08x\n",
+				dentry->d_cookie, (u32)(get_jiffies_64() >> 32));
+			dfprintk(VFS, "  d_fsdata %08x cache_change_attribute %08x\n",
+				dentry->d_fsdata, NFS_I(dir)->cache_change_attribute);
+#endif
 			goto out_bad;
+		}
 		goto out_valid;
 	}
 =


Cheers,
F=E1bio
-- =

ex sed lex awk yacc, e pluribus unix, amem

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
