Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36359 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751316AbcLBD64 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 22:58:56 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:28 +1100
Subject: [PATCH 01/15] Add man-page describing /etc/nfs.conf
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065110794.28046.7740199040148300941.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It may seem a little odd placing this in the "systemd" directory,
but it is a conveninent place, and /etc/nfs.conf was added in
part to help with systemd integration.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/Makefile.am  |    4 ++-
 systemd/nfs.conf.man |   67 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 70 insertions(+), 1 deletion(-)
 create mode 100644 systemd/nfs.conf.man

diff --git a/systemd/Makefile.am b/systemd/Makefile.am
index 49c9b8d3b459..b647ef00a0d1 100644
--- a/systemd/Makefile.am
+++ b/systemd/Makefile.am
@@ -36,7 +36,9 @@ unit_files += \
 endif
 endif
 
-EXTRA_DIST = $(unit_files)
+man5_MANS	= nfs.conf.man
+
+EXTRA_DIST = $(unit_files) $(man5_MANS)
 
 unit_dir = /usr/lib/systemd/system
 generator_dir = /usr/lib/systemd/system-generators
diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
new file mode 100644
index 000000000000..3dd56f735de2
--- /dev/null
+++ b/systemd/nfs.conf.man
@@ -0,0 +1,67 @@
+.TH NFS.CONF 5
+.SH NAME
+nfs.conf \- general configuration for NFS daemons and tools
+.SH SYNOPSIS
+.I /etc/nfs.conf
+.SH DESCRIPTION
+.PP
+This file contains site-specific configuration for various NFS daemons
+and other processes.  Most configuration can also be passed to
+processes via command line arguments, but it can be more convenient to
+have a central file.  In particular, this encourages consistent
+configuration across different processes.
+.PP
+When command line options are provided, they override values set in
+this file.  When this file does not specify a particular parameter,
+and no command line option is provided, each tool provides its own
+default values.
+.PP
+The file format supports multiple sections, each of which can contain
+multiple value assignments.  A section is introduced by a line
+containing the section name enclosed in square brackets, so
+.RS
+.B [global]
+.RE
+would introduce a section called
+.BR global .
+A value assignment is a single line that has the name of the value, an
+equals sign, and a setting for the value, so
+.RS
+.B threads = 4
+.RE
+would set the value named
+.B threads
+in the current section to
+.BR 4 .
+Leading and trailing spaces and tab
+are ignored, as are spaces and tabs surrounding the equals sign.
+.PP
+Any line starting with
+.RB \*(lq # \*(rq
+or
+.RB \*(lq ; \*(rq
+is ignored, as is any blank line.
+.PP
+Lookup of section and value names is case-insensitive.
+
+.SH SECTIONS
+The following sections are known to various programs, and can contain
+the given named values.
+.TP
+.B nfsdcltrack
+Recognized values:
+.BR storagedir .
+
+The
+.B nfsdcltrack
+program is run directly by the Linux kernel and there is no
+opportunity to provide command line arguments, so the configuration
+file is the only way to configure this program.  See
+.BR nfsdcltrack (8)
+for details.
+
+.SH FILES
+.I /etc/nfs.conf
+.SH SEE ALSO
+.BR nfsdcltrack (8),
+.BR nfsmount.conf (5).


