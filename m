Return-Path: keyrings-bounces@linux-nfs.org
From: David Howells <dhowells@redhat.com>
To: chuck.lever@oracle.com
Date: Fri, 14 Nov 2014 14:06:38 +0000
Message-ID: <20141114140638.2927.61085.stgit@warthog.procyon.org.uk>
In-Reply-To: <20141030174612.10093.61557.stgit@manet.1015granger.net>
References: <20141030174612.10093.61557.stgit@manet.1015granger.net>
MIME-Version: 1.0
Cc: neilb@suse.de, linux-nfs@vger.kernel.org, keyrings@linux-nfs.org
Subject: [Keyrings] [PATCH 3/3] KEYS: KEYRING_SEARCH_NO_STATE_CHECK
 overrides KEYRING_SEARCH_DO_STATE_CHECK
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

KEYRING_SEARCH_NO_STATE_CHECK overrides KEYRING_SEARCH_DO_STATE_CHECK because
it's needed for special operations like keyring cycle detection and possession
detection.  Fix the header comment to this effect.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 security/keys/internal.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/security/keys/internal.h b/security/keys/internal.h
index b8960c4959a5..9e77e33bf8bc 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -112,8 +112,8 @@ struct keyring_search_context {
 	const struct cred	*cred;
 	struct key_match_data	match_data;
 	unsigned		flags;
-#define KEYRING_SEARCH_NO_STATE_CHECK	0x0001	/* Skip state checks */
-#define KEYRING_SEARCH_DO_STATE_CHECK	0x0002	/* Override NO_STATE_CHECK */
+#define KEYRING_SEARCH_NO_STATE_CHECK	0x0001	/* Skip state checks (overrides DO_STATE_CHECK) */
+#define KEYRING_SEARCH_DO_STATE_CHECK	0x0002	/* Request state checks */
 #define KEYRING_SEARCH_NO_UPDATE_TIME	0x0004	/* Don't update times */
 #define KEYRING_SEARCH_NO_CHECK_PERM	0x0008	/* Don't check permissions */
 #define KEYRING_SEARCH_DETECT_TOO_DEEP	0x0010	/* Give an error on excessive depth */

_______________________________________________
Keyrings mailing list
Keyrings@linux-nfs.org
To change your subscription to this list, please see http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings
