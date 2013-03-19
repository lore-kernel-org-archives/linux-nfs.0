Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e35.co.us.ibm.com ([32.97.110.153]:44536 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932275Ab3CSVdX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 17:33:23 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <cvogan@us.ibm.com>;
	Tue, 19 Mar 2013 15:33:21 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A0ECC19D8042
	for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 15:32:49 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2JLWkjH085510
	for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 15:32:47 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2JLWf3C017693
	for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 15:32:42 -0600
Received: from d03nm116.boulder.ibm.com (d03nm116.boulder.ibm.com [9.63.40.222])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r2JLWfxI017519
	for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 15:32:41 -0600
To: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Subject: NFS man page patch that moves nordirplus/rdirplus
Message-ID: <OF0365F8D8.55071FDA-ON87257B33.00762456-86257B33.00765660@us.ibm.com>
From: Christopher T Vogan <cvogan@us.ibm.com>
Date: Tue, 19 Mar 2013 16:32:33 -0500
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS man page patch that moves nordirplus/rdirplus from "Options for NFS 
versions 2 and 3 only" to "Options supported by all versions".  Its a 
better fit here since this option is also needed for some NFSv4 servers.


Author: Chris Vogan <cvogan@us.ibm.com>
Date:   Fri Feb 28 14:40:11 2013 -0700

    NFS man page needs updating to clarify that nordirplus mount option
    is also valid for NFSv4. Also should be moved to the section
    "Options supported by all versions".

    Signed-off-by: Chris Vogan <cvogan@gmail.com>
--- nfs.man.save        2013-02-28 14:40:11.530103375 -0700
+++ nfs.man     2013-02-28 14:42:48.028996087 -0700
@@ -345,6 +345,13 @@
 .BR automount (8)
 for details).
 .TP 1.5i
+.BR rdirplus " / " nordirplus
+Selects whether to use NFS v3 or v4 READDIRPLUS requests.
+If this option is not specified, the NFS client uses READDIRPLUS requests
+on NFS v3 or v4 mounts to read small directories.
+Some applications perform better if the client uses only READDIR requests
+for all directories.
+.TP 1.5i
 .BI retry= n
 The number of minutes that the
 .BR mount (8)
@@ -710,13 +717,6 @@
 Disabling the NFSACL sideband protocol may be necessary
 if the negotiation causes problems on the client or server.
 Refer to the SECURITY CONSIDERATIONS section for more details.
-.TP 1.5i
-.BR rdirplus " / " nordirplus
-Selects whether to use NFS version 3 READDIRPLUS requests.
-If this option is not specified, the NFS client uses READDIRPLUS requests
-on NFS version 3 mounts to read small directories.
-Some applications perform better if the client uses only READDIR requests
-for all directories.
 .SS "Options for version 4 only"
 Use these options, along with the options in the first subsection above,
 for NFSv4 only. They will be ignored with older versions.


Christopher Vogan
Dept. W98 NFS Development & Test

