From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/6] Intro: convert lockd to kthread and fix use-after-free
Date: Thu, 13 Dec 2007 15:40:22 -0500
Message-ID: <1197578428-26815-1-git-send-email-jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, nfsv4@linux-nfs.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37462 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755947AbXLMUka (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2007 15:40:30 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The only reply that I got to my last patchset to fix the use-after-free
problem in lockd was from Christoph Hellwig, who said:

> might be better to do the refcounting outside the thread and use the
> kthread api, which is something we still need to do for lockd anyway.

This patchset is an attempt to implement that suggestion. The first
two patches add a new svc_create_kthread() function that works like
svc_create_thread, but uses the kthread API under the covers. The rest
of the patches convert lockd to use this function (and fix a couple of
lockd bugs). The final patch adds reference counting that's needed
to fix the original problem.

Unfortunately, moving the refcounting outside of the thread altogether
isn't feasible for reasons outlined in description of the 6th patch.

Comments and suggestions appreciated...

Signed-off-by: Jeff Layton <jlayton@redhat.com>

