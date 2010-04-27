From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/9] lockd: Document new lockd user space API
Date: Tue, 27 Apr 2010 14:58:20 -0400
Message-ID: <20100427185819.29074.24906.stgit@matisse.1015granger.net>
References: <20100427185411.29074.8889.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:65334 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912Ab0D0S6W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Apr 2010 14:58:22 -0400
Received: by mail-pv0-f174.google.com with SMTP id 2so1611478pvg.19
        for <linux-nfs@vger.kernel.org>; Tue, 27 Apr 2010 11:58:22 -0700 (PDT)
In-Reply-To: <20100427185411.29074.8889.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a file under Documents that describes the file system structure
under /sys/fs/lockd.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 Documentation/filesystems/nfs/00-INDEX            |    2 
 Documentation/filesystems/nfs/lockd-sysfs-api.txt |  117 +++++++++++++++++++++
 2 files changed, 119 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/lockd-sysfs-api.txt

diff --git a/Documentation/filesystems/nfs/00-INDEX b/Documentation/filesystems/nfs/00-INDEX
index 2f68cd6..a3a8c39 100644
--- a/Documentation/filesystems/nfs/00-INDEX
+++ b/Documentation/filesystems/nfs/00-INDEX
@@ -2,6 +2,8 @@
 	- this file (nfs-related documentation).
 Exporting
 	- explanation of how to make filesystems exportable.
+lockd-sysfs-api.txt
+	- how /sys/fs/lockd/ works.
 knfsd-stats.txt
 	- statistics which the NFS server makes available to user space.
 nfs.txt
diff --git a/Documentation/filesystems/nfs/lockd-sysfs-api.txt b/Documentation/filesystems/nfs/lockd-sysfs-api.txt
new file mode 100644
index 0000000..bb6ad8d
--- /dev/null
+++ b/Documentation/filesystems/nfs/lockd-sysfs-api.txt
@@ -0,0 +1,117 @@
+An overview of the /sys/fs/lockd directory hierarchy
+
+Chuck Lever <chuck.lever@oracle.com>
+Tue Apr 27 12:26:31 EDT 2010
+
+Introduction
+------------
+
+Traditionally, lockd and statd communicate via loopback networking.
+Loopback networking can take many different forms, and sometimes is
+not even available (for example, during boot).  Supporting all of
+these configurations can add implementation complexity.
+
+In addition, we'd like to provide a mechanism for NFS server system
+administrators to remove NFS locks on clients that may no longer be
+able to contact the server.
+
+An obvious alternative to loopback networking is to provide a lockd
+user space API via the local file system.  A set of files under /sys
+can export lockd state to user space.
+
+
+File Hierarchy
+---- ---------
+
+When loaded, lockd creates directories under /sys/fs/lockd.  Currently,
+these subdirectories are created:
+
+
+  /sys/fs/lockd/hosts/
+	This directory contains a subdirectory for each cached nlm_host.
+	Each subdirectory is named after the remote's address, the
+	transport protocol it used to contact us ("udp" or "tcp"), and
+	the NLM version number in use.
+
+	Each nlm_host subdirectory contains files that expose the
+	contents of one nlm_host cache entry.  The files are named
+	after each field in the nlm_host data structure.
+
+	You can see the IP address of the remote, the source address
+	the local host uses to contact the remote, the hostname
+	provided by the remote, the NLM version and transport, and
+	other information.
+
+	A symlink is created to the nsm_handle subdirectory (under
+	/sys/fs/lockd/monitor/) associated with this nlm_host cache
+	entry.
+
+
+  /sys/fs/lockd/monitor/
+	This directory contains a subdirectory for each monitored host.
+	Each subdirectory is named after the 16-byte priv cookie lockd
+	uses to identify this host to statd.
+
+	Each host subdirectory contains files that expose the
+	contents of one nsm_handle cache entry.  The files are
+	named after each field in the nsm_handle structure.
+
+	You can see the mon_name and my_name used for this remote,
+	the RPC parms statd will use to call lockd back, the
+	remote's IP address, and other related information.
+
+	A file called "reboot" exists to allow user space to cause
+	the local lockd to initiate reboot recovery for the remote
+	represented by this nsm_handle.  The new NSM state number for
+	this remote is written to this file to trigger reboot
+	recovery.
+
+
+New subdirectories are created in each of monitor/ and hosts/ as
+remotes establish contact with the local lockd.  The entries are
+removed when lockd garbage collects them.
+
+The read-only attribute files provided by this interface are
+permitted read-only to "world."  The reboot attribute is readable
+and writable only by root.
+
+In other words, the data fields of nlm_host and nsm_handle cache
+entries are exposed to user space, one per file, via this directory
+hierarchy.  This is a straightforward, one-to-one mapping of the
+items in the nlm_host and nsm_handle cache to kobjects and thus to
+files and directories.
+
+
+Usage
+-----
+
+To cause lockd to drop locks for a particular remote, a user program:
+
+   1.  Looks up the remote's hostname or IP address in /sys/fs/lockd/
+
+   2.  Reads the current NSM state from the remote's nlm_host
+       attribute file
+
+   3.  Subtracts two from the NSM state number and writes the result
+       into the corresponding nsm_handle reboot attribute file.
+
+Unfortunately, the NSM state number arithmetic is necessary to allow
+lockd to continue to track the NSM state of the remote properly.  NSM
+state number management is an integral part of lockd.  lockd allows
+reboot recovery to start only if the incoming NSM state number is
+different than the NSM state number it currently has for that remote.
+
+New NSM state numbers are generated almost always by adding two.
+Subtracting provides some guarantee that the remote won't reuse the
+NSM state number we made up to trigger reboot recovery.
+
+System administrator capabilities (ie. EUID of 0) are required to write
+the new NSM state number into an nsm_handle's reboot attribute.  At
+some later point, lockd and statd AF_UNIX sockets may also be provided
+to allow NSM activity to proceed without the consistent presence of
+loopback networking.  This might be necessary because programs like
+statd drop root, and thus can't use the root-only interface provided by
+the nsm_handle reboot attribute.
+
+
+

