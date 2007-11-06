From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/15] nfs(5) man page: Add new section for -t nfs4
	mount	options
Date: Mon, 05 Nov 2007 20:03:23 -0500
Message-ID: <20071106010323.5037.58741.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCqi-0004f1-Fu
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:24 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCqn-0004QJ-OT
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:30 -0800
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

Collect mount options for the "nfs4" file system type in their own
section, clarify the descriptions of each option, and use conventional
man page typography.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |  248 ++++++++++++++-------------------------------------
 1 files changed, 70 insertions(+), 178 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 98d282e..9cb673a 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -552,191 +552,83 @@ If this option is not specified, the NFS client uses READDIRPLUS requests
 on NFS version 3 mounts to read small directories.
 Some applications perform better if the client uses only READDIR requests
 for all directories.  
-.SS Options for the nfs4 file system type
-.TP 1.5i
-.I rsize=n
-The number of bytes nfs4 uses when reading files from the server.
-The rsize is negotiated between the server and client to determine 
-the largest block size that both can support.
-The value specified by this option is the maximum size that could 
-be used; however, the actual size used may be smaller.
-Note: Setting this size to a value less than the largest supported
-block size will adversely affect performance.
-.TP 1.5i
-.I wsize=n
-The number of bytes nfs4 uses when writing files to the server.
-The wsize is negotiated between the server and client to determine 
-the largest block size that both can support.
-The value specified by this option is the maximum size that could 
-be used; however, the actual size used may be smaller.
-Note: Setting this size to a value less than the largest supported
-block size will adversely affect performance.
-.TP 1.5i
-.I timeo=n
-The value in tenths of a second before sending the
-first retransmission after an RPC timeout.
-The default value depends on whether
-.IR proto=udp
+.SS "Valid options for the nfs4 file system type"
+Use these options, along with the options in the first subsection above,
+for mounting the
+.B nfs4
+file system type.
+.TP 1.5i
+.BI proto= netid
+The transport protocol used by the RPC client
+to transmit requests to the NFS server for this mount point.
+The value of
+.I netid
+can be either
+.B udp
 or
-.IR proto=tcp
-is in effect (see below).
-The default value for UDP is 7 tenths of a second.
-The default value for TCP is 60 seconds.
-After the first timeout,
-the timeout is doubled after each successive timeout until a maximum
-timeout of 60 seconds is reached or the enough retransmissions
-have occured to cause a major timeout.  Then, if the filesystem
-is hard mounted, each new timeout cascade restarts at twice the
-initial value of the previous cascade, again doubling at each
-retransmission.  The maximum timeout is always 60 seconds.
-.TP 1.5i
-.I retrans=n
-The number of minor timeouts and retransmissions that must occur before
-a major timeout occurs.  The default is 5 timeouts for
-.IR proto=udp
-and 2 timeouts for
-.IR proto=tcp .
-When a major timeout
-occurs, the file operation is either aborted or a "server not responding"
-message is printed on the console.
-.TP 1.5i
-.I acregmin=n
-The minimum time in seconds that attributes of a regular file should
-be cached before requesting fresh information from a server.
-The default is 3 seconds.
-.TP 1.5i
-.I acregmax=n
-The maximum time in seconds that attributes of a regular file can
-be cached before requesting fresh information from a server.
-The default is 60 seconds.
-.TP 1.5i
-.I acdirmin=n
-The minimum time in seconds that attributes of a directory should
-be cached before requesting fresh information from a server.
-The default is 30 seconds.
-.TP 1.5i
-.I acdirmax=n
-The maximum time in seconds that attributes of a directory can
-be cached before requesting fresh information from a server.
-The default is 60 seconds.
-.TP 1.5i
-.I actimeo=n
-Using actimeo sets all of
-.I acregmin,
-.I acregmax,
-.I acdirmin,
-and
-.I acdirmax
-to the same value.
-There is no default value.
+.BR tcp .
+All NFS version 4 servers are required to support TCP,
+so if this mount option is not specified,
+the default transport protocol for NFS version 4 is TCP.
+See the TRANSPORT METHODS section for more details.
 .TP 1.5i
-.I retry=n
-The number of minutes to retry an NFS mount operation
-in the foreground or background before giving up.
-The default value for forground mounts is 2 minutes.  
-The default value for background mounts is 10000 minutes, 
-which is roughly one week.
+.BI port= n
+The numeric value of the server's NFS service port.
+If the server's NFS service is not available on the specified port,
+the mount request fails.
+If this mount option is not specified,
+the NFS client uses the standard NFS port number of 2049
+without first checking the server's rpcbind service.
+This allows an NFS version 4 client to contact an NFS version 4
+server through a firewall that may block rpcbind requests.
+If the specified port value is 0,
+then the NFS client uses the NFS service port number
+advertised by the server's rpcbind service.
+If the server's rpcbind service is not available,
+the server's NFS service is not registered with its rpcbind service,
+or the server's NFS service is not available on the advertised port,
+the mount request fails.
 .TP 1.5i
