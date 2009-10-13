Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34284 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760764AbZJMRcJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Oct 2009 13:32:09 -0400
Date: Tue, 13 Oct 2009 13:31:38 -0400
From: Jeff Layton <jlayton@redhat.com>
To: raini@rainiday.com
Cc: linux-nfs@vger.kernel.org, "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
Message-ID: <20091013133138.77c2cf35@tlielax.poochiereds.net>
In-Reply-To: <08395e6249442278ab2b59c2ae4cfd14.squirrel@webmail.rainiday.com>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
	<20091009121602.5ec86dfb@tlielax.poochiereds.net>
	<1c358fde92c49215d84129a1bfe2c6ec.squirrel@webmail.rainiday.com>
	<20091010090039.4dfd1dfb@tlielax.poochiereds.net>
	<ee56329e7d86a3e4b15001a39bb7e14a.squirrel@webmail.rainiday.com>
	<20091013114441.2882c8b9@tlielax.poochiereds.net>
	<08395e6249442278ab2b59c2ae4cfd14.squirrel@webmail.rainiday.com>
Content-Type: multipart/mixed; boundary="MP_/84qp.4tUk996V6J98+xc.yH"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--MP_/84qp.4tUk996V6J98+xc.yH
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tue, 13 Oct 2009 08:59:29 -0700
raini@rainiday.com wrote:

> 
> > You and Kevin are correct. rpc.gssd only looks at the mtime. When I did
> > the work to allow the CIFS SPNGEO upcall to find alternate credcaches,
> > I implemented the behavior I described (prefer the latest TGT
> > expiration) -- sorry for the confusion...
> >
> > It probably wouldn't be too hard to change rpc.gssd to prefer
> > credcaches with the latest TGT expiration if it was considered a
> > desirable change.
> >
> > Kevin, any thoughts?
> 
> This would be a big plus from me - I still wouldn't be able to create
> per-job ccaches of course, but if a user who knew they needed to run a job
> could create a long lifetime renewable ticket in /tmp/krb5cc_<uid>_batch,
> say, and NFS would use this in preference to a later login ticket, this
> would really help.
> 
> 

Ok, here's a proposed patch...only compile-tested so far. I don't have
time at the moment to test it more extensively so if you could test it
out and report back, that would be helpful.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>

--MP_/84qp.4tUk996V6J98+xc.yH
Content-Type: text/x-patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=0001-gssd-prefer-credcaches-with-latest-TGT-expiration.patch

>From 39564369e8a22b97f4a3021eb527eaf6524ca557 Mon Sep 17 00:00:00 2001
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 13 Oct 2009 13:27:52 -0400
Subject: [PATCH] gssd: prefer credcaches with latest TGT expiration

(Note: this is only compile-tested so far)

gssd currently walks all of the entities in the credcache dir that look
like credcaches, verifies that they are valid and picks the one with the
latest mtime.

There's a problem here however, the one with the latest mtime might still
expire very soon after we pick it. Instead of doing that, have it instead
pick the credcache that has the latest TGT expiration.

With this, someone who wants to run a long-running batch job can get a
TGT with a long expiration time and have some reasonable hope that it'll
run to completion.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/krb5_util.c |   72 ++++++++++++++++++-----------------------------
 1 files changed, 28 insertions(+), 44 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 78e9775..8f1f56d 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -134,11 +134,11 @@ struct gssd_k5_kt_princ *gssd_k5_kt_princ_list = NULL;
 /*==========================*/
 
 static int select_krb5_ccache(const struct dirent *d);
