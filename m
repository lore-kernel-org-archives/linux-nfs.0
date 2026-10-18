Received: from mout.gmx.net (mout.gmx.net [212.227.15.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1888E415B6A;
	Sun, 18 Oct 2026 18:01:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792346519; cv=none; b=WTwfgtKau2oK2y6ImoDnQlXey/l75MfAxft63InNJmt9Z+xi2lsp/k21Z34fkeqETkXBpMRxTBePixR+lmpfka0RVUO2UvdPokMLvPr4cDyPum1j2zRh3nSqvFM5b7DzxzKDr4z1bCIAlIC9+cdbiDtSploix83lq03IEM+3cN8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792346519; c=relaxed/simple;
	bh=+LqNvCiyIrE34FwVutQU9BdJKgrFsxhLFySkGmwBjTY=;
	h=Message-ID:In-Reply-To:References:From:Subject:To:Cc:Date; b=FhbQKEkZirBgk+456wYh1tUY5hJex32KXzwwrxNEwL3mEzWupSHaN6fFkioEueoM1//+G/UiDOYooP0pluHbeXLlA1pdPSBzWy3a0R01aWrvHlL3yfGpqPfnbDaaY3mU+E11VmYZILJNA2ISXIWTxzT5N0tBCbJ/47xPjjvcw+0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b=DA9gz/AJ; arc=none smtp.client-ip=212.227.15.18
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b="DA9gz/AJ"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1792346505; x=1792951305; i=jan.koester@gmx.net;
	bh=vfL22L8nz81DGlmNq7eC1I0KAVMX3Gaf7qlzS+8oY3M=;
	h=X-UI-Sender-Class:Message-ID:In-Reply-To:References:From:Subject:
	 To:Cc:Date:Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=DA9gz/AJyq5KtpSAXfUgTYnwmZxeuvBYlHADVztQVLfge7kIRui00EOPjO6rduyD
	 ENVfCm++Q/cuedi0yJY6Ft8sorseNoOeKAS3iQysQSHAiPuGbRLTEBZhG1NwRuRf+
	 a81wxldxG7Tg+xdbDinKbIjBqTxAnCCcImfe87sFoL8uLa9/78Xas554aJkGmxqW/
	 RigwZ+md6FjfGFfF85JzmB6XcnBeQj5qcEuEbgpOULkwp1KSPvTyLlWdOLF9z42ZY
	 RSWhz07oc1AzRIZbyJnQYaL0hn6L2YypA9n9NXNsCofAeE1nhxIQ/IFUtVdOtfSz/
	 C1WUjvSNWoq8ZrVjbA==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx004
 [212.227.17.190]) with ESMTPSA (Nemesis) id 1Mz9Yv-1wNnz80i0Z-014vKv; Sun, 18
 Oct 2026 20:01:45 +0200
Message-ID: <b07482283efd6069338674425b523a8947e49a28.1792346472.git.jan.koester@gmx.net>
In-Reply-To: <cover.1792346472.git.jan.koester@gmx.net>
References: <cover.1792346472.git.jan.koester@gmx.net>
From: Jan Koester <jan.koester@gmx.net>
Subject: [RFC PATCH 06/41] netlink: keep classic sender ids in skb->cb
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
Date: Sun, 18 Oct 2026 20:01:27 +0200
X-Provags-ID: V03:K1:k9TN29SdzDpdfX7HJPawdq1u6FNYgJLu+cSrumALb2Hixxnkjp/
 cPh5zoHsrobEZpDDMeqql2FXv7eWP/pNRaljlR3jWYt055LH4BAA7UYtcESY1IAFeUbj2r2
 UMuMHJI+9B0o6Xsj3f68Dbkcfkf13InR3iN9g93QxdYPK9/4ISW2wvc0L6a4epNKr7Rjj8i
 inm+d8Qil1R28n6DyHdzw==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:9Aasgl+HSGo=;L8bD+C2xqMpTEo7acr8I+BNB3yh
 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
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

netlink_skb_parms has to fit into skb->cb, and netlink skbs are cloned
together with it for broadcasts, so there is neither room for kuid_t
and kgid_t holding UUIDs nor a single owner for an allocation.

Store the sender ids as classic kernel ids: a UUID or GUID becomes -1,
which reaches the receiver of SCM_CREDENTIALS as the overflow id. The
kernel's own permission checks on netlink messages use the socket's
file credentials, not these.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@gmx.net>
=2D--
 include/linux/netlink.h  |  2 +-
 include/net/scm.h        | 28 ++++++++++++++++++++++++++++
 lib/kobject_uevent.c     |  8 ++++----
 net/netlink/af_netlink.c |  4 ++--
 4 files changed, 35 insertions(+), 7 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 882e9c1b6c..999c7a352e 100644
=2D-- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -23,7 +23,7 @@ enum netlink_skb_flags {
 };
=20
 struct netlink_skb_parms {
-	struct scm_creds	creds;		/* Skb credentials	*/
+	struct scm_creds_classic creds;		/* Skb credentials	*/
 	__u32			portid;
 	__u32			dst_group;
 	__u32			flags;
diff --git a/include/net/scm.h b/include/net/scm.h
index 86ae6bc109..daa52e3d44 100644
=2D-- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -23,6 +23,34 @@ struct scm_creds {
 	kgid_t	gid;
 };
=20
+/*
+ * Sender credentials for skb->cb of skbs that get cloned along with it
+ * (netlink, bluetooth): no room for kuid_t and kgid_t, and no single own=
er
+ * for an allocation. The ids are classic kernel ids; a UUID or GUID beco=
mes
+ * -1, which the receiver of SCM_CREDENTIALS sees as the overflow id.
+ */
+struct scm_creds_classic {
+	u32	pid;
+	uid_t	uid;
+	gid_t	gid;
+};
+
+static inline void scm_creds_to_classic(struct scm_creds_classic *classic=
,
+					const struct scm_creds *creds)
+{
+	classic->pid =3D creds->pid;
+	classic->uid =3D __kuid_val(creds->uid);
+	classic->gid =3D __kgid_val(creds->gid);
+}
+
+static inline void scm_creds_from_classic(struct scm_creds *creds,
+					  const struct scm_creds_classic *classic)
+{
+	creds->pid =3D classic->pid;
+	creds->uid =3D KUIDT_INIT(classic->uid);
+	creds->gid =3D KGIDT_INIT(classic->gid);
+}
+
 #ifdef CONFIG_UNIX
 struct unix_edge;
 #endif
diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index ddbc4d7482..8b63044881 100644
=2D-- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -297,8 +297,8 @@ static struct sk_buff *alloc_uevent_skb(struct kobj_ue=
vent_env *env,
 	skb_put_data(skb, env->buf, env->buflen);
=20
 	parms =3D &NETLINK_CB(skb);
-	parms->creds.uid =3D GLOBAL_ROOT_UID;
-	parms->creds.gid =3D GLOBAL_ROOT_GID;
+	parms->creds.uid =3D __kuid_val(GLOBAL_ROOT_UID);
+	parms->creds.gid =3D __kgid_val(GLOBAL_ROOT_GID);
 	parms->dst_group =3D 1;
 	parms->portid =3D 0;
=20
@@ -362,12 +362,12 @@ static int uevent_net_broadcast_tagged(struct sock *=
usk,
 		/* fix uid */
 		root_uid =3D make_kuid(owning_user_ns, 0);
 		if (uid_valid(root_uid))
-			parms->creds.uid =3D root_uid;
+			parms->creds.uid =3D __kuid_val(root_uid);
=20
 		/* fix gid */
 		root_gid =3D make_kgid(owning_user_ns, 0);
 		if (gid_valid(root_gid))
-			parms->creds.gid =3D root_gid;
+			parms->creds.gid =3D __kgid_val(root_gid);
 	}
=20
 	ret =3D netlink_broadcast(usk, skb, 0, 1, GFP_KERNEL);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 3029894eda..282a5d0da4 100644
=2D-- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1901,7 +1901,7 @@ static int netlink_sendmsg(struct socket *sock, stru=
ct msghdr *msg, size_t len)
=20
 	NETLINK_CB(skb).portid	=3D nlk->portid;
 	NETLINK_CB(skb).dst_group =3D dst_group;
-	NETLINK_CB(skb).creds	=3D scm.creds;
+	scm_creds_to_classic(&NETLINK_CB(skb).creds, &scm.creds);
 	NETLINK_CB(skb).flags	=3D netlink_skb_flags;
=20
 	err =3D -EFAULT;
@@ -1994,7 +1994,7 @@ static int netlink_recvmsg(struct socket *sock, stru=
ct msghdr *msg, size_t len,
 		netlink_cmsg_listen_all_nsid(sk, msg, skb);
=20
 	memset(&scm, 0, sizeof(scm));
-	scm.creds =3D *NETLINK_CREDS(skb);
+	scm_creds_from_classic(&scm.creds, NETLINK_CREDS(skb));
 	if (flags & MSG_TRUNC)
 		copied =3D data_skb->len;
=20
=2D-=20
2.56.0

