Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794176863;
	b=Sy+zidOI1YABshX4nTFYX9PU3DH7I4v8GkGxDkWaWbgMYMdS8Dga1sSLIQa007mNVPB0
	 lNWBqWz3KS3V4G2694Ty3v8Gvd1AQLEGt/qVZxDpuRt0NE1nJC0YcaFMxwNRvWNxr1p/K
	 zUKEX4hrTUNz8KtmKxcs9WS2YGVKJHiDXkA9OtN0FgNYENFGgcsXz1rUApQfyI7TtaFYj
	 JiPt1ulV7NGqIVNdWh7Xx5rF4jLUryS7WUIhlvxH3byHZZ/yvQBqEgi3szWWovtFADc7v
	 /4+uY+web/8fNMnXLwIavT6MwmnSCDu9JDAMut7P437mHTz1W+5n98P2SdXdO7QGz3w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794176863;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=0drM0M3oPrheYDlOFbCeBdCWAIsAz86/BkD133KazZQ=;
	b=yC+ladE8cWbbiVE6JndoVV62//pgfK6lUgWUmL14VzWQXCeLyqD2SacqqXrv/Vpe+Uro
	 yYa19VmlUMpmdJyZ69R/E0mFWd9U44EA3HPiuFgg/VuIRATT3++yIC6ZGyM09X6D2A9T/
	 4gVwBctTQuaVS9ABInkUfv/1YmIpF9dx4uoEMh2sJIC2naPydxZMYbJsyO2KX5JB7gxlA
	 tQuLQwBuREH/7Kf67iTrp/Rm7gxRtNDDFGyP5pDQYBuRgHDTvbeTSjxhe8GFHe5HtlxNH
	 k+O/WAtVVPS6FhaDFNO6fble8wDmo02Zf7OY/q1AEHuYl3qP7nEI/RXRVv+4p2bjkhg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=diNjKykQ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id B713B606A323;
	Sun,  8 Nov 2026 22:27:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=diNjKykQ
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id DD1801F008A3;
	Sun,  8 Nov 2026 22:27:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794176862;
	bh=0drM0M3oPrheYDlOFbCeBdCWAIsAz86/BkD133KazZQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=diNjKykQ0OWyBkItsEkGxnSTBT/OUe4lN7QnjIdkvXBjph2alyyrP/xERUltG5ikw
	 I5qirRtCU7csKf3akOyXPr3fdAt9mPXOdqwd+b7+2uW27EyYkm1HoznfKo45l84ua6
	 +LqAYOvvF1w6Mw0IJ+7YcTXhgDFzD7lbbVRAYqXrLdhaV032XfDwiuAuuu1SCHXXyL
	 VNyyxsReXRZvkpjM1IxMXLTkY/XVl3RxZYkgw1g1Q5ahp8XcbdrTIMB2HxHN/SygQI
	 YBJr6JrOdk8IiLMRFF7LcW+PUmdasnEuvjgzD44rJM0v7DbL55FRFheZyT6YoNxYkG
	 9ayuMQEeZdHlA==
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: Jarkko Sakkinen <jarkko@kernel.org>,
	keyrings@vger.kernel.org,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-integrity@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org,
	Alexander Gordeev <agordeev@linux.ibm.com>,
	Anna Schumaker <anna@kernel.org>,
	Bharath SM <bharathsm@microsoft.com>,
	Christian Borntraeger <borntraeger@linux.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Biggers <ebiggers@kernel.org>,
	Eric Dumazet <edumazet@kernel.org>,
	Heiko Carstens <hca@linux.ibm.com>,
	Jakub Kicinski <kuba@kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	James Morris <jmorris@namei.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Mimi Zohar <zohar@linux.ibm.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Paul Moore <paul@paul-moore.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Simon Horman <horms@kernel.org>,
	Sumit Garg <sumit.garg@kernel.org>,
	Sven Schnelle <svens@linux.ibm.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Vasily Gorbik <gor@linux.ibm.com>
Subject: [PATCH v5 04/12] smb: client: Clear idmap/SPNEGO caches when the last session is unloaded
Date: Mon,  9 Nov 2026 00:27:10 +0200
Message-ID: <20261108222719.304712-5-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261108222719.304712-1-jarkko@kernel.org>
References: <20261108222719.304712-1-jarkko@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

CIFS caches cifs.idmap and cifs.spnego keys in the module-owned keyrings
that are only destroyed in module_exit().

Once keys pin the kernel module of the key type, the cached entries will
retain CIFS pinned after the last SMB session has been torned down.

Serialize the session count transitions with a mutex and clear the idmap
and SPNEGO cache keyrings when the last session is freed.

Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 fs/smb/client/cifs_spnego.c | 12 ++++++++++++
 fs/smb/client/cifsacl.c     | 12 ++++++++++++
 fs/smb/client/cifsproto.h   |  8 ++++++++
 fs/smb/client/misc.c        | 19 +++++++++++++++++--
 4 files changed, 49 insertions(+), 2 deletions(-)

diff --git a/fs/smb/client/cifs_spnego.c b/fs/smb/client/cifs_spnego.c
index 44c407275680..e974f396e07f 100644
--- a/fs/smb/client/cifs_spnego.c
+++ b/fs/smb/client/cifs_spnego.c
@@ -15,6 +15,7 @@
 #include <linux/key-type.h>
 #include <linux/keyctl.h>
 #include <linux/inet.h>
