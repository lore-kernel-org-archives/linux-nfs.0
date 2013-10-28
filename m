Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756645Ab3J1SDn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 14:03:43 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9SI3fAh027010
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 28 Oct 2013 14:03:42 -0400
Received: from smallhat.boston.devel.redhat.com (smallhat.boston.devel.redhat.com [10.19.60.65])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r9SI3eQC004871
	for <linux-nfs@vger.kernel.org>; Mon, 28 Oct 2013 14:03:41 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] mountd: Disabling UDP listeners
Date: Mon, 28 Oct 2013 14:04:28 -0400
Message-Id: <1382983470-10063-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To start down the road of a V4-only environment, 
there needs to be a way to turn off UDP listeners
in mountd, similar to how TCP listeners are 
disabled. 

The patch does that by added the [-u|--no-udp] flags 
which allows the disabling of the UDP listener

Steve Dickson (2):
  mountd: Use protocol bit fields to turn protocols off.
  mountd: Add the ability to disable UDP listeners.

 support/include/rpcmisc.h |  2 +-
 support/nfs/rpcmisc.c     | 19 ++++++++++++++-----
 support/nfs/svc_create.c  |  8 ++++++++
 utils/mountd/mountd.c     | 12 ++++++++----
 utils/mountd/mountd.man   |  3 +++
 5 files changed, 34 insertions(+), 10 deletions(-)

-- 
1.8.3.1

