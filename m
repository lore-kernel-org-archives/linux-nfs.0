Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40477 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752292Ab1KJU0G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Nov 2011 15:26:06 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pAAKQ5bm007127
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 15:26:06 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id pAAKQ5Dg030911
	for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 15:26:05 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] Enable the in-kernel id mapping to be on by default.
Date: Thu, 10 Nov 2011 15:26:01 -0500
Message-Id: <1320956763-17935-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set enables the in-kernel id mapping upcall
mechanism, which will fix deadlocks that can occur 
between the rpc.idmapd daemon and the kernel. 

This set also correct the binary name in the kernel 
documentation

Steve Dickson (2):
  Enable the in-kernel ID mapping upcall mechanism
  Renamed the binary that handles the upcalls to /usr/sbin/nfsidmap

 Documentation/filesystems/nfs/idmapper.txt |   22 +++++++++++-----------
 fs/nfs/Kconfig                             |   10 ++--------
 2 files changed, 13 insertions(+), 19 deletions(-)

-- 
1.7.6.4

