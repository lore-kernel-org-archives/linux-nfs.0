Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 183.141.211.66.inaddr.G4.NET ([66.211.141.183]:36469 "EHLO
	Dobby.4dicksons.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753870Ab3DLQ6K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Apr 2013 12:58:10 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1UQgTp-00032f-8L
	for linux-nfs@vger.kernel.org; Fri, 12 Apr 2013 12:05:37 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] The beginning of the end of v2 support
Date: Fri, 12 Apr 2013 12:05:35 -0400
Message-Id: <1365782736-9764-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patch is beginning of no longer supporting
the NFS version 2 protocol. At this point there no valid 
reason outdated protocol should be used. Plus from a
support/testing stand point its really becoming a thorn.

The following patch simply disables the v2 protocol negation 
by only negotiating to v3. Setting the version on the 
command will be the only way v2 can be used... for now! 

Steve Dickson (1):
  mount: No longer negotiate to v2

 utils/mount/network.c | 13 +++++--------
 utils/mount/stropts.c |  2 ++
 2 files changed, 7 insertions(+), 8 deletions(-)

-- 
1.8.1.4

