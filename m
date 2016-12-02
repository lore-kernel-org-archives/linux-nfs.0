Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36500 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751164AbcLBD7m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 22:59:42 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:29 +1100
Subject: [PATCH 09/15] conffile: add support for include files.
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065110951.28046.8875061295599340938.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A tag

  include = filename

will be replaced by the content of the file.
This must appear after a section heading, and any assignments
not in their own section will be included in the section that this
directive is in.
e.g

 [environment]
  include = /etc/sysconfig/nfs

Signed-off-by: NeilBrown <neilb@suse.com>
---
 support/nfs/conffile.c |    8 ++++++--
 systemd/nfs.conf.man   |   13 +++++++++++++
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 965726c74f6b..8de580bd6970 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -52,6 +52,7 @@
 #pragma GCC visibility push(hidden)
 
 static void conf_load_defaults(void);
+static int conf_load(int trans, char *path);
 static int conf_set(int , char *, char *, char *, 
 	char *, int , int );
 
@@ -308,8 +309,11 @@ conf_parse_line(int trans, char *line, size_t sz)
 					break;
 				}
 			}
-			/* XXX Perhaps should we not ignore errors?  */
-			conf_set(trans, section, arg, line, val, 0, 0);
+			if (strcasecmp(line, "include") == 0)
+				conf_load(trans, val);
+			else
+				/* XXX Perhaps should we not ignore errors?  */
+				conf_set(trans, section, arg, line, val, 0, 0);
 			return;
 		}
 	}
diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 726f603544b7..13459ea85744 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -42,6 +42,19 @@ or
 .RB \*(lq ; \*(rq
 is ignored, as is any blank line.
 .PP
+The value name
+.B include
+is special.  If a section contains
+.RS
+.B include = /some/file/name
+.RE
+then the named file will be read, and any value assignments found
+there-in will be added to the current section.  If the file contains
+section headers, then new sections will be created just as if the
+included file appeared in place of the
+.B include
+line.
+.PP
 Lookup of section and value names is case-insensitive.
 
 Where a Boolean value is expected, any of


