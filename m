From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/15] nfs(5) man page: Add new section for -t nfs
	mount	options
Date: Mon, 05 Nov 2007 20:03:17 -0500
Message-ID: <20071106010317.5037.47177.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCqY-0004em-A4
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:14 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCqd-0004PF-Dz
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:03:20 -0800
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

Collect mount options for the "nfs" file system type in their own
section, clarify the descriptions of each option, and use conventional
man page typography.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |  439 +++++++++++++++++++++++----------------------------
 1 files changed, 196 insertions(+), 243 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 666fd3e..98d282e 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -351,254 +351,207 @@ is legacy caching behavior,
 and is considered a data risk since multiple cached copies
 of the same file on the same client can become out of sync
 following an update of one of the copies.
-.DT
-.SS Options for the nfs file system type
-.TP 1.5i
-.I rsize=n
-The number of bytes NFS uses when reading files from an NFS server.
-The rsize is negotiated between the server and client to determine 
-the largest block size that both can support.
-The value specified by this option is the maximum size that could 
-be used; however, the actual size used may be smaller.
-Note: Setting this size to a value less than the largest supported
-block size will adversely affect performance.
-.TP 1.5i
-.I wsize=n
-The number of bytes NFS uses when writing files to an NFS server.
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
-The default value is 7 tenths of a second.  After the first timeout,
-the timeout is doubled after each successive timeout until a maximum
-timeout of 60 seconds is reached or the enough retransmissions
-have occured to cause a major timeout.  Then, if the filesystem
-is hard mounted, each new timeout cascade restarts at twice the
-initial value of the previous cascade, again doubling at each
-retransmission.  The maximum timeout is always 60 seconds.
-Better overall performance may be achieved by increasing the
-timeout when mounting on a busy network, to a slow server, or through
-several routers or gateways.
-.TP 1.5i
-.I retrans=n
-The number of minor timeouts and retransmissions that must occur before
-a major timeout occurs.  The default is 3 timeouts.  When a major timeout
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
-.TP 1.5i
-.I retry=n
-The number of minutes to retry an NFS mount operation
-in the foreground or background before giving up.
-The default value for forground mounts is 2 minutes.  
-The default value for background mounts is 10000 minutes, 
-which is roughly one week.
-.TP 1.5i
-.I namlen=n
-When an NFS server does not support version two of the
-RPC mount protocol, this option can be used to specify
-the maximum length of a filename that is supported on
-the remote filesystem.  This is used to support the
-POSIX pathconf functions.  The default is 255 characters.
-.TP 1.5i
-.I port=n
-The numeric value of the port to connect to the NFS server on.
-If the port number is 0 (the default) then query the
-remote host's portmapper for the port number to use.
-If the remote host's NFS daemon is not registered with
-its portmapper, the standard NFS port number 2049 is
-used instead.
-.TP 1.5i
-.I mountport=n
-The numeric value of the
-.B mountd
-port.
-.TP 1.5i
-.I mounthost=name
-The name of the host running
-.B mountd .
-.TP 1.5i
-.I mountprog=n
-Use an alternate RPC program number to contact the
-mount daemon on the remote host.  This option is useful
-for hosts that can run multiple NFS servers.
-The default value is 100005 which is the standard RPC
-mount daemon program number.
-.TP 1.5i
-.I mountvers=n
-Use an alternate RPC version number to contact the
-mount daemon on the remote host.  This option is useful
-for hosts that can run multiple NFS servers.
-The default value depends on which kernel you are using.
-.TP 1.5i
-.I nfsprog=n
-Use an alternate RPC program number to contact the
-NFS daemon on the remote host.  This option is useful
-for hosts that can run multiple NFS servers.
-The default value is 100003 which is the standard RPC
-NFS daemon program number.
-.TP 1.5i
-.I nfsvers=n
-Use an alternate RPC version number to contact the
-NFS daemon on the remote host.  This option is useful
-for hosts that can run multiple NFS servers.
-The default value depends on which kernel you are using.
-.TP 1.5i
-.I vers=n
-vers is an alternative to nfsvers and is compatible with
-many other operating systems.
-.TP 1.5i
-.I nolock
-Disable NFS locking. Do not start lockd.
-This is appropriate for mounting the root filesystem or
-.B /usr
+.SS "Valid options for the nfs file system type"
+Use these options, along with the options in the above subsection,
+for mounting the
+.B nfs
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
-.BR /var .
-These filesystems are typically either read-only or not shared, and in
-those cases, remote locking is not needed.
-This also needs to be used with some old NFS servers
-that don't support locking.
-.br
-Note that applications can still get locks on files, but the locks
-only provide exclusion locally.  Other clients mounting the same
-filesystem will not be able to detect the locks.
-.TP 1.5i
-.I bg
-If the first NFS mount attempt times out, retry the mount
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
-.I posix
-Mount the NFS filesystem using POSIX semantics.  This allows
-an NFS filesystem to properly support the POSIX pathconf
-command by querying the mount server for the maximum length
-of a filename.  To do this, the remote host must support version
-two of the RPC mount protocol.  Many NFS servers support only
-version one.
-.TP 1.5i
-.I nocto
-Suppress the retrieval of new attributes when creating a file.
+.BR tcp .
+Each transport protocol uses different default
+.B retrans
+and
+.B timeo
+settings.
+See the description of these two mount options for details.
+.IP
+This mount option controls both how the
+.BR mount (8)
+command communicates with the server's rpcbind and mountd services,
+and what transport protocol the NFS client uses to transmit requests
+to the server's NFS service.
+Specifying
+.B proto=tcp
+forces all traffic from the
+.BR mount (8)
+command and the NFS client to use TCP.
+Specifying
+.B proto=udp
+forces all traffic types to use UDP.
+.IP
+If the
+.B proto
+mount option is not specified, the
+.BR mount (8)
+command chooses a transport for each service.
+If the server doesn't support one or the other protocol, the
+.BR mount (8)
+command attempts to discover which protocol is supported
+and use that one.
+See the TRANSPORT METHODS section below for more details.
 .TP 1.5i
