Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5257 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083Ab1KJU01 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Nov 2011 15:26:27 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pAAKQQsP013210
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 15:26:27 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pAAKQPEB022338
	for <linux-nfs@vger.kernel.org>; Thu, 10 Nov 2011 15:26:26 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] nfsidmap: Added error logging and verbosity flag
Date: Thu, 10 Nov 2011 15:26:23 -0500
Message-Id: <1320956785-18004-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To aid in debugging problems and verifying general
functionality, this patch set adds error logging 
and a -v verbosity flag.

Steve Dickson (2):
  nfsidmap: Added Error Logging
  nfsidmap: Added -v flag

 utils/nfsidmap/Makefile.am  |    2 +-
 utils/nfsidmap/nfsidmap.c   |   46 +++++++++++++++++++++++++++++++++++++++---
 utils/nfsidmap/nfsidmap.man |   15 +++++++++++--
 3 files changed, 55 insertions(+), 8 deletions(-)

-- 
1.7.6.4

