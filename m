Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552550;
	b=PNsugICfuktAF+WI2Js8lkiseadBxdmv5cttk1kTSpvz9xfixXkqodfi0COLH4sU6oS1
	 1ltYOyRrYKcT1+n+3j8M9dHai9pnK4bwqLLQgkNmevt2oTRqcpcMloRydPBt0vCUJ3pvK
	 +45nioyal1RFk7m46TlBDn/pEi0f3l1L+/albhsM99Y7rd2iMDPIedvrnt16P147tCnkH
	 axjUtJ2AT+Wy2pHCsZwDROqUZ3de5Ytp0e9ob6/40XkbHACEDEtptJ+SN/uSdsHhBqfuc
	 Rdu+Q+GMI1boKAzoR+4F8w7sNWl2awKxknP+Lrm4FiOiJK1ViwjyCgXZemv7bWGj+4A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552550;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=hxFh/qYxsEjkqiU/9EQ/uipYSBz29S4QJyXrTGHS+cQ=;
	b=O5/tdUyCiQW9rBEfAGpif+5bvOhgELeNIaLm4bWer2dJt9Pl9oRcWTzpwRmymRCiWsCg
	 gEcS/iR7kNDRxZ0jejqulbBPE6I59QyvnOWHKoEvWmfj1Kq9TnkOaDfOS03UHu1coE2ST
	 opYNwbDIWdtQc73ZATnapGBzuaEOvqDZFrsfIsP+kyzXr2KRf92i0L93IVRt6NC6wXDrq
	 3P/N1dHWgdggsd1WrmuWqUugo+ibpwdf6LEXq6BdaNFYVLP7Dup8EaNIOqf/Db0FyTLRe
	 mclMoUNriIMGrwDxXloCP0GMQW23h0g0HUXPL0oRzeW+23e96jnk4aSLVRHq48ZO/lA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=VzKBknuQ;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54DAF60A263C;
	Wed, 21 Oct 2026 03:15:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 54DAF60A263C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=VzKBknuQ
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552545; bh=e5sVRR6nRFucGipa82Beki5OFNmqIlIw959pmsbZTDc=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=VzKBknuQh34sbYZMtPfVtxrRjt3kDRTWEXxle+BHDtCYXcQ8R/LEaNYV4hlPNQbGz
	 fKhJ0xfyTe2axAAq7mfYzHn+PXArkzoJM6eYtGO7QfUNctyJZm/X6AHMyh6gnFVRUD
	 Am36F2CLTy+dlQOAxEg4fK7sBd47YBwnoZTMci7d0hklGOEccTFL1RjegTcXIHVKL2
	 1Z/g4jQeo38LfLLhnAsRbu6K+PDGy3zWUhe2xEfVk5IE58/3LE+7w82x7yMmt6mg0Z
	 RI/QJEZ4OmyVuc77uEIKqKo69ZoVUMVa3B4fKLU8G14ONupIgJ2lhb1WgE2/CWn7og
	 aHyfLZFCredIA==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id CD89E8A0904;
	Wed, 21 Oct 2026 05:15:44 +0200 (CEST)
Message-ID: <87c721a9d6ca632152d6ccf6e7ce954fb7886301.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 07/41] Bluetooth: keep classic sender ids in skb->cb
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
Date: Wed, 21 Oct 2026 05:15:27 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

struct bt_skb_cb holds the sender's struct scm_creds for HCI sockets,
which no longer fits into skb->cb now that kuid_t and kgid_t can hold
UUIDs and GUIDs. Like netlink, keep them as struct scm_creds_classic:
classic ids as before, the overflow id for UUID and GUID senders.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 include/net/bluetooth/bluetooth.h | 2 +-
 net/bluetooth/hci_sock.c          | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index b624da5026..2c8fe50f4d 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -497,7 +497,7 @@ struct bt_skb_cb {
 		struct l2cap_ctrl l2cap;
 		struct hci_ctrl hci;
 		struct mgmt_ctrl mgmt;
-		struct scm_creds creds;
+		struct scm_creds_classic creds;
 	};
 };
 #define bt_cb(skb) ((struct bt_skb_cb *)((skb)->cb))
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 81068b5857..9f422ae5fd 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -276,7 +276,7 @@ void hci_send_to_sock(struct hci_dev *hdev, struct sk_buff *skb)
 
 static void hci_sock_copy_creds(struct sock *sk, struct sk_buff *skb)
 {
-	struct scm_creds *creds;
+	struct scm_creds_classic *creds;
 
 	if (!sk || WARN_ON(!skb))
 		return;
@@ -300,8 +300,8 @@ static void hci_sock_copy_creds(struct sock *sk, struct sk_buff *skb)
 
 	creds->pid = pid_vnr(sk->sk_peer_pid);
 	if (sk->sk_peer_cred) {
-		creds->uid = sk->sk_peer_cred->uid;
-		creds->gid = sk->sk_peer_cred->gid;
+		creds->uid = __kuid_val(sk->sk_peer_cred->uid);
+		creds->gid = __kgid_val(sk->sk_peer_cred->gid);
 	}
 }
 
@@ -1615,7 +1615,7 @@ static int hci_sock_recvmsg(struct socket *sock, struct msghdr *msg,
 	}
 
 	memset(&scm, 0, sizeof(scm));
-	scm.creds = bt_cb(skb)->creds;
+	scm_creds_from_classic(&scm.creds, &bt_cb(skb)->creds);
 
 	skb_free_datagram(sk, skb);
 
-- 
2.56.0

