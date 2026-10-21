Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552541;
	b=dtamUW8HC8ctCWlbT+TcAa+dlo4AJvSDM/3FYgl/ZBfodR0YgmEVTdvSqxb5x9WAMW8W
	 nI/WAu62fh3eYg4lKbr+fJAVdOls/wr8QB3eqWtKCdj1y3XGGGWg/JvKtDO6FLIjFo/v/
	 72QLGRRbYdNZXrm0qqvNwP5vvc1Mcsoy51J9qhJYbyv6gDqd3g827HmcywosaKbh8/hMv
	 ACaekgzRgKbQ0KKspqT2OJatZLKEn/d9HUPw4GIJcCgAg9FRjcsTpKJmu7+1KZnhZccD5
	 F0Ob3m4lpLBEHmQ5gcbs0jD8PVJY16Ix4KoXRwQmcx5LWY6ALU2zvwaVDMpUn8YdLEw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552541;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=ilgWZq8lBu3cTHC4tjsY3+OD0RL/20qOT/gfO/+8/Ns=;
	b=uLc/2UuvDCXDdpUTh5mFJ6Zt05TYI70cLuGwznTval6jBvtC+IIkZWIO8wmlK9vdJUHg
	 w5N1IyeQFeFZqML980Vsbg7bV6xdsTissaKRAdIiHhL6YYY5KaxglJ3rbhQ1z5LV5k7e8
	 QmVwy1u3LmHLcmq4hwALBa+orqtSdM3BfSqCk71TEH5goeVIh1hB2R9yXVb8rOfv6+MSS
	 Nxcotqlg3gOKNplUj0l6LqiQxV5JxjSDeAF+YL3HkOfxjSfJKco9yBQ/Hx1o/1dfOWRWl
	 QR4Imwbjd25I3ZxngpIE/55Q4ErOURboreVrgdlpK44nZUdGBJsw8pRRmMGwosADpDQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=fmvA1BUI;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 717D3606A33C;
	Wed, 21 Oct 2026 03:15:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 717D3606A33C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=fmvA1BUI
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552538; bh=qWM7jvTDWgnk6/SLc5fl/wvoe0XSEzsjigl1XiisGY4=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=fmvA1BUI9rAIY0k7Lbp7tPKh+8RUjmcHfFo82dzNAmLF4PCA6sf/9cetHzoNvM8m+
	 2bTH6w1iJKcwrlHlo8epNQOBYq1PkVRYLXnXQQwfcQyOlgoaYVgz5unl37kW7RUgdo
	 6zHZafd49DOH5I5qEPddUuCDJk9E62uoKYgw28sOjOzK6Ydl27ObEf9x2Pq5SudfN1
	 +uJDvYoRnrkk1xadlP9i4Qlx6v+GGzurcGwezUevYgBFtJZfpqmVonqQ9glhLrmsyK
	 tSQ+/qleC7T8wlJ+TUsM2NbVAKlA2/7OAe1XFnO/SOgzKrHEpW0xuRqk1Jm9budQAB
	 4AMfhG0kzUuFw==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id E5EF78A08F6;
	Wed, 21 Oct 2026 05:15:37 +0200 (CEST)
Message-ID: <ec61dbb90e69bf33d17565d628ff59eaad8837f3.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 05/41] af_unix: keep sender ids in skb->cb only when
 they are classic ids
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
Date: Wed, 21 Oct 2026 05:15:25 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

unix_skb_parms has to fit into the 48 bytes of skb->cb. With kuid_t and
kgid_t growing to hold UUIDs and GUIDs the two of them alone would take
40 bytes.

Store classic ids as 32 bit values as before, and only for a UUID or
GUID allocate a small struct unix_skb_ids for both, freed together with
the pid reference in unix_destruct_scm(). AF_UNIX skbs carrying a pid
reference are never cloned, so the pointer has a single owner.
Senders with classic ids see no change and no allocation.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 net/unix/af_unix.c | 50 +++++++++++++++++++++++++++++++++++++++-------
 net/unix/af_unix.h | 11 ++++++++--
 2 files changed, 52 insertions(+), 9 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 42cffeafc8..2b17310534 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1969,11 +1969,46 @@ static void unix_peek_fds(struct scm_cookie *scm, struct sk_buff *skb)
 	unix_peek_fpl(scm->fp);
 }
 
