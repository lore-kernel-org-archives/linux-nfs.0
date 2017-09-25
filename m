Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51852 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934132AbdIYNVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Sep 2017 09:21:46 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/2] tweak knfsd session slot table sizing
Date: Mon, 25 Sep 2017 09:21:42 -0400
Message-Id: <1506345704-9486-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Current client and server defaults can limit NFSv4.1+ mounts to as few
as 4 per gigabytes of server RAM, and people have been running into the
limit on upgrading the protocol version from 4.0 to 4.1.

Bump the limit.  Also return smaller ca_maxrequests as the limit
approaches instead of waiting till we have to fail CREATE_SESSION
completely.

A few years ago Trond also posted some patches to dynamically resize
existing sessions as limits approach--I'll revisit those at some point
too.

The numbers chosen here are honestly still a little arbitrary, and we
may tweak them again if we see more problems.

--b.

J. Bruce Fields (2):
  nfsd: increase DRC cache limit
  nfsd: give out fewer session slots as limit approaches

 fs/nfsd/nfs4state.c | 5 +++++
 fs/nfsd/nfssvc.c    | 2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

-- 
2.13.5

