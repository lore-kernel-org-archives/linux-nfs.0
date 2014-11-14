Return-Path: keyrings-bounces@linux-nfs.org
From: David Howells <dhowells@redhat.com>
To: chuck.lever@oracle.com
Date: Fri, 14 Nov 2014 14:06:29 +0000
Message-ID: <20141114140629.2927.82977.stgit@warthog.procyon.org.uk>
In-Reply-To: <20141030174612.10093.61557.stgit@manet.1015granger.net>
References: <20141030174612.10093.61557.stgit@manet.1015granger.net>
MIME-Version: 1.0
Cc: neilb@suse.de, linux-nfs@vger.kernel.org, keyrings@linux-nfs.org
Subject: [Keyrings] [PATCH 2/3] KEYS: When searching a keyring,
 restore KEYRING_SEARCH_DO_STATE_CHECK
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

When searching a keyring or iterating over all the contents of a keyring, we
set KEYRING_SEARCH_DO_STATE_CHECK before checking the root keyring so that the
iterator function will ensure that we have permission to search that keyring.

However, we should restore the value of the flag afterwards as it will
otherwise affect all other keys checked by the iterator.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 security/keys/keyring.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index 8177010174f7..f44b3a8d605a 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -636,6 +636,7 @@ static bool search_nested_keyrings(struct key *keyring,
 	 */
 	if (ctx->match_data.lookup_type == KEYRING_SEARCH_LOOKUP_ITERATE ||
 	    keyring_compare_object(keyring, &ctx->index_key)) {
+		unsigned long saved_flags = ctx->flags;
 		ctx->skipped_ret = 2;
 		ctx->flags |= KEYRING_SEARCH_DO_STATE_CHECK;
 		switch (ctx->iterator(keyring_key_to_ptr(keyring), ctx)) {
@@ -644,6 +645,7 @@ static bool search_nested_keyrings(struct key *keyring,
 		case 2:
 			return false;
 		default:
+			ctx->flags = saved_flags;
 			break;
 		}
 	}

_______________________________________________
Keyrings mailing list
Keyrings@linux-nfs.org
To change your subscription to this list, please see http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings
