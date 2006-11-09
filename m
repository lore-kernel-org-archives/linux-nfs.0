From: Peter Staubach <staubach@redhat.com>
Subject: [PATCH] NFSv3 server side create modes
Date: Thu, 09 Nov 2006 15:10:10 -0500
Message-ID: <45538B22.9030507@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090703080406040006000505"
Cc: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GiGE9-00017p-1t
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 12:10:21 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GiGE9-0007fE-No
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 12:10:22 -0800
To: NFS List <nfs@lists.sourceforge.net>
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
--------------090703080406040006000505
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi.

The attached patch will address a problem where the NFSv3 server
incorrectly sets the mode of a newly created file.  This can occur
when the directory, which contains the newly created file, has a
default ACL on it which causes the mode to changed from that which
was specified in the over the wire attributes.

This problem results from some changes made to the NFSv3 server to
address an interoperability problem which occurred when the Solaris
NFS client was modified to treat file times as signed quantities
instead of unsigned quantities and to return errors to its
applications which it sees file times which appear to be negative.

The NFSv3 exclusive create mechanism works by the client sending
a 64 bit verifier in the over the wire CREATE request.  The Linux
server then breaks up this 64 bit verifier into two 32 bit quantities
and stores them as the initial values for the mtime and atime fields
for the newly created file.  If another CREATE request comes in, the
NFS server can then compare the mtime and atime fields against the
verifier in the new CREATE request in order to determine how to
correctly handle the request.  The server will either fail the
request with EEXIST or treat it as a retransmitted and proceed as
if it is the original request.  After the client successfully receives
a response to its exclusive CREATE request, it is responsible for
sending an over the wire SETATTR to set the mtime and atime fields
to the current time.

The problem with the Solaris client was that it was receiving the
intermediate attributes, ie. the ones that contained the verifier
that it itself had constructed, and based on these attributes,
was failing the exclusive create system call.  This is a bug in
the Solaris NFS client.  A workaround has been implemented in the
Solaris client to ensure that the sign bit in the 64 bit verifier
is not set.  The correct fix would have been to ensure that it just
didn't fail the CREATE call based on the intermediate attributes.

However, this situation was worked around in the Linux NFS server.
The solution was to ensure that the mtime and atime fields were
not negative by masking the two halves of the verifier.  The
leftover two bits were then stored in the mode field.

This then causes the problem which is being seen by NFSv3 clients.
The mode, from the initial attributes in the CREATE request, is
used and is then modified by the contents of the default ACL to
construct the mode of the new file.  The NFS server then changes
the mode to the mode contained in the initial attributes in the
CREATE request.  This can cause the mode to be different than it
should have been.  Thus, the mode comes out differently, based
on whether the file was created locally on the server or via NFS
from a client.

This problem was then worked around in the Linux NFS client by
having it send an NFS_ACL SETACL request making the default ACL
on the directory to be the access ACL on the newly created file.
This causes the mode to be set back to the correct value again.

This solution works for clients who know to send the extra
NFS_ACL call.  It does not work for any other clients, NFS_ACL
aware or not.  It also introduces a performance penalty due to
the extra over the wire operation.

The solution is to modify the Linux NFS server to just mask off
the two sign bits of the halves of the verifier which are stored
in the mtime and atime fields and forget about the two sign bits.
This leaves the mode computations alone and thus, the mode comes
out correctly.  This solution works for clients who don't know
to send the extra NFS_ACL request, clients who don't know anything
about NFS_ACL, and the updated clients who are sending the extra
NFS_ACL request.

This does introduce a slight danger if the client really was
depending upon these two bits to differentiate between different
exclusive CREATE requests.  However, given the algorithms used
by most clients, where one half is the current time on the
client and the other half is the pid of the process or the IP
address of the client, then this danger is minimal.

The attached patch removes the support for the use of the mode
field to store the two bits of the verifier.  It has been tested
using the Connectathon testsuite as well as the test scenario
described in the Red Hat bugzilla:

     https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=128616

    Thanx...

       ps

Signed-off-by: Peter Staubach <staubach@redhat.com>

--------------090703080406040006000505
Content-Type: text/plain;
 name="nfsd_create_v3.devel"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfsd_create_v3.devel"

--- linux-2.6.18.i686/fs/nfsd/vfs.c.org
+++ linux-2.6.18.i686/fs/nfsd/vfs.c
@@ -1244,7 +1244,6 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 	__be32		err;
 	int		host_err;
 	__u32		v_mtime=0, v_atime=0;
-	int		v_mode=0;
 
 	err = nfserr_perm;
 	if (!flen)
@@ -1281,16 +1280,11 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 		goto out;
 
 	if (createmode == NFS3_CREATE_EXCLUSIVE) {
-		/* while the verifier would fit in mtime+atime,
-		 * solaris7 gets confused (bugid 4218508) if these have
-		 * the high bit set, so we use the mode as well
+		/* solaris7 gets confused (bugid 4218508) if these have
+		 * the high bit set, so just clear the high bits.
 		 */
 		v_mtime = verifier[0]&0x7fffffff;
 		v_atime = verifier[1]&0x7fffffff;
-		v_mode  = S_IFREG
-			| ((verifier[0]&0x80000000) >> (32-7)) /* u+x */
-			| ((verifier[1]&0x80000000) >> (32-9)) /* u+r */
-			;
 	}
 	
 	if (dchild->d_inode) {
@@ -1318,7 +1312,6 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 		case NFS3_CREATE_EXCLUSIVE:
 			if (   dchild->d_inode->i_mtime.tv_sec == v_mtime
 			    && dchild->d_inode->i_atime.tv_sec == v_atime
-			    && dchild->d_inode->i_mode  == v_mode
 			    && dchild->d_inode->i_size  == 0 )
 				break;
 			 /* fallthru */
@@ -1338,26 +1331,22 @@ nfsd_create_v3(struct svc_rqst *rqstp, s
 	}
 
 	if (createmode == NFS3_CREATE_EXCLUSIVE) {
-		/* Cram the verifier into atime/mtime/mode */
+		/* Cram the verifier into atime/mtime */
 		iap->ia_valid = ATTR_MTIME|ATTR_ATIME
-			| ATTR_MTIME_SET|ATTR_ATIME_SET
-			| ATTR_MODE;
+			| ATTR_MTIME_SET|ATTR_ATIME_SET;
 		/* XXX someone who knows this better please fix it for nsec */ 
 		iap->ia_mtime.tv_sec = v_mtime;
 		iap->ia_atime.tv_sec = v_atime;
 		iap->ia_mtime.tv_nsec = 0;
 		iap->ia_atime.tv_nsec = 0;
-		iap->ia_mode  = v_mode;
 	}
 
 	/* Set file attributes.
-	 * Mode has already been set but we might need to reset it
-	 * for CREATE_EXCLUSIVE
 	 * Irix appears to send along the gid when it tries to
 	 * implement setgid directories via NFS. Clear out all that cruft.
 	 */
  set_attr:
-	if ((iap->ia_valid &= ~(ATTR_UID|ATTR_GID)) != 0) {
+	if ((iap->ia_valid &= ~(ATTR_UID|ATTR_GID|ATTR_MODE)) != 0) {
  		__be32 err2 = nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
 		if (err2)
 			err = err2;

--------------090703080406040006000505
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------090703080406040006000505
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090703080406040006000505--
