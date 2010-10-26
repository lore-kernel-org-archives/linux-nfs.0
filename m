Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53668 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab0JZP6k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Oct 2010 11:58:40 -0400
Received: by mail-iw0-f174.google.com with SMTP id 10so2336058iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Oct 2010 08:58:40 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/6] nfs(5): Grammar and style fixes
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 26 Oct 2010 11:58:37 -0400
Message-ID: <20101026155837.19184.77590.stgit@matisse.1015granger.net>
In-Reply-To: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
References: <20101026155216.19184.36979.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up grammar and style issues introduced by recent updates.  Also,
I'm not certain inappropriate options are always ignored.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 01bc712..1b86768 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -69,10 +69,9 @@ for details on specifying raw IPv6 addresses.
 .P
 The
 .I fstype
-field contains "nfs", for whatever version of the protocol.
-The
-.B nfs
-allow several mount options, which are described below.
+field contains "nfs".  Use of the "nfs4" fstype in
+.I /etc/fstab
+is deprecated.
 .SH "MOUNT OPTIONS"
 Refer to
 .BR mount (8)
@@ -464,9 +463,9 @@ by other clients, but can impact application and server performance.
 .IP
 The DATA AND METADATA COHERENCE section contains a
 detailed discussion of these trade-offs.
-.SS "Options for versions 2 and 3 only"
+.SS "Options for NFS versions 2 and 3 only"
 Use these options, along with the options in the above subsection,
-for NFSv2/v3 only. They will be ignored for newer versions.
+for NFS versions 2 and 3 only.
 .TP 1.5i
 .BI proto= netid
 The transport protocol name and protocol family the NFS client uses
@@ -761,9 +760,9 @@ conflicting locks.
 .IP
 NOTE: When used together, the 'local_lock' mount option will be overridden
 by 'nolock'/'lock' mount option.
-.SS "Options for version 4 only"
+.SS "Options for NFS version 4 only"
 Use these options, along with the options in the first subsection above,
-for NFSv4 only. They will be ignored with older versions.
+for NFS version 4 and newer.
 .TP 1.5i
 .BI proto= netid
 The transport protocol name and protocol family the NFS client uses

