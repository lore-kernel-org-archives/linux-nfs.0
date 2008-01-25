From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 058/100] svc: Remove unnecessary call to svc_sock_enqueue
Date: Fri, 25 Jan 2008 18:16:38 -0500
Message-ID: <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47445 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932109AbYAYXRt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:49 -0500
In-Reply-To: <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

The svc_tcp_accept function calls svc_sock_enqueue after setting the
SK_CONN bit. This doesn't actually do anything because the SK_BUSY bit
is still set. The call is unnecessary anyway because the generic code in
svc_recv calls svc_sock_received after calling the accept function.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svcsock.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 41d1f81..962dbf4 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1064,7 +1064,6 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	}
 
 	set_bit(SK_CONN, &svsk->sk_flags);
-	svc_sock_enqueue(svsk);
 
 	err = kernel_getpeername(newsock, sin, &slen);
 	if (err < 0) {
-- 
1.5.4.rc2.60.gb2e62

