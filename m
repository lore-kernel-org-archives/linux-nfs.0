Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e7.ny.us.ibm.com ([32.97.182.137]:55431 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932611Ab3CYSnu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 14:43:50 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <cvogan@us.ibm.com>;
	Mon, 25 Mar 2013 14:43:49 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 526676E802A
	for <linux-nfs@vger.kernel.org>; Mon, 25 Mar 2013 14:43:43 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2PIhiiO338582
	for <linux-nfs@vger.kernel.org>; Mon, 25 Mar 2013 14:43:44 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2PIhhp0027332
	for <linux-nfs@vger.kernel.org>; Mon, 25 Mar 2013 12:43:43 -0600
Received: from d03nm116.boulder.ibm.com (d03nm116.boulder.ibm.com [9.63.40.222])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r2PIhg5i027269
	for <linux-nfs@vger.kernel.org>; Mon, 25 Mar 2013 12:43:43 -0600
To: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Subject: [Patch] nfs.man: Move nfsvers to "Options supported by all versions" section
Message-ID: <OF1B1919A7.AE5DDE4D-ON87257B39.0065E293-86257B39.0066DDA1@us.ibm.com>
From: Christopher T Vogan <cvogan@us.ibm.com>
Date: Mon, 25 Mar 2013 13:43:33 -0500
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After inclusion of NFSv4.1 it seems that now you can specify an NFSv4 
mount with either "-tnfs4" or "-overs=4".  I have prepared a patch that 
moves "nfsvers/vers" from "Options for NFS versions 2 and 3 only" to 
"Options supported by all versions".

Author: Chris Vogan <cvogan@us.ibm.com>
Date:   Mon Mar 25 10:12:57 2013 -0700

    Update NFS man page to state that "nfsvers=/vers=" is suitable for all 
NFS version.
    Move from "Options for NFS versions 2 and 3 only" to "Options 
supported by all versions".

    Signed-off-by: Chris Vogan <cvogan@gmail.com>
--- nfs-utils-1.2.7/utils/mount/nfs.man.save    2013-03-25 
10:05:57.781645020 -0700
+++ nfs-utils-1.2.7/utils/mount/nfs.man 2013-03-25 10:12:57.013454158 
-0700
@@ -467,6 +467,18 @@
 and <kernel_soruce>/Documentation/filesystems/caching
 for detail on how to configure the FS-Cache facility.
 Default value is nofsc.
+.TP 1.5i
+.BI nfsvers= n
+The NFS protocol version number used to contact the server's NFS service.
+If the server does not support the requested version, the mount request 
fails.
+If this option is not specified, the client negotiates a suitable version 
with
+the server, trying version 4 first, version 3 second, and version 2 last.
+.TP 1.5i
+.BI vers= n
+This option is an alternative to the
+.B nfsvers
+option.
+It is included for compatibility with other operating systems.
 .SS "Options for NFS versions 2 and 3 only"
 Use these options, along with the options in the above subsection,
 for NFS versions 2 and 3 only.
@@ -613,18 +625,6 @@
 reports the proper maximum component length to applications
 in such cases.
 .TP 1.5i
-.BI nfsvers= n
-The NFS protocol version number used to contact the server's NFS service.
-If the server does not support the requested version, the mount request 
fails.
-If this option is not specified, the client negotiates a suitable version 
with
-the server, trying version 4 first, version 3 second, and version 2 last.
-.TP 1.5i
-.BI vers= n
-This option is an alternative to the
-.B nfsvers
-option.
-It is included for compatibility with other operating systems.
-.TP 1.5i
 .BR lock " / " nolock
 Selects whether to use the NLM sideband protocol to lock files on the 
server.
 If neither option is specified (or if

Christopher Vogan
Dept. W98 NFS Development & Test

