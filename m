Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:45412 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755822Ab0KSRjH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Nov 2010 12:39:07 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1PJUvP-0005fG-VF
	for linux-nfs@vger.kernel.org; Fri, 19 Nov 2010 12:39:04 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] nfs-utils: Add nfsidmap (take 2)
Date: Fri, 19 Nov 2010 12:39:01 -0500
Message-Id: <1290188343-10579-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The is a re-post of Bryan origin patches that added
in the new nfsidmap program. I tweaked them in the
following ways:

Rename the binary from nfs.idmap to nfsidmap to maintain
conformity with the rest of the binary names.

Since do not like to commit patches that do not compile,
I moved all the autoconfig setting to the second patch.
Then I re-wrote Trond's patch to not compile the nfsidmap
code when libnfsidmap does not have the updated support
instead of failing the compilation.

Bryan Schumaker (1):
  Add the new nfsidmap program

Steve Dickson (1):
  Enable nfsidmap to compile

 aclocal/keyutils.m4         |   11 ++++
 aclocal/libnfsidmap.m4      |    4 ++
 configure.ac                |    7 +++
 utils/Makefile.am           |    3 +
 utils/nfsidmap/Makefile.am  |    9 +++
 utils/nfsidmap/nfsidmap.c   |  118 +++++++++++++++++++++++++++++++++++++++++++
 utils/nfsidmap/nfsidmap.man |   60 ++++++++++++++++++++++
 7 files changed, 212 insertions(+), 0 deletions(-)
 create mode 100644 aclocal/keyutils.m4
 create mode 100644 utils/nfsidmap/Makefile.am
 create mode 100644 utils/nfsidmap/nfsidmap.c
 create mode 100644 utils/nfsidmap/nfsidmap.man

-- 
1.7.3.2

