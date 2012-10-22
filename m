Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60605 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755157Ab2JVQFs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 12:05:48 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so3828544iea.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 09:05:48 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/10] nfs-utils: Eliminate dereferencing type punned pointers
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 22 Oct 2012 12:05:46 -0400
Message-ID: <20121022160546.4552.81486.stgit@lebasque.1015granger.net>
In-Reply-To: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
References: <20121022160140.4552.34477.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up compiler warnings:

../../support/include/sockaddr.h: In function ‘compare_sockaddr6’:
../../support/include/sockaddr.h:197:2: warning: dereferencing
  type-punned pointer might break strict-aliasing rules
  [-Wstrict-aliasing]
../../support/include/sockaddr.h:198:7: warning: dereferencing
  type-punned pointer might break strict-aliasing rules
  [-Wstrict-aliasing]
../../support/include/sockaddr.h:199:6: warning: dereferencing
  type-punned pointer might break strict-aliasing rules
  [-Wstrict-aliasing]
../../support/include/sockaddr.h:200:7: warning: dereferencing
  type-punned pointer might break strict-aliasing rules
  [-Wstrict-aliasing]
../../support/include/sockaddr.h:204:2: warning: dereferencing
  type-punned pointer might break strict-aliasing rules
  [-Wstrict-aliasing]
../../support/include/sockaddr.h:204:2: warning: dereferencing
  type-punned pointer might break strict-aliasing rules
  [-Wstrict-aliasing]
../../support/include/sockaddr.h:204:2: warning: dereferencing
  type-punned pointer might break strict-aliasing rules
  [-Wstrict-aliasing]
../../support/include/sockaddr.h:204:2: warning: dereferencing
  type-punned pointer might break strict-aliasing rules
  [-Wstrict-aliasing]
../../support/include/sockaddr.h:204:2: warning: dereferencing
  type-punned pointer might break strict-aliasing rules
  [-Wstrict-aliasing]
../../support/include/sockaddr.h:204:2: warning: dereferencing
  type-punned pointer might break strict-aliasing rules
  [-Wstrict-aliasing]
../../support/include/sockaddr.h:204:2: warning: dereferencing
  type-punned pointer might break strict-aliasing rules
  [-Wstrict-aliasing]
../../support/include/sockaddr.h:204:2: warning: dereferencing
  type-punned pointer might break strict-aliasing rules
  [-Wstrict-aliasing]

Seen with gcc version 4.6.3 20120306 (Red Hat 4.6.3-2) (GCC)

Note also that site-local IPv6 addresses are deprecated, and thus
are no longer encountered.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/sockaddr.h |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
index 9af2543..72766db 100644
--- a/support/include/sockaddr.h
+++ b/support/include/sockaddr.h
@@ -193,16 +193,14 @@ compare_sockaddr6(const struct sockaddr *sa1, const struct sockaddr *sa2)
 {
 	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
 	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
+	const struct in6_addr *saddr1 = &sin1->sin6_addr;
+	const struct in6_addr *saddr2 = &sin2->sin6_addr;
 
-	if ((IN6_IS_ADDR_LINKLOCAL((char *)&sin1->sin6_addr) &&
-	     IN6_IS_ADDR_LINKLOCAL((char *)&sin2->sin6_addr)) ||
-	    (IN6_IS_ADDR_SITELOCAL((char *)&sin1->sin6_addr) &&
-	     IN6_IS_ADDR_SITELOCAL((char *)&sin2->sin6_addr)))
+	if (IN6_IS_ADDR_LINKLOCAL(saddr1) && IN6_IS_ADDR_LINKLOCAL(saddr2))
 		if (sin1->sin6_scope_id != sin2->sin6_scope_id)
 			return false;
 
-	return IN6_ARE_ADDR_EQUAL((char *)&sin1->sin6_addr,
-					(char *)&sin2->sin6_addr);
+	return IN6_ARE_ADDR_EQUAL(saddr1, saddr2);
 }
 #else	/* !IPV6_SUPPORTED */
 static inline _Bool

