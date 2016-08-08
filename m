Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35662 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbcHHS7i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Aug 2016 14:59:38 -0400
Received: by mail-it0-f65.google.com with SMTP id f6so6762128ith.2
        for <linux-nfs@vger.kernel.org>; Mon, 08 Aug 2016 11:59:37 -0700 (PDT)
Received: from klimt.1015granger.net ([2604:8800:100:81fc:ec4:7aff:fe6c:6aa0])
        by smtp.gmail.com with ESMTPSA id w138sm10744147itc.8.2016.08.08.11.59.36
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 11:59:36 -0700 (PDT)
Subject: [PATCH v3 0/2] Eliminate race between LOCK and FREE_STATEID
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 08 Aug 2016 14:59:35 -0400
Message-ID: <20160808184711.11661.86427.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series passes light testing in my lab. If it looks good I will
pass it along to Alexey to confirm it closes the race.

To aid distributors and stable kernel maintainers, wondering if a
Fixes: tag should be added. Alexey first observed this issue in v4.1
kernels (UEK4). But looks like the race could have been introduced
as early as v3.17. Maybe this one?

commit fc5a96c3b70d00c863f69ff4ea7f5dfddbcbc0d8
Author: Jeff Layton <jlayton@primarydata.com>
Date:   Tue Jul 29 21:34:40 2014 -0400

    nfsd: close potential race in nfsd4_free_stateid

There have been a lot of changes since then. It's hard to say if the
race can be attributed to a single commit.


Changes since v2:
- Move NFS4_LOCK_STID arm into a helper, for clarity
- Add more detail to patch description
- Add Jeff's patch to fix similar race in nfsd4_lock

Changes since v1:
- Use s->sc_count to preserve stateid while cl_lock is dropped

---

Chuck Lever (1):
      nfsd: Fix race between FREE_STATEID and LOCK

Jeff Layton (1):
      nfsd: don't return an unhashed lock stateid after taking mutex


 fs/nfsd/nfs4state.c |   65 ++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 48 insertions(+), 17 deletions(-)

--
Chuck Lever
