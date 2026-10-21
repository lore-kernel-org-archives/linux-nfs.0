Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552544;
	b=JrtIR3JI4CJWqXLTBICwaY6vZNNxP7lSt5H9FKOs/ENgYw1G1QwzP/U7Wil9vIfAOKwr
	 c+XISxHAaq8kfBOaF9vgsA8WjVA7x4NRMhXC7k+Qe1UxoPpT0t1/VjXPnrwbMMAyZVKqE
	 ZshQB885eWhPOWU0CYPoPst/mCUaflMhCWDufiaMUFBeTuySL1rY8DEisayJDSn8fx59I
	 aeWu8Cy0wg10/7JX7Xtm2sugdRwXl5UqVVw4P2Leka/+HpCXSdt/Q19vU4wGP+BmRLEOs
	 FuxM3sl2+i6yCCwexqu2quERbaD9/UP+YqSCZbPw+LdrA/VVrTj60SEyrDi5f0/EQ5g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552544;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=UqACSuxX6DxaNqvDAlbYCHcCgrvIR5vS5dUzLn5og68=;
	b=wO3RTSK3O8EQU6ibitZsW/qo7zKG1bprq5bg1Ecbt10hUp19yDPCsg7BtrPj8bXSxSCc
	 i9ynHJ8SUIJUXcBLByxLnbMp0mN6Sld+rK1PS74hNVoCdLglHGHsoSJqTiXzf7GlsB33c
	 5SBCagnaPXzIRnt4pJ0YyHDU1vh1Ppe8tpsSu0qMHb/W594G3y6tfAe6hp1eUYpbSvHJE
	 FrQjPj6b8Jcs4lKvCqdi8YlJBD/hoTqtMzEtT/CTR6R30H+6mFrAfO+1viYnWdImZ0QhD
	 0uBwDxdf40MZWR+Ah1OqCCfRgQPVf091RhXTyIks19Yela3Qhw9MWpcQcY8OEJmiIww==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=R7LnbxTA;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3168360A3816;
	Wed, 21 Oct 2026 03:15:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3168360A3816
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=R7LnbxTA
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552542; bh=dEDP783Ds9eSYM3qDSI8k34UiGMZYGLCrU3gnBJpFgE=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=R7LnbxTAMDKnWR2C+g1gY2C49ZHsMZTlgkdYqpUAqFS9Oafvnz6gt2yXYcndLHebd
	 CDaJH7Ic+IyNmlK70RNOnEwrEnf6dtlXXB+zUo1NzADyPu8leFOAelfM45humTdIIh
	 DW7RbplwDnC720wPtqn7M0EpxzhaUHavDr9VkFd2GaijZigBcIyBldXc+b7oSElprb
	 NT7V/RBkQF/QsDc0cvhNTCqfAp0KmcWHU5yYgeZwNTkBuC9U9nmjgx4HAfK/+QHYpL
	 6z/krgfhs0VDpDI0XfzX3QuCi64W+QCB5d5f+DnjgMVDcnRkrZotI2PJg1Fs9GhwJn
	 iNp1eRi6bwPYg==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 6137E8A0651;
	Wed, 21 Oct 2026 05:15:41 +0200 (CEST)
Message-ID: <6cce823256f7f88ad17a2d16aa4020b1bb228dba.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 06/41] netlink: keep classic sender ids in skb->cb
To: Christian Brauner <brauner@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>,
    "Theodore Y. Ts'o" <tytso@mit.edu>,
    Paul Moore <paul@paul-moore.com>,
    Arnd Bergmann <arnd@arndb.de>,
    linux-fsdevel@vger.kernel.org,
    linux-api@vger.kernel.org,
    linux-security-module@vger.kernel.org,
    linux-arch@vger.kernel.org,
    linux-ext4@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-cifs@vger.kernel.org,
    netdev@vger.kernel.org,
    audit@vger.kernel.org,
    keyrings@vger.kernel.org,
    linux-kernel@vger.kernel.org
Date: Wed, 21 Oct 2026 05:15:26 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

netlink_skb_parms has to fit into skb->cb, and netlink skbs are cloned
together with it for broadcasts, so there is neither room for kuid_t
and kgid_t holding UUIDs nor a single owner for an allocation.

