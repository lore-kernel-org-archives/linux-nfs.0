Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34179 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932162AbcHKOhY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2016 10:37:24 -0400
Received: by mail-io0-f193.google.com with SMTP id i199so539915ioi.1
        for <linux-nfs@vger.kernel.org>; Thu, 11 Aug 2016 07:37:24 -0700 (PDT)
Subject: [PATCH v4 0/2] Eliminate race between LOCK and FREE_STATEID
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Thu, 11 Aug 2016 10:37:21 -0400
Message-ID: <20160811143205.20488.82396.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

IMO this series is both safe and effective and thus is ready to merge.

Alexey reports:

@ All 500 nfslock test runs passed, also run other related NFS tests with 
@ different configurations, as a result they passed as well. 


Changes since v3:
- Add Tested-by tags

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
