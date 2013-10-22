Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22095 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752928Ab3JVISv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 04:18:51 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9M8Ios6006553
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 22 Oct 2013 04:18:51 -0400
Received: from smallhat.boston.devel.redhat.com.org (vpn-59-139.rdu2.redhat.com [10.10.59.139])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r9M8Inoh017257
	for <linux-nfs@vger.kernel.org>; Tue, 22 Oct 2013 04:18:49 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] mountd: disabling turning off TCP listeners
Date: Tue, 22 Oct 2013 04:19:23 -0400
Message-Id: <1382429966-14531-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently it was pointed out to me that the [-n | --no-tcp] flags 
were broken in mountd. Sure enough they are and they broke 
when nfs-utils moved to using libtirpc, which was years ago.

Obviously nobody is using these flags since has not been 
notice until now, but it seemed to me it no longer makes 
any sense to have flags. We really want people to use TCP 
so why should there be a way to turn it off? It should be
the opposite... They should be able to turn off UDP listeners
not TCP... 

So this patch set does just that. It  deprecate the ability to 
disable TCP listeners and addd the ability to disable UDP listeners.

Steve Dickson (3):
  mountd: Use protocol bit fields to turn protocols off.
  mountd: Deprecate the ability to disable TCP listeners.
  mountd: Add the ability to disable UDP listeners.

 support/include/rpcmisc.h |  2 +-
 support/nfs/rpcmisc.c     | 19 ++++++++++++++-----
 support/nfs/svc_create.c  |  5 +++++
 utils/mountd/mountd.c     | 15 +++++++++++----
 utils/mountd/mountd.man   |  6 +++---
 5 files changed, 34 insertions(+), 13 deletions(-)

-- 
1.8.3.1

