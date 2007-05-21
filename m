From: Chris Wright <chrisw@sous-sol.org>
Subject: [patch 17/69] knfsd: Avoid use of unitialised variables on error path when nfs exports.
Date: Mon, 21 May 2007 12:16:29 -0700
Message-ID: <20070521191714.047127000@sous-sol.org>
References: <20070521191612.800400000@sous-sol.org>
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	torvalds@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934058AbXEUTcP@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

-stable review patch.  If anyone has any objections, please let us know.
---------------------

From: NeilBrown <neilb@suse.de>

We need to zero various parts of 'exp' before any 'goto out', otherwise
when we go to free the contents... we die.

Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---

 fs/nfsd/export.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- linux-2.6.21.1.orig/fs/nfsd/export.c
+++ linux-2.6.21.1/fs/nfsd/export.c
@@ -469,6 +469,13 @@ static int svc_export_parse(struct cache
 	nd.dentry = NULL;
 	exp.ex_path = NULL;
 
+	/* fs locations */
+	exp.ex_fslocs.locations = NULL;
+	exp.ex_fslocs.locations_count = 0;
+	exp.ex_fslocs.migrated = 0;
+
+	exp.ex_uuid = NULL;
+
 	if (mesg[mlen-1] != '\n')
 		return -EINVAL;
 	mesg[mlen-1] = 0;
@@ -509,13 +516,6 @@ static int svc_export_parse(struct cache
 	if (exp.h.expiry_time == 0)
 		goto out;
 
-	/* fs locations */
-	exp.ex_fslocs.locations = NULL;
-	exp.ex_fslocs.locations_count = 0;
-	exp.ex_fslocs.migrated = 0;
-
-	exp.ex_uuid = NULL;
-
 	/* flags */
 	err = get_int(&mesg, &an_int);
 	if (err == -ENOENT)

-- 
