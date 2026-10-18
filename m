Received: from mout.gmx.net (mout.gmx.net [212.227.15.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 38AD64AA01B;
	Sun, 18 Oct 2026 18:01:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792346524; cv=none; b=ihrpcU4RdkEmK2Qph6squK3Elt6eExB/Yipjofove0TzEsvbBin+EZCalbgQgJqe1zlXlyed3YRGZYMXBMXTKW+D5gutRVHmSbuZ0E2gjS+VYeQkrSDcIniemnGEnsI0a3VBwBfw3W0eEQ62ulXYPLsB6HMceGcSTJ6S0oK0Dc8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792346524; c=relaxed/simple;
	bh=TWVrAVBoy7wsmsIUbgT16bIcR3+toUuI7FS8sDSs+X8=;
	h=Message-ID:In-Reply-To:References:From:Subject:To:Cc:Date; b=aQEmOFQ4tVqJ4nWu/qgjM/37fGR+2Hau8kEFtJJnyFUQEY0vlOp9paG1hFCMrXPpLb2Lt+5djf3muyAJvqckMZLmxta7/kHgL+JtXTTVbOkNQCBpCSaRVHi0Qguap1SmW3BrMj7DFNn9HmvyTbPisF/vGc4zYAanUeM/Eoj0ymo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b=iHR9/WiJ; arc=none smtp.client-ip=212.227.15.18
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b="iHR9/WiJ"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1792346508; x=1792951308; i=jan.koester@gmx.net;
	bh=BOoqqodapKpc4JEmvY9l9NqcTNd58APvVYJyJT2XvII=;
	h=X-UI-Sender-Class:Message-ID:In-Reply-To:References:From:Subject:
	 To:Cc:Date:Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=iHR9/WiJpovvl2fBpR1LiQpADCQ/iRPkffp8PLWdQZJ2dgIEj5+dGAzA40Iy9JYJ
	 FfncFWmDpZBMw4nf1Ga7LQ8IVr5MSEGTJWeCWXx8tClAwtJH2+3S6ZsKmUS3MgCa+
	 Wrz8FOzQvE9yj3UBR6Tb+C63W1mFIyZMLIzvGJEVmX0ZUXGyMHF+BNK+mKz5n8cpc
	 s/sV7B9C65a4yFbdyXF9M5GDRimBhYswECRfMsBkLyUum5moLLuRFglaSpD2l4JEi
	 EaULmrkcNRlHmdsfNHCTY8FiZy9hkB6QT6t/62+7ZLJast4ypkzjv9qZ/d+EMaZk4
	 l7K5glogv4V8mh2vBw==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx004
 [212.227.17.190]) with ESMTPSA (Nemesis) id 1N2DxE-1wcORe2Hyo-00ukK8; Sun, 18
 Oct 2026 20:01:48 +0200
Message-ID: <0f39fe49a1362d2555513e375f4a81b05374c985.1792346472.git.jan.koester@gmx.net>
In-Reply-To: <cover.1792346472.git.jan.koester@gmx.net>
References: <cover.1792346472.git.jan.koester@gmx.net>
From: Jan Koester <jan.koester@gmx.net>
Subject: [RFC PATCH 07/41] Bluetooth: keep classic sender ids in skb->cb
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
Date: Sun, 18 Oct 2026 20:01:28 +0200
X-Provags-ID: V03:K1:WFuBGJMvWe1NyhGWh2NsiZj68JgosP6rSb6wtglMlzaCzt/5uzc
 fFGMDdKQ3umzIgeoLLJCYdb/ObUuYn1+qRSr9IKqLRyQ7gIoczosn4fzn2pha8T1Jj58b4+
 eJwuUeiXg+GzUHz0dLuuCmhapjdO15N0osujFRZDvyhhkFbwSW6Dx3JGrCBSEhBY5k3EpfG
 owaVxei80iQ0zR10vfESQ==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:ctiJFo5A9jI=;JagAi2IJkxHYt6l6m09GTzigE/9
 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
 0tMpTypwD4mYY9Cppq+E=
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

struct bt_skb_cb holds the sender's struct scm_creds for HCI sockets,
which no longer fits into skb->cb now that kuid_t and kgid_t can hold
UUIDs and GUIDs. Like netlink, keep them as struct scm_creds_classic:
classic ids as before, the overflow id for UUID and GUID senders.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@gmx.net>
=2D--
 include/net/bluetooth/bluetooth.h | 2 +-
 net/bluetooth/hci_sock.c          | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/blu=
etooth.h
index b624da5026..2c8fe50f4d 100644
=2D-- a/include/net/bluetooth/bluetooth.h
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
=2D-- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -276,7 +276,7 @@ void hci_send_to_sock(struct hci_dev *hdev, struct sk_=
buff *skb)
=20
 static void hci_sock_copy_creds(struct sock *sk, struct sk_buff *skb)
 {
-	struct scm_creds *creds;
+	struct scm_creds_classic *creds;
=20
 	if (!sk || WARN_ON(!skb))
 		return;
@@ -300,8 +300,8 @@ static void hci_sock_copy_creds(struct sock *sk, struc=
t sk_buff *skb)
=20
 	creds->pid =3D pid_vnr(sk->sk_peer_pid);
 	if (sk->sk_peer_cred) {
-		creds->uid =3D sk->sk_peer_cred->uid;
-		creds->gid =3D sk->sk_peer_cred->gid;
+		creds->uid =3D __kuid_val(sk->sk_peer_cred->uid);
+		creds->gid =3D __kgid_val(sk->sk_peer_cred->gid);
 	}
 }
=20
@@ -1615,7 +1615,7 @@ static int hci_sock_recvmsg(struct socket *sock, str=
uct msghdr *msg,
 	}
=20
 	memset(&scm, 0, sizeof(scm));
-	scm.creds =3D bt_cb(skb)->creds;
+	scm_creds_from_classic(&scm.creds, &bt_cb(skb)->creds);
=20
 	skb_free_datagram(sk, skb);
=20
=2D-=20
2.56.0

