Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:59567 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041Ab1HKSS1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 14:18:27 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 2/2] blkmapd: add man page
Date: Thu, 11 Aug 2011 14:18:21 -0400
Message-Id: <1313086701-7103-2-git-send-email-rees@umich.edu>
In-Reply-To: <1313086701-7103-1-git-send-email-rees@umich.edu>
References: <1313086701-7103-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/blkmapd.man |   54 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)
 create mode 100644 utils/blkmapd/blkmapd.man

diff --git a/utils/blkmapd/blkmapd.man b/utils/blkmapd/blkmapd.man
new file mode 100644
index 0000000..fd38122
--- /dev/null
+++ b/utils/blkmapd/blkmapd.man
@@ -0,0 +1,54 @@
+.\"
+.\" Copyright 2011, Jim Rees.
+.\"
+.\" You may distribute under the terms of the GNU General Public
+.\" License as specified in the file COPYING that comes with the
+.\" nfs-utils distribution.
+.\"
+.TH blkmapd 8 "11 August 2011"
+.SH NAME
+blkmapd \- pNFS block layout mapping daemon
+.SH SYNOPSIS
+.B "blkmapd [-d] [-f]"
+.SH DESCRIPTION
+The
+.B blkmapd
+daemon performs device discovery and mapping for the parallel NFS (pNFS) block layout
+client [RFC5663].
+.PP
+The pNFS block layout protocol builds a complex storage hierarchy from a set
+of
+.I simple volumes.
+These simple volumes are addressed by content, using a signature on the
+volume to uniquely name each one.
+The daemon locates a volume by examining each block device in the system for
+the given signature.
+.PP
+The topology typically consists of a hierarchy of volumes built by striping,
+slicing, and concatenating the simple volumes.
+The
+.B blkmapd
+daemon uses the device-mapper driver to construct logical devices that
+reflect the server topology, and passes these devices to the kernel for use
+by the pNFS block layout client.
+.SH OPTIONS
+.TP
+.B -d
+Performs device discovery only then exits.
+.TP
+.B -f
+Runs
+.B blkmapd
+in the foreground and sends output to stderr (as opposed to syslogd)
+.SH SEE ALSO
+.BR nfs (5),
+.BR dmsetup (8)
+.sp
+RFC 5661 for the NFS version 4.1 specification.
+.br
+RFC 5663 for the pNFS block layout specification.
+.SH AUTHORS
+.br
+Haiying Tang <Tang_Haiying@emc.com>
+.br
+Jim Rees <rees@umich.edu>
-- 
1.7.4.1

