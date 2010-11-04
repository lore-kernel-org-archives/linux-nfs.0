Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33429 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415Ab0KDPWu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Nov 2010 11:22:50 -0400
Received: from localhost.localdomain (dnsindia.hq.netapp.com [10.58.52.94] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oA4FMYMM029583
	for <linux-nfs@vger.kernel.org>; Thu, 4 Nov 2010 08:22:35 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/18] rewrite of CB_LAYOUTRECALL and layoutstate code
Date: Thu,  4 Nov 2010 11:22:13 -0400
Message-Id: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This code rewrites the layout state handling and the CB_LAYOUTRECALL paths.
It applies to Benny's current pnfs-submit branch (commit eb04948a).

Patch 01 - A session's callback patch that passes the CB_SEQUENCE info (the session in particular) up to subsequent operations.  Andy is looking at issues Trond pointed out with this patch, but something very much like it will come.

02-12 - These are what smallish changes I could pull out of the rewrite.  Patch 03 in particular introduces changes to refcounting that are at the heart of io drain notification.

13 - Sorry this patch is so huge, but I am simultaneously changing the stateid and RPC processing for LAYOUTGET, LAYOUTRETURN, and CB_LAYOUTRECALL, and I did not see an easy way to split them bisectably.

14 - More CB_LAYOUTRECALL changes that could be more easily split out

15-18 Andy's code that puts LAYOUTCOMMIT and LAYOUTRETURN in the same compound as CLOSE


Fred

