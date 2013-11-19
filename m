Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52499 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636Ab3KSO4E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Nov 2013 09:56:04 -0500
Date: Tue, 19 Nov 2013 09:56:01 -0500
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] nfsd4: update 4.1 nfsd status documentation
Message-ID: <20131119145601.GB17460@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This has gone a little stale.

Reported-by: Christoph Hellwig <hch@infradead.org>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 Documentation/filesystems/nfs/nfs41-server.txt |   42 ++++++++----------------
 1 file changed, 14 insertions(+), 28 deletions(-)

Queuing up for 2.6.14.

diff --git a/Documentation/filesystems/nfs/nfs41-server.txt b/Documentation/filesystems/nfs/nfs41-server.txt
index 01c2db7..b930ad0 100644
--- a/Documentation/filesystems/nfs/nfs41-server.txt
+++ b/Documentation/filesystems/nfs/nfs41-server.txt
@@ -5,11 +5,11 @@ Server support for minorversion 1 can be controlled using the
 by reading this file will contain either "+4.1" or "-4.1"
 correspondingly.
 
-Currently, server support for minorversion 1 is disabled by default.
-It can be enabled at run time by writing the string "+4.1" to
+Currently, server support for minorversion 1 is enabled by default.
+It can be disabled at run time by writing the string "-4.1" to
 the /proc/fs/nfsd/versions control file.  Note that to write this
-control file, the nfsd service must be taken down.  Use your user-mode
-nfs-utils to set this up; see rpc.nfsd(8)
+control file, the nfsd service must be taken down.  You can use rpc.nfsd
+for this; see rpc.nfsd(8).
 
 (Warning: older servers will interpret "+4.1" and "-4.1" as "+4" and
 "-4", respectively.  Therefore, code meant to work on both new and old
@@ -29,29 +29,6 @@ are still under development out of tree.
 See http://wiki.linux-nfs.org/wiki/index.php/PNFS_prototype_design
 for more information.
 
-The current implementation is intended for developers only: while it
-does support ordinary file operations on clients we have tested against
-(including the linux client), it is incomplete in ways which may limit
-features unexpectedly, cause known bugs in rare cases, or cause
-interoperability problems with future clients.  Known issues:
-
-	- gss support is questionable: currently mounts with kerberos
-	  from a linux client are possible, but we aren't really
-	  conformant with the spec (for example, we don't use kerberos
-	  on the backchannel correctly).
-	- We do not support SSV, which provides security for shared
-	  client-server state (thus preventing unauthorized tampering
-	  with locks and opens, for example).  It is mandatory for
-	  servers to support this, though no clients use it yet.
-
-In addition, some limitations are inherited from the current NFSv4
-implementation:
-
-	- Incomplete delegation enforcement: if a file is renamed or
-	  unlinked by a local process, a client holding a delegation may
-	  continue to indefinitely allow opens of the file under the old
-	  name.
-
 The table below, taken from the NFSv4.1 document, lists
 the operations that are mandatory to implement (REQ), optional
 (OPT), and NFSv4.0 operations that are required not to implement (MNI)
@@ -169,6 +146,16 @@ NS*| CB_WANTS_CANCELLED      | OPT       | FDELG,      | Section 20.10 |
 
 Implementation notes:
 
+SSV:
+* The spec claims this is mandatory, but we don't actually know of any
+  implementations, so we're ignoring it for now.  The server returns
+  NFS4ERR_ENCR_ALG_UNSUPP on EXCHANGE_ID, which should be future-proof.
+
+GSS on the backchannel:
+* Again, theoretically required but not widely implemented (in
+  particular, the current Linux client doesn't request it).  We return
+  NFS4ERR_ENCR_ALG_UNSUPP on CREATE_SESSION.
+
 DELEGPURGE:
 * mandatory only for servers that support CLAIM_DELEGATE_PREV and/or
   CLAIM_DELEG_PREV_FH (which allows clients to keep delegations that
@@ -176,7 +163,6 @@ DELEGPURGE:
   now.
 
 EXCHANGE_ID:
-* only SP4_NONE state protection supported
 * implementation ids are ignored
 
 CREATE_SESSION:
-- 
1.7.9.5

