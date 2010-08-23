Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:56494 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab0HWRKp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Aug 2010 13:10:45 -0400
Received: by gxk23 with SMTP id 23so2190914gxk.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Aug 2010 10:10:45 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] More mountd patches
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Aug 2010 13:10:38 -0400
Message-ID: <20100823170552.2123.43124.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

Here are some clean-up and bug fix patches I'd like you to apply
before I start sending the IPv6 series.

The first two fix a bug reported by Neil.  I posted these to you a
few weeks ago, but I don't see them in your repo yet.

The next bug is the statd DNS bug that Ben Hutchings reported months
ago.  We just got confirmation that the patch does indeed fix the
problem.

The last two patches are two clean-ups from my IPv6 series.  The first
is uncontroversial.  The second converts exportfs to use xlog() more
idiomatically, allowing debugging messages in libexport.a to be
enabled from the exportfs command line.

---

Chuck Lever (5):
      exportfs: Use xlog() for error reporting
      exportfs: exportfs.c no longer needs #include "xmalloc.h"
      statd: statd fails to monitor if no reverse mapping of mon_name exists
      libexport: Fix IP address check in check_netgroup()
      libexport: Add a common exit label to check_netgroup()


 support/export/client.c   |   44 ++++++++++++++++++++++++--------
 utils/exportfs/exportfs.c |   62 ++++++++++++++++++++++++---------------------
 utils/statd/hostname.c    |    4 ++-
 3 files changed, 69 insertions(+), 41 deletions(-)

-- 
Chuck Lever
