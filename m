Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:59187 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756937Ab3IHQ6p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 8 Sep 2013 12:58:45 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] exportfs: Fix the default authentication flavour setting
Date: Sun, 8 Sep 2013 12:58:39 -0400
Message-ID: <1378659519-18924-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 11ba3b1e01b67b7d19f26fba94fabdb60878e809 (Add a default flavor
to an export's e_secinfo list) breaks the ordering of security flavours
in the secinfo list, by reordering 'sec=sys' to always be the first
secinfo flavour if one fails to set a default 'sec' setting.

An export of the form:

/export -sync,no_subtree_check,mp \
           192.168.1.0/24(sec=krb5p:krb5i:krb5,rw,sec=sys,ro)

ends up getting translated by exportfs into the following entry in
/var/lib/nfs/etab:

/export	192.168.1.0/24(ro,sync,wdelay,hide,nocrossmnt,\
                       secure,root_squash,no_all_squash,\
		       no_subtree_check,secure_locks,acl,\
		       mountpoint,anonuid=65534,anongid=65534,\
		       sec=sys,ro,root_squash,no_all_squash,\
		       sec=krb5p:krb5i:krb5,rw,root_squash,no_all_squash)

Note how the 'sec=sys' is now listed first...

The fix is to defer adding the default flavour until the call to
secinfo_show, when we can see if it is even needed at all.
With the patch, the above export is now correctly entered in
/var/lib/nfs/etab as:

/export	192.168.1.0/24(ro,sync,wdelay,hide,nocrossmnt,\
			secure,root_squash,no_all_squash,\
			no_subtree_check,secure_locks,acl,\
			mountpoint,anonuid=65534,anongid=65534,\
			sec=krb5p:krb5i:krb5,rw,root_squash,no_all_squash,\
			sec=sys,ro,root_squash,no_all_squash)

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
---
 support/nfs/exports.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index dea040f..3e99de6 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -63,6 +63,7 @@ static int	parsesquash(char *list, int **idp, int *lenp, char **ep);
 static int	parsenum(char **cpp);
 static void	freesquash(void);
 static void	syntaxerr(char *msg);
+static struct flav_info *find_flavor(char *name);
 
 void
 setexportent(char *fname, char *type)
@@ -201,6 +202,8 @@ void secinfo_show(FILE *fp, struct exportent *ep)
 	struct sec_entry *p1, *p2;
 	int flags;
 
+	if (ep->e_secinfo[0].flav == NULL)
+		secinfo_addflavor(find_flavor("sys"), ep);
 	for (p1=ep->e_secinfo; p1->flav; p1=p2) {
 
 		fprintf(fp, ",sec=%s", p1->flav->flavour);
@@ -643,8 +646,6 @@ bad_option:
 			cp++;
 	}
 
-	if (ep->e_secinfo[0].flav == NULL)
-		secinfo_addflavor(find_flavor("sys"), ep);
 	fix_pseudoflavor_flags(ep);
 	ep->e_squids = squids;
 	ep->e_sqgids = sqgids;
-- 
1.8.3.1

