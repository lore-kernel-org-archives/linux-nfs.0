From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 1/2] mount: silently fails when bad option values are given
Date: Thu,  3 Jun 2010 12:51:37 -0400
Message-ID: <1275583898-17908-2-git-send-email-steved@redhat.com>
References: <1275583898-17908-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13513 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755096Ab0FCQvl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jun 2010 12:51:41 -0400
Received: from int-mx03.intmail.prod.int.phx2.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o53Gpe1H020938
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 3 Jun 2010 12:51:40 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx03.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o53GpeKW024332
	for <linux-nfs@vger.kernel.org>; Thu, 3 Jun 2010 12:51:40 -0400
Received: from localhost.localdomain (fathat.boston.devel.redhat.com [10.16.60.125])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id o53GpcaD027759
	for <linux-nfs@vger.kernel.org>; Thu, 3 Jun 2010 12:51:39 -0400
In-Reply-To: <1275583898-17908-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mount.nfs should not only fail when an invalid option values
are supplied (as it does), it should also print a diagnostic
message identifying the problem

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c   |   29 +++++++++++++++++++++++++----
 utils/mount/nfsumount.c |    4 +---
 2 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index c541257..b08ce80 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1211,7 +1211,10 @@ nfs_nfs_program(struct mount_options *options, unsigned long *program)
 			*program = tmp;
 			return 1;
 		}
+	/* FALLTHRU */
 	case PO_BAD_VALUE:
+		nfs_error(_("%s: invalid value for 'nfsprog=' option"),
+				progname);
 		return 0;
 	}
 
@@ -1249,11 +1252,14 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 				*version = tmp;
 				return 1;
 			}
+		/* FALLTHRU */
+		case PO_BAD_VALUE:
+			nfs_error(_("%s: invalid value for 'vers=' option"),
+					progname);
 			return 0;
 		case PO_NOT_FOUND:
-			nfs_error(_("%s: option parsing error\n"),
+			nfs_error(_("%s: parsing error on 'vers=' option\n"),
 					progname);
-		case PO_BAD_VALUE:
 			return 0;
 		}
 	case 4: /* nfsvers */
@@ -1263,11 +1269,14 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 				*version = tmp;
 				return 1;
 			}
+		/* FALLTHRU */
+		case PO_BAD_VALUE:
+			nfs_error(_("%s: invalid value for 'nfsvers=' option"),
+					progname);
 			return 0;
 		case PO_NOT_FOUND:
-			nfs_error(_("%s: option parsing error\n"),
+			nfs_error(_("%s: parsing error on 'nfsvers=' option\n"),
 					progname);
-		case PO_BAD_VALUE:
 			return 0;
 		}
 	}
@@ -1335,7 +1344,10 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
 			*port = tmp;
 			return 1;
 		}
+	/* FALLTHRU */
 	case PO_BAD_VALUE:
+		nfs_error(_("%s: invalid value for 'port=' option"),
+				progname);
 		return 0;
 	}
 
@@ -1422,7 +1434,10 @@ nfs_mount_program(struct mount_options *options, unsigned long *program)
 			*program = tmp;
 			return 1;
 		}
+	/* FALLTHRU */
 	case PO_BAD_VALUE:
+		nfs_error(_("%s: invalid value for 'mountprog=' option"),
+				progname);
 		return 0;
 	}
 
@@ -1451,7 +1466,10 @@ nfs_mount_version(struct mount_options *options, unsigned long *version)
 			*version = tmp;
 			return 1;
 		}
+	/* FALLTHRU */
 	case PO_BAD_VALUE:
+		nfs_error(_("%s: invalid value for 'mountvers=' option"),
+				progname);
 		return 0;
 	}
 
@@ -1509,7 +1527,10 @@ nfs_mount_port(struct mount_options *options, unsigned long *port)
 			*port = tmp;
 			return 1;
 		}
+	/* FALLTHRU */
 	case PO_BAD_VALUE:
+		nfs_error(_("%s: invalid value for 'mountport=' option"),
+				progname);
 		return 0;
 	}
 
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 9d798a2..1514340 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -179,10 +179,8 @@ static int nfs_umount_do_umnt(struct mount_options *options,
 	struct pmap nfs_pmap, mnt_pmap;
 	sa_family_t family;
 
-	if (!nfs_options2pmap(options, &nfs_pmap, &mnt_pmap)) {
-		nfs_error(_("%s: bad mount options"), progname);
+	if (!nfs_options2pmap(options, &nfs_pmap, &mnt_pmap))
 		return EX_FAIL;
-	}
 
 	/* Skip UMNT call for vers=4 mounts */
 	if (nfs_pmap.pm_vers == 4)
-- 
1.6.5.2

