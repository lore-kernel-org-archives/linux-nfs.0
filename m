Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36558 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752480AbcLBEAA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 23:00:00 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:30 +1100
Subject: [PATCH 12/15] conffile: allow $name expansion of tag values.
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065110986.28046.17206049919694436884.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the value for a tag starts with '$', then the remainder
of the value is treated as an environment variable name.
It is looked up in the environment (getenv) and if not found,
it is looked for in the [environment] section of the config file.

This lookup is formed as access time e.g. by conf_get_str(), not at
parse time.

The expected usage is that the config file can contain something like

 [environment]
  include = /etc/sysconfig/nfs
 [other-section]
  tag = $NAME

and conf_get_str("other-section","tag") will report the value of "NAME"
in the given file.

As different distributions used different environment files, and different
variable names with-in them, a distro could provide a static config file
which maps from names in that environment file to config tags requires
by NFS daemons.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 support/nfs/conffile.c |   16 ++++++++++++++--
 systemd/nfs.conf.man   |    8 ++++++++
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index eaff5f5c35ea..e4f685c558fa 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -519,12 +519,24 @@ char *
 conf_get_str(char *section, char *tag)
 {
 	struct conf_binding *cb;
-
+retry:
 	cb = LIST_FIRST (&conf_bindings[conf_hash (section)]);
 	for (; cb; cb = LIST_NEXT (cb, link)) {
 		if (strcasecmp (section, cb->section) == 0
-				&& strcasecmp (tag, cb->tag) == 0)
+		    && strcasecmp (tag, cb->tag) == 0) {
+			if (cb->value[0] == '$') {
+				/* expand $name from [environment] section,
+				 * or from environment
+				 */
+				char *env = getenv(cb->value+1);
+				if (env)
+					return env;
+				section = "environment";
+				tag = cb->value + 1;
+				goto retry;
+			}
 			return cb->value;
+		}
 	}
 	return 0;
 }
diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 8cf55668b664..03f1f2be534d 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -45,6 +45,14 @@ or
 .RB \*(lq ; \*(rq
 is ignored, as is any blank line.
 .PP
+If the assigned value started with a
+.RB \*(lq $ \*(rq
+then the remainder is treated as a name and looked for in the section
+.B [environment]
+or in the processes environment (see
+.BR environ (7)).
+The value found is used for this value.
+.PP
 The value name
 .B include
 is special.  If a section contains


