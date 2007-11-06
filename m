From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/15] nfs(5) man page: Add new SECURITY
	CONSIDERATIONS section
Date: Mon, 05 Nov 2007 20:03:43 -0500
Message-ID: <20071106010343.5037.32765.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCr2-0004fr-QR
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:44 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCr8-0004V7-AI
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:50 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Add a section to nfs(5) that discusses the security features available in
the Linux NFS client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |  117 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 117 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 083e974..f4c0790 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -931,6 +931,123 @@ the client's initial contact with the server.
 If contact with the client cannot be established,
 the server simply does not grant any delegations to
 that client.
+.SH "SECURITY CONSIDERATIONS"
+NFS servers control access to file data,
+but they depend on their RPC implementation
+to provide authentication of NFS requests.
+Traditional NFS access control mimics
+the standard mode bit access control provided in local file systems.
+Traditional RPC authentication uses a number
+to represent each user
+(usually the user's own uid),
+a number to represent the user's group (the user's gid),
+and a set of up to 16 auxiliary group numbers
+to represent other groups of which the user may be a member.
+.P
+Typically, file data and user ID values appear
+in the clear on the network.
+Moreover, NFS versions 2 and 3 use
+separate sideband protocols for mounting,
+locking and unlocking files,
+and reporting system status of clients and servers.
+These auxiliary protocols use no authentication.
+.P
+In addition to combining these sideband protocols with the main NFS protocol,
+NFS version 4 introduces more advanced forms of access control,
+authentication, and in-transit data protection.
+The NFS version 4 specification mandates NFSv4 ACLs,
+RPCGSS authentication, and RPCGSS security flavors
+that provide per-RPC integrity checking and encryption.
+The new security features therefore apply to all NFS version 4 operations
+including mounting, file locking, and so on.
+RPCGSS authentication can also be used with NFS versions 2 and 3,
+but does not protect their sideband protocols.
+.P
+The
+.B sec
+mount option specifies the RPCGSS security mode
+that is in effect on a given NFS mount point.
+Specifying
+.B sec=krb5
+provides cryptographic proof of a user's identity in each RPC request.
+This makes a very strong guarantee
+about who is accessing data on the server.
+Note that additional configuration besides adding this mount option
+is required in order to enable Kerberos security.
+See the
+.BR rpc.gssd (8)
+man page for details.
+.P
+Two additional flavors of Kerberos security are supported.
+The
+.B krb5i
+security flavor provides a cryptographically strong guarantee
+that the data in each RPC request has not been tampered with.
+The
+.B krb5p
+security flavor encrypts every RPC request
+to prevent data exposure during network transit.
+Expect some performance impact
+when using integrity checking or encryption, however.
+Similar support for other forms of cryptographic security
+is also available, including lipkey and SPKM3.
+.P
+The NFS version 4 protocol allows
+clients and servers to negotiate among multiple security flavors
+during mount processing.
+However, Linux does not yet implement such negotiation.
+The Linux client specifies a single security flavor at mount time
+which remains in effect for the lifetime of the mount.
+If the server does not support this flavor,
+the initial mount request is rejected by the server.
+.SS "Mounting through a firewall"
+A firewall may reside between an NFS client and server,
+or the client or server may block some of its own ports via IP
+filter rules.
+It is still possible to mount an NFS server through a firewall,
+though some of the
+.BR mount (8)
+command's automatic service endpoint discovery mechanisms may not work,
+requiring you to provide specific endpoint details via NFS mount options.
+.P
+NFS servers normally run a portmapper or rpcbind daemon to advertise
+their service endpoints to clients.
+The rpcbind daemon uses a well-known port number (111) so that
+clients can easily find it when they try to discover where each
+RPC-based service is running and what transport protocols are
+supported.
+Although NFS most often uses a standard port number (2049),
+auxiliary services such as the NLM service can choose to use
+any unused port number at random.
+.P
+Common firewall configurations block the well-known rpcbind port.
+In the absense of an rpcbind service,
+the server administrator fixes the port number
+of NFS-related services so that the firewall
+can allow access to specific NFS service ports.
+Client administrators then specify the port number
+for the mountd service via the
+.BR mount (8)
+command's
+.B mountport
+option.
+It may also be necessary to enforce the use of TCP or UDP
+if the firewall blocks one of those transports.
+.SS "NFS Access Control Lists"
+Solaris allows NFS version 3 clients direct access
+to POSIX Access Control Lists stored in its local file systems.
+This proprietary sideband protocol, known as NFSACL,
+provides finer grained access control than mode bits.
+Linux implements this protocol
+for compatibility with the Solaris NFS implementation.
+The NFSACL protocol never became a standard part
+of the NFS version 3 specification, however.
+.P
+The NFS version 4 specification mandates a new version
+of Access Control Lists that are semantically richer than POSIX ACLs.
+NFS version 4 ACLs are not fully compatible with POSIX ACLs,
+thus some translation between the two is required
+in an environment that mixes POSIX ACLs and NFS version 4. 
 .SH FILES
 .I /etc/fstab
 .SH "SEE ALSO"


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
