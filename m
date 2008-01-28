From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/2] NLM: fix use after free in lockd
Date: Mon, 28 Jan 2008 14:29:09 -0500
Message-ID: <1201548551-23592-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48737 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753472AbYA1T3R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 14:29:17 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This first patch in this set replaces the patch that I had originally
proposed for fixing the use after free problem. The earlier patch seemed
to work in some situations, but when the timing was a bit different it
was still possible for lockd to go down before the RPC callback
occurred. The fix is to just tear down the rpc client altogether.

The second patch in the set prevents a problem whereby lockd could stay
up indefinitely looping through nlmsvc_retry_blocked. 

This set depends on the patchset I proposed earlier to convert lockd to
use the kthread API.

Comments and/or suggestions appreciated.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
