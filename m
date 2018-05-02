Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:59158 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751181AbeEBLHb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 May 2018 07:07:31 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 01ED3406C74A
        for <linux-nfs@vger.kernel.org>; Wed,  2 May 2018 11:07:31 +0000 (UTC)
Message-ID: <1525259249.7518.1.camel@redhat.com>
Subject: [PATCH] nfs-utils: Add man page for nfsconftool cli
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Wed, 02 May 2018 12:07:29 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide a man page for the cli tool added by my previous patchset

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 tools/nfsconf/Makefile.am     |  3 ++
 tools/nfsconf/nfsconftool.man | 81 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 84 insertions(+)
 create mode 100644 tools/nfsconf/nfsconftool.man

diff --git a/tools/nfsconf/Makefile.am b/tools/nfsconf/Makefile.am
index 4baaa26..a15a7d9 100644
--- a/tools/nfsconf/Makefile.am
+++ b/tools/nfsconf/Makefile.am
@@ -1,5 +1,8 @@
 ## Process this file with automake to produce Makefile.in
 
+man8_MANS	= nfsconftool.man
+EXTRA_DIST	= $(man8_MANS)
+
 bin_PROGRAMS = nfsconftool
 
 nfsconftool_SOURCES = nfsconfcli.c
diff --git a/tools/nfsconf/nfsconftool.man b/tools/nfsconf/nfsconftool.man
new file mode 100644
index 0000000..b70ec38
--- /dev/null
+++ b/tools/nfsconf/nfsconftool.man
@@ -0,0 +1,81 @@
+.\"
+.\" nfsconftool(8)
+.\"
+.TH nfsconftool 8 "2 May 2018"
+.SH NAME
+nfsconftool \- Query various NFS configuration settings
+.SH SYNOPSIS
+.B nfsconftool \-\-dump
+.RB [ \-v | \-\-verbose ]
+.RB [ \-f | \-\-file
+.IR infile.conf ]
+.RI [ outfile ]
+.P
+.B nfsconftool \-\-get
+.RB [ \-v | \-\-verbose ]
+.RB [ \-f | \-\-file
+.IR infile.conf ]
+.RB [ \-a | \-\-arg
+.IR subsection ]
+.IR section
+.IR tag
+.P
+.B nfsconftool \-\-isset
+.RB [ \-v | \-\-verbose ]
+.RB [ \-f | \-\-file
+.IR infile.conf ]
+.RB [ \-a | \-\-arg
+.IR subsection ]
+.IR section
+.IR tag
+.SH DESCRIPTION
+The
+.B nfsconftool
+command can be used to test for and retrieve configuration settings
+from a range of nfs-utils configuration files.
+.SS Modes
+The following modes are available:
+.IP "\fB\-d, \-\-dump\fP"
+Output an alphabetically sorted dump of the current configuration in conf file format. Accepts an optional filename in which to write the output.
+.IP "\fB\-i, \-\-isset\fP"
+Test if a specific tag has a value set.
+.IP "\fB\-g, \-\-get\fP"
+Output the current value of the specified tag.
+.SH OPTIONS
+.SS Options valid in all modes
+.TP
+.B \-v, \-\-verbose
+Increase verbosity and print debugging information.
+.TP
+.B \-f, \-\-file \fIinfile\fR
+Select a different config file to operate upon, default is
+.I /etc/nfs.conf
+.SS Options only valid in \fB\-\-get\fR and \fB\-\-isset\fR modes.
+.TP
+.B \-a, \-\-arg \fIsubsection\fR
+Select a specific sub-section
+.SH EXIT STATUS
+.SS \fB\-\-isset\fR mode
+In this mode the command will return success (0) if the selected tag has a value, any other exit code indicates the value is not set, or some other error has occured.
+.SS all other modes
+Success is indicated by an exit status of zero, any other status indicates an error. Error messages are output on stderr, and increasing verbosity will give more detailed explanations if any are available.
+.SH EXAMPLES
+.TP
+.B nfsconftool -v --dump --file /tmp/testconf.conf  sorted.conf
+Check a new config file for syntax errors and output a sorted version for ease of comparison with existing settings.
+.TP
+.B if ! nfsconftool --isset gssd preferred-realm ; then echo 'No prefered realm configured for gss'; fi
+The tool allows for easy testing of configuration values from shell scripts, here we test if a specific value has been set.
+.TP
+.B nfsconftool --file /etc/nfsmount.conf --get --arg /home MountPoint background
+Show default value for \fIbackground\fR option for NFS mounts of the \fI/home\fR path.
+.SH FILES
+.TP
+.B /etc/nfs.conf
+.SH SEE ALSO
+.BR nfsd (8),
+.BR exportfs (8),
+.BR idmapd (8),
+.BR statd (8)
+.SH AUTHOR
+Justin Mitchell <jumitche@redhat.com>
-- 
1.8.3.1



