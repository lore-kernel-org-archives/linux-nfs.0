From: <trond.myklebust@fys.uio.no>
Subject: Re: NFS client write performance issue ... thoughts?
Date: Fri, 9 Jan 2004 22:30:24 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <32997.141.211.133.197.1073683824.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="----=_20040109223024_89784"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Af4DB-0007mz-3Z
	for nfs@lists.sourceforge.net; Fri, 09 Jan 2004 13:30:33 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Af4DA-0000ZL-Do
	for nfs@lists.sourceforge.net; Fri, 09 Jan 2004 13:30:32 -0800
To: <pausmith@nortelnetworks.com>
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

------=_20040109223024_89784
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit

På to , 08/01/2004 klokka 12:47, skreiv Paul Smith:
> Do you know when those accounting errors were fixed?

In the official kernels? 2.4.22, I believe... However there are patches
going back to 2.4.19...

See http://www.fys.uio.no/~trondmy/src/Linux-2.4.x/2.4.19/

The main patch you want will be linux-2.4.19-14-call_start.dif

>
> ClearCase implements its own virtual filesystem type, and so is
> heavily tied to specific kernels (the kernel module is not open source
> of course :( ).  We basically can move to any kernel that has been
> released as part of an official Red Hat release (say, 2.4.20-8 from
> RH9 would work), but no other kernels can be used (the ClearCase
> kernel module has checks on the sizes of various kernel structures and
> won't load if they're not what it thinks they should be--and since
> it's a filesystem it cares deeply about structures that have tended to
> change a lot.  It won't even work with vanilla kernel.org kernels of
> the same version.)

Blech...

Note: if you want to try implementing a scheme like what you propose,
then the simplest way to do it, would be to add something like the
following patch. It disables nfs_strategy(), then causes
nfs_updatepage() to extend the request size if it sees that we're not
using byte-range locking, and the complete page is in cache.

Cheers,
  Trond



------=_20040109223024_89784
Content-Type: text/html; name="untitled-1.2"
Content-Disposition: attachment; filename="untitled-1.2"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.0.9">
</HEAD>
<BODY>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="1">P&#229; to , 08/01/2004 klokka 12:47, skreiv Paul Smith:
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>Do you know when those accounting errors were fixed?</I></FONT></PRE>
</BLOCKQUOTE>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">In the official kernels? 2.4.22, I believe... However there are patches going back to 2.4.19...<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">See <A HREF="http://www.fys.uio.no/~trondmy/src/Linux-2.4.x/2.4.19">http://www.fys.uio.no/~trondmy/src/Linux-2.4.x/2.4.19</A>/<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">The main patch you want will be linux-2.4.19-14-call_start.dif<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>
ClearCase implements its own virtual filesystem type, and so is heavily
tied to specific kernels (the kernel module is not open source of course
:( ).  We basically can move to any kernel that has been released as
part of an official Red Hat release (say, 2.4.20-8 from RH9 would work),
but no other kernels can be used (the ClearCase kernel module has checks
on the sizes of various kernel structures and won't load if they're not
what it thinks they should be--and since it's a filesystem it cares
deeply about structures that have tended to change a lot.  It won't even
work with vanilla kernel.org kernels of the same version.)</I></FONT></PRE>
</BLOCKQUOTE>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">Blech...<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">Note: if you want to try implementing a scheme like what you propose, then the simplest way to do it, would be to add something like the following patch. It disables nfs_strategy(), then causes nfs_updatepage() to extend the request size if it sees that we're not using byte-range locking, and the complete page is in cache.<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">Cheers,<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">&nbsp; Trond<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
</BODY>
</HTML>

------=_20040109223024_89784
Content-Type: text/plain; name="gnurr.dif"
Content-Disposition: attachment; filename="gnurr.dif"

--- linux-2.4.23-rc1/fs/nfs/write.c.orig	2003-11-16 19:24:23.000000000 -0500
+++ linux-2.4.23-rc1/fs/nfs/write.c	2004-01-09 16:25:18.000000000 -0500
@@ -746,6 +746,7 @@ nfs_update_request(struct file* file, st
 static void
 nfs_strategy(struct inode *inode)
 {
+#if 0
 	unsigned int	dirty, wpages;
 
 	dirty  = inode->u.nfs_i.ndirty;
@@ -760,6 +761,7 @@ nfs_strategy(struct inode *inode)
 	if (dirty >= NFS_STRATEGY_PAGES * wpages)
 		nfs_flush_file(inode, NULL, 0, 0, 0);
 #endif
+#endif
 }
 
 int
@@ -849,8 +851,19 @@ nfs_updatepage(struct file *file, struct
 		SetPageUptodate(page);
 		nfs_unlock_request(req);
 		nfs_strategy(inode);
-	} else
+	} else {
+		/* If we are not locking, and the page is up to date,
+		 * we may write out the entire page for efficiency.
+		 */
+		if (Page_Uptodate(page) && inode->i_flock == 0) {
+			req->wb_offset = 0;
+			if (page->index < (inode->i_size >> PAGE_CACHE_SHIFT))
+				req->wb_bytes = PAGE_CACHE_SIZE;
+			else
+				req->wb_bytes = inode->i_size & PAGE_CACHE_MASK;
+		}
 		nfs_unlock_request(req);
+	}
 done:
         dprintk("NFS:      nfs_updatepage returns %d (isize %Ld)\n",
                                                 status, (long long)inode->i_size);


------=_20040109223024_89784--



-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
