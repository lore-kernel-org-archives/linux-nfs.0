From: <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.0 -- nfs client runs 15x faster if client app runs as root.
Date: Thu, 8 Jan 2004 16:12:26 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <33640.68.42.103.198.1073574746.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="----=_20040108161226_73587"
Cc: <ewhiting@amis.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Aebps-0002gH-BI
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 07:12:36 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Aebpr-000119-PK
	for nfs@lists.sourceforge.net; Thu, 08 Jan 2004 07:12:35 -0800
To: <gael.roualland@oleane.net>
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

------=_20040108161226_73587
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit

På to , 08/01/2004 klokka 09:15, skreiv Gaël Roualland:
> Has the file exec permission set ?
> If yes this would look like an earlier problem that seems to still
> occur on 2.6.0.
> See http://marc.theaimsgroup.com/?l=linux-nfs&m=106966481311224 and
> http://marc.theaimsgroup.com/?l=linux-nfs&m=106981736010493.

Yeah. It turned out to be remove_suid() that was causing an empty
SETATTR to be sent after every write(). The solution is just to filter
out all requests that will result in empty SETATTRs. The server will
automatically do the honours w.r.t. the suid bit as soon as it receives
our write.

Cheers,
  Trond



------=_20040108161226_73587
Content-Type: text/html; name="untitled-1.2"
Content-Disposition: attachment; filename="untitled-1.2"

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.0.9">
</HEAD>
<BODY>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="1">P&#229; to , 08/01/2004 klokka 09:15, skreiv Ga&#235;l Roualland:
<BLOCKQUOTE TYPE=CITE>
<PRE><FONT COLOR="#737373"><I>Has the file exec permission set ?
If yes this would look like an earlier problem that seems to still occur
on 2.6.0.
See </FONT><A HREF="http://marc.theaimsgroup.com/?l=linux-nfs&m=106966481311224"><U>http://marc.theaimsgroup.com/?l=linux-nfs&amp;m=106966481311224</U></A><FONT COLOR="#737373"> and</FONT>
<A HREF="http://marc.theaimsgroup.com/?l=linux-nfs&m=106981736010493"><U>http://marc.theaimsgroup.com/?l=linux-nfs&amp;m=106981736010493</U></A><FONT COLOR="#737373">.</I></FONT></PRE>
</BLOCKQUOTE>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">Yeah. It turned out to be remove_suid() that was causing an empty SETATTR to be sent after every write(). The solution is just to filter<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">out all requests that will result in empty SETATTRs. The server will automatically do the honours w.r.t. the suid bit as soon as it receives our write.<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">Cheers,<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0">&nbsp; Trond<BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
<!--+GtkHTML:<DATA class="ClueFlow" key="orig" value="0"><BR>
</BODY>
</HTML>

------=_20040108161226_73587
Content-Type: text/plain; name="linux-2.6.1-01-fix_setattr.dif"
Content-Disposition: attachment; filename="linux-2.6.1-01-fix_setattr.dif"

 inode.c |    9 +++++++++
 1 files changed, 9 insertions(+)

diff -u --recursive --new-file --show-c-function linux-2.6.1-rc2/fs/nfs/inode.c linux-2.6.1-01-fix_setattr/fs/nfs/inode.c
--- linux-2.6.1-rc2/fs/nfs/inode.c	2004-01-07 22:57:48.000000000 -0500
+++ linux-2.6.1-01-fix_setattr/fs/nfs/inode.c	2004-01-08 00:22:49.000000000 -0500
@@ -791,6 +791,8 @@ out_no_inode:
 	goto out;
 }
 
+#define NFS_VALID_ATTRS (ATTR_MODE|ATTR_UID|ATTR_GID|ATTR_SIZE|ATTR_ATIME_SET|ATTR_MTIME_SET)
+
 int
 nfs_setattr(struct dentry *dentry, struct iattr *attr)
 {
@@ -798,6 +800,11 @@ nfs_setattr(struct dentry *dentry, struc
 	struct nfs_fattr fattr;
 	int error;
 
+	/* Optimization: if the end result is no change, don't RPC */
+	attr->ia_valid &= NFS_VALID_ATTRS;
+	if (attr->ia_valid == 0)
+		return 0;
+
 	lock_kernel();
 
 	/*
@@ -813,6 +820,8 @@ printk("nfs_setattr: revalidate failed, 
 
 	if (!S_ISREG(inode->i_mode)) {
 		attr->ia_valid &= ~ATTR_SIZE;
+		if (attr->ia_valid == 0)
+			goto out;
 	} else {
 		filemap_fdatawrite(inode->i_mapping);
 		error = nfs_wb_all(inode);


------=_20040108161226_73587--



-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
