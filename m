Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43941 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751091AbcLHE16 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 23:27:58 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Thu, 08 Dec 2016 15:27:24 +1100
Subject: [PATCH 02/10] nfsd: remove pointless memory allocations.
Cc: linux-nfs@vger.kernel.org
Message-ID: <148117124466.31271.5520473899286758519.stgit@noble>
In-Reply-To: <148117122602.31271.13586847542442809540.stgit@noble>
References: <148117122602.31271.13586847542442809540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is not need to e.g. strdup(optarg), and the value is constant.
It can just be used directly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/nfsd/nfsd.c |   13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 89179be76113..d8f873ba3717 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -71,8 +71,8 @@ main(int argc, char **argv)
 	int grace = -1;
 	int lease = -1;
 
-	progname = xstrdup(basename(argv[0]));
-	port = xstrdup("nfs");
+	progname = basename(argv[0]);
+	port = "nfs";
 	haddr = xmalloc(sizeof(char *));
 	haddr[0] = NULL;
 
@@ -126,14 +126,13 @@ main(int argc, char **argv)
 					exit(1);
 				}
 			}
-			haddr[hcounter] = xstrdup(optarg);
+			haddr[hcounter] = optarg;
 			hcounter++;
 			break;
 		case 'P':	/* XXX for nfs-server compatibility */
 		case 'p':
 			/* only the last -p option has any effect */
-			free(port);
-			port = xstrdup(optarg);
+			port = optarg;
 			break;
 		case 'r':
 			rdma_port = "nfsrdma";
@@ -334,11 +333,7 @@ set_threads:
 	if ((error = nfssvc_threads(count)) < 0)
 		xlog(L_ERROR, "error starting threads: errno %d (%m)", errno);
 out:
-	free(port);
-	for(i=0; i < hcounter; i++)
-		free(haddr[i]);
 	free(haddr);
-	free(progname);
 	return (error != 0);
 }
 


