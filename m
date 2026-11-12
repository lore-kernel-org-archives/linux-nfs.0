Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794495152;
	b=LnOMNUeVX8dyj/PJpq83fME6taJi2wkwHvmNYw92OAjC5HQosLXX+M0sbxxwn37eTPAM
	 1Nau5jtDlXPkUE4sx0C1pw62cD4tsD9PXoF/J4nfzJwzC9seZ0uz5eNvlD3SccQOeG68z
	 cC50xvOAvI9sWwuSUQlZQ/R4wy9+UDV66rGuzwGNEMDLpzxUw9vdZ8YnWdMo2O+FZ6wlu
	 VnBe0M2rSam2kK/8iIBxgUig45enoK0UU4KBCthPZsG+9pPhz1qtqFLnjJ6g5aJ5GF3C3
	 GXRv/88LOif0PUyAcANRtd+g7Q+dqTsa9jaTaNkSdrcapCgMcShng++QX5JHNU0NCFw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794495152;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=sFElQzYD6Y1gK0lja5fun9iMqP/owVHQ9Sc3q90mCmI=;
	b=OuvZRjC5v54BqPR5OZKcJ39z1myxwTwYMrr0m1S5JV7mYjPu+tLq5KwQY27qrla0p/GK
	 tIhTcM323ocLO4XWh+olAYYpWQSfpkozTNpP5notSahj7hGf/Xua+dohPUmcdJeVx/Xhr
	 8iXCh19fE4PKaXaR/Nqfhe9QqBuiQDU9brjH4nXpQ8J2eVhpqLodRVq8clnGDJ/RY7aAi
	 JPkk5u8L13nekxyMo+nZxnEuyJI+dFBjUXXcAO9Thrh2OZ3sr/Yt4NnFZfWLz/xKxyKQ/
	 PIE9VMMCJTRFnlollyOClGbZ53n0moHK2K5mLm6mNaA0RUQpYiboTs9BfcpMoMbUHhw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hFLUkVTP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 944A8606A321;
	Thu, 12 Nov 2026 14:52:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hFLUkVTP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 02DC91F00A0A;
	Thu, 12 Nov 2026 14:52:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794495152;
	bh=sFElQzYD6Y1gK0lja5fun9iMqP/owVHQ9Sc3q90mCmI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hFLUkVTP+klpYSIVptdlzsNQ6vAHrj97o+jYJywXKbu3TDBZ1sbaoej6bNeCz564h
	 lPUjwz07rGE2WRgYnHjE5oBXGmAU1sifePwzzwz8RoTszZ2BTCwjgYRIKffXLdvhFT
	 roS7TxVnfCluTxNXcon4TnfQX2/wyjVVjxWiqUMCqJVIGeHBkDk8UZaMAF0NsdxysY
	 LRJNqVaFH81mZaDxsqLZ1FjlcHOWWg7NhgU+7nvGDUpjDcuVhPbGjoBTie24AaLslZ
	 fcLJB4So16otQ+keDuFvL8HPHNscBmkfVTOfF8pepp4J2y3D33Y31Bf7dYD5LDU3Uj
	 a3cxh1S3LUC3A==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 09:52:09 -0500
Subject: [PATCH net-next v2 05/10] handshake: Pick up session tags passed
 during the DONE downcall
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261112-tls-session-tags-v2-5-a587a50de7fc@kernel.org>
References: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
In-Reply-To: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Keith Busch <kbusch@kernel.org>, 
 Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, 
 Sagi Grimberg <sagi@grimberg.me>, Chaitanya Kulkarni <kch@nvidia.com>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Eric Dumazet <edumazet@kernel.org>
