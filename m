From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/15] nfs(5) man page: Add new section for common nfs
	and	nfs4 mount options
Date: Mon, 05 Nov 2007 20:03:12 -0500
Message-ID: <20071106010312.5037.56523.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCqX-0004eh-SG
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:14 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCqd-0004Nt-7o
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:19 -0800
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

Collect common options in their own section, clarify the descriptions of
each option, and use conventional man page typography.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |  268 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 268 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 45c6da1..666fd3e 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -84,6 +84,274 @@ generic option in
 .I /etc/fstab
 if you do not need to specify any mount options. 
 .DT
+.SS "Valid options for either the nfs or nfs4 file system type"
+These options are valid to use when mounting either
+.B nfs
+or
+.B nfs4
+file system types.
+They imply the same behavior
+and have the same default for both file system types.
+.TP 1.5i
+.BR soft " / " hard
+Determines the recovery behavior of the RPC client
+after an RPC request times out.
+If neither option is specified,
+or if the
+.B hard
+option is specified, RPC requests are retried indefinitely.
+If the
+.B soft
+option is specified, then the RPC client fails an RPC request
+after a major timeout occurs,
+causing the NFS client to return an error
+to the calling application.
+.IP
+.I NB:
+A so-called "soft" timeout can cause
+silent data corruption in certain cases,
+so use the
+.B soft
+option only when client responsiveness
+is more important than data integrity.
+Using NFS over TCP or lengthening your retransmit timeout
+via the
+.B timeo
+option may mitigate some of the risk of using the
+.B soft
+option.
+.TP 1.5i
+.BI timeo= n
+The value, in tenths of a second, before timing out an RPC request.
+The default value is 600 (60 seconds) for NFS over TCP.
+The
+.B timeo
+value defaults to 7 tenths of a second for NFS over UDP.
+However, for NFS over UDP, the Linux RPC client uses an adaptive
+algorithm to estimate the timeout value for frequently used
+request types, such as READ and WRITE, and uses the
+.B timeo
+setting for infrequently used request types, such as FSINFO.
+.IP
+After each timeout, the RPC client may retransmit the timed out request,
+or it may take some other action depending on the settings of the
+.B hard
+or
+.B retrans
+options.
+.TP 1.5i
+.BI retrans= n
+The number of RPC timeouts that must occur before a major timeout occurs.
+If the
+.B retrans
+option is not specified, a default of 3 timeouts for each request
+is used.
+.IP
+The RPC client generates a "server not responding" message
+after a major timeout.
+Then, if the file system is mounted with the
+.B hard
+option,
+it continues to retransmit the request.
+If the file system is mounted with the
+.B soft
+mount option,
+the RPC client abandons the request after a major timeout,
+and causes NFS to return an error to the application.
+.TP 1.5i
+.BI rsize= n
+The maximum number of bytes in each network READ request
+that the NFS client can receive when reading data from a file
+on an NFS server.
+The actual data payload size of each NFS READ request is equal to
+or smaller than the
+.B rsize
+setting.
+.IP
+The
+.B rsize
+value is a positive integral multiple of 1024,
+and the largest value supported by the Linux NFS client
+is 1,048,576 bytes.
+Specified values outside of this range are rounded down
+to the closest multiple of 1024, and specified values smaller
+than 1024 are replaced with a default of 4096.
+If an
+.B rsize
+value is not specified, or if a value is specified but is larger
+than the maximums either the client or server support,
+the client and server negotiate the largest
+.B rsize
+value that both support.
+.IP
+The
+.B rsize
+mount option as specified on the
+.BR mount (8)
+command line appears in the
+.I /etc/mtab
+file, but the effective
+.B rsize
+value negotiated by the client and server is reported in the
+.I /proc/mounts
+file.
+.TP 1.5i
+.BI wsize= n
+The maximum number of bytes per network WRITE request
+that the NFS client can send when writing data to a file
+on an NFS server.
+See the description of the
+.B rsize
+option for more details.
+.TP 1.5i
+.BI acregmin= n
+The minimum time in seconds that the NFS client caches
+attributes of a regular file before it requests
+fresh attribute information from a server.
+If this option is not specified, the NFS client uses
+a 3 second minimum.
+.TP 1.5i
+.BI acregmax= n
+The maximum time in seconds that the NFS client caches
+attributes of a regular file before it requests
+fresh attribute information from a server.
+If this option is not specified, the NFS client uses
+a 60 second maximum.
+.TP 1.5i
+.BI acdirmin= n
+The minimum time in seconds that the NFS client caches
+attributes of a directory before it requests
+fresh attribute information from a server.
+If this option is not specified, the NFS client uses
+a 30 second minimum.
+.TP 1.5i
+.BI acdirmax= n
+The maximum time in seconds that the NFS client caches
+attributes of a directory before it requests
+fresh attribute information from a server.
+If this option is not specified, the NFS client uses
+a 60 second maximum.
+.TP 1.5i
+.BI actimeo= n
+Using
+.B actimeo
+sets all of
+.BR acregmin ,
+.BR acregmax ,
+.BR acdirmin ,
+and
+.B acdirmax
+to the same value.
+If this option is not specified, the NFS client uses
+the defaults for each of these options listed above.
+.TP 1.5i
+.BR ac " / " noac
+Selects whether to attribute caching, and force synchronous writes.
+The
+.B noac
+option is synonymous with using
+.BR actimeo=0,sync .
+If this option is not specified, the default behavior is
+to cache attributes normally and write data asynchronously.
+.IP
+Using the
+.B noac
+option provides much greater cache coherency among NFS clients
+accessing the same files,
+but it extracts a significant performance penalty.
+Judicious use of file locking is encouraged instead.
+The DATA AND METADATA COHERENCY section contains a detailed discussion
+of these trade-offs.
+.TP 1.5i
+.BR bg " / " fg
+Determines how the
+.BR mount (8)
+command behaves if an attempt to mount a remote share fails.
+The
+.B fg
+option causes
+.BR mount (8)
+to exit with an error status if any part of the mount request
+times out or fails outright.
+This is called a "foreground" mount,
+and is the default behavior if neither the
+.B fg
+nor
+.B bg
+mount option is specified.
+If the
+.B bg
+option is specified, a timeout or failure causes the
+.BR mount (8)
+command to fork a child which continues to attempt
+to mount the remote share.
+The parent immediately returns with a zero exit code.
+This is known as a "background" mount.
+.IP
+If the local mount point directory is missing, the
+.BR mount (8)
+command acts as if the mount request timed out.
+This permits nested NFS mounts specified in
+.I /etc/fstab
+to proceed in any order during system initialization,
+even if some NFS servers are not yet available.
+Alternatively these issues can be addressed
+using an automounter (see
+.BR automount (8)
+for details).
+.TP 1.5i
+.BI retry= n
+The number of minutes that the
+.BR mount (8)
+command retries an NFS mount operation
+in the foreground or background before giving up.
+If this option is not specified, the default value for foreground mounts
+is 2 minutes, and the default value for background mounts is 10000 minutes,
+which is roughly one week.
+.TP 1.5i
+.BI sec= mode
+The RPCGSS security flavor to use for accessing files on this mount point.
+If the
+.B sec
+option is not specified, or if
+.B sec=sys
+is specified, the RPC client uses the AUTH_SYS security flavor
+for all RPC operations on this mount point.
+Valid security flavors are
+.BR none ,
+.BR sys ,
+.BR krb5 ,
+.BR krb5i ,
+.BR krb5p ,
+.BR lkey ,
+.BR lkeyi ,
+.BR lkeyp ,
+.BR spkm ,
+.BR spkmi ,
+and
+.BR spkmp .
+See the SECURITY CONSIDERATIONS section for details.
+.TP 1.5i
+.BR sharecache " / " nosharecache
+Determines how the client's data and attribute cache is shared
+between mount points that mount the same remote share.
+If neither option not specified, or the
+.B sharecache
+option is specified, then all mounts of the same remote share
+on a client use the same data cache.
+If the
+.B nosharecache
+option is specified, then files under that mount point
+are cached separately from files under other mount points
+that may be accessing the same remote share.
+.IP
+As of kernel 2.6.18, the behavior specified by
+.B nosharecache
+is legacy caching behavior,
+and is considered a data risk since multiple cached copies
+of the same file on the same client can become out of sync
+following an update of one of the copies.
+.DT
 .SS Options for the nfs file system type
 .TP 1.5i
 .I rsize=n


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
