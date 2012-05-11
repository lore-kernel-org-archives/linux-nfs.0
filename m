Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:41865 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757962Ab2EKNpa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 May 2012 09:45:30 -0400
Received: by qadb17 with SMTP id b17so1246328qad.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 May 2012 06:45:29 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] nfsd: clean up share access with accessor functions
Date: Fri, 11 May 2012 09:45:10 -0400
Message-Id: <1336743914-944-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While looking over the share/deny mode stuff in knfsd, I ended up doing
some cleanup to make the code a bit easier to understand. In the future
this may help us by encapsulating the share/deny code to some degree.

This set should introduce no behavioral changes, it's just cleanup for
now, but is probably reasonable for 3.5.

Jeff Layton (4):
  nfsd: consolidate set_access and set_deny
  nfsd: make test_share a bool return
  nfsd: wrap accesses to st_access_bmap
  nfsd: wrap all accesses to st_deny_bmap

 fs/nfsd/nfs4state.c |  149 ++++++++++++++++++++++++++++++++-------------------
 1 files changed, 93 insertions(+), 56 deletions(-)

-- 
1.7.7.6

