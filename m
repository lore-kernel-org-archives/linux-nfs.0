From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 26/38: SERVER: new routine fh_dup2()
Date: Wed, 14 Aug 2002 16:49:08 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141648380.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f54o-00071b-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:49:10 -0700
To: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Define fh_dup2(), which copies a _verified_ filehandle, taking care
of refcounts accordingly.  (This will be used by RESTOREFH/SAVEFH and
a few other places.)

--- old/include/linux/nfsd/nfsfh.h	Thu Aug  1 16:16:29 2002
+++ new/include/linux/nfsd/nfsfh.h	Sun Aug 11 22:56:12 2002
@@ -238,6 +238,14 @@ fh_copy(struct svc_fh *dst, struct svc_f
 	return dst;
 }

+static __inline__ void
+fh_dup2(struct svc_fh *dst, struct svc_fh *src)
+{
+	fh_put(dst);
+	dget(src->fh_dentry);
+	*dst = *src;
+}
+
 static __inline__ struct svc_fh *
 fh_init(struct svc_fh *fhp, int maxsize)
 {



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
