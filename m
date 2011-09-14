Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:61457 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757463Ab1INTu1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Sep 2011 15:50:27 -0400
Received: by yie30 with SMTP id 30so1705048yie.19
        for <linux-nfs@vger.kernel.org>; Wed, 14 Sep 2011 12:50:26 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Allow my_name to change when locking
To: skinsbursky@parallels.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 14 Sep 2011 15:50:24 -0400
Message-ID: <20110914194646.3008.77560.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Instead of picking up utsname()->nodename in the NSM XDR layer, allow
upper layers to determine the value of SM_MON(my_name) and
NLM_LOCK(caller_name).

This should make it easier to support NFSv2 and v3 in containers.

Lightly tested the client side.  Server side changes need review
and testing.

---

Chuck Lever (2):
      lockd: Use my_name instead of utsname when constructing NLM_LOCK args
      NLM: Allow upper layers to select my_name


 fs/lockd/clntproc.c         |    6 +++---
 fs/lockd/host.c             |    7 ++++++-
 fs/lockd/mon.c              |   36 +++++++++++++++++++++++++-----------
 fs/lockd/svclock.c          |    2 +-
 include/linux/lockd/lockd.h |    4 +++-
 5 files changed, 38 insertions(+), 17 deletions(-)

-- 
Chuck Lever
