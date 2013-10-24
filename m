Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31048 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754844Ab3JXSQa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Oct 2013 14:16:30 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9OIGTLE023009
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 24 Oct 2013 14:16:30 -0400
Received: from smallhat.boston.devel.redhat.com.org (vpn-62-59.rdu2.redhat.com [10.10.62.59])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r9OIGSR7030193
	for <linux-nfs@vger.kernel.org>; Thu, 24 Oct 2013 14:16:28 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] mountd: disabling turning off TCP listeners (v2)
Date: Thu, 24 Oct 2013 14:17:10 -0400
Message-Id: <1382638633-6710-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[ Here is the second try for these patches incorporating the code review..]

Recently it was pointed out to me that the [-n | --no-tcp] flags 
were broken in mountd. Sure enough they are and they broke 
when nfs-utils moved to using libtirpc, which was years ago.

Obviously nobody is using these flags since has not been 
notice until now, but it seemed to me it no longer makes 
any sense to have flags. We really want people to use TCP 
so why should there be a way to turn it off? It should be
the opposite... They should be able to turn off UDP listeners
not TCP... 


Steve Dickson (3):
  mountd: Use protocol bit fields to turn protocols off.
  mountd: Deprecate the ability to disable TCP listeners.
  mountd: Add the ability to disable UDP listeners.

 support/include/rpcmisc.h |  2 +-
 support/nfs/rpcmisc.c     | 19 ++++++++++++++-----
 support/nfs/svc_create.c  |  5 +++++
 utils/mountd/mountd.c     | 17 ++++++++++++-----
 utils/mountd/mountd.man   |  6 +++---
 5 files changed, 35 insertions(+), 14 deletions(-)

-- 
1.8.3.1

