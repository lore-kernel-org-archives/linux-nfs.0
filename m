Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:51745 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab2LCRW4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2012 12:22:56 -0500
Received: by mail-ie0-f176.google.com with SMTP id 13so5461777iea.21
        for <linux-nfs@vger.kernel.org>; Mon, 03 Dec 2012 09:22:55 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] mountd clean-ups for nfs-utils 1.2.8
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 03 Dec 2012 12:17:22 -0500
Message-ID: <20121203171549.1390.64007.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Here are four clean-up patches I've had for a while, and one patch
that augments junction resolution debugging messages.

---

Chuck Lever (5):
      mountd: Report the absolute path used to load the junction plug-in
      libexport.a: xtab.c no longer needs #include xmalloc.h
      libexport.a: rmtab.c no longer needs #include xmalloc.h
      mountd: cache.c no longer needs #include xmalloc.h
      mountd: auth.c no longer needs #include xmalloc.h


 support/export/rmtab.c |    6 +++---
 support/export/xtab.c  |    2 +-
 utils/mountd/auth.c    |    3 ++-
 utils/mountd/cache.c   |    8 +++++++-
 4 files changed, 13 insertions(+), 6 deletions(-)

-- 
Chuck Lever
