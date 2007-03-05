From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Mon, 05 Mar 2007 15:35:27 -0500
Message-ID: <45EC7F0F.4090600@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090702020505070800050400"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOJuE-0006pv-G9
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 12:35:38 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOJuG-0002RK-7c
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 12:35:40 -0800
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
--------------090702020505070800050400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Over the last new months, I've been getting beaten up
about the fact the Fedora Core clients (FC5 and FC6)
no loner works with Tru64 server. The problem is
accessing mounted directories would fail with -ENOTDIR.
Similar to:

# ls /mnt/alpha/doc
/bin/ls: cannot open directory /mnt/alpha/doc: Not a directory

After months of floundering around looking at ethereal
traces and such, I actually was able to trace down a
Tru64 server to test against (thanks you very much HP!).

Low and behold... it turns not to be a Linux client
bug at all... but only Linux clients failed because
they seem to actually care what fsids are being returned.

The problem is this: Tru64 server exporting Advfs fileystems
return sign extend fsids in most but not all NFS procedures.

Meaning most fattrs returned by the server have a fsid of:
     fsid: 0xffffffff8419f8d5

but in some procs (like READDIRPLUS) the fsid is
     fsid: 0x000000008419f8d5

Which is _clearly_ wrong and does not happen with UFS
exports on the same server.

So its my contention that Tru64 has been broken forever
since only Linux clients fail, which started due to the
following patch that went into 2.6.12:

commit 55a975937d40cac582e981ddc8ed783b3dcc043c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 9 09:34:19 2006 -0400

   NFS: Ensure the client submounts, when it crosses a server mountpoint.

In this patch, fsids are compared to the first fsid that was received
during the mount ala:

@ -877,6 +883,11 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, 
struct
     if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS)
         && fattr->size <= NFS_LIMIT_READDIRPLUS)
            set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode)
+          /* Deal with crossing mountpoints */
+          if (!nfs_fsid_equal(&NFS_SB(sb)->fsid, &fattr->fsid)) {
+               inode->i_op = &nfs_mountpoint_inode_operations;
+               inode->i_fop = NULL;
+          }
(Although its a bit different in today kernel) setting i_op to
nfs_mountpoint_inode_operations causes lookups to fail with
ENOTDIR in __link_path_walk() due the following check:

     if (lookup_flags & LOOKUP_DIRECTORY) {
         err = -ENOTDIR;
         if (!inode->i_op || !inode->i_op->lookup)
             break;
     }
since i_op->lookup == NULL in the nfs_mountpoint_inode_operations
structure.

Now it must be the case that only Linux clients do this type of cross
mount checking since it appears other clients don't seem to
fail in a similar fashion (at least I have not heard of any).

So the question is what to do....

Now it's a well know fact that Tru64 is on its death bed which means
its in maintenance mode and the chances of it getting fixed are slim
to none... And one could argue, that since Linux clients once did
at one time worked with Tru64 servers and only the Linux client have
changed, the Linux client should make some effort to once again
interoperable with these types servers.  I personally don't agree with
this, one should never fix client for a broken server.... but... in my
world these type of problems are called regressions... So,
unfortunately, I need to do anything and everything (with reason) to
fix these types of problems...

So with that said... attached is that patch that does indeed
fix this problem. As the comments states, the received fsid
is signed extend and then is rechecked after the first
comparison fails.


I hopeful this will be accept...

steved.


--------------090702020505070800050400
Content-Type: text/x-patch;
 name="linux-2.6.18-nfs-Tru64-hack.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.18-nfs-Tru64-hack.patch"


Deal with broken Tru64 servers that send different fsids
(due to sign extensions) by sign extending the received
fsid and then doing the comparison.

Signed-off-by: Steve Dickson <steved@redhat.com>
Acked-by: Peter Staubach <staubach@redhat.com>

--- linux-2.6.18.i686/include/linux/nfs_xdr.h.orig	2007-03-05 11:13:35.000000000 -0500
+++ linux-2.6.18.i686/include/linux/nfs_xdr.h	2007-03-05 13:23:00.000000000 -0500
@@ -21,10 +21,26 @@ struct nfs_fsid {
 
 /*
  * Helper for checking equality between 2 fsids.
+ * Hack Alert:
+ * Due do broken Tru64 servers sending sign extend
+ * 32bit fsids in most but _not_ all procedures, 
+ * we need to be a bit clever as well as make an 
+ * assumption when comparing fsids.
+ *
+ * If the assumption can be made that the bottom 32 bits 
+ * of an fsids will *always* change when the fsid changes
+ * then it should be safe to only look at the bottom 32 bits
+ * during a 64bit comparison.
+ *
+ * So by sign extending the fsid we just received (i.e. b->major) 
+ * and then do the comparison, we are still going a 64bit
+ * comparison but only really "looking at" the bottom 32 bits.
  */
 static inline int nfs_fsid_equal(const struct nfs_fsid *a, const struct nfs_fsid *b)
 {
-	return a->major == b->major && a->minor == b->minor;
+	return (a->major == b->major || 
+	    a->major == (uint64_t)((int64_t)((int32_t)(b->major & 0xffffffff)))) &&
+		a->minor == b->minor;
 }
 
 struct nfs_fattr {

--------------090702020505070800050400
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------090702020505070800050400
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090702020505070800050400--
