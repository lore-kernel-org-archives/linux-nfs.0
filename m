From: Peter Staubach <staubach@redhat.com>
Subject: [PATCH] NFS server subtree_check returns dubious value
Date: Thu, 27 Apr 2006 14:45:56 -0400
Message-ID: <44511164.4080303@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070204080600050601050005"
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
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
--------------070204080600050601050005
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi.

Attached is a patch which addresses a problem found when a Linux NFS server
uses the "subtree_check" export option.

The "subtree_check" NFS export option was designed to prohibit a client from
using a file handle for which it should not have permission.  The algorithm
used is to ensure that the entire path to the file being referenced is
accessible to the user attempting to use the file handle.  If some part of
the path is not accessible, then the operation is aborted and the 
appropriate
version of ESTALE is returned to the NFS client.

The error, ESTALE, is unfortunate in that it causes NFS clients to make
certain assumptions about the continued existence of the file.  They assume
that the file no longer exists and refuse to attempt to access it again.
In this case, the file really does exist, but access was denied by the
server for a particular user.

A better error to return would be an EACCES sort of error.  This would
inform the client that the particular operation that it was attempting
was not allowed, without the nasty side effects of the ESTALE error.

    Thanx...

       ps

Signed-off-by: Peter Staubach <staubach@redhat.com>

--------------070204080600050601050005
Content-Type: text/plain;
 name="devel.today"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="devel.today"

--- linux-2.6.16.x86_64/fs/exportfs/expfs.c.org
+++ linux-2.6.16.x86_64/fs/exportfs/expfs.c
@@ -102,7 +102,7 @@ find_exported_dentry(struct super_block 
 		if (acceptable(context, result))
 			return result;
 		if (S_ISDIR(result->d_inode->i_mode)) {
-			/* there is no other dentry, so fail */
+			err = -EACCES;
 			goto err_result;
 		}
 

--------------070204080600050601050005--


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
