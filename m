From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 09/12] Use owner rather than filename format in
	choosing cred cache files
Date: Thu, 08 Feb 2007 17:27:35 -0500
Message-ID: <20070208222735.23464.48640.stgit@rock.citi.umich.edu>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFHk6-0006sm-TL
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:51 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HFHk8-0006o4-BQ
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:52 -0800
In-Reply-To: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Kevin Coffman <kwc@citi.umich.edu>

Signed-off-by: Glenn Machin <gmachin@sandia.gov>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>

Some installations use different name formats for their credentials
caches.  Instead of checking that the uid is part of the name, just
make sure that uid is the owner of the file.
This is a modification of the original patch from Glenn.
---

 utils/gssd/krb5_util.c |  106 +++++++++++++++++++++++-------------------------
 1 files changed, 50 insertions(+), 56 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index c43eb36..096f6cf 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -185,72 +185,66 @@ gssd_find_existing_krb5_ccache(uid_t uid
 		perror("scandir looking for krb5 credentials caches");
 	}
 	else if (n > 0) {
-		char substring[128];
-		char fullstring[128];
 		char statname[1024];
-		snprintf(substring, sizeof(substring), "_%d_", uid);
-		snprintf(fullstring, sizeof(fullstring), "_%d", uid);
 		for (i = 0; i < n; i++) {
 			printerr(3, "CC file '%s' being considered\n",
 				 namelist[i]->d_name);
-			if (strstr(namelist[i]->d_name, substring) ||
-			    !strcmp(namelist[i]->d_name, fullstring)) {
-				snprintf(statname, sizeof(statname),
-					 "%s/%s", ccachedir,
-					 namelist[i]->d_name);
-				if (stat(statname, &tmp_stat)) {
-					printerr(0, "Error doing stat "
-						    "on file '%s'\n",
-						 statname);
-					continue;
-				}
-				if (!S_ISREG(tmp_stat.st_mode)) {
-					printerr(3, "File '%s' is not "
-						    "a regular file\n",
-						 statname);
-					continue;
-				}
-				printerr(3, "CC file '%s' matches "
-					    "name check and has "
-					    "mtime of %u\n",
-					 namelist[i]->d_name,
-					 tmp_stat.st_mtime);
-				/* if more than one match is found,
-				 * return the most recent (the one
-				 * with the latest mtime),
-				 * and don't free the dirent */
-				if (!found) {
+			snprintf(statname, sizeof(statname),
+				 "%s/%s", ccachedir, namelist[i]->d_name);
+			if (stat(statname, &tmp_stat)) {
+				printerr(0, "Error doing stat on file '%s'\n",
+					 statname);
+				free(namelist[i]);
+				continue;
+			}
+			/* Only pick caches owned by the user (uid) */
+			if (tmp_stat.st_uid != uid) {
+				printerr(3, "'%s' owned by %u, not %u\n",
+					 statname, tmp_stat.st_uid, uid);
+				free(namelist[i]);
+				continue;
+			}
+			if (!S_ISREG(tmp_stat.st_mode)) {
+				printerr(3, "'%s' is not a regular file\n",
+					 statname);
+				free(namelist[i]);
+				continue;
+			}
+			printerr(3, "CC file '%s' matches owner check and has "
+				 "mtime of %u\n",
+				 namelist[i]->d_name, tmp_stat.st_mtime);
+			/*
+			 * if more than one match is found, return the most
+			 * recent (the one with the latest mtime), and
+			 * don't free the dirent
+			 */
+			if (!found) {
+				best_match_dir = namelist[i];
+				best_match_stat = tmp_stat;
+				found++;
+			}
+			else {
+				/*
+				 * If the current match has an mtime later
+				 * than the one we are looking at, then use
+				 * the current match.  Otherwise, we still
+				 * have the best match.
+				 */
+				if (tmp_stat.st_mtime >
+					    best_match_stat.st_mtime) {
+					free(best_match_dir);
 					best_match_dir = namelist[i];
 					best_match_stat = tmp_stat;
-					found++;
 				}
 				else {
-					/*
-					 * If the current match has
-					 * an mtime later than the
-					 * one we are looking at,
-					 * then use the current match.
-					 * Otherwise, we still have
-					 * the best match.
-					 */
-					if (tmp_stat.st_mtime >
-						    best_match_stat.st_mtime) {
-						free(best_match_dir);
-						best_match_dir = namelist[i];
-						best_match_stat = tmp_stat;
-					}
-					else {
-						free(namelist[i]);
-					}
-					printerr(3, "CC file '%s' is our "
-						    "current best match "
-						    "with mtime of %u\n",
-						 best_match_dir->d_name,
-						 best_match_stat.st_mtime);
+					free(namelist[i]);
 				}
+				printerr(3, "CC file '%s' is our "
+					    "current best match "
+					    "with mtime of %u\n",
+					 best_match_dir->d_name,
+					 best_match_stat.st_mtime);
 			}
-			else
-				free(namelist[i]);
 		}
 		free(namelist);
 	}

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
