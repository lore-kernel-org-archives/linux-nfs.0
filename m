From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS problems across reboot
Date: Tue, 9 Apr 2002 09:10:09 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15538.9041.556777.656841@notabene.cse.unsw.edu.au>
References: <3CACA93C.5010304@blue-labs.org>
	<3CAD6A78.4205CD61@moving-picture.com>
	<3CAFCE8C.5030300@blue-labs.org>
	<15535.55222.401084.736426@notabene.cse.unsw.edu.au>
	<15535.56536.237108.198660@notabene.cse.unsw.edu.au>
	<3CB19E57.EB3F1441@moving-picture.com>
	<3CB1B5DC.36F6C520@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uiE9-00026F-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Apr 2002 16:07:09 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <james-p@moving-picture.com>) (for <nfs@lists.sourceforge.net>)
	By tone With Smtp ; Tue, 9 Apr 2002 09:06:55 +1000
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: message from James Pearson on Monday April 8
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

On Monday April 8, james-p@moving-picture.com wrote:
> Having a quick look through the nfs-utils source, as a test, I changed
> fendrmtabent() in nfs-utils-0.3.3/support/nfs/rmtab.c (used by mountd)
> to:
> 
> void
> fendrmtabent(FILE *fp)
> {
>         if (fp) {
>                 fflush(fp);
>                 fdatasync(fileno(fp));
>                 fclose(fp);
>         }
> }
> 
> 
> which appears to help - I can reset my test server immediately after a
> client mounts a disk - without getting the 'Permission denied' problems.
> 
> However, I have no idea if this is a 'sensible' thing to do ... if it is
> OK to do this, would using fdatasync() elsewhere be helpful?
> 

Yes, this is a perfectly sensible thing to do.
I have have just committed this change to the CVS, thanks.

NeilBrown

Index: ChangeLog
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/ChangeLog,v
retrieving revision 1.167
diff -u -r1.167 ChangeLog
--- ChangeLog	8 Apr 2002 21:42:17 -0000	1.167
+++ ChangeLog	8 Apr 2002 23:04:55 -0000
@@ -1,3 +1,9 @@
+2002-04-09  NeilBrown <neilb@cse.unsw.edu.au>
+	James Pearson <james-p@moving-picture.com>
+
+	* support/nfs/rmtab.c(fendrmtabent): sync changes to 
+	storage before returning, as this is critical state
+
 2002-04-08  H.J. Lu <hjl@lucon.org>
 
 	* etc/redhat/nfs: New.
Index: support/nfs/rmtab.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/support/nfs/rmtab.c,v
retrieving revision 1.2
diff -u -r1.2 rmtab.c
--- support/nfs/rmtab.c	1 Jun 2000 00:57:12 -0000	1.2
+++ support/nfs/rmtab.c	8 Apr 2002 23:04:56 -0000
@@ -114,8 +114,14 @@
 void
 fendrmtabent(FILE *fp)
 {
-	if (fp)
+	if (fp) {
+		/* If it was written to, we really want
+		 * to flush to disk before returning
+		 */
+		fflush(fp);
+		fdatasync(fileno(fp));
 		fclose(fp);
+	}
 }
 
 void


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

Sponsored by http://www.ThinkGeek.com/