-.I port=n
-The numeric value of the port to connect to the NFS server on.
-If the port number is 0 (the default) then query the
-remote host's portmapper for the port number to use.
-If the remote host's NFS daemon is not registered with
-its portmapper, the standard NFS port number 2049 is
-used instead.
-.TP 1.5i
-.I proto=n
-Mount the NFS filesystem using a specific network protocol
-instead of the default UDP protocol.
-Many NFS version 4 servers only support TCP.
-Valid protocol types are
-.IR udp
-and
-.IR tcp .
-.TP 1.5i
-.I clientaddr=n.n.n.n
-Specifies a single IPv4 address in dotted-quad form that
-the NFS client advertises to allow servers to perform
-NFSv4 callback requests against files on this mount point.
-If the server is not able to establish callback connections
-to clients, performance may degrade, or accesses to
-files may temporarily hang.
+.BR intr " / " nointr
+Selects whether to allow signals to interrupt file operations
+on this mount point.
+When a system call is interrupted while an NFS operation is outstanding,
+the system call returns EINTR.
+If the
+.B intr
+option is not specified, signals can interrupt NFS file operations.
+Using the
+.B intr
+option is preferred to using the
+.B soft
+option because it is significantly less likely to result in data corruption.
+.TP 1.5i
+.BR cto " / " nocto
+Selects whether to use close-to-open cache coherency semantics
+for NFS directories on this mount point.
+If this option is not specified,
+the default is to use close-to-open cache coherency
+semantics for directories.
+File data caching behavior is not affected by this option.
+The DATA AND METADATA COHERENCY section discusses
+the behavior of this option in more detail.
+.TP 1.5i
+.BI clientaddr= n.n.n.n
+Specifies a single IPv4 address in dotted-quad form
+that the NFS client advertises to allow servers
+to perform NFS version 4 callback requests
+against files on this mount point.
+If the server is not able to establish callback connections to clients,
+performance may degrade, or accesses to files may temporarily hang.
 .IP
 If this option is not specified, the
 .BR mount (8)
-command attempts to discover an appropriate callback
-address automatically.
+command attempts to discover an appropriate callback address automatically.
 The automatic discovery process is not perfect, however.
-In the presence of multiple client network interfaces, special
-routing policies, or atypical network topologies, the exact
-address to use for callbacks may be nontrivial to determine,
-and should be explicitly set using this mount option.
-.TP 1.5i
-.I sec=mode
-Same as \f3sec=mode\f1 for the nfs filesystem type (see above).
-.TP 1.5i
-.I bg
-If an NFS mount attempt times out, retry the mount
-in the background.
-After a mount operation is backgrounded, all subsequent mounts
-on the same NFS server will be backgrounded immediately, without
-first attempting the mount.
-A missing mount point is treated as a timeout,
-to allow for nested NFS mounts.
-.TP 1.5i
-.I fg
-If the first NFS mount attempt times out, retry the mount
-in the foreground.
-This is the complement of the
-.I bg
-option, and also the default behavior.
-.TP 1.5i
-.I soft
-If an NFS file operation has a major timeout then report an I/O error to
-the calling program.
-The default is to continue retrying NFS file operations indefinitely.
-.TP 1.5i
-.I hard
-If an NFS file operation has a major timeout then report
-"server not responding" on the console and continue retrying indefinitely.
-This is the default.
-.TP 1.5i
-.I intr
-If an NFS file operation has a major timeout and it is hard mounted,
-then allow signals to interupt the file operation and cause it to
-return EINTR to the calling program.  The default is to not
-allow file operations to be interrupted.
-.TP 1.5i
-.I nocto
-Suppress the retrieval of new attributes when creating a file.
-.TP 1.5i
-.I noac
-Disable attribute caching, and force synchronous writes.
-This extracts a
-server performance penalty but it allows two different NFS clients
-to get reasonable good results when both clients are actively
-writing to common filesystem on the server.
-.TP 1.5i
-.I nosharecache
-As of kernel 2.6.18, it is no longer possible to mount the same
-same filesystem with different mount options to a new mountpoint.
-It was deemed unsafe to do so, since cached data cannot be shared
-between the two mountpoints. In consequence, files or directories
-that were common to both mountpoint subtrees could often be seen to
-be out of sync following an update.
-.br
-This option allows administrators to select the pre-2.6.18 behaviour,
-permitting the same filesystem to be mounted with different mount
-options.
-.br
-.B Beware:
-Use of this option is not recommended unless you are certain that there
-are no hard links or subtrees of this mountpoint that are mounted
-elsewhere.
-.P
-All of the non-value options have corresponding nooption forms.
-For example, nointr means don't allow file operations to be
-interrupted.
+In the presence of multiple client network interfaces,
+special routing policies,
+or atypical network topologies,
+the exact address to use for callbacks may be nontrivial to determine. 
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
