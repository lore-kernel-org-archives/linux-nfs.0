From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 22/38: SERVER: error codes in include/linux/nfsd/nfsd.h
Date: Tue, 13 Aug 2002 19:05:19 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131904590.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ekj3-0003HT-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 16:05:21 -0700
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


Add some new NFSv4-only error codes to include/linux/nfsd/nfsd.h

--- old/include/linux/nfsd/nfsd.h	Wed Jul 24 16:03:27 2002
+++ new/include/linux/nfsd/nfsd.h	Tue Jul 30 21:04:31 2002
@@ -170,6 +170,16 @@ void		nfsd_lockd_unexport(struct svc_cli
 #define	nfserr_serverfault	__constant_htonl(NFSERR_SERVERFAULT)
 #define	nfserr_badtype		__constant_htonl(NFSERR_BADTYPE)
 #define	nfserr_jukebox		__constant_htonl(NFSERR_JUKEBOX)
+#define nfserr_bad_cookie	__constant_htonl(NFSERR_BAD_COOKIE)
+#define nfserr_same		__constant_htonl(NFSERR_SAME)
+#define nfserr_clid_inuse	__constant_htonl(NFSERR_CLID_INUSE)
+#define	nfserr_resource		__constant_htonl(NFSERR_RESOURCE)
+#define nfserr_nofilehandle	__constant_htonl(NFSERR_NOFILEHANDLE)
+#define nfserr_minor_vers_mismatch	__constant_htonl(NFSERR_MINOR_VERS_MISMATCH)
+#define nfserr_symlink		__constant_htonl(NFSERR_SYMLINK)
+#define nfserr_not_same		__constant_htonl(NFSERR_NOT_SAME)
+#define nfserr_readdir_nospc	__constant_htonl(NFSERR_READDIR_NOSPC)
+#define nfserr_bad_xdr		__constant_htonl(NFSERR_BAD_XDR)

 /* error code for internal use - if a request fails due to
  * kmalloc failure, it gets dropped.  Client should resend eventually



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
