Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36336 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752811AbdGSUx4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Jul 2017 16:53:56 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id AE90961BB4
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 20:53:56 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-122-174.rdu2.redhat.com [10.10.122.174])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 65E9917C14
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 20:53:56 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 00/11] Removed a bunch random warnings
Date: Wed, 19 Jul 2017 16:53:43 -0400
Message-Id: <20170719205354.10006-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I upgraded to Fedora 26 and went to apply Neil's 
recent mount patches and ended up seeing all 
these warning. 

These patches fix those warnings

Steve Dickson (11):
  rpcdebug.c: remove a warning
  present_address: remove a warning
  atomicio: removed a warning
  cache.c: removed a couple warning
  nfsd.c: removed a few warnings
  bldev_read_serial: removed a couple warnings
  device-discovery.c: removed a warning
  network.c: removed some warnings
  nfsmount: remove a warning
  nfs4mount: removed a warning
  nfsdcltrack.c: remove a warning

 support/misc/tcpwrapper.c        | 1 +
 support/nfs/atomicio.c           | 1 +
 tools/rpcdebug/rpcdebug.c        | 3 ++-
 utils/blkmapd/device-discovery.c | 1 +
 utils/blkmapd/device-inq.c       | 2 ++
 utils/mount/network.c            | 5 +++++
 utils/mount/nfs4mount.c          | 1 +
 utils/mount/nfsmount.c           | 1 +
 utils/mountd/cache.c             | 1 +
 utils/nfsd/nfsd.c                | 5 ++++-
 utils/nfsdcltrack/nfsdcltrack.c  | 1 +
 11 files changed, 20 insertions(+), 2 deletions(-)

-- 
2.13.3

