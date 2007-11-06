From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/15] nfs(5) man page: Add new DATA AND METADATA
	COHERENCY	section
Date: Mon, 05 Nov 2007 20:03:38 -0500
Message-ID: <20071106010338.5037.25674.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCqs-0004fW-J9
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:34 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCqy-0004Tq-0m
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:40 -0800
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

Add a section to nfs(5) that discusses how the NFS client caches data and
metadata, and what mount options can be use to alter this caching behavior.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |  192 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 192 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 0debdb0..083e974 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -739,6 +739,198 @@ whole NFS requests,
 thus retransmit timeouts are usually in the subsecond range.
 The Linux RPC client employs an RTT estimator that
 dynamically manages the timeout settings for requests sent via UDP. 
+.SH "DATA AND METADATA COHERENCY"
+Some modern cluster file systems provide
+perfect cache coherence among their clients.
+Perfect cache coherency among disparate NFS clients
+is expensive to achieve, especially on wide area networks.
+Thus NFS settles for weaker cache coherency that satisfies
+the requirements of most everyday types of file sharing.
+Everyday file sharing is commonly completely sequential:
+first client A opens a file, writes something to it, then closes it;
+then client B opens the same file, and reads the changes.
+.DT
+.SS "Close-to-open cache consistency"
+When an application opens a file stored on an NFS server,
+the NFS client checks that it still exists on the server
+and is permitted to the opener by sending a GETATTR or ACCESS request.
+When the application closes the file,
+the NFS client writes back any pending changes
+to the file so that the next opener can view the changes.
+This also gives the NFS client an opportunity to report
+any server write errors to the application
+via the return code from
+.BR close (2).
+The behavior of checking at open time and flushing at close time
+is referred to as close-to-open cache consistency.
+.SS "Weak cache consistency"
+There are still opportunities for a client's data cache
+to contain stale data.
+The NFS version 3 protocol introduced "weak cache consistency"
+(also known as WCC) which provides a way of efficiently checking
+a file's attributes before and after a single request
+to allow a client to help identify changes
+that could have been made by other clients.
+When a client is using many concurrent operations
+that update the same file at the same time
+(for example, during asynchronous write behind),
+it is still difficult to tell whether it was
+that client's updates or some other client's updates
+that altered the file.
+.SS "Attribute caching"
+Use the 
+.B noac
+mount option to achieve attribute cache coherency
+among multiple clients.
+Almost every file system operation checks
+file attribute information.
+The client keeps this information cached
+for a period of time to reduce network and server load.
+When
+.B noac
+is in effect, a client's file attribute cache is disabled,
+so each operation that needs to check a file's attributes
+is forced to go back to the server.
+This permits a client to see changes to a file very quickly,
+at the cost of many extra network operations.
+.P
+Be careful not to confuse the
+.B noac
+option with "no data caching."
+The
+.B noac
+mount option prevents the client from caching file metadata,
+but there are still races that may result in data incoherency
+between client and server.
+.P
+As illustrated above,
+the NFS protocol is not designed to support
+true cluster file system cache coherency
+without some type of application serialization.
+If absolute cache coherency among clients is required,
+applications should use file locking,
+or applications can open their files with the O_DIRECT flag
+to disable data caching entirely.
+.SS "The sync mount option"
+The NFS client treats the
+.B sync
+mount option differently than some other file systems
+(see
+.BR mount (8)
+for a description of the generic
+.B sync
+and
+.B async
+mount options).
+If neither option is specified, or the async option is specified,
+the NFS client delays writes to the server
+until memory pressure forces reclamation of system memory resources,
+an application invokes
+.BR close (2)
+or flushes the file data explicitly,
+or the file is locked or unlocked via
+.BR fcntl (2).
+In other words, under normal circumstances,
+data written by an application may not immediately appear
+on the server that hosts the file.
+.P
+If the
+.B sync
+option is specified on a mount point,
+any system call that writes data to files on that mount point
+causes that data to be flushed to the server
+before the system call returns control to user space.
+This provides greater data coherency among clients,
+but at a significant performance cost.
+.SS "Using file locks with NFS"
+A separate sideband protocol,
+known as the Network Lock Manager protocol,
+is used to manage file locks in NFS version 2 and version 3.
+To support lock recovery after a client or server reboot,
+a second sideband protocol,
+known as the Network Status Manager protocol,
+is also required.
+In NFS version 4,
+file locking is supported directly in the main NFS protocol,
+and the NLM and NSM sideband protocols are not used.
+.P
+The NLM and NSM services are usually started automatically,
+and no extra configuration is required.
+Configure all NFS clients with fully-qualified domain names
+to ensure that NFS servers can find clients to notify them of server reboots.
+.P
+NLM supports advisory file locks only.
+To lock NFS files, use
+.BR fcntl (2)
+with the F_GETLK and F_SETLK commands.
+The NFS client converts file locks obtained via
+.BR flock (2)
+to advisory locks.
+.P
+When mounting servers that do not support the NLM protocol,
+or when mounting an NFS server through a firewall
+that blocks the NLM service port,
+specify the
+.B nolock
+mount option.
+Specifying the
+.B nolock
+option may also be advised to improve the performance
+of a proprietary application which runs on a single client
+and uses file locks extensively. 
+.SS "NFS version 4 caching features"
+The data and metadata caching behavior of NFS version 4
+clients is similar to that of earlier versions.
+However, NFS version 4 adds two features that improve
+cache behavior:
+.I change attributes
+and
+.IR "file delegation" .
+.P
+The
+.I change attribute
+is a new part of NFS file and directory metadata
+which tracks data changes.
+It replaces the use of a file's modification
+and change time stamps
+as a way for clients to validate the content
+of their caches.
+Change attributes are independent of the time stamp
+resolution on either the server or client, however.
+.P
+A
+.I file delegation
+is a contract between an NFS version 4 client
+and server that allows the client to treat a file temporarily
+as if that client is its only accessor.
+The server promises to notify the client if another client
+attempts to access that file via a callback request.
+Once a file has been delegated to a client, the client can
+cache that file's data and metadata aggressively without
+contacting the server.
+.P
+File delegations come in two flavors.
+A
+.I read
+delegation means that the server notifies the client
+about any other clients that want to write to the file.
+A
+.I write
+delegation means that the client gets notified about
+either read or write accessors.
+.P
+Servers grant file delegations when a file is opened,
+and can recall delegations at any time when another
+client wants access to the file that conflicts with
+any delegations that have already been granted.
+Delegations on directories are not supported.
+.P
+In order to support delegation callback, the server
+checks the network return path to the client during
+the client's initial contact with the server.
+If contact with the client cannot be established,
+the server simply does not grant any delegations to
+that client.
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
