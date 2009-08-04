From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] nfs(5): Remove trailing blanks
Date: Tue, 04 Aug 2009 14:06:55 -0400
Message-ID: <20090804180655.21944.7435.stgit@matisse.1015granger.net>
References: <20090804180334.21944.64404.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:20499 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933010AbZHDSIV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2009 14:08:21 -0400
In-Reply-To: <20090804180334.21944.64404.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: eliminate trailing blanks in utils/mount/nfs.man.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |  261 +++++++++++++++++++++++++------------------=
--------
 1 files changed, 130 insertions(+), 131 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 87a71c6..280ddcb 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -28,7 +28,7 @@ The
 file describes how
 .BR mount (8)
 should assemble a system's file name hierarchy
-from various independent file systems=20
+from various independent file systems
 (including file systems exported by NFS servers).
 Each line in the
 .I /etc/fstab
@@ -56,7 +56,7 @@ by NFS, thus conventionally each contain the digit ze=
ro. For example:
 .P
 The server's hostname and export pathname
 are separated by a colon, while
-the mount options are separated by commas. The remaining fields=20
+the mount options are separated by commas. The remaining fields
 are separated by blanks or tabs.
 The server's hostname can be an unqualified hostname,
 a fully qualified domain name,
@@ -70,17 +70,16 @@ The
 and
 .B nfs4
 file system types share similar mount options,
-which are described below.=20
+which are described below.
 .SH "MOUNT OPTIONS"
-Refer to=20
+Refer to
 .BR mount (8)
 for a description of generic mount options
-available for all file systems. If you do not need to=20
-specify any mount options, use the generic option=20
+available for all file systems. If you do not need to
+specify any mount options, use the generic option
 .B defaults
 in
 .IR /etc/fstab .
-.=20
 .DT
 .SS "Valid options for either the nfs or nfs4 file system type"
 These options are valid to use when mounting either
@@ -100,7 +99,7 @@ option is specified), NFS requests are retried indef=
initely.
 If the
 .B soft
 option is specified, then the NFS client fails an NFS request
-after=20
+after
 .B retrans
 retransmissions have been sent,
 causing the NFS client to return an error
@@ -119,8 +118,8 @@ option may mitigate some of the risks of using the
 option.
 .TP 1.5i
 .BI timeo=3D n
-The time (in tenths of a second) the NFS client waits for a=20
-response before it retries an NFS request. If this=20
+The time (in tenths of a second) the NFS client waits for a
+response before it retries an NFS request. If this
 option is not specified, requests are retried every
 60 seconds for NFS over TCP.
 The NFS client does not perform any kind of timeout backoff
@@ -128,7 +127,7 @@ for NFS over TCP.
 .IP
 However, for NFS over UDP, the client uses an adaptive
 algorithm to estimate an appropriate timeout value for frequently used
-request types (such as READ and WRITE requests), but uses the=20
+request types (such as READ and WRITE requests), but uses the
 .B timeo
 setting for infrequently used request types (such as FSINFO requests).
 If the
@@ -141,13 +140,13 @@ up to a maximum timeout length of 60 seconds.
 .TP 1.5i
 .BI retrans=3D n
 The number of times the NFS client retries a request before
-it attempts further recovery action. If the=20
+it attempts further recovery action. If the
 .B retrans
-option is not specified, the NFS client tries each request=20
+option is not specified, the NFS client tries each request
 three times.
 .IP
 The NFS client generates a "server not responding" message
