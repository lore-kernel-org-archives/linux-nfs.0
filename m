Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793840016;
	b=2OcKxByOqAU1zq07OPGwRgM7R3SLoQK6gBDVZ040tKe82AbJkBk6HCv4FAfJM4FCp3vy
	 3cUNmRL45AtyPgjbRUM4fyUZ7AUj2OCjgbs1JCjBymM41g/sh5W76Vb7TPuvm3ahWZFNp
	 vfEwiLvMIk2LDOkJGAvbAE+a2/4mIC80dTSxFCx6Fq3QHzufwAvNIqD/UumLtZF9kY/A9
	 f/C36uvlv8WcABABO+zwwRqMXhK0XN+CyAdSoiy5YtgFNcgKvb/ogf9J1lJAt1E1gfsgu
	 iIrWJQ9BRX54K1bjPbaoZVh0Cq/P+JgOcqW/lP/RZrdgv6IeY7zpNkZMuzFxOVtvOwQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793840016;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=5XqHOcPtfGR8QDmVaE5rTMda+qP/4wTAdzTXd0Fuq6k=;
	b=d2E/Bq1BMawfDkLEyT/tkvrVOauRZ7ixzYoFAixuS54cHwMdxzaAcVtfycMBg1Q/D1p5
	 0dQzuwMwh+E0CrzUW+rup4oBSo1cvl8Wu+GYheNcPCI3U2Smuy6weSCUSk5I5KNr9jRgh
	 uvzymO9sTXsW+Do8NcGR4iYCJuOGPAx8zpdfAS1Zo1/xE/QzzlPfkM/ekFzwjoCWHAdpO
	 rEG44l6n7RXOfZ8COqtXrdToIvTROnnX5Xoh5ElgO1hKj+uGgnXZUynVWs6gCn1coVkg8
	 laPPZYZDEJgepElHKpW4HgOwOLl1vn4Ivk76AtYwymRY3govG0zLgfJjqARV550MOFg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gcq2V9mm;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id F2179606D82E;
	Thu,  5 Nov 2026 00:53:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gcq2V9mm
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id DF7841F00A20;
	Thu,  5 Nov 2026 00:53:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793840015;
	bh=5XqHOcPtfGR8QDmVaE5rTMda+qP/4wTAdzTXd0Fuq6k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gcq2V9mmFUYPK3wev96C/1uaByWW4ddYxYJ91eEgjGO2WJYPcpgy4RTFDUgOuETxW
	 wAMHnq/Y7lYkz5F/pDvbu+zfEwZ91u9bVC43qW+fjKn009ffRN1YXVJmj74sGzbNy/
	 MJ9Mr7jZqqpExibjSgCPbuKHB/wWXldkeaX6mC6OIU2te4nFLOsvmBQBTJYFp0DdWK
	 LaA/vqkVTghYRhfZdF/VYRX1qpRRYiGHP+ZyVRFD8KZF+4uyPU0oddX00Jw5/gIeBn
	 2IN218n4gWPtuSrCNFsEKYnsrm7+CJV7aOWOlQXHE6ywmTXkN4l7Ln1mla2Xi8RYB9
	 s4vPFHSjwPGCg==
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
	samba-technical@lists.samba.org,
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
Subject: [RFC PATCH v3 04/11] smb: client: Clear idmap/SPNEGO caches when the last session is unloaded
Date: Thu,  5 Nov 2026 02:53:03 +0200
Message-ID: <20261105005311.804098-5-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261105005311.804098-1-jarkko@kernel.org>
References: <20261105005311.804098-1-jarkko@kernel.org>
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
 fs/smb/client/cifs_spnego.c |  6 ++++++
 fs/smb/client/cifsacl.c     |  6 ++++++
 fs/smb/client/cifsproto.h   |  8 ++++++++
 fs/smb/client/misc.c        | 19 +++++++++++++++++--
 4 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/fs/smb/client/cifs_spnego.c b/fs/smb/client/cifs_spnego.c
index 44c407275680..939e14e755e5 100644
--- a/fs/smb/client/cifs_spnego.c
+++ b/fs/smb/client/cifs_spnego.c
@@ -190,6 +190,12 @@ cifs_get_spnego_key(struct cifs_ses *sesInfo,
 	return spnego_key;
 }
 
+void
+cifs_spnego_clear_cache(void)
+{
+	WARN_ON(keyring_clear(spnego_cred->thread_keyring));
+}
+
 int
 init_cifs_spnego(void)
 {
diff --git a/fs/smb/client/cifsacl.c b/fs/smb/client/cifsacl.c
index 346899da91eb..126b976c2547 100644
--- a/fs/smb/client/cifsacl.c
+++ b/fs/smb/client/cifsacl.c
@@ -539,6 +539,12 @@ sid_to_id(struct cifs_sb_info *cifs_sb, struct smb_sid *psid,
 	return 0;
 }
 
+void
+cifs_idmap_clear_cache(void)
+{
+	WARN_ON(keyring_clear(root_cred->thread_keyring));
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

