Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54390 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751473AbeFDOux (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Jun 2018 10:50:53 -0400
Received: from smtp.corp.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 14EFD30D19A6
        for <linux-nfs@vger.kernel.org>; Mon,  4 Jun 2018 14:50:53 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-215.phx2.redhat.com [10.3.116.215])
        by smtp.corp.redhat.com (Postfix) with ESMTP id BF88330012D0
        for <linux-nfs@vger.kernel.org>; Mon,  4 Jun 2018 14:50:52 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/4] Removed more warnings that now errors via -W
Date: Mon,  4 Jun 2018 10:50:47 -0400
Message-Id: <20180604145051.146390-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The patches remove more warnings that are errors via the -W flags. 
Basically allows RHEL7 to compile with following flags:

-Wformat=2 -Wmissing-include-dirs \
-Wunused -Wlogical-op \
-Wmissing-prototypes -Wmissing-declarations -Wstrict-prototypes \
-Wmissing-noreturn -Wshadow \
-Wunreachable-code -Wdisabled-optimization \
-fstrict-aliasing -fstrict-overflow \
-fexceptions -fstack-protector \
-fasynchronous-unwind-tables -fpie" \

There are still warnings but there are no more fatel errors. 


Steve Dickson (4):
  xtab.c: Removed overflow in implicit constant conversion errors
  Removed ISO C does not support the '%m' gnu_printf format errors
  Removed format expects argument of type errors
  gssd.c: Remomved a couple of warning errors

 support/include/exportfs.h |  2 +-
 utils/gssd/gssd.c          | 20 ++++++++++----------
 utils/idmapd/idmapd.c      |  3 ++-
 utils/nfsidmap/nfsidmap.c  |  2 +-
 utils/nfsstat/nfsstat.c    |  6 +++---
 utils/statd/statd.c        |  7 ++++---
 6 files changed, 21 insertions(+), 19 deletions(-)

-- 
1.8.3.1

