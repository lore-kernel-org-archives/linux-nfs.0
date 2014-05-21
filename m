Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57697 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752618AbaEUQF2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 May 2014 12:05:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/2] fix for find_lockowner_str crash
Date: Wed, 21 May 2014 12:05:23 -0400
Message-Id: <1400688325-5345-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This is for 3.15 and stable.

Jeff, cc'ing you since I seem to recall Trond's series changes to using
a single lockowner.  I think the following is the quicker fix for
stable, but you could convince me otherwise.

J. Bruce Fields (2):
  nfsd4: remove lockowner when removing lock stateid
  nfsd4: warn on finding lockowner without stateid's

 fs/nfsd/nfs4state.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

-- 
1.9.0