-static int gssd_find_existing_krb5_ccache(uid_t uid, char *dirname,
+static time_t gssd_find_existing_krb5_ccache(uid_t uid, char *dirname,
 		struct dirent **d);
 static int gssd_get_single_krb5_cred(krb5_context context,
 		krb5_keytab kt, struct gssd_k5_kt_princ *ple, int nocache);
-static int query_krb5_ccache(const char* cred_cache, char **ret_princname,
+static time_t query_krb5_ccache(const char* cred_cache, char **ret_princname,
 		char **ret_realm);
 
 /*
@@ -171,24 +171,22 @@ select_krb5_ccache(const struct dirent *d)
  * The caller is responsible for freeing the dirent if one is returned.
  *
  * Returns:
- *	0 => could not find an existing entry
- *	1 => found an existing entry
+ *	 0 => could not find an existing entry
+ *	>0 => found an existing entry
  */
-static int
+static time_t
 gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 {
 	struct dirent **namelist;
 	int n;
 	int i;
-	int found = 0;
 	struct dirent *best_match_dir = NULL;
-	struct stat best_match_stat, tmp_stat;
+	struct stat tmp_stat;
 	char buf[1030];
 	char *princname = NULL;
 	char *realm = NULL;
-	int score, best_match_score = 0;
+	time_t tmp_time, best_match_time = 0;
 
-	memset(&best_match_stat, 0, sizeof(best_match_stat));
 	*d = NULL;
 	n = scandir(dirname, &namelist, select_krb5_ccache, 0);
 	if (n < 0) {
@@ -225,18 +223,15 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 				free(namelist[i]);
 				continue;
 			}
-			if (!query_krb5_ccache(buf, &princname, &realm)) {
+
+			tmp_time = query_krb5_ccache(buf, &princname, &realm);
+			if (!tmp_time) {
 				printerr(3, "CC file '%s' is expired or corrupt\n",
 					 statname);
 				free(namelist[i]);
 				continue;
 			}
 
-			score = 0;
-			if (preferred_realm &&
-					strcmp(realm, preferred_realm) == 0) 
-				score++;
-
 			printerr(3, "CC file '%s'(%s@%s) passed all checks and"
 				    " has mtime of %u\n",
 				 statname, princname, realm, 
@@ -246,49 +241,38 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
 			 * recent (the one with the latest mtime), and
 			 * don't free the dirent
 			 */
-			if (!found) {
+			if (!best_match_time) {
 				best_match_dir = namelist[i];
-				best_match_stat = tmp_stat;
-				best_match_score = score;
-				found++;
-			}
-			else {
+				best_match_time = tmp_time;
+			} else {
 				/*
-				 * If current score is higher than best match 
-				 * score, we use the current match. Otherwise,
-				 * if the current match has an mtime later
-				 * than the one we are looking at, then use
-				 * the current match.  Otherwise, we still
-				 * have the best match.
+				 * prefer the credcache that has the latest
+				 * TGT expiration time. This is helpful when
+				 * for ensuring that long-running jobs don't
+				 * lose their credentials.
 				 */
-				if (best_match_score < score ||
-				    (best_match_score == score && 
-				       tmp_stat.st_mtime >
-					    best_match_stat.st_mtime)) {
+				if (tmp_time > best_match_time) {
 					free(best_match_dir);
 					best_match_dir = namelist[i];
-					best_match_stat = tmp_stat;
-					best_match_score = score;
-				}
-				else {
+					best_match_time = tmp_time;
+				} else {
 					free(namelist[i]);
 				}
 				printerr(3, "CC file '%s/%s' is our "
 					    "current best match "
-					    "with mtime of %u\n",
+					    "with expire time of %u\n",
 					 dirname, best_match_dir->d_name,
-					 best_match_stat.st_mtime);
+					 best_match_time);
 			}
 			free(princname);
 			free(realm);
 		}
 		free(namelist);
 	}
-	if (found)
-	{
+	if (best_match_time)
 		*d = best_match_dir;
-	}
-	return found;
+
+	return best_match_time;
 }
 
 
@@ -935,7 +919,7 @@ static inline int data_is_equal(krb5_data d1, krb5_data d2)
 		&& memcmp(d1.data, d2.data, d1.length) == 0);
 }
 
-static int
+static time_t
 check_for_tgt(krb5_context context, krb5_ccache ccache,
 	      krb5_principal principal)
 {
@@ -959,7 +943,7 @@ check_for_tgt(krb5_context context, krb5_ccache ccache,
 				data_is_equal(creds.server->data[1],
 					      principal->realm) &&
 				creds.times.endtime > time(NULL))
-			found = 1;
+			found = creds.times.endtime;
 		krb5_free_cred_contents(context, &creds);
 	}
 	krb5_cc_end_seq_get(context, ccache, &cur);
@@ -967,7 +951,7 @@ check_for_tgt(krb5_context context, krb5_ccache ccache,
 	return found;
 }
 
-static int
+static time_t
 query_krb5_ccache(const char* cred_cache, char **ret_princname,
 		  char **ret_realm)
 {
-- 
1.6.0.6


--MP_/84qp.4tUk996V6J98+xc.yH--