Store the sender ids as classic kernel ids: a UUID or GUID becomes -1,
which reaches the receiver of SCM_CREDENTIALS as the overflow id. The
kernel's own permission checks on netlink messages use the socket's
file credentials, not these.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 include/linux/netlink.h  |  2 +-
 include/net/scm.h        | 28 ++++++++++++++++++++++++++++
 lib/kobject_uevent.c     |  8 ++++----
 net/netlink/af_netlink.c |  4 ++--
 4 files changed, 35 insertions(+), 7 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 882e9c1b6c..999c7a352e 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -23,7 +23,7 @@ enum netlink_skb_flags {
 };
 
 struct netlink_skb_parms {
-	struct scm_creds	creds;		/* Skb credentials	*/
+	struct scm_creds_classic creds;		/* Skb credentials	*/
 	__u32			portid;
 	__u32			dst_group;
 	__u32			flags;
diff --git a/include/net/scm.h b/include/net/scm.h
index 86ae6bc109..daa52e3d44 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -23,6 +23,34 @@ struct scm_creds {
 	kgid_t	gid;
 };
 
+/*
+ * Sender credentials for skb->cb of skbs that get cloned along with it
+ * (netlink, bluetooth): no room for kuid_t and kgid_t, and no single owner
+ * for an allocation. The ids are classic kernel ids; a UUID or GUID becomes
+ * -1, which the receiver of SCM_CREDENTIALS sees as the overflow id.
+ */
+struct scm_creds_classic {
+	u32	pid;
+	uid_t	uid;
+	gid_t	gid;
+};
+
+static inline void scm_creds_to_classic(struct scm_creds_classic *classic,
+					const struct scm_creds *creds)
+{
+	classic->pid = creds->pid;
+	classic->uid = __kuid_val(creds->uid);
+	classic->gid = __kgid_val(creds->gid);
+}
+
+static inline void scm_creds_from_classic(struct scm_creds *creds,
+					  const struct scm_creds_classic *classic)
+{
+	creds->pid = classic->pid;
+	creds->uid = KUIDT_INIT(classic->uid);
+	creds->gid = KGIDT_INIT(classic->gid);
+}
+
 #ifdef CONFIG_UNIX
 struct unix_edge;
 #endif
diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index ddbc4d7482..8b63044881 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -297,8 +297,8 @@ static struct sk_buff *alloc_uevent_skb(struct kobj_uevent_env *env,
 	skb_put_data(skb, env->buf, env->buflen);
 
 	parms = &NETLINK_CB(skb);
-	parms->creds.uid = GLOBAL_ROOT_UID;
-	parms->creds.gid = GLOBAL_ROOT_GID;
+	parms->creds.uid = __kuid_val(GLOBAL_ROOT_UID);
+	parms->creds.gid = __kgid_val(GLOBAL_ROOT_GID);
 	parms->dst_group = 1;
 	parms->portid = 0;
 
@@ -362,12 +362,12 @@ static int uevent_net_broadcast_tagged(struct sock *usk,
 		/* fix uid */
 		root_uid = make_kuid(owning_user_ns, 0);
 		if (uid_valid(root_uid))
-			parms->creds.uid = root_uid;
+			parms->creds.uid = __kuid_val(root_uid);
 
 		/* fix gid */
 		root_gid = make_kgid(owning_user_ns, 0);
 		if (gid_valid(root_gid))
-			parms->creds.gid = root_gid;
+			parms->creds.gid = __kgid_val(root_gid);
 	}
 
 	ret = netlink_broadcast(usk, skb, 0, 1, GFP_KERNEL);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 9fdf964224..9f1ac580cc 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1897,7 +1897,7 @@ static int netlink_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 	NETLINK_CB(skb).portid	= nlk->portid;
 	NETLINK_CB(skb).dst_group = dst_group;
-	NETLINK_CB(skb).creds	= scm.creds;
+	scm_creds_to_classic(&NETLINK_CB(skb).creds, &scm.creds);
 	NETLINK_CB(skb).flags	= netlink_skb_flags;
 
 	err = -EFAULT;
@@ -1990,7 +1990,7 @@ static int netlink_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		netlink_cmsg_listen_all_nsid(sk, msg, skb);
 
 	memset(&scm, 0, sizeof(scm));
-	scm.creds = *NETLINK_CREDS(skb);
+	scm_creds_from_classic(&scm.creds, NETLINK_CREDS(skb));
 	if (flags & MSG_TRUNC)
 		copied = data_skb->len;
 
-- 
2.56.0