-.I noac
-Disable all forms of attribute caching entirely.  This extracts a
-significant performance penalty but it allows two different NFS clients
-to get reasonable results when both clients are actively
-writing to a common export on the server.
+.B udp
+The
+.B udp
+option is an alternative to specifying
+.BR proto=udp.
+It is included for compatibility with other operating systems.
 .TP 1.5i
-.I noacl
-Disables Access Control List (ACL) processing.
+.B tcp
+The
+.B tcp
+option is an alternative to specifying
+.BR proto=tcp.
+It is included for compatibility with other operating systems.
+.TP 1.5i
+.BI port= n
+The numeric value of the server's NFS service port.
+If the server's NFS service is not available on the specified port,
+the mount request fails.
+If this option is not specified, or if the specified port value is 0,
+then the NFS client uses the NFS service port number
+advertised by the server's rpcbind service.
+If the server's rpcbind service is not available,
+the server's NFS service is not registered with its rpcbind service,
+or the server's NFS service is not available on the advertised port,
+the mount request fails.
+.TP 1.5i
+.BI namlen= n
+The maximum length of a pathname component on this mount.
+If this option is not specified, the maximum length is negotiated
+with the server and is usually 255 characters.
+.IP
+Some early versions of NFS did not support this negotiation.
+Using this option can ensure that
+.BR pathconf (3)
+reports the proper maximum component length to applications
+in this circumstance.
+.TP 1.5i
+.BI mountport= n
+The numeric value of the server's mountd port.
+If the server's mountd service is not available on the specified port,
+the mount request fails.
+If this option is not specified,
+or if the specified port value is 0, then the
+.BR mount (8)
+command uses the mountd service port number
+advertised by the server's rpcbind service.
+If the server's rpcbind service is not available,
+the server's mountd service is not registered with its rpcbind service,
+or the server's mountd service is not available on the advertised port,
+the mount request fails.
+.IP
+This option can be used when mounting an NFS server
+through a firewall that blocks the rpcbind protocol.
 .TP 1.5i
