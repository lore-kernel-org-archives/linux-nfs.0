Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756302AbZKEODm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Nov 2009 09:03:42 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nA5E3lOL030498
	for <linux-nfs@vger.kernel.org>; Thu, 5 Nov 2009 09:03:48 -0500
Subject: [PATCH] nfs-utils: mount options can be lost when using bg option
From: Harshula Jayasuriya <harshula@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain
Date: Fri, 06 Nov 2009 01:03:45 +1100
Message-Id: <1257429825.2984.26.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

When mounting an NFS export *without* the "bg" option, try_mount() is
called only once. Before calling it, the variables mount_opts and
extra_opts are set up. Then try_mount() calls nfsmount(), the latter
assumes that the aforementioned variables can be modified. Most
significantly, it allows the variable extra_opts to be modified.

When the "bg" mount option is used *and* the first try_mount() attempt
fails, it daemonizes the process and calls try_mount() again,
unfortunately, we've lost the required mount options in the variable
extra_opts.

See https://bugzilla.redhat.com/show_bug.cgi?id=529370 for details.

Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
---
 utils/mount/mount.c    |    3 +++
 utils/mount/nfsmount.c |    7 +++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 355df79..6b9e164 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -593,6 +593,9 @@ int main(int argc, char *argv[])
 	if (mnt_err == EX_BG) {
 		printf(_("%s: backgrounding \"%s\"\n"),
 			progname, spec);
+		printf(_("%s: mount options: \"%s\"\n"),
+			progname, extra_opts);
+
 		fflush(stdout);
 
 		/*
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 6355681..6b3356c 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -170,7 +170,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 	struct pmap *mnt_pmap = &mnt_server->pmap;
 	struct pmap *nfs_pmap = &nfs_server->pmap;
 	int len;
-	char *opt, *opteq, *p, *opt_b;
+	char *opt, *opteq, *p, *opt_b, *tmp_opts;
 	char *mounthost = NULL;
 	char cbuf[128];
 	int open_quote = 0;
@@ -179,7 +179,8 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 	*bg = 0;
 
 	len = strlen(new_opts);
-	for (p=old_opts, opt_b=NULL; p && *p; p++) {
+	tmp_opts = xstrdup(old_opts);
+	for (p=tmp_opts, opt_b=NULL; p && *p; p++) {
 		if (!opt_b)
 			opt_b = p;		/* begin of the option item */
 		if (*p == '"')
@@ -457,10 +458,12 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 			goto out_bad;
 		*mnt_server->hostname = mounthost;
 	}
+	free(tmp_opts);
 	return 1;
  bad_parameter:
 	nfs_error(_("%s: Bad nfs mount parameter: %s\n"), progname, opt);
  out_bad:
+	free(tmp_opts);
 	return 0;
 }
 
--

cya,
#

