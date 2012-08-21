Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46814 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758564Ab2HUU5g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:36 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 14/14] nfsd: document kernel interfaces for nfsd configuration
Date: Tue, 21 Aug 2012 16:57:32 -0400
Message-Id: <1345582652-18476-15-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

These are only needed by nfs-utils.  But I needed to remind myself how
they worked recently and thought this might be helpful.  It's short and
incomplete for now as I was only interested in startup, shutdown, and
configuration of listening sockets.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 .../filesystems/nfs/nfsd-admin-interfaces.txt      |   41 ++++++++++++++++++++
 1 file changed, 41 insertions(+)
 create mode 100644 Documentation/filesystems/nfs/nfsd-admin-interfaces.txt

diff --git a/Documentation/filesystems/nfs/nfsd-admin-interfaces.txt b/Documentation/filesystems/nfs/nfsd-admin-interfaces.txt
new file mode 100644
index 0000000..56a96fb
--- /dev/null
+++ b/Documentation/filesystems/nfs/nfsd-admin-interfaces.txt
@@ -0,0 +1,41 @@
+Administrative interfaces for nfsd
+^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+
+Note that normally these interfaces are used only by the utilities in
+nfs-utils.
+
+nfsd is controlled mainly by pseudofiles under the "nfsd" filesystem,
+which is normally mounted at /proc/fs/nfsd/.
+
+The server is always started by the first write of a nonzero value to
+nfsd/threads.
+
+Before doing that, NFSD can be told which sockets to listen on by
+writing to nfsd/portlist; that write may be:
+
+	- an ascii-encoded file descriptor, which should refer to a
+	  bound (and listening, for tcp) socket, or
+	- "transportname port", where transportname is currently either
+	  "udp", "tcp", or "rdma".
+
+If nfsd is started without doing any of these, then it will create one
+udp and one tcp listener at port 2049 (see nfsd_init_socks).
+
+On startup, nfsd and lockd grace periods start.
+
+nfsd is shut down by a write of 0 to nfsd/threads.  All locks and state
+are thrown away at that point.
+
+Between startup and shutdown, the number of threads may be adjusted up
+or down by additional writes to nfsd/threads or by writes to
+nfsd/pool_threads.
+
+For more detail about files under nfsd/ and what they control, see
+fs/nfsd/nfsctl.c; most of them have detailed comments.
+
+Implementation notes
+^^^^^^^^^^^^^^^^^^^^
+
+Note that the rpc server requires the caller to serialize addition and
+removal of listening sockets, and startup and shutdown of the server.
+For nfsd this is done using nfsd_mutex.
-- 
1.7.9.5

