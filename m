Received: from mout.gmx.net (mout.gmx.net [212.227.15.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 18785414439;
	Sun, 18 Oct 2026 18:01:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792346519; cv=none; b=kZnlVRgPOWyLE2ZcEKH5dOb6iQqsQMaTyG+1ggPIV2WXnrGYFzy1itj6h8KgrlrphjRPb5xs0UbtmQ28tX/3YB6jhYHzTysUHsbBhFbkTGOVOeStS8BJPwViLjYGNdb7Xe133jXvqJoknV4rvwjzWIad/0NVBPE1NRRgcTWDE9Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792346519; c=relaxed/simple;
	bh=TmCy/Q+V7uYkoDxDRfdhyd1/buspw/Q37Xfki9esTTk=;
	h=Message-ID:In-Reply-To:References:From:Subject:To:Cc:Date; b=OqgXhO1/tyNvIhSbDIB9aehzU2ds2P5pWTjkwh2OvBP2dwFLwJP1ggdua04HlXxuURTwsZ/Zvqvs2jG7YMwJUlHWvq7JQji3G+PEmbQm1/mIM8aUzPIGvCEclSNFGO2rQ/KxgzJDDlPI+TslCE8unqn3kEnWlV1EPES6W5yC0SM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b=mfo7gZ58; arc=none smtp.client-ip=212.227.15.18
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b="mfo7gZ58"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1792346502; x=1792951302; i=jan.koester@gmx.net;
	bh=Uhr0WE0qAUviSvaVEh4Q64OqRPDHfgQaX+yEPhQNp7o=;
	h=X-UI-Sender-Class:Message-ID:In-Reply-To:References:From:Subject:
	 To:Cc:Date:Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=mfo7gZ58ycjWhlv14DinLHTadbOtXRZHWcx3wIYhN1KpUUFT9gj66p12MIWvpEYZ
	 HXECmvpSHunnUwL4a4IMb82XXniCm8BflmeA4GH9HYeTJ3vqcyqQzcFgpyT8qmh9P
	 lK2C1oovQFl8b6Y4O7wg1JmtozO+qmi5RTe4poWTWNChBZJdvDtXPyQxA7Xld9WDq
	 JDUoYiPA62TNQ92q/4B8QWp5XVnbetChtlxf+c1G/qArxQmE/hF7PxFC9Jbsf/2qu
	 sAtPqjZ1kfi7tED8sM1/Z0f5I81T+d6BXlghGqBzhcrpE0ZY0H9FFJBa+F6pT/GH8
	 TJ/xsYccMFc9XLYzBw==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx004
 [212.227.17.190]) with ESMTPSA (Nemesis) id 1N1wq3-1wcf1w3XlR-00tMmo; Sun, 18
 Oct 2026 20:01:41 +0200
Message-ID: <69bd72874419c45adbe80c98c815bb2f00af88cf.1792346472.git.jan.koester@gmx.net>
In-Reply-To: <cover.1792346472.git.jan.koester@gmx.net>
References: <cover.1792346472.git.jan.koester@gmx.net>
From: Jan Koester <jan.koester@gmx.net>
Subject: [RFC PATCH 05/41] af_unix: keep sender ids in skb->cb only when they
 are classic ids
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
Date: Sun, 18 Oct 2026 20:01:26 +0200
X-Provags-ID: V03:K1:vH1gyIst4zVShFGkuH2A28Kg8CuX9IIXpVu6l/mwfT3HWtDnQ+g
 /4MSl6F3/29nNBf5ieIfkmkGUUZSnPWxI8shfjbhwzVZ3sYO3UFyCVwAJq78/A/U3y8WPMK
 0Z8KSlaCAWsbaQgDIMbewir2dE7aZYDVtNtfG519tvGyzF6eD5cH9tq/EeaNYTspRIP9gNF
 aRdkzhiUpox7tgerYxXTg==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:/Hnz5AT+cc0=;Vz4O1YH6wEj4QgRmaWXM4QSNKRW
 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
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

unix_skb_parms has to fit into the 48 bytes of skb->cb. With kuid_t and
kgid_t growing to hold UUIDs and GUIDs the two of them alone would take
40 bytes.

Store classic ids as 32 bit values as before, and only for a UUID or
GUID allocate a small struct unix_skb_ids for both, freed together with
the pid reference in unix_destruct_scm(). AF_UNIX skbs carrying a pid
reference are never cloned, so the pointer has a single owner.
Senders with classic ids see no change and no allocation.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@gmx.net>
=2D--
 net/unix/af_unix.c | 50 +++++++++++++++++++++++++++++++++++++++-------
 net/unix/af_unix.h | 11 ++++++++--
 2 files changed, 52 insertions(+), 9 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 42cffeafc8..2b17310534 100644
=2D-- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1969,11 +1969,46 @@ static void unix_peek_fds(struct scm_cookie *scm, =
struct sk_buff *skb)
 	unix_peek_fpl(scm->fp);
 }
