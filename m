Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:49487 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754376Ab3DXQI1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2013 12:08:27 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <cvogan@us.ibm.com>;
	Wed, 24 Apr 2013 10:08:25 -0600
In-Reply-To: <OF1B1919A7.AE5DDE4D-ON87257B39.0065E293-86257B39.0066DDA1@us.ibm.com>
References: <OF1B1919A7.AE5DDE4D-ON87257B39.0065E293-86257B39.0066DDA1@us.ibm.com>
To: Christopher T Vogan <cvogan@us.ibm.com>
Cc: linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org
MIME-Version: 1.0
Subject: Re: [Patch] nfs.man: Move nfsvers to "Options supported by all versions" section
Message-ID: <OFC3D6E59E.970CBC4B-ON87257B57.00586B78-86257B57.00588757@us.ibm.com>
From: Christopher T Vogan <cvogan@us.ibm.com>
Date: Wed, 24 Apr 2013 11:06:57 -0500
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Does anyone agree or disagree with a man page update over the placement of 
nfsvers/vers option?


Christopher Vogan
Dept. W98 NFS Development & Test



From:   Christopher T Vogan/San Jose/IBM@IBMUS
To:     linux-nfs@vger.kernel.org, 
Date:   03/25/2013 01:48 PM
Subject:        [Patch] nfs.man: Move nfsvers to "Options supported by all 
versions" section
Sent by:        linux-nfs-owner@vger.kernel.org



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

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html



