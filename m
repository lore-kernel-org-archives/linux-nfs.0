From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] nfs(5): document new [no]resvport option
Date: Fri, 27 Feb 2009 15:05:19 -0500
Message-ID: <20090227200518.11301.46939.stgit@ingres.1015granger.net>
References: <20090227200511.11301.33720.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:29594 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756460AbZB0UHA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2009 15:07:00 -0500
In-Reply-To: <20090227200511.11301.33720.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kernel 2.6.28 adds a new mount option: [no]resvport.  Document the new
option in the nfs(5) man page.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   66 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 0c86559..ad2a14d 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -405,6 +405,23 @@ is legacy caching behavior. This
 is considered a data risk since multiple cached copies
 of the same file on the same client can become out of sync
 following a local update of one of the copies.
+.TP 1.5i
+.BR resvport " / " noresvport
+Specifies whether the NFS client should use a privileged source port
+when communicating with an NFS server for this mount point.
+If this option is not specified, or the
+.B resvport
+option is specified, the NFS client uses a privileged source port.
+If the
+.B noresvport
+option is specified, the NFS client uses a non-privileged source port.
+This option is supported in kernels 2.6.28 and later.
+.IP
+Using non-privileged source ports helps increase the maximum number of
+NFS mount points allowed on a client, but NFS servers must be configured
+to allow clients to connect via non-privileged source ports.
+.IP
+Refer to the SECURITY CONSIDERATIONS section for important details.
 .SS "Valid options for the nfs file system type"
 Use these options, along with the options in the above subsection,
 for mounting the
@@ -1212,6 +1229,55 @@ The Linux client specifies a single security flavor at mount time
 which remains in effect for the lifetime of the mount.
 If the server does not support this flavor,
 the initial mount request is rejected by the server.
+.SS "Using non-privileged source ports"
+NFS clients usually communicate with NFS servers via network sockets.
+Each end of a socket is assigned a port value, which is simply a number
+between 1 and 65535 that distinguishes socket endpoints at the same
+IP address.
+A socket is uniquely defined by a tuple that includes the transport
+protocol (TCP or UDP) and the port values and IP addresses of both
+endpoints.
+.P
+The NFS client can choose any source port value for its sockets,
+but usually chooses a
+.I privileged
+port.
+A privileged port is a port value less than 1024.
+Only a process with root privileges may create a socket
+with a privileged source port.
+.P
+The exact range of privileged source ports that can be chosen is
+set by a pair of sysctls to avoid choosing a well-known port, such as
+the port used by ssh.
+This means the number of source ports available for the NFS client,
+and therefore the number of socket connections that can be used
+at the same time,
+is practically limited to only a few hundred.
+.P
+As described above, the traditional default NFS authentication scheme,
+known as AUTH_SYS, relies on sending local UID and GID numbers to identify
+users making NFS requests.
+An NFS server assumes that if a connection comes from a privileged port,
+the UID and GID numbers in the NFS requests on this connection have been
+verified by the client's kernel or some other local authority.
+This is an easy system to spoof, but on a trusted physical network between
+trusted hosts, it is entirely adequate.
+.P
+Roughly speaking, one socket is used for each NFS mount point.
+If a client could use non-privileged source ports as well,
+the number of sockets allowed,
+and thus the maximum number of concurrent mount points,
+would be much larger.
+.P
+Using non-privileged source ports may compromise server security somewhat,
+since any user on AUTH_SYS mount points can now pretend to be any other
+when making NFS requests.
+Thus NFS servers do not support this by default.
+They explicitly allow it usually via an export option.
+.P
+To retain good security while allowing as many mount points as possible,
+it is best to allow non-privileged client connections only if the server
+and client both require strong authentication, such as Kerberos.
 .SS "Mounting through a firewall"
 A firewall may reside between an NFS client and server,
 or the client or server may block some of its own ports via IP

