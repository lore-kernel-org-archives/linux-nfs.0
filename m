From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/4] NLM: fix lockd hang when client blocking on released lock isn't responding
Date: Wed,  6 Feb 2008 11:34:09 -0500
Message-ID: <1202315653-11840-1-git-send-email-jlayton@redhat.com>
To: bfields@fieldses.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34199 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755169AbYBFQeQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 11:34:16 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset fixes the problem that Bruce pointed out last week when
we were discussing the lockd-kthread patches.

The main problem is described in patch #1 and that patch also fixes the
DoS. The remaining patches clean up how GRANT_MSG callbacks handle an
unresponsive client. The goal in those is to make sure that we don't
end up with a ton of duplicate RPC's in queue and that we try to handle
an invalidated block correctly.

Bruce, I'd like to see this fixed in 2.6.25 if at all possible.

Comments and suggestions are appreciated.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

