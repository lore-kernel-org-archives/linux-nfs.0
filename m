Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10023 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753296AbaCYPFd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Mar 2014 11:05:33 -0400
Subject: [PATCH] KEYS: Allow special keys (eg. DNS results) to be
 invalidated by CAP_SYS_ADMIN
From: David Howells <dhowells@redhat.com>
To: trond.myklebust@primarydata.com
Cc: dhowells@redhat.com, keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        steved@redhat.com, linux-kernel@vger.kernel.org
Date: Tue, 25 Mar 2014 15:05:24 +0000
Message-ID: <20140325150524.8763.8009.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Special kernel keys, such as those used to hold DNS results for AFS, CIFS and
NFS and those used to hold idmapper results for NFS, used to be
'invalidateable' with key_revoke().  However, since the default permissions for
keys were reduced:

	Commit: 96b5c8fea6c0861621051290d705ec2e971963f1
	KEYS: Reduce initial permissions on keys

it has become impossible to do this.

Add a key flag (KEY_FLAG_ROOT_CAN_INVAL) that will permit a key to be
invalidated by root.  This should not be used for system keyrings as the
garbage collector will try and remove any invalidate key.  For system keyrings,
KEY_FLAG_ROOT_CAN_CLEAR can be used instead.

After this, from userspace, keyctl_invalidate() and "keyctl invalidate" can be
used by any possessor of CAP_SYS_ADMIN (typically root) to invalidate DNS and
idmapper keys.  Invalidated keys are immediately garbage collected and will be
immediately rerequested if needed again.

Signed-off-by: David Howells <dhowells@redhat.com>
Tested-by: Steve Dickson <steved@redhat.com>
---

 fs/nfs/idmap.c               |    2 ++
 include/linux/key.h          |    1 +
 net/dns_resolver/dns_query.c |    1 +
 security/keys/keyctl.c       |   15 ++++++++++++++-
 4 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 567983d2c0eb..b7458d77f511 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -282,6 +282,8 @@ static struct key *nfs_idmap_request_key(const char *name, size_t namelen,
 						desc, "", 0, idmap);
 		mutex_unlock(&idmap->idmap_mutex);
 	}
+	if (!IS_ERR(rkey))
+		set_bit(KEY_FLAG_ROOT_CAN_INVAL, &rkey->flags);
 
 	kfree(desc);
 	return rkey;
diff --git a/include/linux/key.h b/include/linux/key.h
index 80d677483e31..3993480b0ac5 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -170,6 +170,7 @@ struct key {
 #define KEY_FLAG_INVALIDATED	7	/* set if key has been invalidated */
 #define KEY_FLAG_TRUSTED	8	/* set if key is trusted */
 #define KEY_FLAG_TRUSTED_ONLY	9	/* set if keyring only accepts links to trusted keys */
+#define KEY_FLAG_ROOT_CAN_INVAL	10	/* set if key can be invalidated by root without permission */
 
 	/* the key type and key description string
 	 * - the desc is used to match a key against search criteria
diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.c
index e7b6d53eef88..bb432b0e85d3 100644
--- a/net/dns_resolver/dns_query.c
+++ b/net/dns_resolver/dns_query.c
@@ -129,6 +129,7 @@ int dns_query(const char *type, const char *name, size_t namelen,
 	}
 
 	down_read(&rkey->sem);
+	set_bit(KEY_FLAG_ROOT_CAN_INVAL, &rkey->flags);
 	rkey->perm |= KEY_USR_VIEW;
 
 	ret = key_validate(rkey);
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index cee72ce64222..7e791bc12796 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -404,12 +404,25 @@ long keyctl_invalidate_key(key_serial_t id)
 	key_ref = lookup_user_key(id, 0, KEY_SEARCH);
 	if (IS_ERR(key_ref)) {
 		ret = PTR_ERR(key_ref);
+
+		/* Root is permitted to invalidate certain special keys */
+		if (capable(CAP_SYS_ADMIN)) {
+			key_ref = lookup_user_key(id, 0, 0);
+			if (IS_ERR(key_ref))
+				goto error;
+			if (test_bit(KEY_FLAG_ROOT_CAN_INVAL,
+				     &key_ref_to_ptr(key_ref)->flags))
+				goto invalidate;
+			goto error_put;
+		}
+
 		goto error;
 	}
 
+invalidate:
 	key_invalidate(key_ref_to_ptr(key_ref));
 	ret = 0;
-
+error_put:
 	key_ref_put(key_ref);
 error:
 	kleave(" = %ld", ret);

