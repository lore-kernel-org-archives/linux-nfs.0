Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1-relais-roc.national.inria.fr ([192.134.164.82]:51986 "EHLO
	mail1-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752822Ab0IGJJZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 05:09:25 -0400
From: Guillaume Rousse <Guillaume.Rousse@inria.fr>
To: linux-nfs@vger.kernel.org
Cc: Guillaume Rousse <Guillaume.Rousse@inria.fr>
Subject: [PATCH] clarification about options supported by different versions
Date: Tue,  7 Sep 2010 11:09:18 +0200
Message-Id: <1283850558-9750-1-git-send-email-Guillaume.Rousse@inria.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Signed-off-by: Guillaume Rousse <Guillaume.Rousse@inria.fr>
---
 utils/mount/nfs.man |   50 ++++++++++++++++++++------------------------------
 1 files changed, 20 insertions(+), 30 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 3806635..fe58015 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -3,8 +3,6 @@
 .SH NAME
 nfs \- fstab format and options for the
 .B nfs
-and
-.B nfs4
 file systems
 .SH SYNOPSIS
 .I /etc/fstab
@@ -71,14 +69,10 @@ for details on specifying raw IPv6 addresses.
 .P
 The
 .I fstype
-field contains either "nfs" (for version 2 or version 3 NFS mounts)
-or "nfs4" (for NFS version 4 mounts).
+field contains "nfs", for whatever version of the protocol.
 The
 .B nfs
-and
-.B nfs4
-file system types share similar mount options,
-which are described below.
+allow several mount options, which are described below.
 .SH "MOUNT OPTIONS"
 Refer to
 .BR mount (8)
@@ -89,14 +83,8 @@ specify any mount options, use the generic option
 in
 .IR /etc/fstab .
 .DT
-.SS "Valid options for either the nfs or nfs4 file system type"
-These options are valid to use when mounting either
-.B nfs
-or
-.B nfs4
-file system types.
-They imply the same behavior
-and have the same default for both file system types.
+.SS "Options supported by all versions"
+These options are valid to use with any NFS version.
 .TP 1.5i
 .BR soft " / " hard
 Determines the recovery behavior of the NFS client
@@ -476,11 +464,9 @@ by other clients, but can impact application and server performance.
 .IP
 The DATA AND METADATA COHERENCE section contains a
 detailed discussion of these trade-offs.
-.SS "Valid options for the nfs file system type"
+.SS "Options for versions 2 and 3 only"
 Use these options, along with the options in the above subsection,
-for mounting the
-.B nfs
-file system type.
+for NFSv2/v3 only. They will be ignored for newer versions.
 .TP 1.5i
 .BI proto= netid
 The transport protocol name and protocol family the NFS client uses
@@ -722,11 +708,9 @@ If this option is not specified, the NFS client uses READDIRPLUS requests
 on NFS version 3 mounts to read small directories.
 Some applications perform better if the client uses only READDIR requests
 for all directories.
-.SS "Valid options for the nfs4 file system type"
+.SS "Options for version 4 only"
 Use these options, along with the options in the first subsection above,
-for mounting the
-.B nfs4
-file system type.
+for NFSv4 only. They will be ignored with older versions.
 .TP 1.5i
 .BI proto= netid
 The transport protocol name and protocol family the NFS client uses
@@ -823,6 +807,13 @@ In the presence of multiple client network interfaces,
 special routing policies,
 or atypical network topologies,
 the exact address to use for callbacks may be nontrivial to determine.
+.SH nfs4 FILE SYSTEM TYPE
+The
+.BR nfs4
+file system type is an old syntax for specifying NFSv4 usage. It can still 
+be used with all NFSv4-specific and common options, excepted the
+.B nfsvers
+mount option.
 .SH MOUNT CONFIGURATION FILE
 If the mount command is configured to do so, all of the mount options 
 described in the previous section can also be configured in the 
@@ -844,12 +835,11 @@ file system type and specify the
 .B nfsvers=3
 mount option.
 To mount using NFS version 4,
-use the
-.B nfs4
-file system type.
-The
-.B nfsvers
-mount option is not supported for the
+use either the
+.B nfs
+file system type, with the
+.B nfsvers=4
+mount option, or the 
 .B nfs4
 file system type.
 .P
-- 
1.7.2.3

