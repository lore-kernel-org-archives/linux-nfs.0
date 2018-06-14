Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55522 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754695AbeFNTcO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Jun 2018 15:32:14 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/5] knfsd miscellaneous cleanup
Date: Thu, 14 Jun 2018 15:32:08 -0400
Message-Id: <1529004733-6022-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Some cleanup and one minor bugfix.

--b.

J. Bruce Fields (5):
  nfsd4: less confusing nfsd4_compound_in_session
  nfsd4: cleanup sessionid in nfsd4_destroy_session
  nfsd: update obselete comment referencing the BKL
  nfsd: clarify check_op_ordering
  nfsd: fix corrupted reply to badly ordered compound

 fs/nfsd/nfs4proc.c  | 14 ++++++++++----
 fs/nfsd/nfs4state.c | 20 ++++++++++----------
 2 files changed, 20 insertions(+), 14 deletions(-)

-- 
2.17.1