+/*
+ * The sender's ids, in the skb itself for legacy ids; UUIDs and GUIDs don't
+ * fit in skb->cb and come from an allocation, freed with the pid reference
+ * in unix_destruct_scm().
+ */
+static int unix_skb_set_ids(struct sk_buff *skb, kuid_t uid, kgid_t gid)
+{
+	struct unix_skb_ids *ids = NULL;
+
+	if (!uid_is_legacy(uid) || !gid_is_legacy(gid)) {
+		ids = kmalloc_obj(*ids, GFP_KERNEL_ACCOUNT);
+		if (!ids)
+			return -ENOMEM;
+		ids->uid = uid;
+		ids->gid = gid;
+	}
+	kfree(UNIXCB(skb).ids);
+	UNIXCB(skb).ids = ids;
+	UNIXCB(skb).uid = __kuid_val(uid);
+	UNIXCB(skb).gid = __kgid_val(gid);
+	return 0;
+}
+
+static kuid_t unix_skb_uid(const struct sk_buff *skb)
+{
+	return UNIXCB(skb).ids ? UNIXCB(skb).ids->uid : KUIDT_INIT(UNIXCB(skb).uid);
+}
+
+static kgid_t unix_skb_gid(const struct sk_buff *skb)
+{
+	return UNIXCB(skb).ids ? UNIXCB(skb).ids->gid : KGIDT_INIT(UNIXCB(skb).gid);
+}
+
 static void unix_destruct_scm(struct sk_buff *skb)
 {
 	struct scm_cookie scm = {};
 
 	swap(scm.pid, UNIXCB(skb).pid);
+	kfree(UNIXCB(skb).ids);
+	UNIXCB(skb).ids = NULL;
 
 	if (UNIXCB(skb).fp)
 		unix_detach_fds(&scm, skb);
@@ -1992,20 +2027,21 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 	int err = 0;
 
 	UNIXCB(skb).pid = get_pid(scm->pid);
-	UNIXCB(skb).uid = scm->creds.uid;
-	UNIXCB(skb).gid = scm->creds.gid;
 	UNIXCB(skb).fp = NULL;
+	skb->destructor = unix_wfree;
+	err = unix_skb_set_ids(skb, scm->creds.uid, scm->creds.gid);
+	if (err)
+		return err;
 	unix_get_secdata(scm, skb);
 	if (scm->fp && send_fds)
 		err = unix_attach_fds(scm, skb);
 
-	skb->destructor = unix_wfree;
 	return err;
 }
 
 static void unix_skb_to_scm(struct sk_buff *skb, struct scm_cookie *scm)
 {
-	scm_set_cred(scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
+	scm_set_cred(scm, UNIXCB(skb).pid, unix_skb_uid(skb), unix_skb_gid(skb));
 	unix_set_secdata(scm, skb);
 }
 
@@ -2039,7 +2075,7 @@ static int unix_maybe_add_creds(struct sk_buff *skb, const struct sock *sk,
 			return err;
 
 		UNIXCB(skb).pid = get_pid(pid);
-		current_uid_gid(&UNIXCB(skb).uid, &UNIXCB(skb).gid);
+		return unix_skb_set_ids(skb, current_uid(), current_gid());
 	}
 
 	return 0;
@@ -2049,8 +2085,8 @@ static bool unix_skb_scm_eq(struct sk_buff *skb,
 			    struct scm_cookie *scm)
 {
 	return UNIXCB(skb).pid == scm->pid &&
-	       uid_eq(UNIXCB(skb).uid, scm->creds.uid) &&
-	       gid_eq(UNIXCB(skb).gid, scm->creds.gid) &&
+	       uid_eq(unix_skb_uid(skb), scm->creds.uid) &&
+	       gid_eq(unix_skb_gid(skb), scm->creds.gid) &&
 	       unix_secdata_eq(scm, skb);
 }
 
diff --git a/net/unix/af_unix.h b/net/unix/af_unix.h
index 8119dbeef3..e861a430cf 100644
--- a/net/unix/af_unix.h
+++ b/net/unix/af_unix.h
@@ -10,10 +10,17 @@
 
 struct sock *unix_peer_get(struct sock *sk);
 
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
-- 
2.56.0