+#include <linux/ratelimit.h>
 #include "cifsglob.h"
 #include "cifs_spnego.h"
 #include "cifs_debug.h"
@@ -190,6 +191,17 @@ cifs_get_spnego_key(struct cifs_ses *sesInfo,
 	return spnego_key;
 }
 
+void
+cifs_spnego_clear_cache(void)
+{
+	int ret;
+
+	ret = keyring_clear(spnego_cred->thread_keyring);
+	if (ret)
+		pr_warn_ratelimited("Failed to clear SPNEGO cache: %d; cache pins remain\n",
+				    ret);
+}
+
 int
 init_cifs_spnego(void)
 {
diff --git a/fs/smb/client/cifsacl.c b/fs/smb/client/cifsacl.c
index 346899da91eb..60c60c23dd34 100644
--- a/fs/smb/client/cifsacl.c
+++ b/fs/smb/client/cifsacl.c
@@ -13,6 +13,7 @@
 #include <linux/string.h>
 #include <linux/keyctl.h>
 #include <linux/key-type.h>
+#include <linux/ratelimit.h>
 #include <uapi/linux/posix_acl.h>
 #include <linux/posix_acl.h>
 #include <linux/posix_acl_xattr.h>
@@ -539,6 +540,17 @@ sid_to_id(struct cifs_sb_info *cifs_sb, struct smb_sid *psid,
 	return 0;
 }
 
+void
+cifs_idmap_clear_cache(void)
+{
+	int ret;
+
+	ret = keyring_clear(root_cred->thread_keyring);
+	if (ret)
+		pr_warn_ratelimited("Failed to clear idmap cache: %d; cache pins remain\n",
+				    ret);
+}
+
 int
 init_cifs_idmap(void)
 {
diff --git a/fs/smb/client/cifsproto.h b/fs/smb/client/cifsproto.h
index f9ea35597bc2..2930a40d1b67 100644
--- a/fs/smb/client/cifsproto.h
+++ b/fs/smb/client/cifsproto.h
@@ -58,8 +58,16 @@ do {									\
 } while (0)
 int init_cifs_idmap(void);
 void exit_cifs_idmap(void);
+void cifs_idmap_clear_cache(void);
 int init_cifs_spnego(void);
 void exit_cifs_spnego(void);
+#ifdef CONFIG_CIFS_UPCALL
+void cifs_spnego_clear_cache(void);
+#else
+static inline void cifs_spnego_clear_cache(void)
+{
+}
+#endif
 const char *build_path_from_dentry(struct dentry *direntry, void *page);
 char *__build_path_from_dentry_optional_prefix(struct dentry *direntry,
 					       void *page, const char *tree,
diff --git a/fs/smb/client/misc.c b/fs/smb/client/misc.c
index ec28f102ea08..11c0330be489 100644
--- a/fs/smb/client/misc.c
+++ b/fs/smb/client/misc.c
@@ -9,6 +9,8 @@
 #include <linux/slab.h>
 #include <linux/ctype.h>
 #include <linux/mempool.h>
+#include <linux/key.h>
+#include <linux/mutex.h>
 #include <linux/vmalloc.h>
 #include "cifsglob.h"
 #include "cifsproto.h"
@@ -33,6 +35,9 @@ struct tcon_list {
 	struct cifs_tcon *tcon;
 };
 
+/* Serialize session admission with the last session's cache clear. */
+static DEFINE_MUTEX(cifs_session_mutex);
+
 /* The xid serves as a useful identifier for each incoming vfs request,
    in a similar way to the mid which is useful to track each sent smb,
    and CurrentXid can also provide a running counter (although it
@@ -74,7 +79,6 @@ sesInfoAlloc(void)
 
 	ret_buf = kzalloc_obj(struct cifs_ses);
 	if (ret_buf) {
-		atomic_inc(&sesInfoAllocCount);
 		spin_lock_init(&ret_buf->ses_lock);
 		ret_buf->ses_status = SES_NEW;
 		++ret_buf->ses_count;
@@ -84,6 +88,10 @@ sesInfoAlloc(void)
 		spin_lock_init(&ret_buf->iface_lock);
 		INIT_LIST_HEAD(&ret_buf->iface_list);
 		spin_lock_init(&ret_buf->chan_lock);
+
+		mutex_lock(&cifs_session_mutex);
+		atomic_inc(&sesInfoAllocCount);
+		mutex_unlock(&cifs_session_mutex);
 	}
 	return ret_buf;
 }
@@ -99,7 +107,6 @@ sesInfoFree(struct cifs_ses *buf_to_free)
 	}
 
 	unload_nls(buf_to_free->local_nls);
-	atomic_dec(&sesInfoAllocCount);
 	kfree(buf_to_free->serverOS);
 	kfree(buf_to_free->serverDomain);
 	kfree(buf_to_free->serverNOS);
@@ -115,6 +122,14 @@ sesInfoFree(struct cifs_ses *buf_to_free)
 		kref_put(&iface->refcount, release_iface);
 	spin_unlock(&buf_to_free->iface_lock);
 	kfree_sensitive(buf_to_free);
+
+	mutex_lock(&cifs_session_mutex);
+	if (atomic_dec_and_test(&sesInfoAllocCount)) {
+		cifs_idmap_clear_cache();
+		cifs_spnego_clear_cache();
+		key_gc_flush();
+	}
+	mutex_unlock(&cifs_session_mutex);
 }
 
 struct cifs_tcon *
-- 
2.47.3

