Return-Path: keyrings-bounces@linux-nfs.org
From: David Howells <dhowells@redhat.com>
To: chuck.lever@oracle.com
Date: Fri, 14 Nov 2014 15:18:18 +0000
Message-ID: <20141114151818.20661.21735.stgit@warthog.procyon.org.uk>
In-Reply-To: <20141030174612.10093.61557.stgit@manet.1015granger.net>
References: <20141030174612.10093.61557.stgit@manet.1015granger.net>
MIME-Version: 1.0
Cc: neilb@suse.de, linux-nfs@vger.kernel.org, keyrings@linux-nfs.org
Subject: [Keyrings] [PATCH] KEYS: search_nested_keyrings() should honour
 NO_STATE_CHECK for the root
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings>,
	<mailto:keyrings-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/keyrings>
List-Post: <mailto:keyrings@linux-nfs.org>
List-Help: <mailto:keyrings-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings>,
	<mailto:keyrings-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: keyrings-bounces@linux-nfs.org
Errors-To: keyrings-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

search_nested_keyrings() should probably honour KEYRING_SEARCH_NO_STATE_CHECK
when checking the keyring at the root of its search by not setting
DO_STATE_CHECK if NO_STATE_CHECK is set.

For the moment, this doesn't really matter as NO_STATE_CHECK is only used for
cycle detection and possession determination, neither of which use
keyring_search_iterator() as the search iterator check function, so
DO_STATE_CHECK is actually ignored there.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 security/keys/keyring.c          |    7 ++++---
 security/keys/request_key.c      |    1 +
 security/keys/request_key_auth.c |    1 +
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index 8177010174f7..41166f38a6e9 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -628,6 +628,10 @@ static bool search_nested_keyrings(struct key *keyring,
 	       ctx->index_key.type->name,
 	       ctx->index_key.description);
 
+#define STATE_CHECKS (KEYRING_SEARCH_NO_STATE_CHECK | KEYRING_SEARCH_DO_STATE_CHECK)
+	BUG_ON((ctx->flags & STATE_CHECKS) == 0 ||
+	       (ctx->flags & STATE_CHECKS) == STATE_CHECKS);
+	
 	if (ctx->index_key.description)
 		ctx->index_key.desc_len = strlen(ctx->index_key.description);
 
@@ -637,7 +641,6 @@ static bool search_nested_keyrings(struct key *keyring,
 	if (ctx->match_data.lookup_type == KEYRING_SEARCH_LOOKUP_ITERATE ||
 	    keyring_compare_object(keyring, &ctx->index_key)) {
 		ctx->skipped_ret = 2;
-		ctx->flags |= KEYRING_SEARCH_DO_STATE_CHECK;
 		switch (ctx->iterator(keyring_key_to_ptr(keyring), ctx)) {
 		case 1:
 			goto found;
@@ -649,8 +652,6 @@ static bool search_nested_keyrings(struct key *keyring,
 	}
 
 	ctx->skipped_ret = 0;
-	if (ctx->flags & KEYRING_SEARCH_NO_STATE_CHECK)
-		ctx->flags &= ~KEYRING_SEARCH_DO_STATE_CHECK;
 
 	/* Start processing a new keyring */
 descend_to_keyring:
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index bb4337c7ae1b..0bb23f98e4ca 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -516,6 +516,7 @@ struct key *request_key_and_link(struct key_type *type,
 		.match_data.cmp		= key_default_cmp,
 		.match_data.raw_data	= description,
 		.match_data.lookup_type	= KEYRING_SEARCH_LOOKUP_DIRECT,
+		.flags			= KEYRING_SEARCH_DO_STATE_CHECK,
 	};
 	struct key *key;
 	key_ref_t key_ref;
diff --git a/security/keys/request_key_auth.c b/security/keys/request_key_auth.c
index 6639e2cb8853..5d672f7580dd 100644
--- a/security/keys/request_key_auth.c
+++ b/security/keys/request_key_auth.c
@@ -249,6 +249,7 @@ struct key *key_get_instantiation_authkey(key_serial_t target_id)
 		.match_data.cmp		= key_default_cmp,
 		.match_data.raw_data	= description,
 		.match_data.lookup_type	= KEYRING_SEARCH_LOOKUP_DIRECT,
+		.flags			= KEYRING_SEARCH_DO_STATE_CHECK,
 	};
 	struct key *authkey;
 	key_ref_t authkey_ref;

_______________________________________________
Keyrings mailing list
Keyrings@linux-nfs.org
To change your subscription to this list, please see http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings
