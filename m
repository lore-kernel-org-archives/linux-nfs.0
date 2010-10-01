Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9112 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582Ab0JAQDf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 12:03:35 -0400
Received: from localhost.localdomain (vpn2ntap-420885.hq.netapp.com [10.58.51.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o91G3Uek008238
	for <linux-nfs@vger.kernel.org>; Fri, 1 Oct 2010 09:03:31 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/7] misc fixes and cleanup
Date: Fri,  1 Oct 2010 12:02:44 -0400
Message-Id: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The first 3 do some cleanup preparing for the hopefully final devinfo submission.

The last 3 fix some use of freed memory problems using the synch error handler (that
were never being triggered because the asynch error handler got there first, at least
until the LAYOUTGET code got restructured.)

Fred
 
