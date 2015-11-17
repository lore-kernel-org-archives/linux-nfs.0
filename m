Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:36306 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753631AbbKQLx6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:58 -0500
Received: by qgad10 with SMTP id d10so3415730qga.3
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:57 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 38/38] nfs: add a Kconfig option for NFS reexporting and documentation
Date: Tue, 17 Nov 2015 06:53:00 -0500
Message-Id: <1447761180-4250-39-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 Documentation/filesystems/nfs/reexport.txt | 95 ++++++++++++++++++++++++++++++
 fs/nfs/Kconfig                             | 11 ++++
 2 files changed, 106 insertions(+)
 create mode 100644 Documentation/filesystems/nfs/reexport.txt

diff --git a/Documentation/filesystems/nfs/reexport.txt b/Documentation/filesystems/nfs/reexport.txt
new file mode 100644
index 000000000000..4ecfd3832338
--- /dev/null
+++ b/Documentation/filesystems/nfs/reexport.txt
@@ -0,0 +1,95 @@
+Re-exporting nfs via nfsd:
+--------------------------
+It is possible to reeexport a nfs filesystem via nfsd, but there are
+some limitations to this scheme.
+
+The primary use case for this is allowing clients that do not support
+newer versions of NFS to access servers that do not export older
+versions of NFS. In particular, it's a way to distribute pnfs support to
+non-pnfs enabled clients (albeit at the cost of an extra hop).
+
+There are a number of caveats to doing this -- be sure to read the
+entire document below and make sure that you know what you're doing!
+
+Quick Start:
+------------
+1) ensure that the kernel is built with CONFIG_NFS_REEXPORT
+
+2) Mount the _entire_ directory tree that you wish to reexport on the
+server. nfsd is unable to cross server filesystem boundaries
+automatically, so the entire tree to be reexported must be mounted
+prior to exporting.
+
+3) Add exports for the reexported filesystem to /etc/exports, assigning
+fsid= values to each. NFS doesn't have a persistent UUID or device
+number that is guaranteed to be unique across multiple servers, so
+fsid= values must always be explicitly assigned.
+
+4) Avoid stateful operations from the clients. File locking is
+particularly problematic, but reexporting NFSv4 via NFSv4 is likely to
+have similar problems with open and delegation stateids as well.
+
+The gory details of reexportng:
+-------------------------------
+Below is a detailed list of the _known_ problems with reexporting NFS
+via nfsd. Be aware of these facts when using this feature:
+
+Filehandle size:
+----------------
+The maximum filehandle size is governed by the NFS version. Version 2
+used fixed 32 byte filehandles. Version 3 moved to variable length
+filehandles that can be up to 64 bytes in size. NFSv4 increased that
+maximum to 128 bytes.
+
+When reexporting an NFS filesystem, the underlying filehandle from the
+server must be embedded inside the filehandles presented to clients.
+Thus if the underlying server presents filehandles that are too big, the
+reexporting server can fail to encode them. This can lead to
+NFSERR_OPNOTSUPP errors being returned to clients.
+
+This is not a trivial thing to programatically determine ahead of time
+(and it can vary even within the same server), so some foreknowledge of
+how the underlying server constructs filehandles, and their maximum
+size is a must.
+
+No subtree checking:
+--------------------
+Subtree checking requires that information about the parent be encoded
+in non-directory filehandles. Since filehandle space is already at a
+premium, subtree checking is disallowed on reexported nfs filesystems.
+
+No crossing of mountpoints:
+---------------------------
+Crossing from one exported filesystem to another typically involves the
+nfs client doing a behind-the-scenes mount of the "child" filesystem. nfsd
+lacks the machinery to do this. It could (in principle) be added, but
+there's really no point as there is no way to ensure that the fsid
+(filesystem identifier) value that got assigned was persistent.
+
+Lack of a persistent fsid= value:
+---------------------------------
+NFS filesystems don't have a persistent value that we can stuff into
+the fsid. We could repackage the one that the server provides, but that
+could lead to collisions if the reexporting server has mounts to
+different underlying servers. Thus, reexporting NFS requires assigning
+a fsid= value in the export options. This value must be persistent
+across reboots of the reexporting server as well or the clients will
+see filehandles change (the dreaded "Stale NFS filehandle" error).
+
+Statefulness and locking:
+-------------------------
+Holding any sort of state across a reexported NFS mount is problematic.
+It's always possible that the reexporting server could reboot, in which
+case it will lose track of the state held on the underlying server.
+
+When it comes back up, the clients will then try to reclaim that state
+from the reexporter, but the reexporter can't provide the necessary
+guarantees to ensure that conflicting state wasn't set and released
+during the time it was down. This may mean silent data corruption.
+Any sort of stateful operations against the reexporting fileserver are
+best avoided.
+
+Because of this, it's best to use a configuration that does not involve
+the clients holding any state on the reexporter. For example, reexporting
+a NFSv4 filesystem to legacy clients via NFSv3 (sans file locking) should
+basically work.
diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index f31fd0dd92c6..92ad6bcc81cc 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -200,3 +200,14 @@ config NFS_DEBUG
 	depends on NFS_FS && SUNRPC_DEBUG
 	select CRC32
 	default y
+
+config NFS_REEXPORT
+	bool "Allow reexporting of NFS filesystems via knfsd"
+	depends on NFSD
+	default n
+	help
+	  This option allows NFS filesystems to be re-exported via knfsd.
+	  This is generally only useful in some very limited situations.
+	  One such is to allow legacy client access to servers that do not
+	  support older NFS versions. Use with caution and be sure to read
+	  Documentation/filesystems/nfs/reexport.txt first!
-- 
2.4.3

