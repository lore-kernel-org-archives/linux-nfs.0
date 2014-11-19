Return-Path: keyrings-bounces@linux-nfs.org
From: David Howells <dhowells@redhat.com>
To: cth@carlh.net, chuck.lever@oracle.com
Date: Wed, 19 Nov 2014 12:22:49 +0000
Message-ID: <20141119122249.26494.25661.stgit@warthog.procyon.org.uk>
In-Reply-To: <20141119122238.26494.23666.stgit@warthog.procyon.org.uk>
References: <20141119122238.26494.23666.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Cc: neilb@suse.de, linux-nfs@vger.kernel.org, keyrings@linux-nfs.org,
        linux-kernel@vger.kernel.org
Subject: [Keyrings] [PATCH 2/2] KEYS: request_key() should reget expired
 keys rather than give EKEYEXPIRED
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

Since the keyring facility can be viewed as a cache (at least in some
applications), the local expiration time on the key should probably be viewed
as a 'needs updating after this time' property rather than an absolute 'anyone
now wanting to use this object is out of luck' property.

Since request_key() is the main interface for the usage of keys, this should
update or replace an expired key rather than issuing EKEYEXPIRED if the local
expiration has been reached (ie. it should refresh the cache).

For absolute conditions where refreshing the cache probably doesn't help, the
key can be negatively instantiated using KEYCTL_REJECT_KEY with EKEYEXPIRED
given as the error to issue.  This will still cause request_key() to return
EKEYEXPIRED as that was explicitly set.

In the future, if the key type has an update op available, we might want to
upcall with the expired key and allow the upcall to update it.  We would pass
a different operation name (the first column in /etc/request-key.conf) to the
request-key program.

request_key() returning EKEYEXPIRED is causing an NFS problem which Chuck
Lever describes thusly:

	After about 10 minutes, my NFSv4 functional tests fail because the
	ownership of the test files goes to "-2". Looking at /proc/keys
	shows that the id_resolv keys that map to my test user ID have
	expired. The ownership problem persists until the expired keys are
	purged from the keyring, and fresh keys are obtained.

	I bisected the problem to 3.13 commit b2a4df200d57 ("KEYS: Expand
	the capacity of a keyring"). This commit inadvertantly changes the
	API contract of the internal function keyring_search_aux().

	The root cause appears to be that b2a4df200d57 made "no state check"
	the default behavior. "No state check" means the keyring search
	iterator function skips checking the key's expiry timeout, and
	returns expired keys.  request_key_and_link() depends on getting
	an -EAGAIN result code to know when to perform an upcall to refresh
	an expired key.

This patch can be tested directly by:

	keyctl request2 user debug:fred a @s
	keyctl timeout %user:debug:fred 3
	sleep 4
	keyctl request2 user debug:fred a @s

Without the patch, the last command gives error EKEYEXPIRED, but with the
command it gives a new key.

Reported-by: Carl Hetherington <cth@carlh.net>
Reported-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 security/keys/internal.h    |    1 +
 security/keys/keyring.c     |    3 ++-
 security/keys/request_key.c |    3 ++-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/security/keys/internal.h b/security/keys/internal.h
index b8960c4959a5..200e37867336 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -117,6 +117,7 @@ struct keyring_search_context {
 #define KEYRING_SEARCH_NO_UPDATE_TIME	0x0004	/* Don't update times */
 #define KEYRING_SEARCH_NO_CHECK_PERM	0x0008	/* Don't check permissions */
 #define KEYRING_SEARCH_DETECT_TOO_DEEP	0x0010	/* Give an error on excessive depth */
+#define KEYRING_SEARCH_SKIP_EXPIRED	0x0020	/* Ignore expired keys (intention to replace) */
 
 	int (*iterator)(const void *object, void *iterator_data);
 
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index 238aa172f25b..e72548b5897e 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -546,7 +546,8 @@ static int keyring_search_iterator(const void *object, void *iterator_data)
 		}
 
 		if (key->expiry && ctx->now.tv_sec >= key->expiry) {
-			ctx->result = ERR_PTR(-EKEYEXPIRED);
+			if (!(ctx->flags & KEYRING_SEARCH_SKIP_EXPIRED))
+				ctx->result = ERR_PTR(-EKEYEXPIRED);
 			kleave(" = %d [expire]", ctx->skipped_ret);
 			goto skipped;
 		}
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index 0bb23f98e4ca..0c7aea4dea54 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -516,7 +516,8 @@ struct key *request_key_and_link(struct key_type *type,
 		.match_data.cmp		= key_default_cmp,
 		.match_data.raw_data	= description,
 		.match_data.lookup_type	= KEYRING_SEARCH_LOOKUP_DIRECT,
-		.flags			= KEYRING_SEARCH_DO_STATE_CHECK,
+		.flags			= (KEYRING_SEARCH_DO_STATE_CHECK |
+					   KEYRING_SEARCH_SKIP_EXPIRED),
 	};
 	struct key *key;
 	key_ref_t key_ref;

_______________________________________________
Keyrings mailing list
Keyrings@linux-nfs.org
To change your subscription to this list, please see http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings
