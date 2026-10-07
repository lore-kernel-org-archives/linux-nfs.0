Received: from mail-oo1-f50.google.com (mail-oo1-f50.google.com [209.85.161.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 01C893A6F04
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 19:59:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791403191; cv=none; b=H5LfIT90f27NTCv9CPZCIVTITuI6WNL+URERJy+GB6t6DQGS212NaogMEuTki9xkUm+DOwg6w6WKO1yKDOEdEapBU6CIoWyslxxxFoEa8MpnNGeJILYgIx8XK9EQXDK4RwB4wE32MfG2zVFT4v8z6Uly48whqCmBHcL3PZ2yj9c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791403191; c=relaxed/simple;
	bh=qgOqAIrzkFVv3pR41i4HnBt20Mw4cWVHW1Yivzd/Wx0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jkf4siUTPsiNw287H/lkNX9VtnKalRg+joO8KFBtsjrD+dPSSkstmb6hg8wd5CWHICky9otwDDBtSuPkokjM2L8gud/f4FLCk3upPQ8QhV6q1/UfvZjbb3UxvjLIOIyF/cqbyL6k0dFYWCI1f8FapOkc7CHdjbs30qLpwiH4ais=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=QOX2Ajx7; arc=none smtp.client-ip=209.85.161.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="QOX2Ajx7"
Received: by mail-oo1-f50.google.com with SMTP id 006d021491bc7-6cfed5dd083so3305549eaf.1
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2026 12:59:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791403189; x=1792007989; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=owCAAy82Opl9I0OXoUtQLC3+594nC+cfFTkiDVH7AB8=;
        b=QOX2Ajx7/9WZNf10PN17G4P7FU+UHEJR94i5lBnwO7tzlUV9iq3nHfqcaoy7ruHvSg
         CbDKD1fOTcwtgIDMqXdzGjPOTPWNWBXvuBYBOLJWZNX5xuWX2RgDsvobIA3DW2axk/HU
         faZU6qRj9BAKQwqJ3DBxFvoMlAuoJg0rvYsIB1/7BHzGE3sFqVWofnldO/Gg1DMeJ0lG
         x3UAepsdI3EoKmfOPp9jQiL/cSw2WMhOo4/YcxACNb+X8ktJNxXI+X4Yf6WXVY8txSmt
         /7NTKAud6wNPjMjqxvAPYggHHKJxEqmQyZqx7JXVQDm3bZ7mF1i7AtNDpZiMa2L1dadI
         HWsQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791403189; x=1792007989;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=owCAAy82Opl9I0OXoUtQLC3+594nC+cfFTkiDVH7AB8=;
        b=N5EmO0gG3w8IRRiBou8wE5dd86/Li3pIN4d3QFUEYXt/7b5g/jq/CRl+TJlk8QrxBD
         mZGfewo6odLXsovWgL+v6f9LNQXP4yzuQNaoj4yppULo6KA/jbE7m7q3XoIMs0FYbsnq
         GalWQuLD7TnFA4BqHDqtHEU5SjDHnXDDIusFOYdy6suH+4WXrny+TBFOovypEbYq6Dan
         KOL3Cb6C2oTSKlHki03uc2kUQRdbfha93/Rvl/4MNwPVrzl7/ipCaVHfD1/UMv8OMOpz
         UBiTTHaocJYGpgcgCYLaUAYzrBFtZ7FxY04SFVTr2D3e+kaN27k0/aNNo1doPeQekFq3
         ZS+Q==
X-Gm-Message-State: AFuF++mrYdPxIfQemcYdF0Rxbdy992XeMsTO6K+EjoGKyYjfDkw0ES/z
	7uEtI8q3y0u+77P9D2FycATeb8Uxa3UW31KtuQwNtr3ftHcOhovUF0GWlU08KDaK8WI=
X-Gm-Gg: AYBFou04FlZZG5C+Y+InR80WF3i4hyFyvUiuu/shBA0/+/jYYTyrNsRcwjGRDJqL6z2
	2LfpKsTOD0RB4xeBtXuJIapz7hrdM/mT7zu+QRT2kZflAaUU10NLfHxi5dNO9bvP4SqooWzc53/
	gSDzwv/ljxZsmCtXl3SpLc1OakOWf9uue0X3VLy6kZq9Efi5Zuv+2v6m+aYC9JP46buuMYOvIxp
	/jh+y6ZrLKSFy7RS77MR3neexqwuS1HrFGqurnWJPBbnlW3bu7eT9200ZzMYr5J09ORG/6sKAhM
	zsiUU5E2trQrn5KWOkkPCh8ZlAVKkmMpHjUUmtgDV+ZZ+Fpqi37sVAso7mSzkP6gD5zmBLtBrUw
	P9eBg0t6z7rNQA9IgAVhL1i7eAbx/QT7DWuia60lUe5Saed6GJNBcd+2qLHpf5DDtdNCvWkeR6a
	WYbKsBYSLJZb6jDiF/1JuNpU8qE/BmvIpZa7o55chvzg4KawxpCLnPw7CJZd3Nq+Rzcz1NlLRJ9
	3HivfmzLusgyrBEaO62VIW/CMWPwMlcxx/rakSOQg==
X-Received: by 2002:a05:6820:4cc4:b0:6cd:3ffc:e330 with SMTP id 006d021491bc7-6e7a7c25072mr3182451eaf.78.1791403188654;
        Wed, 07 Oct 2026 12:59:48 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a274c9c520sm1084285fac.16.2026.10.07.12.59.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 07 Oct 2026 12:59:48 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org,
	Daire Byrne <daire@dneg.com>,
	bpf@vger.kernel.org,
	Martin KaFai Lau <martin.lau@linux.dev>
Subject: [PATCH RFC v2 7/9] selftests/bpf: add svc_classifier tests
Date: Wed,  7 Oct 2026 15:59:32 -0400
Message-ID: <aeb501171cf5bbd04d324afefb39682387552c8c.1791402701.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1791402701.git.bcodding@hammerspace.com>
References: <cover.1791402701.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

A classifier for RPC service transports that looks the peer address
up in an LPM trie keyed by {family, address}, the reference for the
sunrpc svc_classifier struct_ops, and tests of the attach model: a
second attach in the same network namespace fails with -EBUSY, a link
update replaces the classifier, a detached instance can be attached
again, a classifier attached inside a namespace does not occupy the
initial one, and a namespace that exits leaves its link to detach into
nothing.  Skipped where the struct_ops is not registered.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 tools/testing/selftests/bpf/config            |   2 +
 .../selftests/bpf/prog_tests/svc_classifier.c | 104 ++++++++++++++++++
 .../selftests/bpf/progs/bpf_svc_classifier.c  |  80 ++++++++++++++
 3 files changed, 186 insertions(+)
 create mode 100644 tools/testing/selftests/bpf/prog_tests/svc_classifier.c
 create mode 100644 tools/testing/selftests/bpf/progs/bpf_svc_classifier.c

diff --git a/tools/testing/selftests/bpf/config b/tools/testing/selftests/bpf/config
index ea7044f30adc..2cb7080d7da2 100644
--- a/tools/testing/selftests/bpf/config
+++ b/tools/testing/selftests/bpf/config
@@ -114,6 +114,7 @@ CONFIG_IP_NF_IPTABLES=y
 CONFIG_IP6_NF_IPTABLES=y
 CONFIG_IP6_NF_FILTER=y
 CONFIG_NF_NAT=y
+CONFIG_NFS_FS=y
 CONFIG_PACKET=y
 CONFIG_RC_CORE=y
 CONFIG_SAMPLES=y
@@ -133,6 +134,7 @@ CONFIG_TCP_CONG_BBR=y
 CONFIG_INFINIBAND=y
 CONFIG_SMC=y
 CONFIG_SMC_HS_CTRL_BPF=y
+CONFIG_SUNRPC_BPF_CLASSIFY=y
 CONFIG_DIBS=y
 CONFIG_DIBS_LO=y
 CONFIG_PM_WAKELOCKS=y
diff --git a/tools/testing/selftests/bpf/prog_tests/svc_classifier.c b/tools/testing/selftests/bpf/prog_tests/svc_classifier.c
new file mode 100644
index 000000000000..887af29b21c7
--- /dev/null
+++ b/tools/testing/selftests/bpf/prog_tests/svc_classifier.c
@@ -0,0 +1,104 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * The svc_classifier struct_ops: one per network namespace, bound to
+ * the attaching task's namespace; replace by link update; detach by
+ * link close; a namespace that exits leaves its link empty.
+ */
+#include <test_progs.h>
+#include "bpf_svc_classifier.skel.h"
+
+static struct bpf_svc_classifier *load(void)
+{
+	struct bpf_svc_classifier *skel;
+
+	skel = bpf_svc_classifier__open_and_load();
+	if (!skel && (errno == ENOENT || errno == EINVAL || errno == EOPNOTSUPP)) {
+		test__skip();
+		return NULL;
+	}
+	ASSERT_OK_PTR(skel, "bpf_svc_classifier__open_and_load");
+	return skel;
+}
+
+static void test_attach(void)
+{
+	struct bpf_svc_classifier *one, *two;
+	struct bpf_link *link, *busy;
+	int err;
+
+	one = load();
+	if (!one)
+		return;
+	two = load();
+	if (!two)
+		goto out_one;
+
+	link = bpf_map__attach_struct_ops(one->maps.prefix);
+	if (!ASSERT_OK_PTR(link, "attach"))
+		goto out_two;
+
+	busy = bpf_map__attach_struct_ops(two->maps.prefix);
+	ASSERT_ERR_PTR(busy, "second attach");
+	ASSERT_EQ(errno, EBUSY, "second attach errno");
+
+	err = bpf_link__update_map(link, two->maps.prefix);
+	ASSERT_OK(err, "replace");
+
+	/* the replaced instance can be attached again once released */
+	bpf_link__destroy(link);
+	link = bpf_map__attach_struct_ops(one->maps.prefix);
+	ASSERT_OK_PTR(link, "attach after detach");
+	bpf_link__destroy(link);
+out_two:
+	bpf_svc_classifier__destroy(two);
+out_one:
+	bpf_svc_classifier__destroy(one);
+}
+
+static void test_netns(void)
+{
+	struct bpf_svc_classifier *inner, *outer;
+	struct netns_obj *ns;
+	struct bpf_link *link, *link2;
+
+	inner = load();
+	if (!inner)
+		return;
+	outer = load();
+	if (!outer)
+		goto out_inner;
+
+	ns = netns_new("svc_classifier_ns", true);
+	if (!ASSERT_OK_PTR(ns, "netns_new"))
+		goto out_outer;
+
+	/* attached inside the namespace */
+	link = bpf_map__attach_struct_ops(inner->maps.prefix);
+	if (!ASSERT_OK_PTR(link, "attach in netns"))
+		goto out_ns;
+
+	/* the initial namespace is free */
+	netns_free(ns);
+	ns = NULL;
+	link2 = bpf_map__attach_struct_ops(outer->maps.prefix);
+	ASSERT_OK_PTR(link2, "attach in init_net");
+	bpf_link__destroy(link2);
+
+	/* the link of the dead namespace detaches into nothing */
+	bpf_link__destroy(link);
+out_ns:
+	if (ns)
+		netns_free(ns);
+out_outer:
+	bpf_svc_classifier__destroy(outer);
+out_inner:
+	bpf_svc_classifier__destroy(inner);
+}
+
+void test_svc_classifier(void)
+{
+	if (test__start_subtest("attach"))
+		test_attach();
+	if (test__start_subtest("netns"))
+		test_netns();
+}
diff --git a/tools/testing/selftests/bpf/progs/bpf_svc_classifier.c b/tools/testing/selftests/bpf/progs/bpf_svc_classifier.c
new file mode 100644
index 000000000000..bae9d115ee74
--- /dev/null
+++ b/tools/testing/selftests/bpf/progs/bpf_svc_classifier.c
@@ -0,0 +1,80 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * A svc_classifier for RPC service transports: the peer address is looked
+ * up in an LPM trie keyed by {family, address}; a hit returns the class
+ * word stored there, a miss returns 0, the anonymous client.  A key of
+ * prefixlen 0 is the default for every family, 8 the default for one.
+ */
+#include <vmlinux.h>
+#include <bpf/bpf_helpers.h>
+#include <bpf/bpf_tracing.h>
+#include <bpf/bpf_core_read.h>
+
+char _license[] SEC("license") = "GPL";
+
+#define AF_INET			2
+#define AF_INET6		10
+
+#define SVC_CLASSIFIER_NAME_MAX	16
+
+struct svc_xprt___local {
+	struct __kernel_sockaddr_storage xpt_remote;
+} __attribute__((preserve_access_index));
+
+struct svc_classifier___local {
+	char name[SVC_CLASSIFIER_NAME_MAX];
+	__u32 (*classify)(const struct svc_xprt___local *xprt);
+};
+
+struct prefix_key {
+	__u32 prefixlen;	/* 8 (the family byte) + address bits */
+	__u8 family;
+	__u8 addr[16];
+};
+
+struct {
+	__uint(type, BPF_MAP_TYPE_LPM_TRIE);
+	__type(key, struct prefix_key);
+	__type(value, __u32);
+	__uint(max_entries, 1024);
+	__uint(map_flags, BPF_F_NO_PREALLOC);
+} prefixes SEC(".maps");
+
+__u64 classified;
+
+SEC("struct_ops/classify")
+__u32 BPF_PROG(prefix_classify, const struct svc_xprt___local *xprt)
+{
+	struct __kernel_sockaddr_storage ss;
+	struct prefix_key key = {};
+	__u32 *class;
+
+	if (bpf_core_read(&ss, sizeof(ss), &xprt->xpt_remote))
+		return 0;
+
+	key.family = ss.ss_family;
+	switch (ss.ss_family) {
+	case AF_INET:
+		/* struct sockaddr_in: port at 2, address at 4 */
+		__builtin_memcpy(key.addr, &ss.__data[2], 4);
+		key.prefixlen = 8 + 32;
+		break;
+	case AF_INET6:
+		/* struct sockaddr_in6: port at 2, flowinfo at 4, address at 8 */
+		__builtin_memcpy(key.addr, &ss.__data[6], 16);
+		key.prefixlen = 8 + 128;
+		break;
+	default:
+		return 0;
+	}
+
+	__sync_fetch_and_add(&classified, 1);
+	class = bpf_map_lookup_elem(&prefixes, &key);
+	return class ? *class : 0;
+}
+
+SEC(".struct_ops.link")
+struct svc_classifier___local prefix = {
+	.name		= "prefix",
+	.classify	= (void *)prefix_classify,
+};
-- 
2.53.0

