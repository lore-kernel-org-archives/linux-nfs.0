From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 091/112] lockd: Eliminate harmless mixed sign comparison in
	nlmdbg_cookie2a()
Date: Fri, 25 Jan 2008 11:37:56 -0500
Message-ID: <20080125163756.31887.16711.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13473 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757108AbYAYRCS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:02:18 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH1HAG020978
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:02:05 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

The cookie->len field is unsigned, so the loop index variable in
nlmdbg_cookie2a() should also be unsigned.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/xdr.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 633653b..3e459e1 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -612,8 +612,7 @@ const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie)
 	 * called with BKL held.
 	 */
 	static char buf[2*NLM_MAXCOOKIELEN+1];
-	int i;
-	int len = sizeof(buf);
+	unsigned int i, len = sizeof(buf);
 	char *p = buf;
 
 	len--;	/* allow for trailing \0 */
