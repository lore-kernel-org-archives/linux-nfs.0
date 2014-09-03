Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:32738 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877AbaICSPp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Sep 2014 14:15:45 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: Fix state owner lock usage
Date: Wed, 3 Sep 2014 14:15:39 -0400
Message-ID: <1409768140-3826-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The function can_open_cached() is used to determine if we can open a file
using cached information.  It does this by reading values from the state
structure, which I think means we need to be holding the so_lock to get the
right answer.  The current code calls this function twice - once without the
lock, and then a second time with the lock to check the answer.  I think
this is technically correct, since false positives are verified and false
negatives lead to the normal open code.

Even if the code is correct, it's not immediately obvious to me why it works
so I think it's worth taking a second look at.

What do you all think?

Anna


Anna Schumaker (1):
  NFS: Clear up state owner lock usage

 fs/nfs/nfs4proc.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

-- 
2.1.0

