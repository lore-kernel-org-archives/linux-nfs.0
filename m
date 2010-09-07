Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18395 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757890Ab0IGUW3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:22:29 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o87KMSRe030359
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 16:22:29 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o87KMSnk001714
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 16:22:28 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] mount: Updated RDMA processing in the mount command.
Date: Tue,  7 Sep 2010 16:21:58 -0400
Message-Id: <1283890921-3447-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Here the code I've been testing for the last 4 days.

Steve Dickson (3):
  Added support for the the -o rdma option
  Ensure the corrrect address family is used on RDMA mounts
  Document the rdma mount option in the nfs man page

 support/nfs/getport.c |   21 +++++++++++++++++++++
 utils/mount/nfs.man   |   14 +++++++++++++-
 utils/mount/stropts.c |   33 +++++++++++++++++++++++----------
 3 files changed, 57 insertions(+), 11 deletions(-)

-- 
1.7.2.1
