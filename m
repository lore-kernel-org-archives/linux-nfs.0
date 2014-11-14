Return-Path: keyrings-bounces@linux-nfs.org
From: David Howells <dhowells@redhat.com>
To: chuck.lever@oracle.com
Date: Fri, 14 Nov 2014 14:06:19 +0000
Message-ID: <20141114140619.2927.86929.stgit@warthog.procyon.org.uk>
In-Reply-To: <20141030174612.10093.61557.stgit@manet.1015granger.net>
References: <20141030174612.10093.61557.stgit@manet.1015granger.net>
MIME-Version: 1.0
Cc: neilb@suse.de, linux-nfs@vger.kernel.org, keyrings@linux-nfs.org
Subject: [Keyrings] [PATCH 1/3] KEYS: request_key_and_link() needs to
 request state checks when searching
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

request_key_and_link() needs to request state checks be performed on the
potentially extant keys when it requests a search of the process keyrings.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 security/keys/request_key.c |    1 +
 1 file changed, 1 insertion(+)

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

_______________________________________________
Keyrings mailing list
Keyrings@linux-nfs.org
To change your subscription to this list, please see http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings
