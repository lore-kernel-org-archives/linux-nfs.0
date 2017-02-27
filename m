Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57292 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751471AbdB0WFp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 27 Feb 2017 17:05:45 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <cover.1487802542.git.jstancek@redhat.com>
References: <cover.1487802542.git.jstancek@redhat.com>
To: Jan Stancek <jstancek@redhat.com>
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, bcodding@redhat.com, asavkov@redhat.com
Subject: Re: [PATCH 0/2] key payload access with just rcu_read_lock()
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 27 Feb 2017 22:04:21 +0000
Message-ID: <9557.1488233061@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jan Stancek <jstancek@redhat.com> wrote:

> this is a follow-up for "suspicious RCU usage" warning described
> in these 2 linux-nfs threads:
>   http://marc.info/?t=147558830300003&r=1&w=2
>   http://marc.info/?t=148776770500001&r=1&w=2
> 
> Did you have something like in mind?

How about the attached?  It's similar to what you did, but I made the split
functions different from the original so that all users have to reconsider
what they actually want.

David
---
commit 6b83b77697e1cec537d131f5f84e8e10c78d36e0
Author: David Howells <dhowells@redhat.com>
Date:   Mon Feb 27 16:47:13 2017 +0000

    KEYS: Differentiate uses of rcu_dereference_key() and user_key_payload()
    
    rcu_dereference_key() and user_key_payload() are currently being used in
    two different, incompatible ways:
    
     (1) As a wrapper to rcu_dereference() - when only the RCU read lock used
         to protect the key.
    
     (2) As a wrapper to rcu_dereference_protected() - when the key semaphor is
         used to protect the key and the may be being modified.
    
    Fix this by splitting both of the key wrappers to produce:
    
     (1) RCU accessors for keys when caller has the key semaphore locked:
    
            dereference_key_locked()
            user_key_payload_locked()
    
     (2) RCU accessors for keys when caller holds the RCU read lock:
    
            dereference_key_rcu()
            user_key_payload_rcu()
    
    This should fix following warning in the NFS idmapper
    
      ===============================
      [ INFO: suspicious RCU usage. ]
      4.10.0 #1 Tainted: G        W
      -------------------------------
      ./include/keys/user-type.h:53 suspicious rcu_dereference_protected() usage!
      other info that might help us debug this:
      rcu_scheduler_active = 2, debug_locks = 0
      1 lock held by mount.nfs/5987:
        #0:  (rcu_read_lock){......}, at: [<d000000002527abc>] nfs_idmap_get_key+0x15c/0x420 [nfsv4]
      stack backtrace:
      CPU: 1 PID: 5987 Comm: mount.nfs Tainted: G        W       4.10.0 #1
      Call Trace:
        dump_stack+0xe8/0x154 (unreliable)
        lockdep_rcu_suspicious+0x140/0x190
        nfs_idmap_get_key+0x380/0x420 [nfsv4]
        nfs_map_name_to_uid+0x2a0/0x3b0 [nfsv4]
        decode_getfattr_attrs+0xfac/0x16b0 [nfsv4]
        decode_getfattr_generic.constprop.106+0xbc/0x150 [nfsv4]
        nfs4_xdr_dec_lookup_root+0xac/0xb0 [nfsv4]
        rpcauth_unwrap_resp+0xe8/0x140 [sunrpc]
        call_decode+0x29c/0x910 [sunrpc]
        __rpc_execute+0x140/0x8f0 [sunrpc]
        rpc_run_task+0x170/0x200 [sunrpc]
        nfs4_call_sync_sequence+0x68/0xa0 [nfsv4]
        _nfs4_lookup_root.isra.44+0xd0/0xf0 [nfsv4]
        nfs4_lookup_root+0xe0/0x350 [nfsv4]
        nfs4_lookup_root_sec+0x70/0xa0 [nfsv4]
        nfs4_find_root_sec+0xc4/0x100 [nfsv4]
        nfs4_proc_get_rootfh+0x5c/0xf0 [nfsv4]
        nfs4_get_rootfh+0x6c/0x190 [nfsv4]
        nfs4_server_common_setup+0xc4/0x260 [nfsv4]
        nfs4_create_server+0x278/0x3c0 [nfsv4]
        nfs4_remote_mount+0x50/0xb0 [nfsv4]
        mount_fs+0x74/0x210
        vfs_kern_mount+0x78/0x220
        nfs_do_root_mount+0xb0/0x140 [nfsv4]
        nfs4_try_mount+0x60/0x100 [nfsv4]
        nfs_fs_mount+0x5ec/0xda0 [nfs]
        mount_fs+0x74/0x210
        vfs_kern_mount+0x78/0x220
        do_mount+0x254/0xf70
        SyS_mount+0x94/0x100
        system_call+0x38/0xe0
    
    Reported-by: Jan Stancek <jstancek@redhat.com>
    Signed-off-by: David Howells <dhowells@redhat.com>

diff --git a/Documentation/security/keys.txt b/Documentation/security/keys.txt
index 3849814bfe6d..0e03baf271bd 100644
--- a/Documentation/security/keys.txt
+++ b/Documentation/security/keys.txt
@@ -1151,8 +1151,21 @@ access the data:
      usage.  This is called key->payload.rcu_data0.  The following accessors
      wrap the RCU calls to this element:
 
-	rcu_assign_keypointer(struct key *key, void *data);
-	void *rcu_dereference_key(struct key *key);
+     (a) Set or change the first payload pointer:
+
+		rcu_assign_keypointer(struct key *key, void *data);
+
+     (b) Read the first payload pointer with the key semaphore held:
+
+		[const] void *dereference_key_locked([const] struct key *key);
+
+	 Note that the return value will inherit its constness from the key
+	 parameter.  Static analysis will give an error if it things the lock
+	 isn't held.
+
+     (c) Read the first payload pointer with the RCU read lock held:
+
+		const void *dereference_key_rcu(const struct key *key);
 
 
 ===================
diff --git a/fs/fscache/object-list.c b/fs/fscache/object-list.c
index 5d5ddaa84b21..67f940892ef8 100644
--- a/fs/fscache/object-list.c
+++ b/fs/fscache/object-list.c
@@ -329,7 +329,7 @@ static void fscache_objlist_config(struct fscache_objlist_data *data)
 	config = 0;
 	rcu_read_lock();
 