-.I sec=mode
-Set the security flavor for this mount to "mode".
-The default setting is \f3sec=sys\f1, which uses local
-unix uids and gids to authenticate NFS operations (AUTH_SYS).
-Other currently supported settings are:
-\f3sec=krb5\f1, which uses Kerberos V5 instead of local unix uids
-and gids to authenticate users;
-\f3sec=krb5i\f1, which uses Kerberos V5 for user authentication
-and performs integrity checking of NFS operations using secure
-checksums to prevent data tampering; and
-\f3sec=krb5p\f1, which uses Kerberos V5 for user authentication
-and integrity checking, and encrypts NFS traffic to prevent
-traffic sniffing (this is the most secure setting).
-Note that there is a performance penalty when using integrity
-or privacy.
-.TP 1.5i
-.I tcp
-Mount the NFS filesystem using the TCP protocol.  This is the default
-if it is supported by both client and server.  Many NFS servers only
-support UDP.
-.TP 1.5i
-.I udp
-Mount the NFS filesystem using the UDP protocol.
-.TP 1.5i
-.I nordirplus
-Disables NFSv3 READDIRPLUS RPCs. Use this option when
-mounting servers that don't support or have broken
-READDIRPLUS implementations.
+.BI mounthost= name
+The hostname of the host running mountd.
+If this option is not specified, the
+.BR mount (8)
+command assumes that the mountd service runs
+on the same host as the NFS service.
+.TP 1.5i
+.BI mountvers= n
+The RPC version number used to contact the server's mountd.
+If this option is not specified, the client uses a version number
+appropriate to the requested NFS version.
+This option is useful when multiple NFS services
+are running on the same remote server host.
+.TP 1.5i
+.BI nfsvers= n
+The NFS protocol version number used to contact the server's NFS service.
+The Linux client supports version 2 and version 3 of the NFS protocol
+when using the
+.B nfs
+file system type.
+If the server does not support the requested version,
+the mount request fails.
+If this option is not specified, the client attempts to use version 3,
+but negotiates the NFS version with the server if version 3 support
+is not available.
+.TP 1.5i
+.BI vers= n
+This option is an alternative to the
+.B nfsvers
+option.
+It is included for compatibility with other operating systems.
+.TP 1.5i
+.BR lock " / " nolock
+Selects whether to use the NLM sideband protocol to lock files on the server.
+If this option is not specified, the default is to use NLM locking
+for this mount point.
+When using the
+.B nolock
+option, applications can lock files,
+but such locks provide exclusion only against other applications
+running on the same client.
+Remote applications are not affected by these locks.
+.IP
+NLM locking must be disabled with the
+.B nolock
+option when using NFS to mount
+.I /var
+because
+.I /var
+contains files used by the NLM implementation on Linux.
+Using the
+.B nolock
+option is also required when mounting shares on NFS servers
+that do not support the NLM protocol.
+.TP 1.5i
+.BR intr " / " nointr
+Selects whether to allow signals to interrupt file operations
+on this mount point.
+When a system call is interrupted while an NFS operation is outstanding,
+the system call returns EINTR.
+If the
+.B intr
+option is not specified,
+signals do not interrupt NFS file operations.
+Using the
+.B intr
+option is preferred to using the
+.B soft
+option because it is significantly less likely to result in data corruption.
 .TP 1.5i
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
+.BR cto " / " nocto
+Selects whether to use close-to-open cache coherency semantics.
+If this option is not specified, the default is to use close-to-open
+cache coherency semantics.
+Using the
+.B nocto
+option may improve performance for read-only mounts,
+but should be used only if the data on the server changes only occasionally.
+The DATA AND METADATA COHERENCY section discusses the behavior
+of this option in more detail.
+.TP 1.5i
+.BR acl " / " noacl
+Selects whether to use the NFSACL sideband protocol on this mount point.
+The NFSACL sideband protocol is a proprietary protocol
+implemented in Solaris that manages Access Control Lists,
+and was never made a standard part of the NFS protocol specification.
+If this option is not specified,
+the NFS client negotiates with the server
+to see if the NFSACL protocol is supported,
+and uses it if the server supports it.
+Disabling the NFSACL sideband protocol may be necessary
+if the negotiation causes problems on the client or server.
+See the SECURITY CONSIDERATIONS section for more details.
+.TP 1.5i
+.BR rdirplus " / " nordirplus
+Selects whether to use NFS version 3 READDIRPLUS RPCs.
+If this option is not specified, the NFS client uses READDIRPLUS requests
+on NFS version 3 mounts to read small directories.
+Some applications perform better if the client uses only READDIR requests
+for all directories.  
 .SS Options for the nfs4 file system type
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
