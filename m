From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 1/2] mount: silently fails when bad option values are given
Date: Thu,  3 Jun 2010 09:02:13 -0400
Message-ID: <1275570134-24864-2-git-send-email-steved@redhat.com>
References: <1275570134-24864-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:57826 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752510Ab0FCNCP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jun 2010 09:02:15 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1OKA3q-0004JY-DH
	for linux-nfs@vger.kernel.org; Thu, 03 Jun 2010 09:02:14 -0400
In-Reply-To: <1275570134-24864-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mount.nfs should not only fail when an invalid option values
are supplied (as it does), it should also print a diagnostic
message identifying the problem

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/network.c   |   20 ++++++++++++++++++--
 utils/mount/nfsumount.c |    4 +---
 2 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index c541257..d9903ed 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1212,6 +1212,8 @@ nfs_nfs_program(struct mount_options *options, unsigned long *program)
 			return 1;
 		}
 	case PO_BAD_VALUE:
+		nfs_error(_("%s: invalid value for 'nfsprog=' option"),
+				progname);
 		return 0;
 	}
 
@@ -1251,9 +1253,12 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 			}
 			return 0;
 		case PO_NOT_FOUND:
-			nfs_error(_("%s: option parsing error\n"),
+			nfs_error(_("%s: parsing error on 'vers=' option\n"),
 					progname);
+			return 0;
 		case PO_BAD_VALUE:
+			nfs_error(_("%s: invalid value for 'vers=' option"),
+					progname);
 			return 0;
 		}
 	case 4: /* nfsvers */
@@ -1265,9 +1270,12 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
 			}
 			return 0;
 		case PO_NOT_FOUND:
-			nfs_error(_("%s: option parsing error\n"),
+			nfs_error(_("%s: parsing error on 'nfsvers=' option\n"),
 					progname);
+			return 0;
 		case PO_BAD_VALUE:
+			nfs_error(_("%s: invalid value for 'nfsvers=' option"),
+					progname);
 			return 0;
 		}
 	}
@@ -1336,6 +1344,8 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
 			return 1;
 		}
 	case PO_BAD_VALUE:
+		nfs_error(_("%s: invalid value for 'port=' option"),
+				progname);
 		return 0;
 	}
 
@@ -1423,6 +1433,8 @@ nfs_mount_program(struct mount_options *options, unsigned long *program)
 			return 1;
 		}
 	case PO_BAD_VALUE:
+		nfs_error(_("%s: invalid value for 'mountprog=' option"),
+				progname);
 		return 0;
 	}
 
@@ -1452,6 +1464,8 @@ nfs_mount_version(struct mount_options *options, unsigned long *version)
 			return 1;
 		}
 	case PO_BAD_VALUE:
+		nfs_error(_("%s: invalid value for 'mountvers=' option"),
+				progname);
 		return 0;
 	}
 
@@ -1510,6 +1524,8 @@ nfs_mount_port(struct mount_options *options, unsigned long *port)
 			return 1;
 		}
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
1.6.6.1