Cc: kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=23365; i=cel@kernel.org;
 h=from:subject:message-id; bh=/dbDTZx1480j4JHBOAAifuNv3wnqQf2GWOJme5p7LV4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9dKgjM37ZDLHJLdckongJFNUsDqgaMo8FEMDA
 2kkeKk0YAqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavXSoAAKCRAzarMzb2Z/
 lzSkD/45CCiO2hefyU8b7qTJK4Fi8h1ktkHbFyLR51OVZNAwUUAmyLOMyBAIa/6a7qX5pgrRdSG
 JO0fNl7XmGF6cIvTex9aXRxLIOrsWdRfpH0KRfxRoAtspA7rQy7NIvADzw5M1Sg+o8ix1aR+jJc
 eBxsLQCkOAA4Q+rrLG6CtQUnPWOKTsKIXTtNrmHcMooXZCz+cLXWx99vRGINDknn1mmVuZUI8F/
 RX2rFvb95rrfPPHyGOuzIm03ENrF02azKopfkn9ScYvG7wt9YY+qWbDkKWP8C9zrwtcoHiUrBlK
 NKP2Vq6iaz03SLZ6y3mXy1APRkCFxAK14kyV5obGcJyUVZRSr61l1hfQ3LWfkOCI8A5brPKQuhV
 vE9TL0hxBqaMsBk41qo2UhYL+fRl7B+mLcOw0KP40H0guHw4qUSiH0Tt9hOpm9vma3iTUggB0Pt
 tN49eKkTV7VGbN9httZYAtgYTZUaiVbf9wTzA0ItnVUGrxoulakRk6GS/1LfMoVDLzgN0cYDLB8
 9AozwS5SoSI4f00UPJS/RWn60+ouMDkJ/ngJ208eI8IaeC/RY/y+naRT6lvOyJYWNxYdEW9EeqA
 bta/NdqUuu0lgiXGSD4O8oIBg8IdjOtEeMtEFIF2RgAclS2iRtnG2FT0S2szg9zK43DJXny27Et
 cdZL105nMfZ5fkg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Upper Layer Protocols such as NFS have no way to base access control
on TLS certificate characteristics. Parsing x.509 in the kernel
duplicates work user space libraries already do. The tlshd daemon can
evaluate certificates against administrator-defined policies and
assign tags indicating which policies a certificate satisfies.

Collect session tags from the DONE netlink downcall and pass them to
handshake consumers via their completion callback. NFSD, for example,
can then restrict export access to connections whose certificate
earned a particular tag, without parsing the certificate itself. The
tags are valid only while the callback runs. Release them as soon
as the callback returns, so a long-lived transport such as an NFS
connection does not hold them for the life of the socket.

The genl family runs DONE with parallel_ops, so concurrent downcalls
for the same socket can both reach the same handshake_req. Split
handshake_complete() into a try/finish pair. The handler collects
tags into a private stringset before taking the completion gate, and
the winner hands the set to handshake_finish_complete(). A duplicate
downcall is refused with -EBUSY. handshake_req_cancel() returns false
once the gate is taken, and svc_tcp_handshake() then waits
uninterruptibly for its callback. Collecting the tags first keeps the
handler's GFP_KERNEL allocations out of that wait.

The DONE downcall can now fail, where before it always returned
success. A tag the parser rejects completes the handshake with -EIO
and returns the parse error to tlshd. The extended ACK names the
rejected tag attribute. The request is complete on that path, so a
retry collects -EBUSY.

When the count of distinct tags exceeds HANDSHAKE_MAX_SESSIONTAGS, the
handler truncates the list, logs pr_warn_once(), and returns success.
Failing the DONE with -E2BIG would signal the daemon definitively, but
it would also tear down an otherwise usable handshake.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/networking/tls-handshake.rst |  51 ++++++++
 include/net/handshake.h                    |  31 ++++-
 net/Kconfig                                |   1 +
 net/handshake/handshake-test.c             | 197 +++++++++++++++++++++++++++++
 net/handshake/handshake.h                  |   9 ++
 net/handshake/netlink.c                    | 110 +++++++++++++++-
 net/handshake/request.c                    |  59 +++++++--
 net/handshake/tlshd.c                      |   2 +-
 8 files changed, 448 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/tls-handshake.rst b/Documentation/networking/tls-handshake.rst
index 7e9f4bd659b4..eb8cfe3367cb 100644
--- a/Documentation/networking/tls-handshake.rst
+++ b/Documentation/networking/tls-handshake.rst
@@ -201,6 +201,10 @@ The @peerid parameter contains the serial number of a key containing the
 remote peer's identity or the value TLS_NO_PEERID if the session is not
 authenticated.
 
