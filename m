Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61988 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757131Ab3GQUnv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jul 2013 16:43:51 -0400
Subject: [PATCH 04/10] KEYS: key_is_dead() should take a const key pointer
 argument
To: keyrings@linux-nfs.org
From: David Howells <dhowells@redhat.com>
Cc: linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 17 Jul 2013 21:43:47 +0100
Message-ID: <20130717204347.8591.38268.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130717204314.8591.52892.stgit@warthog.procyon.org.uk>
References: <20130717204314.8591.52892.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

key_is_dead() should take a const key pointer argument as it doesn't modify
what it points to.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 security/keys/internal.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/security/keys/internal.h b/security/keys/internal.h
index df971fe..490aef5 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -203,7 +203,7 @@ extern struct key *key_get_instantiation_authkey(key_serial_t target_id);
 /*
  * Determine whether a key is dead.
  */
-static inline bool key_is_dead(struct key *key, time_t limit)
+static inline bool key_is_dead(const struct key *key, time_t limit)
 {
 	return
 		key->flags & ((1 << KEY_FLAG_DEAD) |