-	confkey = user_key_payload(key);
+	confkey = user_key_payload_rcu(key);
 	buf = confkey->data;
 
 	for (len = confkey->datalen - 1; len >= 0; len--) {
diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index c444285bb1b1..835c163f61af 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -316,7 +316,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
 	if (ret < 0)
 		goto out_up;
 
-	payload = user_key_payload(rkey);
+	payload = user_key_payload_rcu(rkey);
 	if (IS_ERR_OR_NULL(payload)) {
 		ret = PTR_ERR(payload);
 		goto out_up;
diff --git a/include/keys/user-type.h b/include/keys/user-type.h
index c56fef40f53e..932f85d7a19c 100644
--- a/include/keys/user-type.h
+++ b/include/keys/user-type.h
@@ -48,9 +48,14 @@ extern void user_describe(const struct key *user, struct seq_file *m);
 extern long user_read(const struct key *key,
 		      char __user *buffer, size_t buflen);
 
-static inline const struct user_key_payload *user_key_payload(const struct key *key)
+static inline const struct user_key_payload *user_key_payload_rcu(const struct key *key)
 {
-	return (struct user_key_payload *)rcu_dereference_key(key);
+	return (struct user_key_payload *)dereference_key_rcu(key);
+}
+
+static inline struct user_key_payload *user_key_payload_locked(struct key *key)
+{
+	return (struct user_key_payload *)dereference_key_locked(key);
 }
 
 #endif /* CONFIG_KEYS */
diff --git a/include/linux/key.h b/include/linux/key.h
index 722914798f37..e45212f2777e 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -354,7 +354,10 @@ static inline bool key_is_instantiated(const struct key *key)
 		!test_bit(KEY_FLAG_NEGATIVE, &key->flags);
 }
 
-#define rcu_dereference_key(KEY)					\
+#define dereference_key_rcu(KEY)					\
+	(rcu_dereference((KEY)->payload.rcu_data0))
+
+#define dereference_key_locked(KEY)					\
 	(rcu_dereference_protected((KEY)->payload.rcu_data0,		\
 				   rwsem_is_locked(&((struct key *)(KEY))->sem)))
 
diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.c
index ecc28cff08ab..d502c94b1a82 100644
--- a/net/dns_resolver/dns_query.c
+++ b/net/dns_resolver/dns_query.c
@@ -70,7 +70,7 @@ int dns_query(const char *type, const char *name, size_t namelen,
 	      const char *options, char **_result, time64_t *_expiry)
 {
 	struct key *rkey;
-	const struct user_key_payload *upayload;
+	struct user_key_payload *upayload;
 	const struct cred *saved_cred;
 	size_t typelen, desclen;
 	char *desc, *cp;
@@ -141,7 +141,7 @@ int dns_query(const char *type, const char *name, size_t namelen,
 	if (ret)
 		goto put;
 
-	upayload = user_key_payload(rkey);
+	upayload = user_key_payload_locked(rkey);
 	len = upayload->datalen;
 
 	ret = -ENOMEM;
diff --git a/security/keys/dh.c b/security/keys/dh.c
index 531ed2ec132f..893af4c45038 100644
--- a/security/keys/dh.c
+++ b/security/keys/dh.c
@@ -55,7 +55,7 @@ static ssize_t mpi_from_key(key_serial_t keyid, size_t maxlen, MPI *mpi)
 		if (status == 0) {
 			const struct user_key_payload *payload;
 
-			payload = user_key_payload(key);
+			payload = user_key_payload_locked(key);
 
 			if (maxlen == 0) {
 				*mpi = NULL;
diff --git a/security/keys/encrypted-keys/encrypted.c b/security/keys/encrypted-keys/encrypted.c
index 4fb315cddf5b..0010955d7876 100644
--- a/security/keys/encrypted-keys/encrypted.c
+++ b/security/keys/encrypted-keys/encrypted.c
@@ -314,7 +314,7 @@ static struct key *request_user_key(const char *master_desc, const u8 **master_k
 		goto error;
 
 	down_read(&ukey->sem);
-	upayload = user_key_payload(ukey);
+	upayload = user_key_payload_locked(ukey);
 	*master_key = upayload->data;
 	*master_keylen = upayload->datalen;
 error:
@@ -926,7 +926,7 @@ static long encrypted_read(const struct key *key, char __user *buffer,
 	size_t asciiblob_len;
 	int ret;
 
-	epayload = rcu_dereference_key(key);
+	epayload = dereference_key_locked(key);
 
 	/* returns the hex encoded iv, encrypted-data, and hmac as ascii */
 	asciiblob_len = epayload->datablob_len + ivsize + 1
diff --git a/security/keys/trusted.c b/security/keys/trusted.c
index 90d61751ff12..2ae31c5a87de 100644
--- a/security/keys/trusted.c
+++ b/security/keys/trusted.c
@@ -1140,12 +1140,12 @@ static int trusted_update(struct key *key, struct key_preparsed_payload *prep)
 static long trusted_read(const struct key *key, char __user *buffer,
 			 size_t buflen)
 {
-	struct trusted_key_payload *p;
+	const struct trusted_key_payload *p;
 	char *ascii_buf;
 	char *bufp;
 	int i;
 
-	p = rcu_dereference_key(key);
+	p = dereference_key_locked(key);
 	if (!p)
 		return -EINVAL;
 	if (!buffer || buflen <= 0)
diff --git a/security/keys/user_defined.c b/security/keys/user_defined.c
index e187c8909d9d..bbee5424ff7c 100644
--- a/security/keys/user_defined.c
+++ b/security/keys/user_defined.c
@@ -107,7 +107,7 @@ int user_update(struct key *key, struct key_preparsed_payload *prep)
 	/* attach the new data, displacing the old */
 	key->expiry = prep->expiry;
 	if (!test_bit(KEY_FLAG_NEGATIVE, &key->flags))
-		zap = rcu_dereference_key(key);
+		zap = dereference_key_locked(key);
 	rcu_assign_keypointer(key, prep->payload.data[0]);
 	prep->payload.data[0] = NULL;
 
@@ -169,7 +169,7 @@ long user_read(const struct key *key, char __user *buffer, size_t buflen)
 	const struct user_key_payload *upayload;
 	long ret;
 
-	upayload = user_key_payload(key);
+	upayload = user_key_payload_rcu(key);
 	ret = upayload->datalen;
 
 	/* we can return the data as is */
