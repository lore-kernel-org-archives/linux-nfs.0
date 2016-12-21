Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44861 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752273AbcLUAUA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Dec 2016 19:20:00 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 21 Dec 2016 11:19:13 +1100
Subject: [PATCH 1/4] nfsd: fix setting of minor version from config file.
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Message-ID: <148227955377.31345.11860695256203867484.stgit@noble>
In-Reply-To: <148227940052.31345.1974080582264239934.stgit@noble>
References: <148227940052.31345.1974080582264239934.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Several problem here:
- code didn't actually work, as it cleared a bit from minorversset
  when it should have cleared from minorvers
- code did not allow minor versions to be enabled, which is useful
  when a new minor version is partially implemented in the kernel
  but not yet enabled by default
- code allowed version 4.0 to be enabled/disabled, which the kernel
  does not support (as for 4.9 at least).

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/nfsd/nfsd.c   |   16 ++++++++++++++--
 utils/nfsd/nfsd.man |    6 +++---
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 3c451aa46be1..eb346f67f9e4 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -107,12 +107,24 @@ main(int argc, char **argv)
 	/* We assume the kernel will default all minor versions to 'on',
 	 * and allow the config file to disable some.
 	 */
-	for (i = 0; i <= NFS4_MAXMINOR; i++) {
+	for (i = NFS4_MINMINOR; i <= NFS4_MAXMINOR; i++) {
 		char tag[20];
 		sprintf(tag, "vers4.%d", i);
+		/* The default for minor version support is to let the
+		 * kernel decide.  We could ask the kernel what that choice
+		 * will be, but that is needlessly complex.
+		 * Instead, perform a config-file lookup using each of the
+		 * two possible default.  If the result is different from the
+		 * default, then impose that value, else don't make a change
+		 * (i.e. don't set the bit in minorversset).
+		 */
 		if (!conf_get_bool("nfsd", tag, 1)) {
 			NFSCTL_VERSET(minorversset, i);
-			NFSCTL_VERUNSET(minorversset, i);
+			NFSCTL_VERUNSET(minorvers, i);
+		}
+		if (conf_get_bool("nfsd", tag, 0)) {
+			NFSCTL_VERSET(minorversset, i);
+			NFSCTL_VERSET(minorvers, i);
 		}
 	}
 
diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index 9381cf9d30c3..8d198e25685e 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -161,10 +161,10 @@ by default.
 .B vers4.1
 .TP
 .B vers4.2
-.TP
-.B vers4.3
 Setting these to "off" or similar will disable the selected minor
-versions.  All are enabled by default.
+versions.  Setting to "on" will enable them.  The default values
+are determined by the kernel, and usually minor versions default to
+being enabled once the implementation is sufficiently complete.
 
 .SH NOTES
 If the program is built with TI-RPC support, it will enable any protocol and


