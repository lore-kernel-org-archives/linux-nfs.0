From: Fred Isaman <iisaman@citi.umich.edu>
Subject: [PATCH 0/2]: nfs_pageio_add_request related deadlocks - try 2
Date: Wed, 19 Mar 2008 11:24:37 -0400
Message-ID: <1205940280-10479-1-git-send-email-iisaman@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:23361 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758647AbYCSUOx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 16:14:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Resend of patches, with Trond's suggested renaming.  Also fix a compile
problem with the second patch due to forward reference.


