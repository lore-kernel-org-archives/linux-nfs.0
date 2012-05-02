Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34341 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752999Ab2EBVh7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 May 2012 17:37:59 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        NeilBrown <neilb@suse.de>, "J. Bruce Fields" <bfields@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] mountd: fix export upcall failure in use_ipaddr case.
Date: Wed,  2 May 2012 17:37:51 -0400
Message-Id: <1335994675-11751-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1335994675-11751-1-git-send-email-bfields@redhat.com>
References: <1335994675-11751-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

After 0509d3428f523 "mountd: Replace "struct hostent" with "struct
addinfo"", the export upcall fails in the use_ipaddr case.

I think we never noticed because a) the use_ipaddr case is rarer than
the !use_ipaddr case, and b) the nfsd_fh upcall does a preemptive export
downcall that renders the nfsd export call unnecessary in some cases.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/cache.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ac9cdbd..cf07b56 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -1064,6 +1064,7 @@ static void nfsd_export(FILE *f)
 			goto out;
 		ai = client_resolve(tmp->ai_addr);
 		freeaddrinfo(tmp);
+		if (!ai)
 			goto out;
 	}
 
-- 
1.7.7.6

