Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44871 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752273AbcLUAUH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Dec 2016 19:20:07 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 21 Dec 2016 11:19:14 +1100
Subject: [PATCH 2/4] nfsd: Do not permit manipulation of NFSv4.0,
 e.g. "-N 4.0"
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Message-ID: <148227955395.31345.17174406788901291213.stgit@noble>
In-Reply-To: <148227940052.31345.1974080582264239934.stgit@noble>
References: <148227940052.31345.1974080582264239934.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The code maps this into "-4.32", which the kernel rejects.
The kernel also rejects "-4.0" (when written to the 'versions'
file).
So require the minor number to be at least NFS4_MINMINOR, which is '1'.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/nfsd/nfsd.c   |    4 ++--
 utils/nfsd/nfsd.man |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index eb346f67f9e4..20f4b7952203 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -179,7 +179,7 @@ main(int argc, char **argv)
 			case 4:
 				if (*p == '.') {
 					int i = atoi(p+1);
-					if (i > NFS4_MAXMINOR) {
+					if (i < NFS4_MINMINOR || i > NFS4_MAXMINOR) {
 						fprintf(stderr, "%s: unsupported minor version\n", optarg);
 						exit(1);
 					}
@@ -201,7 +201,7 @@ main(int argc, char **argv)
 			case 4:
 				if (*p == '.') {
 					int i = atoi(p+1);
-					if (i > NFS4_MAXMINOR) {
+					if (i < NFS4_MINMINOR || i > NFS4_MAXMINOR) {
 						fprintf(stderr, "%s: unsupported minor version\n", optarg);
 						exit(1);
 					}
diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index 8d198e25685e..8901fb6c6872 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -57,7 +57,7 @@ This option can be used to request that
 .B rpc.nfsd
 does not offer certain versions of NFS. The current version of
 .B rpc.nfsd
-can support NFS versions 2,3,4 and the newer version 4.1.
+can support major NFS versions 2,3,4 and the minor versions 4.1 and 4.2.
 .TP
 .B \-s " or " \-\-syslog
 By default,
@@ -82,7 +82,7 @@ This option can be used to request that
 .B rpc.nfsd
 offer certain versions of NFS. The current version of
 .B rpc.nfsd
-can support NFS versions 2,3,4 and the newer version 4.1.
+can support major NFS versions 2,3,4 and the minor versions 4.1 and 4.2.
 .TP
 .B \-L " or " \-\-lease-time seconds
 Set the lease-time used for NFSv4.  This corresponds to how often


