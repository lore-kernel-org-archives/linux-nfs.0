Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57398 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674Ab2DXFrz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 01:47:55 -0400
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Date: Tue, 24 Apr 2012 15:46:38 +1000
Subject: [PATCH 2/6] auth_authenticate_newcache: prefer non-V4ROOT export over
 V4ROOT exports.
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Message-ID: <20120424054638.20130.72127.stgit@notabene.brown>
In-Reply-To: <20120424054003.20130.16209.stgit@notabene.brown>
References: <20120424054003.20130.16209.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently auth_authenticate_internal finds an export and if it
is a V4ROOT export, it reports that there is no match.  Unlike
lookup_export() it doesn't keep looking for an acceptable export.

So remove the test from auth_authenticate_internal(), and add it to
auth_authenticate_newcache(), where the search can be allowed to
continue.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 utils/mountd/auth.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index ccc849a..3843756 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -159,6 +159,9 @@ auth_authenticate_newcache(const struct sockaddr *caller,
 				continue;
 			if (use_ipaddr && !client_check(exp->m_client, ai))
 				continue;
+			if (exp->m_export.e_flags & NFSEXP_V4ROOT)
+				/* not acceptable for v[23] export */
+				continue;
 			break;
 		}
 	*error = not_exported;
@@ -187,10 +190,6 @@ auth_authenticate_internal(const struct sockaddr *caller, const char *path,
 			return NULL;
 		}
 	}
-	if (exp->m_export.e_flags & NFSEXP_V4ROOT) {
-		*error = no_entry;
-		return NULL;
-	}
 	if (!(exp->m_export.e_flags & NFSEXP_INSECURE_PORT) &&
 		     nfs_get_port(caller) >= IPPORT_RESERVED) {
 		*error = illegal_port;


