Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19419 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932815Ab1CWN2C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 09:28:02 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/12] NFSv4.1 pnfs wave5 submission (try 2)
Date: Wed, 23 Mar 2011 09:27:43 -0400
Message-Id: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is try 2 of the submission.  The first accidently had Andy's
LAYOUTCOMMIT patch squashed into one of the other patches.  No other
change was made from version 1.



These are the "wave5" pnfs patches, which implement COMMIT to data
server and LAYOUTCOMMIT, using the new rules from the proposed errata
which has come out of the Feb 2011 interim IETF meeting.  At this
point, the intent is that the files layout pNFS client is spec
compliant, though it has some obvious limitations, such as using only
whole file layouts.

These apply to Trond's trond/nfs-for-next branch, and are also available
at git://linux-nfs.org/~iisaman/linux-pnfs.git under the tag
wave5-submission-02

Fred

