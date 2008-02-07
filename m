From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/3] NLM: convert lockd to kthreads (try #11)
Date: Thu,  7 Feb 2008 16:34:52 -0500
Message-ID: <1202420095-5818-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50802 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756303AbYBGVe5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 16:34:57 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is try #11 of the conversion of lockd to the kthread API.

The main differences from the last patchset are:

1) the addition of a patch to svc_recv to have it check
   kthread_should_stop in various places

2) the removal of the send_sig() call from lockd_down

...as Trond cleverly pointed out, if we strategically place a
kthread_should_stop call after changing the task state, then we don't
need anything else to prevent a long hang in schedule_timeout().

Comments, suggestions or ACK's appreciated...

Thanks,

Jeff Layton <jlayton@redhat.com>
