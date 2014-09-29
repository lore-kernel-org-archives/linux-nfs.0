Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:13440 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754236AbaI2Q3M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2014 12:29:12 -0400
From: <andros@netapp.com>
To: <trond.myklebust@rimarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 0/1] NFSv4.1: Fix an NFSv4.1 state renewal regression
Date: Mon, 29 Sep 2014 12:29:04 -0400
Message-ID: <1412008145-36085-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Version 3 responds to a review request by Trond:

The problem here isn't that we're failing to send a SEQUENCE in a
situation where we're not required to do so by the spec. The problem
is that we're failing to rearm renewd when we skip that SEQUENCE call.

Instead of removing them, could you rather please modify the above
lines to return an error, and then have nfs4_renew_state() respond by
calling nfs4_schedule_state_renewal(), instead of just skipping it as
we do today. In fact, AFAICS we want to do the same when the renew
call fails due to ENOMEM (but not when it returns EIO, since that
signals that the nfs_client is in the process of shutting down).

Andy Adamson (1):
  NFSv4.1: Fix an NFSv4.1 state renewal      regression

 fs/nfs/nfs4proc.c   |  2 +-
 fs/nfs/nfs4renewd.c | 14 ++++++++++++--
 2 files changed, 13 insertions(+), 3 deletions(-)

-- 
1.8.3.1

