Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:32829 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754539AbdCJAi2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Mar 2017 19:38:28 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 10 Mar 2017 11:36:39 +1100
Subject: [PATCH 1/3] NFSD: further refinement of content of
 /proc/fs/nfsd/versions
Cc: Trond Myklebust <trondmy@primarydata.com>, linux-nfs@vger.kernel.org
Message-ID: <148910619911.3032.4329058022476162122.stgit@noble>
In-Reply-To: <148910618557.3032.8265198632788708076.stgit@noble>
References: <148910618557.3032.8265198632788708076.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prior to
  e35659f1b03c ("NFSD: correctly range-check v4.x minor version when setting versions.")

v4.0 could not be disabled without disabling all NFSv4 protocols.
So the 'versions' file contained ±4 ±4.1 ±4.2.
Writing "-4" would disable all v4 completely.  Writing +4 would enabled those
minor versions that are currently enabled, either by default or otherwise.

After that commit, it was possible to disable v4.0 independently.  To
maximize backward compatibility with use cases which never disabled
v4.0, the "versions" file would never contain "+4.0" - that was implied
by "+4", unless explicitly negated by "-4.0".

This introduced an inconsistency in that it was possible to disable all
minor versions, but still have the major version advertised.
e.g. "-4.0 -4.1 -4.2 +4" would result in NFSv4 support being advertised,
but all attempts to use it rejected.

Commit
  d3635ff07e8c ("nfsd: fix configuration of supported minor versions")

and following removed this inconsistency. If all minor version were disabled,
the major would be disabled too.  If any minor was enabled, the major would be
disabled.
This patch also treated "+4" as equivalent to "+4.0" and "-4" as "-4.0".
A consequence of this is that writing "-4" would only disable 4.0.
This is a regression against the earlier behaviour, in a use case that rpc.nfsd
actually uses.
The command "rpc.nfsd -N 4" will write "+2 +3 -4" to the versions files.
Previously, that would disable v4 completely.  Now it will only disable v4.0.

Also "4.0" never appears in the "versions" file when read.
So if only v4.1 is available, the previous kernel would have reported
"+4 -4.0 +4.1 -4.2"  the current kernel reports "-4 +4.1 -4.2" which
could easily confuse.

This patch restores the implication that "+4" and "-4" apply more
globals and do not imply "4.0".
Specifically:
 writing "-4" will disable all 4.x minor versions.
 writing "+4" will enable all 4.1 minor version if none are currently enabled.
    rpc.nfsd will list minor versions before major versions, so
      rpc.nfsd -V 4.2 -N 4.1
    will write "-4.1 +4.2 +2 +3 +4"
    so it would be a regression for "+4" to enable always all versions.
 reading "-4" implies that no v4.x are enabled
 reading "+4" implies that some v4.x are enabled, and that v4.0 is enabled unless
 "-4.0" is also present.  All other minor versions will explicitly be listed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfsd/nfsctl.c |   43 +++++++++++++++++++++++++++++++++----------
 1 file changed, 33 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 73e75ac90525..8bf8f667a8cf 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -538,13 +538,21 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 
 static ssize_t
 nfsd_print_version_support(char *buf, int remaining, const char *sep,
-		unsigned vers, unsigned minor)
+		unsigned vers, int minor)
 {
-	const char *format = (minor == 0) ? "%s%c%u" : "%s%c%u.%u";
+	const char *format = minor < 0 ? "%s%c%u" : "%s%c%u.%u";
 	bool supported = !!nfsd_vers(vers, NFSD_TEST);
 
-	if (vers == 4 && !nfsd_minorversion(minor, NFSD_TEST))
+	if (vers == 4 && minor >= 0 &&
+	    !nfsd_minorversion(minor, NFSD_TEST))
 		supported = false;
+	if (minor == 0 && supported)
+		/*
+		 * special case for backward compatability.
+		 * +4.0 is never reported, it is implied by
+		 * +4, unless -4.0 is present.
+		 */
+		return 0;
 	return snprintf(buf, remaining, format, sep,
 			supported ? '+' : '-', vers, minor);
 }
@@ -554,7 +562,6 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 	char *mesg = buf;
 	char *vers, *minorp, sign;
 	int len, num, remaining;
-	unsigned minor;
 	ssize_t tlen = 0;
 	char *sep;
 	struct nfsd_net *nn = net_generic(netns(file), nfsd_net_id);
@@ -575,6 +582,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 		if (len <= 0) return -EINVAL;
 		do {
 			enum vers_op cmd;
+			unsigned minor;
 			sign = *vers;
 			if (sign == '+' || sign == '-')
 				num = simple_strtol((vers+1), &minorp, 0);
@@ -585,8 +593,8 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 					return -EINVAL;
 				if (kstrtouint(minorp+1, 0, &minor) < 0)
 					return -EINVAL;
-			} else
-				minor = 0;
+			}
+
 			cmd = sign == '-' ? NFSD_CLEAR : NFSD_SET;
 			switch(num) {
 			case 2:
@@ -594,8 +602,20 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 				nfsd_vers(num, cmd);
 				break;
 			case 4:
-				if (nfsd_minorversion(minor, cmd) >= 0)
-					break;
+				if (*minorp == '.') {
+					if (nfsd_minorversion(minor, cmd) < 0)
+						return -EINVAL;
+				} else if ((cmd == NFSD_SET) != nfsd_vers(num, NFSD_TEST)) {
+					/*
+					 * Either we have +4 and no minors are enabled,
+					 * or we have -4 and at least one minor is enabled.
+					 * In either case, propagate 'cmd' to all minors.
+					 */
+					minor = 0;
+					while (nfsd_minorversion(minor, cmd) >= 0)
+						minor++;
+				}
+				break;
 			default:
 				return -EINVAL;
 			}
@@ -612,9 +632,11 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 	sep = "";
 	remaining = SIMPLE_TRANSACTION_LIMIT;
 	for (num=2 ; num <= 4 ; num++) {
+		int minor;
 		if (!nfsd_vers(num, NFSD_AVAIL))
 			continue;
-		minor = 0;
+
+		minor = -1;
 		do {
 			len = nfsd_print_version_support(buf, remaining,
 					sep, num, minor);
@@ -624,7 +646,8 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 			buf += len;
 			tlen += len;
 			minor++;
-			sep = " ";
+			if (len)
+				sep = " ";
 		} while (num == 4 && minor <= NFSD_SUPPORTED_MINOR_VERSION);
 	}
 out:


