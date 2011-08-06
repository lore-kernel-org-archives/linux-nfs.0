Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gerard.telenet-ops.be ([195.130.132.48]:55187 "EHLO
	gerard.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657Ab1HFHlg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2011 03:41:36 -0400
From: Luk Claes <luk@debian.org>
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Cc: Luk Claes <luk@debian.org>, Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 6/6] nfs.man: Fix macro use for fstab examples
Date: Sat,  6 Aug 2011 09:41:19 +0200
Message-Id: <1312616479-312-7-git-send-email-luk@debian.org>
In-Reply-To: <1312616479-312-1-git-send-email-luk@debian.org>
References: <1312616479-312-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The groff macros for filling (word-wrapping) and tabulation control are
lower-case, but are written in upper-case here and so have been ignored.

Change the .NF and .FI lines to lower-case.

Change the .TA lines to lower-case and fix the tab stops to work both
on a terminal and in Postscript output.

Delete the .SP line where .sp would be redundant.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Luk Claes <luk@debian.org>
---
 utils/mount/nfs.man |   37 ++++++++++++++++++-------------------
 1 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 6152235..dfb0bc9 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -46,11 +46,10 @@ files on this mount point.
 The fifth and sixth fields on each line are not used
 by NFS, thus conventionally each contain the digit zero. For example:
 .P
-.SP
-.NF
-.TA 2.5i +0.75i +0.75i +1.0i
+.nf
+.ta 8n +14n +14n +9n +20n
 	server:path	/mountpoint	fstype	option,option,...	0 0
-.FI
+.fi
 .P
 The server's hostname and export pathname
 are separated by a colon, while
@@ -900,40 +899,40 @@ The following example from an
 file causes the mount command to negotiate
 reasonable defaults for NFS behavior.
 .P
-.NF
-.TA 2.5i +0.7i +0.7i +.7i
+.nf
+.ta 8n +16n +6n +6n +30n
 	server:/export	/mnt	nfs	defaults	0 0
-.FI
+.fi
 .P
 Here is an example from an /etc/fstab file for an NFS version 2 mount over UDP.
 .P
-.NF
-.TA 2.5i +0.7i +0.7i +.7i
+.nf
+.ta 8n +16n +6n +6n +30n
 	server:/export	/mnt	nfs	nfsvers=2,proto=udp	0 0
-.FI
+.fi
 .P
 Try this example to mount using NFS version 4 over TCP
 with Kerberos 5 mutual authentication.
 .P
-.NF
-.TA 2.5i +0.7i +0.7i +.7i
+.nf
+.ta 8n +16n +6n +6n +30n
 	server:/export	/mnt	nfs4	sec=krb5	0 0
-.FI
+.fi
 .P
 This example can be used to mount /usr over NFS.
 .P
-.NF
-.TA 2.5i +0.7i +0.7i +.7i
+.nf
+.ta 8n +16n +6n +6n +30n
 	server:/export	/usr	nfs	ro,nolock,nocto,actimeo=3600	0 0
-.FI
+.fi
 .P
 This example shows how to mount an NFS server
 using a raw IPv6 link-local address.
 .P
-.NF
-.TA 2.5i +0.7i +0.7i +.7i
+.nf
+.ta 8n +40n +5n +4n +9n
 	[fe80::215:c5ff:fb3e:e2b1%eth0]:/export	/mnt	nfs	defaults	0 0
-.FI
+.fi
 .SH "TRANSPORT METHODS"
 NFS clients send requests to NFS servers via
 Remote Procedure Calls, or
-- 
1.7.5.4