=20
+/*
+ * The sender's ids, in the skb itself for legacy ids; UUIDs and GUIDs do=
n't
+ * fit in skb->cb and come from an allocation, freed with the pid referen=
ce
+ * in unix_destruct_scm().
+ */
+static int unix_skb_set_ids(struct sk_buff *skb, kuid_t uid, kgid_t gid)
+{
+	struct unix_skb_ids *ids =3D NULL;
+
+	if (!uid_is_legacy(uid) || !gid_is_legacy(gid)) {
+		ids =3D kmalloc_obj(*ids, GFP_KERNEL_ACCOUNT);
+		if (!ids)
+			return -ENOMEM;
+		ids->uid =3D uid;
+		ids->gid =3D gid;
+	}
+	kfree(UNIXCB(skb).ids);
+	UNIXCB(skb).ids =3D ids;
+	UNIXCB(skb).uid =3D __kuid_val(uid);
+	UNIXCB(skb).gid =3D __kgid_val(gid);
+	return 0;
+}
+
+static kuid_t unix_skb_uid(const struct sk_buff *skb)
+{
+	return UNIXCB(skb).ids ? UNIXCB(skb).ids->uid : KUIDT_INIT(UNIXCB(skb).u=
id);
+}
+
+static kgid_t unix_skb_gid(const struct sk_buff *skb)
+{
+	return UNIXCB(skb).ids ? UNIXCB(skb).ids->gid : KGIDT_INIT(UNIXCB(skb).g=
id);
+}
+
 static void unix_destruct_scm(struct sk_buff *skb)
 {
 	struct scm_cookie scm =3D {};
=20
 	swap(scm.pid, UNIXCB(skb).pid);
+	kfree(UNIXCB(skb).ids);
+	UNIXCB(skb).ids =3D NULL;
=20
 	if (UNIXCB(skb).fp)
 		unix_detach_fds(&scm, skb);
@@ -1992,20 +2027,21 @@ static int unix_scm_to_skb(struct scm_cookie *scm,=
 struct sk_buff *skb, bool sen
 	int err =3D 0;
=20
 	UNIXCB(skb).pid =3D get_pid(scm->pid);
-	UNIXCB(skb).uid =3D scm->creds.uid;
-	UNIXCB(skb).gid =3D scm->creds.gid;
 	UNIXCB(skb).fp =3D NULL;
+	skb->destructor =3D unix_wfree;
+	err =3D unix_skb_set_ids(skb, scm->creds.uid, scm->creds.gid);
+	if (err)
+		return err;
 	unix_get_secdata(scm, skb);
 	if (scm->fp && send_fds)
 		err =3D unix_attach_fds(scm, skb);
=20
-	skb->destructor =3D unix_wfree;
 	return err;
 }
=20
 static void unix_skb_to_scm(struct sk_buff *skb, struct scm_cookie *scm)
 {
-	scm_set_cred(scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
+	scm_set_cred(scm, UNIXCB(skb).pid, unix_skb_uid(skb), unix_skb_gid(skb))=
;
 	unix_set_secdata(scm, skb);
 }
=20
@@ -2039,7 +2075,7 @@ static int unix_maybe_add_creds(struct sk_buff *skb,=
 const struct sock *sk,
 			return err;
=20
 		UNIXCB(skb).pid =3D get_pid(pid);
-		current_uid_gid(&UNIXCB(skb).uid, &UNIXCB(skb).gid);
+		return unix_skb_set_ids(skb, current_uid(), current_gid());
 	}
=20
 	return 0;
@@ -2049,8 +2085,8 @@ static bool unix_skb_scm_eq(struct sk_buff *skb,
 			    struct scm_cookie *scm)
 {
 	return UNIXCB(skb).pid =3D=3D scm->pid &&
-	       uid_eq(UNIXCB(skb).uid, scm->creds.uid) &&
-	       gid_eq(UNIXCB(skb).gid, scm->creds.gid) &&
+	       uid_eq(unix_skb_uid(skb), scm->creds.uid) &&
+	       gid_eq(unix_skb_gid(skb), scm->creds.gid) &&
 	       unix_secdata_eq(scm, skb);
 }
=20
diff --git a/net/unix/af_unix.h b/net/unix/af_unix.h
index 8119dbeef3..e861a430cf 100644
=2D-- a/net/unix/af_unix.h
+++ b/net/unix/af_unix.h
@@ -10,10 +10,17 @@
=20
 struct sock *unix_peer_get(struct sock *sk);
=20
-struct unix_skb_parms {
-	struct pid		*pid;		/* skb credentials	*/
+/* The sender's ids, when either is a UUID or GUID */
+struct unix_skb_ids {
 	kuid_t			uid;
 	kgid_t			gid;
+};
+
+struct unix_skb_parms {
+	struct pid		*pid;		/* skb credentials	*/
+	struct unix_skb_ids	*ids;		/* uid and gid, or NULL	*/
+	uid_t			uid;		/* for ids NULL: legacy	*/
+	gid_t			gid;		/* uid and gid		*/
 	struct scm_fp_list	*fp;		/* Passed files		*/
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Security ID		*/
=2D-=20
2.56.0