+The @tags parameter points to a stringset containing session metadata
+assigned by the handshake agent. See the "Session Tags" section
+below for details on lifetime and safe access patterns.
+
 A best practice is to close and destroy the socket immediately if the
 handshake failed.
 
@@ -221,3 +225,50 @@ received message data is TLS record data or session metadata.
 See tls.rst for details on how a kTLS consumer recognizes incoming
 (decrypted) application data, alerts, and handshake packets once the
 socket has been promoted to use the TLS ULP.
+
+
+Session Tags
+============
+
+When a TLS handshake completes successfully, the handshake agent may
+assign metadata tags to the session. These tags enable kernel consumers
+to make authorization decisions based on certificate characteristics
+without parsing x.509 certificates directly.
+
+The handshake agent evaluates the peer's certificate against
+administrator-defined policies and assigns tags indicating which
+policies the certificate satisfies. For example, an administrator
+might configure the agent to assign an "internal-servers" tag when a
+certificate's Issuer DN matches a particular corporate CA.
+
+Tags are delivered to the consumer via the @tags parameter of the
+completion callback. The stringset is valid only for the duration of the
+callback. Consumers needing persistent access must copy the stringset
+using stringset_copy() before returning.
+
+To check whether a session has a particular tag:
+
+.. code-block:: c
+
+  if (stringset_is_member(tags, "internal-servers")) {
+          /* Certificate matched the internal-servers policy */
+  }
+
+To check whether a session has any tag from a small fixed set:
+
+.. code-block:: c
+
+  if (stringset_is_member(tags, "admin") ||
+      stringset_is_member(tags, "operator")) {
+          /* Certificate matched admin or operator policy */
+  }
+
+When the required set is dynamic (e.g., parsed from an export option),
+construct a stringset and use stringset_intersection() to test for any
+overlap. See Documentation/core-api/stringset.rst for the
+initialization, add, and finalize sequence.
+
+If the handshake failed or no tags were assigned, the stringset is
+empty. The handshake layer always delivers a finalized stringset to
+the callback, so consumers may call stringset_is_member() and
+stringset_intersection() unconditionally without a separate guard.
diff --git a/include/net/handshake.h b/include/net/handshake.h
index c227d42bd767..ad96e92af04d 100644
--- a/include/net/handshake.h
+++ b/include/net/handshake.h
@@ -10,8 +10,36 @@
 #ifndef _NET_HANDSHAKE_H
 #define _NET_HANDSHAKE_H
 
+#include <linux/errno.h>
 #include <linux/stringset.h>
 
