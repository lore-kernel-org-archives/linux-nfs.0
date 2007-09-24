From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/14] mount.nfs: teach [u]mount.nfs[4] to exit
	with	EX_SUCCESS instead of 0
Date: Mon, 24 Sep 2007 11:28:38 -0400
Message-ID: <20070924152838.3804.79937.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZps6-0006oq-NR
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:18 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZpsB-000644-GR
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:23 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Use the newly defined EX_SUCCESS exit code in all the right places.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c     |    8 ++++----
 utils/mount/nfs4mount.c |    2 +-
 utils/mount/nfsmount.c  |    2 +-
 utils/mount/nfsumount.c |    4 ++--
 utils/mount/stropts.c   |    4 ++--
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 2513943..751fbb9 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -237,7 +237,7 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 
 	if (flags & MS_REMOUNT) {
 		update_mtab(ment.mnt_dir, &ment);
-		return 0;
+		return EX_SUCCESS;
 	}
 
 	lock_mtab();
@@ -261,7 +261,7 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 		goto fail_close;
 	}
 
-	result = 0;
+	result = EX_SUCCESS;
 
 fail_close:
 	endmntent(mtab);
@@ -421,7 +421,7 @@ int main(int argc, char *argv[])
 			printf("%s ("PACKAGE_STRING")\n", progname);
 		else
 			mount_usage();
-		exit(0);
+		exit(EX_SUCCESS);
 	}
 
 	if ((argc < 3)) {
@@ -444,7 +444,7 @@ int main(int argc, char *argv[])
 			break;
 		case 'V':
 			printf("%s: ("PACKAGE_STRING")\n", progname);
-			exit(0);
+			exit(EX_SUCCESS);
 		case 'w':
 			flags &= ~MS_RDONLY;
 			break;
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index c4e8bfb..4790c79 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -448,7 +448,7 @@ int nfs4mount(const char *spec, const char *node, int flags,
 		}
 	}
 
-	return 0;
+	return EX_SUCCESS;
 
 fail:
 	return retval;
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 5839482..6c34a2b 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -863,7 +863,7 @@ noauth_flavors:
 		}
 	}
 
-	return 0;
+	return EX_SUCCESS;
 
 	/* abort */
  fail:
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index a78ab26..ca9c801 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -209,7 +209,7 @@ static int do_nfs_umount(const char *spec, char *opts)
 		return EX_USAGE;
 	}
 
-	return 0;
+	return EX_SUCCESS;
 }
 
 static struct option umount_longopts[] =
@@ -305,7 +305,7 @@ int nfsumount(int argc, char *argv[])
 			/* umount might call us twice.  The second time there will
 			 * be no entry in mtab and we should just exit quietly
 			 */
-			return 0;
+			return EX_SUCCESS;
 
 		only_root:
 			nfs_error(_("%s: You are not permitted to unmount %s"),
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 236a3b4..a04596d 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -283,7 +283,7 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 		}
 	}
 
-	return 0;
+	return EX_SUCCESS;
 }
 
 /*
@@ -339,5 +339,5 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 		}
 	}
 
-	return 0;
+	return EX_SUCCESS;
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
