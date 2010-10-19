From: Steve Dickson <steved@redhat.com>
Subject: Froe 0d941e1c15147045c26a6cc4918743786e8a1e40 Mon Sep 17 00:00:00 2001
Date: Tue, 19 Oct 2010 16:00:23 -0400
Message-ID: <1287518425-12962-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23653 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752520Ab0JST4H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Oct 2010 15:56:07 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o9JJu6pM003230
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 19 Oct 2010 15:56:06 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o9JJu6hJ028627
	for <linux-nfs@vger.kernel.org>; Tue, 19 Oct 2010 15:56:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here are a couple tweaks of two man pages that
have been point out. 

Steve Dickson (2):
  Cleared up the sync option in the exportfs man page
  Updated rpc.mountd man page

 utils/exportfs/exports.man |    4 +++-
 utils/mountd/mountd.man    |    6 +++---
 2 files changed, 6 insertions(+), 4 deletions(-)

-- 
1.7.2.3