+/*
+ * Bounds the cost of stringset_intersection() in consumer
+ * authorization checks.
+ */
+#define HANDSHAKE_MAX_SESSIONTAGS	64
+
+/**
+ * handshake_session_tag_len - Content length of a session tag payload
+ * @data: start of an NLA_STRING tag payload
+ * @len: payload length in bytes, including any trailing NUL
+ *
+ * A tag payload may arrive with or without a single trailing NUL, and
+ * the terminator is not part of the content. NLA_STRING cannot express
+ * "no NUL except as terminator," so callers validate the payload here.
+ *
+ * Return: content length in bytes, or -EINVAL if the payload is empty
+ * or carries an embedded NUL.
+ */
+static inline int handshake_session_tag_len(const char *data, size_t len)
+{
+	if (len > 0 && data[len - 1] == '\0')
+		len--;
+	if (len == 0 || memchr(data, '\0', len))
+		return -EINVAL;
+	return len;
+}
+
 enum {
 	TLS_NO_KEYRING = 0,
 	TLS_NO_PEERID = 0,
@@ -24,7 +52,8 @@ enum {
  * @data: opaque context pointer set via tls_handshake_args.ta_data
  * @status: zero on success, otherwise a negative errno
  * @peerid: serial number of peer identity key, or TLS_NO_PEERID
- * @tags: session tags assigned by the handshake agent
+ * @tags: session tags assigned by the handshake agent; never NULL,
+ *        always finalized, and empty when no tags were assigned
  *
  * The @tags pointer is valid only for the duration of this callback.
  * A consumer requiring persistent access must copy the set with
diff --git a/net/Kconfig b/net/Kconfig
index 76ab44aa439a..aab2d2f03d4d 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -93,6 +93,7 @@ source "net/xdp/Kconfig"
 config NET_HANDSHAKE
 	bool
 	depends on SUNRPC || NVME_TARGET_TCP || NVME_TCP
+	select STRINGSET
 	default y
 
 config NET_HANDSHAKE_KUNIT_TEST
diff --git a/net/handshake/handshake-test.c b/net/handshake/handshake-test.c
index 4b99acd9f9c7..21fccfa94d89 100644
--- a/net/handshake/handshake-test.c
+++ b/net/handshake/handshake-test.c
@@ -12,7 +12,9 @@
 
 #include <net/sock.h>
 #include <net/genetlink.h>
+#include <net/netlink.h>
 #include <net/netns/generic.h>
+#include <net/handshake.h>
 
 #include <uapi/linux/handshake.h>
 #include "handshake.h"
@@ -516,6 +518,173 @@ static void handshake_req_destroy_test1(struct kunit *test)
 	KUNIT_EXPECT_PTR_EQ(test, handshake_req_destroy_test, req);
 }
 
+static struct sk_buff *handshake_done_msg(struct kunit *test,
+					  struct nlmsghdr **nlhp)
+{
+	struct sk_buff *skb;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, skb);
+	*nlhp = nlmsg_put(skb, 0, 0, HANDSHAKE_CMD_DONE, GENL_HDRLEN, 0);
+	KUNIT_ASSERT_NOT_NULL(test, *nlhp);
+	return skb;
+}
+
+/*
+ * handshake_get_sessiontags() leaves the collected set unfinalized,
+ * as the netlink handler does. Cases below that query membership
+ * finalize first, the way handshake_finish_complete() does before
+ * delivery to the consumer.
+ */
+static void handshake_sessiontags_basic(struct kunit *test)
+{
+	struct genl_info info = {};
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	DEFINE_STRINGSET(tags);
+
+	skb = handshake_done_msg(test, &nlh);
+	nla_put_string(skb, HANDSHAKE_A_DONE_TAG, "alpha");
+	nla_put_string(skb, HANDSHAKE_A_DONE_TAG, "beta");
+	nlmsg_end(skb, nlh);
+	info.nlhdr = nlh;
+
+	KUNIT_EXPECT_EQ(test, handshake_get_sessiontags(&tags, &info), 0);
+	stringset_finalize(&tags);
+	KUNIT_EXPECT_EQ(test, stringset_count(&tags), 2);
+	KUNIT_EXPECT_TRUE(test, stringset_is_member(&tags, "alpha"));
+	KUNIT_EXPECT_TRUE(test, stringset_is_member(&tags, "beta"));
+
+	stringset_destroy(&tags);
+	kfree_skb(skb);
+}
+
+static void handshake_sessiontags_none(struct kunit *test)
+{
+	struct genl_info info = {};
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	DEFINE_STRINGSET(tags);
+
+	skb = handshake_done_msg(test, &nlh);
+	nla_put_u32(skb, HANDSHAKE_A_DONE_STATUS, 0);
+	nlmsg_end(skb, nlh);
+	info.nlhdr = nlh;
+
+	KUNIT_EXPECT_EQ(test, handshake_get_sessiontags(&tags, &info), 0);
+	KUNIT_EXPECT_EQ(test, stringset_count(&tags), 0);
+
+	stringset_destroy(&tags);
+	kfree_skb(skb);
+}
+
+static void handshake_sessiontags_trailing_nul(struct kunit *test)
+{
+	struct genl_info info = {};
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	DEFINE_STRINGSET(tags);
+
+	/* A payload of 6 carries "gamma" plus its terminator. */
+	skb = handshake_done_msg(test, &nlh);
+	nla_put(skb, HANDSHAKE_A_DONE_TAG, 6, "gamma");
+	nlmsg_end(skb, nlh);
+	info.nlhdr = nlh;
+
+	KUNIT_EXPECT_EQ(test, handshake_get_sessiontags(&tags, &info), 0);
+	stringset_finalize(&tags);
+	KUNIT_EXPECT_EQ(test, stringset_count(&tags), 1);
+	KUNIT_EXPECT_TRUE(test, stringset_is_member(&tags, "gamma"));
+
+	stringset_destroy(&tags);
+	kfree_skb(skb);
+}
+
+static void handshake_sessiontags_embedded_nul(struct kunit *test)
+{
+	struct genl_info info = {};
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	DEFINE_STRINGSET(tags);
+
+	skb = handshake_done_msg(test, &nlh);
+	nla_put(skb, HANDSHAKE_A_DONE_TAG, 3, "a\0b");
+	nlmsg_end(skb, nlh);
+	info.nlhdr = nlh;
+
+	KUNIT_EXPECT_EQ(test, handshake_get_sessiontags(&tags, &info), -EINVAL);
+	KUNIT_EXPECT_EQ(test, stringset_count(&tags), 0);
+
+	stringset_destroy(&tags);
+	kfree_skb(skb);
+}
+
+static void handshake_sessiontags_empty(struct kunit *test)
+{
+	struct genl_info info = {};
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	DEFINE_STRINGSET(tags);
+
+	skb = handshake_done_msg(test, &nlh);
+	nla_put(skb, HANDSHAKE_A_DONE_TAG, 0, "");
+	nlmsg_end(skb, nlh);
+	info.nlhdr = nlh;
+
+	KUNIT_EXPECT_EQ(test, handshake_get_sessiontags(&tags, &info), -EINVAL);
+
+	stringset_destroy(&tags);
+	kfree_skb(skb);
+}
+
+static void handshake_sessiontags_duplicate(struct kunit *test)
+{
+	struct genl_info info = {};
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	DEFINE_STRINGSET(tags);
+
+	skb = handshake_done_msg(test, &nlh);
+	nla_put_string(skb, HANDSHAKE_A_DONE_TAG, "dup");
+	nla_put_string(skb, HANDSHAKE_A_DONE_TAG, "dup");
+	nlmsg_end(skb, nlh);
+	info.nlhdr = nlh;
+
+	KUNIT_EXPECT_EQ(test, handshake_get_sessiontags(&tags, &info), 0);
+	KUNIT_EXPECT_EQ(test, stringset_count(&tags), 2);
+	stringset_finalize(&tags);
+	KUNIT_EXPECT_EQ(test, stringset_count(&tags), 1);
+	KUNIT_EXPECT_TRUE(test, stringset_is_member(&tags, "dup"));
+
+	stringset_destroy(&tags);
+	kfree_skb(skb);
+}
+
+static void handshake_sessiontags_truncate(struct kunit *test)
+{
+	struct genl_info info = {};
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	DEFINE_STRINGSET(tags);
+	unsigned int i;
+
+	skb = handshake_done_msg(test, &nlh);
+	for (i = 0; i < HANDSHAKE_MAX_SESSIONTAGS + 6; i++) {
+		char tag[16];
+
+		snprintf(tag, sizeof(tag), "tag%u", i);
+		nla_put_string(skb, HANDSHAKE_A_DONE_TAG, tag);
+	}
+	nlmsg_end(skb, nlh);
+	info.nlhdr = nlh;
+
+	KUNIT_EXPECT_EQ(test, handshake_get_sessiontags(&tags, &info), 0);
+	KUNIT_EXPECT_EQ(test, stringset_count(&tags), HANDSHAKE_MAX_SESSIONTAGS);
+
+	stringset_destroy(&tags);
+	kfree_skb(skb);
+}
+
 static struct kunit_case handshake_api_test_cases[] = {
 	{
 		.name			= "req_alloc API fuzzing",
@@ -562,6 +731,34 @@ static struct kunit_case handshake_api_test_cases[] = {
 		.name			= "req_destroy works",
 		.run_case		= handshake_req_destroy_test1,
 	},
+	{
+		.name			= "sessiontags basic",
+		.run_case		= handshake_sessiontags_basic,
+	},
+	{
+		.name			= "sessiontags none present",
+		.run_case		= handshake_sessiontags_none,
+	},
+	{
+		.name			= "sessiontags trailing NUL",
+		.run_case		= handshake_sessiontags_trailing_nul,
+	},
+	{
+		.name			= "sessiontags embedded NUL",
+		.run_case		= handshake_sessiontags_embedded_nul,
+	},
+	{
+		.name			= "sessiontags empty tag",
+		.run_case		= handshake_sessiontags_empty,
+	},
+	{
+		.name			= "sessiontags duplicate",
+		.run_case		= handshake_sessiontags_duplicate,
+	},
+	{
+		.name			= "sessiontags truncate at cap",
+		.run_case		= handshake_sessiontags_truncate,
+	},
 	{}
 };
 
diff --git a/net/handshake/handshake.h b/net/handshake/handshake.h
index da61cadd1ad3..11f57d09b511 100644
--- a/net/handshake/handshake.h
+++ b/net/handshake/handshake.h
@@ -10,6 +10,8 @@
 #ifndef _INTERNAL_HANDSHAKE_H
 #define _INTERNAL_HANDSHAKE_H
 
+#include <linux/stringset.h>
+
 /* Per-net namespace context */
 struct handshake_net {
 	spinlock_t		hn_lock;	/* protects next 3 fields */
@@ -36,6 +38,7 @@ struct handshake_req {
 	struct file			*hr_file;
 	struct sock			*hr_sk;
 	void				(*hr_odestruct)(struct sock *sk);
+	struct stringset		hr_tags;
 
 	/* Always the last field */
 	char				hr_priv[];
@@ -77,6 +80,9 @@ int handshake_genl_notify(struct net *net, const struct handshake_proto *proto,
 struct nlmsghdr *handshake_genl_put(struct sk_buff *msg,
 				    struct genl_info *info);
 struct handshake_net *handshake_pernet(struct net *net);
+#if IS_ENABLED(CONFIG_KUNIT)
+int handshake_get_sessiontags(struct stringset *tags, struct genl_info *info);
+#endif
 
 /* request.c */
 struct handshake_req *handshake_req_alloc(const struct handshake_proto *proto,
@@ -88,6 +94,9 @@ struct handshake_req *handshake_req_hash_lookup(struct sock *sk);
 struct handshake_req *handshake_req_next(struct handshake_net *hn, int class);
 int handshake_req_submit(struct socket *sock, struct handshake_req *req,
 			 gfp_t flags);
+bool handshake_try_complete(struct handshake_req *req);
+void handshake_finish_complete(struct handshake_req *req, int status,
+			       struct genl_info *info, struct stringset *tags);
 void handshake_complete(struct handshake_req *req, int status,
 			struct genl_info *info);
 bool handshake_req_cancel(struct sock *sk);
diff --git a/net/handshake/netlink.c b/net/handshake/netlink.c
index 73b8314d9010..b03e33f97e60 100644
--- a/net/handshake/netlink.c
+++ b/net/handshake/netlink.c
@@ -16,6 +16,7 @@
 
 #include <net/sock.h>
 #include <net/genetlink.h>
+#include <net/handshake.h>
 #include <net/netns/generic.h>
 
 #include <kunit/visibility.h>
@@ -130,11 +131,93 @@ int handshake_nl_accept_doit(struct sk_buff *skb, struct genl_info *info)
 	return err;
 }
 
+static bool handshake_sessiontag_is_dup(const struct stringset *tags,
+					const struct nlattr *nla)
+{
+	unsigned int i;
+	char *tag;
+
+	stringset_for_each(tags, i, tag) {
+		if (!nla_strcmp(nla, tag))
+			return true;
+	}
+	return false;
+}
+
+/**
+ * handshake_get_sessiontags - Collect session tags from a DONE downcall
+ * @tags: initialized stringset to fill, left unfinalized on return
+ * @info: netlink message context for the downcall
+ *
+ * The caller retains ownership of @tags. Tags dropped under memory
+ * pressure, or truncated at HANDSHAKE_MAX_SESSIONTAGS, are not an
+ * error.
+ *
+ * Context: May sleep. Must be called before the completion gate is
+ *          taken.
+ *
+ * Return: 0 on success, or a negative errno if a tag payload was
+ * malformed, in which case no tags are collected.
+ */
+VISIBLE_IF_KUNIT int handshake_get_sessiontags(struct stringset *tags,
+					       struct genl_info *info)
+{
+	unsigned int count = 0;
+	struct nlattr *nla;
+	int rem;
+
+	nlmsg_for_each_attr_type(nla, HANDSHAKE_A_DONE_TAG, info->nlhdr,
+				 GENL_HDRLEN, rem) {
+		if (handshake_session_tag_len(nla_data(nla), nla_len(nla)) < 0) {
+			NL_SET_BAD_ATTR(info->extack, nla);
+			return -EINVAL;
+		}
+		count++;
+	}
+	if (count == 0)
+		return 0;
+	if (count > HANDSHAKE_MAX_SESSIONTAGS)
+		count = HANDSHAKE_MAX_SESSIONTAGS;
+	if (!stringset_alloc(tags, count, GFP_KERNEL)) {
+		pr_warn_once("handshake: dropping session tags under memory pressure\n");
+		return 0;
+	}
+
+	nlmsg_for_each_attr_type(nla, HANDSHAKE_A_DONE_TAG, info->nlhdr,
+				 GENL_HDRLEN, rem) {
+		char *tag;
+
+		/* A repeated tag does not count against the cap. */
+		if (handshake_sessiontag_is_dup(tags, nla))
+			continue;
+
+		/*
+		 * At most HANDSHAKE_MAX_SESSIONTAGS tags are kept. A
+		 * dropped tag can only narrow the consumer's
+		 * authorization, never widen it.
+		 */
+		if (stringset_count(tags) >= HANDSHAKE_MAX_SESSIONTAGS) {
+			pr_warn_once("handshake: more than %u session tags\n",
+				     HANDSHAKE_MAX_SESSIONTAGS);
+			break;
+		}
+
+		tag = nla_strdup(nla, GFP_KERNEL);
+		if (!tag)
+			continue;
+		if (!stringset_add(tags, tag))
+			kfree(tag);
+	}
+	return 0;
+}
+EXPORT_SYMBOL_IF_KUNIT(handshake_get_sessiontags);
+
 int handshake_nl_done_doit(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net *net = sock_net(skb->sk);
 	struct handshake_req *req;
 	struct socket *sock;
+	DEFINE_STRINGSET(tags);
 	int fd, status, err;
 
 	if (GENL_REQ_ATTR_CHECK(info, HANDSHAKE_A_DONE_SOCKFD))
@@ -158,10 +241,33 @@ int handshake_nl_done_doit(struct sk_buff *skb, struct genl_info *info)
 	status = -EIO;
 	if (info->attrs[HANDSHAKE_A_DONE_STATUS])
 		status = -(int)nla_get_u32(info->attrs[HANDSHAKE_A_DONE_STATUS]);
+	err = 0;
+	if (!status) {
+		int ret = handshake_get_sessiontags(&tags, info);
 
-	handshake_complete(req, status, info);
+		/*
+		 * A malformed tag casts doubt on the rest of the
+		 * agent's tag set, so the consumer sees a failed
+		 * handshake.
+		 */
+		if (ret < 0) {
+			err = ret;
+			trace_handshake_cmd_done_err(net, req, sock->sk, err);
+			status = -EIO;
+		}
+	}
+
+	if (!handshake_try_complete(req)) {
+		trace_handshake_cmd_done_err(net, req, sock->sk, -EBUSY);
+		stringset_destroy(&tags);
+		sockfd_put(sock);
+		return -EBUSY;
+	}
+
+	/* handshake_finish_complete() takes ownership, so no destroy here. */
+	handshake_finish_complete(req, status, info, &tags);
 	sockfd_put(sock);
-	return 0;
+	return err;
 }
 
 static unsigned int handshake_net_id;
diff --git a/net/handshake/request.c b/net/handshake/request.c
index ff739ee81cb8..72515e5e8cc2 100644
--- a/net/handshake/request.c
+++ b/net/handshake/request.c
@@ -80,6 +80,7 @@ static void handshake_req_destroy(struct handshake_req *req)
 		req->hr_proto->hp_destroy(req);
 	rhashtable_remove_fast(&handshake_rhashtbl, &req->hr_rhash,
 			       handshake_rhash_params);
+	stringset_destroy(&req->hr_tags);
 	kfree(req);
 }
 
@@ -125,6 +126,7 @@ struct handshake_req *handshake_req_alloc(const struct handshake_proto *proto,
 		return NULL;
 
 	INIT_LIST_HEAD(&req->hr_list);
+	stringset_init(&req->hr_tags);
 	req->hr_proto = proto;
 	return req;
 }
@@ -321,20 +323,61 @@ int handshake_req_submit(struct socket *sock, struct handshake_req *req,
 }
 EXPORT_SYMBOL(handshake_req_submit);
 
-void handshake_complete(struct handshake_req *req, int status,
-			struct genl_info *info)
+/**
+ * handshake_try_complete - Take the unique-completer gate
+ * @req: handshake request to complete
+ *
+ * Exactly one caller wins the gate and drives completion to the
+ * consumer. handshake_req_cancel() returns %false once the gate is
+ * taken, so a winner that sleeps first lets a concurrent cancel free
+ * callback data while the consumer callback is still pending.
+ *
+ * Context: The winner must reach handshake_finish_complete() without
+ *          sleeping.
+ * Return: %true if the caller won the gate, %false otherwise.
+ */
+bool handshake_try_complete(struct handshake_req *req)
+{
+	return !test_and_set_bit(HANDSHAKE_F_REQ_COMPLETED, &req->hr_flags);
+}
+
+/**
+ * handshake_finish_complete - Deliver completion to the consumer
+ * @req: handshake request to complete
+ * @status: 0, or the negative errno to report to the consumer
+ * @info: netlink message context, or NULL if not from a downcall
+ * @tags: session tags to publish, or NULL; ownership passes to @req
+ *
+ * Context: The caller has won the gate via handshake_try_complete()
+ *          and has not slept since.
+ */
+void handshake_finish_complete(struct handshake_req *req, int status,
+			       struct genl_info *info, struct stringset *tags)
 {
 	struct sock *sk = req->hr_sk;
 	struct net *net = sock_net(sk);
+	struct file *file = req->hr_file;
 
-	if (!test_and_set_bit(HANDSHAKE_F_REQ_COMPLETED, &req->hr_flags)) {
-		struct file *file = req->hr_file;
+	if (tags)
+		req->hr_tags = *tags;
 
-		trace_handshake_complete(net, req, sk, status);
-		req->hr_proto->hp_done(req, status, info);
+	trace_handshake_complete(net, req, sk, status);
+	/*
+	 * Consumers may query hr_tags on any completion path, and
+	 * stringset_is_member() WARNs on an unfinalized set.
+	 */
+	stringset_finalize(&req->hr_tags);
+	req->hr_proto->hp_done(req, status, info);
+	stringset_destroy(&req->hr_tags);
 
-		fput(file);
-	}
+	fput(file);
+}
+
+void handshake_complete(struct handshake_req *req, int status,
+			struct genl_info *info)
+{
+	if (handshake_try_complete(req))
+		handshake_finish_complete(req, status, info, NULL);
 }
 EXPORT_SYMBOL_IF_KUNIT(handshake_complete);
 
diff --git a/net/handshake/tlshd.c b/net/handshake/tlshd.c
index 997edc3fe31c..a9c5e5bedced 100644
--- a/net/handshake/tlshd.c
+++ b/net/handshake/tlshd.c
@@ -106,7 +106,7 @@ static void tls_handshake_done(struct handshake_req *req,
 		set_bit(HANDSHAKE_F_REQ_SESSION, &req->hr_flags);
 
 	treq->th_consumer_done(treq->th_consumer_data, status,
-			       treq->th_peerid[0], NULL);
+			       treq->th_peerid[0], &req->hr_tags);
 }
 
 #if IS_ENABLED(CONFIG_KEYS)

-- 
2.56.0