-after=20
+after
 .B retrans
 retries, then attempts further recovery (depending on whether the
 .B hard
@@ -166,21 +165,21 @@ is 1,048,576 bytes (one megabyte).
 The
 .B rsize
 value is a positive integral multiple of 1024.
-Specified=20
+Specified
 .B rsize
 values lower than 1024 are replaced with 4096; values larger than
 1048576 are replaced with 1048576. If a specified value is within the =
supported
-range but not a multiple of 1024, it is rounded down to the nearest=20
+range but not a multiple of 1024, it is rounded down to the nearest
 multiple of 1024.
 .IP
 If an
 .B rsize
-value is not specified, or if the specified=20
-.B rsize=20
+value is not specified, or if the specified
+.B rsize
 value is larger than the maximum that either client or server can supp=
ort,
 the client and server negotiate the largest
 .B rsize
-value that they can both support.=20
+value that they can both support.
 .IP
 The
 .B rsize
@@ -197,7 +196,7 @@ file.
 .BI wsize=3D n
 The maximum number of bytes per network WRITE request
 that the NFS client can send when writing data to a file
-on an NFS server. The actual data payload size of each=20
+on an NFS server. The actual data payload size of each
 NFS WRITE request is equal to
 or smaller than the
 .B wsize
@@ -207,19 +206,19 @@ is 1,048,576 bytes (one megabyte).
 Similar to
 .B rsize
 , the
-.B wsize=20
+.B wsize
 value is a positive integral multiple of 1024.
-Specified=20
+Specified
 .B wsize
 values lower than 1024 are replaced with 4096; values larger than
 1048576 are replaced with 1048576. If a specified value is within the =
supported
-range but not a multiple of 1024, it is rounded down to the nearest=20
+range but not a multiple of 1024, it is rounded down to the nearest
 multiple of 1024.
 .IP
 If a
 .B wsize
-value is not specified, or if the specified=20
-.B wsize=20
+value is not specified, or if the specified
+.B wsize
 value is larger than the maximum that either client or server can supp=
ort,
 the client and server negotiate the largest
 .B wsize
@@ -235,31 +234,31 @@ file. However, the effective
 .B wsize
 value negotiated by the client and server is reported in the
 .I /proc/mounts
-file.=20
+file.
 .TP 1.5i
 .BR ac " / " noac
-Selects whether the client may cache file attributes. If neither =20
-option is specified (or if=20
+Selects whether the client may cache file attributes. If neither
+option is specified (or if
 .B ac
-is specified), the client caches file =20
-attributes. =20
+is specified), the client caches file
+attributes.
 .IP
-To improve performance, NFS clients cache file =20
-attributes. Every few seconds, an NFS client checks the server's versi=
on of each =20
-file's attributes for updates.  Changes that occur on the server in =20
-those small intervals remain undetected until the client checks the =20
-server again. The=20
+To improve performance, NFS clients cache file
+attributes. Every few seconds, an NFS client checks the server's versi=
on of each
+file's attributes for updates.  Changes that occur on the server in
+those small intervals remain undetected until the client checks the
+server again. The
 .B noac
-option prevents clients from caching file =20
-attributes so that applications can more quickly detect file changes =20
+option prevents clients from caching file
+attributes so that applications can more quickly detect file changes
 on the server.
 .IP
-In addition to preventing the client from caching file attributes, =20
-the=20
+In addition to preventing the client from caching file attributes,
+the
 .B noac
-option forces application writes to become synchronous so =20
-that local changes to a file become visible on the server =20
-immediately.  That way, other clients can quickly detect recent =20
+option forces application writes to become synchronous so
+that local changes to a file become visible on the server
+immediately.  That way, other clients can quickly detect recent
 writes when they check the file's attributes.
 .IP
 Using the
@@ -383,20 +382,20 @@ Refer to the SECURITY CONSIDERATIONS section for =
details.
 .TP 1.5i
 .BR sharecache " / " nosharecache
 Determines how the client's data cache and attribute cache are shared
-when mounting the same export more than once concurrently.  Using the =
=20
-same cache reduces memory requirements on the client and presents =20
-identical file contents to applications when the same remote file is =20
+when mounting the same export more than once concurrently.  Using the
+same cache reduces memory requirements on the client and presents
+identical file contents to applications when the same remote file is
 accessed via different mount points.
 .IP
-If neither option is specified, or if the=20
+If neither option is specified, or if the
 .B sharecache
-option is =20
-specified, then a single cache is used for all mount points that =20
-access the same export.  If the=20
+option is
+specified, then a single cache is used for all mount points that
+access the same export.  If the
 .B nosharecache
-option is specified, =20
-then that mount point gets a unique cache.  Note that when data and =20
-attribute caches are shared, the mount options from the first mount =20
+option is specified,
+then that mount point gets a unique cache.  Note that when data and
+attribute caches are shared, the mount options from the first mount
 point take effect for subsequent concurrent mounts of the same export.
 .IP
 As of kernel 2.6.18, the behavior specified by
@@ -489,9 +488,9 @@ In addition to controlling how the NFS client trans=
mits requests to
 the server, this mount option also controls how the
 .BR mount (8)
 command communicates with the server's rpcbind and mountd services.
-Specifying=20
+Specifying
 .B proto=3Dtcp
-forces all traffic from the=20
+forces all traffic from the
 .BR mount (8)
 command and the NFS client to use TCP.
 Specifying
@@ -617,9 +616,9 @@ It is included for compatibility with other operati=
ng systems.
 .TP 1.5i
 .BR lock " / " nolock
 Selects whether to use the NLM sideband protocol to lock files on the =
server.
-If neither option is specified (or if=20
-.B lock=20
-is specified), NLM locking is used for this mount point.=20
+If neither option is specified (or if
+.B lock
+is specified), NLM locking is used for this mount point.
 When using the
 .B nolock
 option, applications can lock files,
@@ -641,13 +640,13 @@ that do not support the NLM protocol.
 .TP 1.5i
 .BR intr " / " nointr
 Selects whether to allow signals to interrupt file operations
-on this mount point. If neither option=20
-is specified (or if=20
+on this mount point. If neither option
+is specified (or if
 .B nointr
 is specified),
 signals do not interrupt NFS file operations. If
-.B intr=20
-is specified, system calls return EINTR if an in-progress NFS operatio=
n is interrupted by=20
+.B intr
+is specified, system calls return EINTR if an in-progress NFS operatio=
n is interrupted by
 a signal.
 .IP
 Using the
@@ -665,13 +664,13 @@ compatibility with older kernels.
 .TP 1.5i
 .BR cto " / " nocto
 Selects whether to use close-to-open cache coherence semantics.
-If neither option is specified (or if=20
+If neither option is specified (or if
 .B cto
 is specified), the client uses close-to-open
-cache coherence semantics. If the=20
-.B nocto=20
+cache coherence semantics. If the
+.B nocto
 option is specified, the client uses a non-standard heuristic to deter=
mine when
-files on the server have changed.=20
+files on the server have changed.
 .IP
 Using the
 .B nocto
@@ -683,13 +682,13 @@ of this option in more detail.
 .BR acl " / " noacl
 Selects whether to use the NFSACL sideband protocol on this mount poin=
t.
 The NFSACL sideband protocol is a proprietary protocol
-implemented in Solaris that manages Access Control Lists. NFSACL was n=
ever=20
+implemented in Solaris that manages Access Control Lists. NFSACL was n=
ever
 made a standard part of the NFS protocol specification.
 .IP
-If neither=20
+If neither
 .B acl
-nor=20
-.B noacl=20
+nor
+.B noacl
 option is specified,
 the NFS client negotiates with the server
 to see if the NFSACL protocol is supported,
@@ -703,7 +702,7 @@ Selects whether to use NFS version 3 READDIRPLUS re=
quests.
 If this option is not specified, the NFS client uses READDIRPLUS reque=
sts
 on NFS version 3 mounts to read small directories.
 Some applications perform better if the client uses only READDIR reque=
sts
-for all directories. =20
+for all directories.
 .SS "Valid options for the nfs4 file system type"
 Use these options, along with the options in the first subsection abov=
e,
 for mounting the
@@ -719,8 +718,8 @@ can be either
 or
 .BR tcp .
 All NFS version 4 servers are required to support TCP,
-so if this mount option is not specified, the NFS version 4 client=20
-uses the TCP transport protocol.=20
+so if this mount option is not specified, the NFS version 4 client
+uses the TCP transport protocol.
 Refer to the TRANSPORT METHODS section for more details.
 .TP 1.5i
 .BI port=3D n
@@ -743,12 +742,12 @@ or the server's NFS service is not available on t=
he advertised port.
 .TP 1.5i
 .BR intr " / " nointr
 Selects whether to allow signals to interrupt file operations
-on this mount point. If neither option is specified (or if=20
-.B intr=20
-is specified), system calls return EINTR if an in-progress NFS operati=
on =20
-is interrupted by a signal.  If=20
+on this mount point. If neither option is specified (or if
+.B intr
+is specified), system calls return EINTR if an in-progress NFS operati=
on
+is interrupted by a signal.  If
 .B nointr
-is specified, signals do not =20
+is specified, signals do not
 interrupt NFS operations.
 .IP
 Using the
@@ -770,7 +769,7 @@ for NFS directories on this mount point.
 If neither
 .B cto
 nor
-.B nocto=20
+.B nocto
 is specified,
 the default is to use close-to-open cache coherence
 semantics for directories.
@@ -780,11 +779,11 @@ The DATA AND METADATA COHERENCE section discusses
 the behavior of this option in more detail.
 .TP 1.5i
 .BI clientaddr=3D n.n.n.n
-Specifies  a  single  IPv4  address  (in dotted-quad form)=20
-that the NFS client advertises to allow servers=20
-to perform NFS version 4 callback requests against=20
-files on this mount point. If  the  server is unable to=20
-establish callback connections to clients, performance=20
+Specifies  a  single  IPv4  address  (in dotted-quad form)
+that the NFS client advertises to allow servers
+to perform NFS version 4 callback requests against
+files on this mount point. If  the  server is unable to
+establish callback connections to clients, performance
 may degrade, or accesses to files may temporarily hang.
 .IP
 If this option is not specified, the
@@ -794,7 +793,7 @@ The automatic discovery process is not perfect, how=
ever.
 In the presence of multiple client network interfaces,
 special routing policies,
 or atypical network topologies,
-the exact address to use for callbacks may be nontrivial to determine.=
=20
+the exact address to use for callbacks may be nontrivial to determine.
 .SH EXAMPLES
 To mount an export using NFS version 2,
 use the
@@ -867,33 +866,33 @@ and data transfer size settings for a mount point=
=2E
 In some cases, however, it pays to specify
 these settings explicitly using mount options.
 .P
-Traditionally, NFS clients used the UDP transport exclusively for =20
-transmitting requests to servers.  Though its implementation is =20
-simple, NFS over UDP has many limitations that prevent smooth =20
-operation and good performance in some common deployment =20
-environments.  Even an insignificant packet loss rate results in the =20
-loss of whole NFS requests; as such, retransmit timeouts are usually =20
-in the subsecond range to allow clients to recover quickly from =20
-dropped requests, but this can result in extraneous network traffic =20
+Traditionally, NFS clients used the UDP transport exclusively for
+transmitting requests to servers.  Though its implementation is
+simple, NFS over UDP has many limitations that prevent smooth
+operation and good performance in some common deployment
+environments.  Even an insignificant packet loss rate results in the
+loss of whole NFS requests; as such, retransmit timeouts are usually
+in the subsecond range to allow clients to recover quickly from
+dropped requests, but this can result in extraneous network traffic
 and server load.
 .P
-However, UDP can be quite effective in specialized settings where =20
-the network=E2=80=99s MTU is large relative to NFS=E2=80=99s data tran=
sfer size (such =20
-as network environments that enable jumbo Ethernet frames).  In such =20
-environments, trimming the=20
-.B rsize=20
-and=20
-.B wsize=20
-settings so that each =20
-NFS read or write request fits in just a few network frames (or even =20
-in  a single  frame) is advised.  This reduces the probability that =20
-the loss of a single MTU-sized network frame results in the loss of =20
+However, UDP can be quite effective in specialized settings where
+the network=E2=80=99s MTU is large relative to NFS=E2=80=99s data tran=
sfer size (such
+as network environments that enable jumbo Ethernet frames).  In such
+environments, trimming the
+.B rsize
+and
+.B wsize
+settings so that each
+NFS read or write request fits in just a few network frames (or even
+in  a single  frame) is advised.  This reduces the probability that
+the loss of a single MTU-sized network frame results in the loss of
 an entire large read or write request.
 .P
-TCP is the default transport protocol used for all modern NFS=20
+TCP is the default transport protocol used for all modern NFS
 implementations.  It performs well in almost every conceivable
-network environment and provides excellent guarantees against data=20
-corruption caused by network unreliability.  TCP is often a =20
+network environment and provides excellent guarantees against data
+corruption caused by network unreliability.  TCP is often a
 requirement for mounting a server through a network firewall.
 .P
 Under normal circumstances, networks drop packets much more
@@ -904,11 +903,11 @@ After  the client exhausts its retransmits (the v=
alue of the
 .B retrans
 mount option), it assumes a network partition has occurred,
 and attempts to reconnect to the server on a fresh socket. Since
-TCP itself makes network data transfer reliable,=20
+TCP itself makes network data transfer reliable,
 .B rsize
-and=20
+and
 .B wsize
-can safely be allowed to default to the largest values supported by =20
+can safely be allowed to default to the largest values supported by
 both client and server, independent of the network's MTU size.
 .SS "Using the mountproto mount option"
 This section applies only to NFS version 2 and version 3 mounts
@@ -993,8 +992,8 @@ Some modern cluster file systems provide
 perfect cache coherence among their clients.
 Perfect cache coherence among disparate NFS clients
 is expensive to achieve, especially on wide area networks.
-As such, NFS settles for weaker cache coherence that=20
-satisfies the requirements of most file sharing types. Normally,=20
+As such, NFS settles for weaker cache coherence that
+satisfies the requirements of most file sharing types. Normally,
 file sharing is completely sequential:
 first client A opens a file, writes something to it, then closes it;
 then client B opens the same file, and reads the changes.
@@ -1028,7 +1027,7 @@ it is still difficult to tell whether it was
 that client's updates or some other client's updates
 that altered the file.
 .SS "Attribute caching"
-Use the=20
+Use the
 .B noac
 mount option to achieve attribute cache coherence
 among multiple clients.
@@ -1057,7 +1056,7 @@ The NFS protocol is not designed to support
 true cluster file system cache coherence
 without some type of application serialization.
 If absolute cache coherence among clients is required,
-applications should use file locking. Alternatively, applications=20
+applications should use file locking. Alternatively, applications
 can also open their files with the O_DIRECT flag
 to disable data caching entirely.
 .SS "Directory entry caching"
@@ -1117,7 +1116,7 @@ and has no effect on how the NFS client caches th=
e attributes of files.
 The NFS client treats the
 .B sync
 mount option differently than some other file systems
-(refer to=20
+(refer to
 .BR mount (8)
 for a description of the generic
 .B sync
@@ -1128,16 +1127,16 @@ If neither
 .B sync
 nor
 .B async
-is specified (or if the=20
-.B async=20
+is specified (or if the
+.B async
 option is specified),
 the NFS client delays sending application
 writes to the server
-until any of these events occur:=20
+until any of these events occur:
 .IP
 Memory pressure forces reclamation of system memory resources.
 .IP
-An application flushes file data explicitly with=20
+An application flushes file data explicitly with
 .BR sync (2),
 .BR msync (2),
 or
@@ -1165,7 +1164,7 @@ but at a significant performance cost.
 Applications can use the O_SYNC open flag to force application
 writes to individual files to go to the server immediately without
 the use of the
-.B sync=20
+.B sync
 mount option.
 .SS "Using file locks with NFS"
 The Network Lock Manager protocol is a separate sideband protocol
@@ -1200,15 +1199,15 @@ mount option. NLM locking must be disabled with=
 the
 .B nolock
 option when using NFS to mount
 .I /var
-because=20
-.I /var=20
+because
+.I /var
 contains files used by the NLM implementation on Linux.
 .P
 Specifying the
 .B nolock
 option may also be advised to improve the performance
 of a proprietary application which runs on a single client
-and uses file locks extensively.=20
+and uses file locks extensively.
 .SS "NFS version 4 caching features"
 The data and metadata caching behavior of NFS version 4
 clients is similar to that of earlier versions.
@@ -1292,7 +1291,7 @@ authentication, and in-transit data protection.
 The NFS version 4 specification mandates NFSv4 ACLs,
 RPCGSS authentication, and RPCGSS security flavors
 that provide per-RPC integrity checking and encryption.
-Because NFS version 4 combines the =20
+Because NFS version 4 combines the
 function of the sideband protocols into the main NFS protocol,
 the new security features apply to all NFS version 4 operations
 including mounting, file locking, and so on.
@@ -1306,11 +1305,11 @@ that is in effect on a given NFS mount point.
 Specifying
 .B sec=3Dkrb5
 provides cryptographic proof of a user's identity in each RPC request.
-This provides strong verification of the identity of users=20
+This provides strong verification of the identity of users
 accessing data on the server.
 Note that additional configuration besides adding this mount option
 is required in order to enable Kerberos security.
-Refer to the=20
+Refer to the
 .BR rpc.gssd (8)
 man page for details.
 .P
@@ -1395,15 +1394,15 @@ filter rules.
 It is still possible to mount an NFS server through a firewall,
 though some of the
 .BR mount (8)
-command's automatic service endpoint discovery mechanisms may not work=
; this=20
+command's automatic service endpoint discovery mechanisms may not work=
; this
 requires you to provide specific endpoint details via NFS mount option=
s.
 .P
 NFS servers normally run a portmapper or rpcbind daemon to advertise
-their service endpoints to clients. Clients use the rpcbind daemon to =
determine:=20
+their service endpoints to clients. Clients use the rpcbind daemon to =
determine:
 .IP
 What network port each RPC-based service is using
 .IP
-What transport protocols each RPC-based service supports=20
+What transport protocols each RPC-based service supports
 .P
 The rpcbind daemon uses a well-known port number (111) to help clients=
 find a service endpoint.
 Although NFS often uses a standard port number (2049),
@@ -1435,9 +1434,9 @@ of the NFS version 3 specification, however.
 .P
 The NFS version 4 specification mandates a new version
 of Access Control Lists that are semantically richer than POSIX ACLs.
-NFS version 4 ACLs are not fully compatible with POSIX ACLs; as such,=20
+NFS version 4 ACLs are not fully compatible with POSIX ACLs; as such,
 some translation between the two is required
-in an environment that mixes POSIX ACLs and NFS version 4.=20
+in an environment that mixes POSIX ACLs and NFS version 4.
 .SH FILES
 .TP 1.5i
 .I /etc/fstab
@@ -1514,4 +1513,4 @@ RFC 1833 for the RPC bind specification.
 .br
 RFC 2203 for the RPCSEC GSS API protocol specification.
 .br
-RFC 3530 for the NFS version 4 specification.=20
+RFC 3530 for the NFS version 4 specification.

