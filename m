Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60605 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754862Ab2JVQFj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 12:05:39 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3828544iea.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 09:05:39 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/10] nfs-utils compiler warning clean ups
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 22 Oct 2012 12:05:35 -0400
Message-ID: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

These address compiler warnings in mountd and gssd that I've found
during recent sojourns in that code base.  I've done some light
testing, but more critical review and testing would be appreciated.

I think these are appropriate for your next release of nfs-utils.

---

Chuck Lever (10):
      rpc.gssd: Squelch compiler error
      rpc.gssd: Squelch compiler warning
      rpc.gssd: Squelch compiler warning
      mountd: Avoid unnecessary type conversions
      mountd: Avoid unnecessary type conversions
      mountd: Avoid unnecessary type conversions
      mountd: Make local functions static
      mountd: Eliminate unnecessary type conversions
      mountd: Avoid unnecessary type conversions
      nfs-utils: Eliminate dereferencing type punned pointers


 support/include/nfslib.h   |    1 +
 support/include/sockaddr.h |   10 ++++------
 support/nfs/cacheio.c      |    5 +++++
 utils/gssd/gss_util.c      |    2 +-
 utils/gssd/gssd_proc.c     |   13 +++++++------
 utils/mountd/cache.c       |   34 ++++++++++++++++++----------------
 6 files changed, 36 insertions(+), 29 deletions(-)

-- 
Chuck Lever
