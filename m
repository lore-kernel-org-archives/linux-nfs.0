Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753945AbbKGSON (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Nov 2015 13:14:13 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 77370461C3
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2015 18:14:13 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-59-101.rdu2.redhat.com [10.10.59.101])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tA7IECrL027545
	for <linux-nfs@vger.kernel.org>; Sat, 7 Nov 2015 13:14:12 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] Improving rpc.gssd's debugging 
Date: Sat,  7 Nov 2015 13:14:07 -0500
Message-Id: <1446920050-5968-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that rpc.gssd is the critical path of every
NFS mount, any favored mount, I thought I would
take a crack at making the daemon a bit more 
debuggable by making the logging more readable.

The first level of debugging (-v) will only log 
errors and warnings that are not normally logged.
I'm thinking this might be a good level to run
at a customer's site.

I also thought about changing the majority of the 
printerr(0) which always log to printerr(1)s. I 
decided not to since I figured more info is 
better.

Note, I didn't remove any of the messages, I just pushed
them back to other debug levels. 

I trimmed down the second level of debugging (-vv) 
by again moving them back to other levels. 

The third level (-vvv) is basically the same.

Using the fourth level (-vvvv) to enable all the logging
that old level three did.

Thoughts/Comments... A waste of a good Saturday afternoon?? ;-) 

Steve Dickson (3):
  gssd: reworked first level of debugging
  gssd: log all fatal errors
  gssd: reworked second level of debugging

 utils/gssd/context_heimdal.c |  2 +-
 utils/gssd/context_lucid.c   |  6 +++---
 utils/gssd/gssd.c            | 14 +++++++-------
 utils/gssd/gssd_proc.c       | 32 +++++++++++++-------------------
 utils/gssd/krb5_util.c       | 28 ++++++++++++++++------------
 5 files changed, 40 insertions(+), 42 deletions(-)

-- 
2.4.3

