Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24519 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753648Ab1IVTpC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 15:45:02 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8MJj11U002384
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 15:45:01 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p8MJj085012846
	for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 15:45:01 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] configure.ac: clean up.
Date: Thu, 22 Sep 2011 15:44:56 -0400
Message-Id: <1316720699-2611-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Steve Dickson (3):
  configure.ac: Remove the NFS v3 enable flag
  configure.ac: Removed unused defines in config.h
  configure.ac: Added a v4.1 dependency on v4.0

 configure.ac |   17 +++--------------
 1 files changed, 3 insertions(+), 14 deletions(-)

-- 
1.7.6.2

