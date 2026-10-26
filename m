Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793045600;
	b=isi5f5KL3wcqlbtxsCThsKvUrfOXtiAbY3OYQqEPFJkLt8FkVb7x4RW1mVjJAmZOY4SN
	 ZZrMbfFdgD/CbysHlkMlrmq0WWIggq49OwwBsdkzG2SjSb9b/L3UrGBu1Ojl8cRw9uU4J
	 ordlL0VrMLIuA4ln1Ct8gvRE1ELBZVrZxpebywplfyOWdlJgqHfqze8B5helt3ykqUgKn
	 8OHYqHKHmTY8fXp99kNyaTKSLvkW2yhxeq0wq2JUt4jzaPukj392NPNwEbqnLokxXyWag
	 BlXQh4o9UodpR2KVriS+w2TY52VrM4cPNGNWuz6+//QIrSNgYM3t5q6mftjbFUcnqHw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793045600;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Subject:Date:
	 Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=urvuUoiTmi5cWC47MKq7qneqcIl1uFp74XHLgaaK26s=;
	b=Qvvqv8itHvbVI1ewfFiqqXX7jnUqerUlgabMH1gFg90lor4Og/GtXyY3gKFIHPiVvzkp
	 3K+JHabFc1U5g88g0278zn7QHAvixhHYRT+ohjftJBIIukMft5WXKfzWN3kv/6fNuDGuY
	 Dez1g/1wjinpEHw/+3JPqB7WxemkFP19Wg26TJj7zMvq3FUVB54ntNiE1/Qr6sDpwJ2Go
	 QJGJrTMWNIWRgYMTXAeR5KeW3OcASSXXODuA9rq0p/P5pteMuBPko2cmHes0dYwKcN8/7
	 icWdkNTeV9qGVPMJ74AAUA2qxBoclansv6SKrEVLZ+iRbOq9Vgm7/lJKKU2TJBxv1bg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=otoVWANP;
	arc=none smtp.remote-ip=209.85.221.51
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F5FA606A31E
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 20:13:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9F5FA606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=otoVWANP
Received: by mail-wr1-f51.google.com with SMTP id ffacd0b85a97d-48dfc0421d9so2982345f8f.1
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 13:13:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1793045598; x=1793650398; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=urvuUoiTmi5cWC47MKq7qneqcIl1uFp74XHLgaaK26s=;
        b=otoVWANPvQPtTuiq2OuAbwl1pUNnNSO3Qh+d82CHJAWLB0e4DSv/HE68vSowCnrxRG
         PIvCeTtwCNlbH57NLh/+/H3wt4jxlMymFk7rUsdO7oNl9AxxBDdSn9BF9z/oposnjwql
         762qNjyYPayYPAKMhoMfzTvvGkfWoHJOL+D5jKM+fCPLkTpN9K6OsV/IoCjcts6CXmfD
         pXEvsY1qz8kuwYW3uaygRalWbAMOh9SB6M4NT4pIHS8NXkEbcPC88zaAk6CreTYAk1uJ
         VBIUQgoi8+jcyO7ZCkfC6nl76r2OITMkOO8QvLSf6FhEcppkhS5lKgAJl6fGWoNO+mEy
         /5fw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793045598; x=1793650398;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=urvuUoiTmi5cWC47MKq7qneqcIl1uFp74XHLgaaK26s=;
        b=WEPXp0bL147GXI5CqJDv3AQfeFqB59VTuejdLD2qLR52m88Pg0qsUpc4iDbpV6y3zD
         sHX8KsbWD2IoX7bxjsHxTgQdScXT7tzzIz6FmTD3HCQqP9eQi3UJGZoNXuj6DTAolfXM
         IeLI/y+cSm7yVk/rtaoxCijqVtvboVnBmr8IWRq6HUm7+XQMYhMperO7cERXeEDKXmQo
         1qx30LVzQVcrT5iwzbakXLzRiG6jpbI2xJDI+pZGujZcnzop0OB9113jfOClHd7p06Sy
         4PZkEzPVyWighiyBAgIZrclb5Je/cpm66wr7iMBE1zK/pnqbFMBQyqG3rcHXh7vjRKvs
         BdAQ==
X-Gm-Message-State: AFq9FYLJ02ZWscFcm85WAoHRzHU0I2ZbTjk7VUfmD2xvmb4x3AksfkPC
	QSK+Z3LtMKRuqmZ5Z22HhE1Aklu+tpq+3H94+DiLz6VmmLxq36A1VexarVr3GQ==
X-Gm-Gg: AYBFou2usZqWW3qLasEf9LyY3N4xJQYQwDU0TSf5o/ywLKIchTBr4ELkSX9uav02XNf
	We/PUkIk8imxPnV6e5gOux51Q9Vxnzde3ln9D1NBG0yPfK6pEe4iiiQ82AeZ1bJ0muxGhm2rFWK
	M/HPJO4UAui2Bc5fueChbaUvDaUbA5/+SoBo6esRETUJIf+yoAOHOFxGO04TFpF9vHrxMl4/gnR
	ubs+64tzTtNuX4NT5sfboEkxKtPTFKenghCrxT4K8w4b3tWtVBRMYrbAIFnUyb70KIBQtvmU74D
	YFxyt33LLcpqvgRqQpQB/DD9txPfgQQPWMJmSrdO2uQNtTMdahzbb5bTRNwBcKOWPI8tML3dq3V
	wVwUyDbvIZT930OW5Ubiq6IW/sRePq0b7VrWkJxXvBPJeyb6GvVCjp1r0QbC4H+Cf6P7933t/e+
	JI1h1z+P04pGm6YrQbN6jB1nlOgszH+MxU3BntTIxS+fU644gXlb22cXS2TLQanmqKEjJ0Rhc/c
	BdcwRrhg1Q3cH4GzOwXCP/xrGClJf38KRcewaza8BW9of/UhFo1r9bGNn+kgh9j3ic=
X-Received: by 2002:a05:6000:4304:b0:48e:4e26:146e with SMTP id ffacd0b85a97d-48e4e261514mr8220002f8f.55.1793045597883;
        Mon, 26 Oct 2026 13:13:17 -0700 (PDT)
Received: from unicorn.lan.internal ([2a0d:3341:b894:4600:5203:12d3:9baa:d7cb])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e3ebcb99esm17623186f8f.23.2026.10.26.13.13.14
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Oct 2026 13:13:17 -0700 (PDT)
From: Giuseppe Piscitelli <ooonea@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH nfs-utils] nfsdctl: inspect only the command request policy
Date: Mon, 26 Oct 2026 21:12:36 +0100
Message-ID: <20261026201258.663687-1-ooonea@gmail.com>
X-Mailer: git-send-email 2.54.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

CTRL_CMD_GETPOLICY also describes nested attribute policies. Counting
those attributes as command capabilities can enable unsupported flags.
Select the do-operation policy index before computing its maximum, and
keep that index across dump messages.

Signed-off-by: Giuseppe Piscitelli <ooonea@gmail.com>
Assisted-by: OpenAI Codex
---
A four-case callback harness passed with this change (one case passed
before). An isolated Linux 7.3 VM passed nfsdctl threads 0/autostart and
NFSv3/v4.2 write/read, sync and root-squash checks with nfs-utils 3.1.1.
These results are from October 23; no new build or runtime test was run.

 utils/nfsdctl/nfsdctl.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index 505b38d..67e2a0b 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -561,10 +561,15 @@ static int nfsd_nl_family_setup(struct nl_sock *sock)
 	return nfsd_nl_family;
 }
 
+struct nfsd_cmd_policy {
+	int *max_nlattr;
+	int policy_index;
+};
+
 static int getpolicy_handler(struct nl_msg *msg, void *arg)
 {
 	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
-	int *max_nlattr = arg;
+	struct nfsd_cmd_policy *policy = arg;
 	struct nlattr *attr;
 	int rem;
 
@@ -572,13 +577,23 @@ static int getpolicy_handler(struct nl_msg *msg, void *arg)
 		struct nlattr *a, *b;
 		int i, j;
 
+		if (nla_type(attr) == CTRL_ATTR_OP_POLICY) {
+			nla_for_each_nested(a, attr, i) {
+				b = nla_find(nla_data(a), nla_len(a),
+					     CTRL_ATTR_POLICY_DO);
+				if (b)
+					policy->policy_index = nla_get_u32(b);
+			}
+		}
 		if (nla_type(attr) == CTRL_ATTR_POLICY) {
 			nla_for_each_nested(a, attr, i) {
+				if (nla_type(a) != policy->policy_index)
+					continue;
 				nla_for_each_nested(b, a, j) {
 					int idx = nla_type(b);
 
-					if (*max_nlattr < idx)
-						*max_nlattr = idx;
+					if (*policy->max_nlattr < idx)
+						*policy->max_nlattr = idx;
 				}
 			}
 		}
@@ -589,6 +604,7 @@ static int getpolicy_handler(struct nl_msg *msg, void *arg)
 static int query_nfsd_nl_cmd_policy(struct nl_sock *sock, int cmd,
 				    int *max_nlattr)
 {
+	struct nfsd_cmd_policy policy = { max_nlattr, -1 };
 	struct genlmsghdr *ghdr;
 	struct nlmsghdr *nlh;
 	struct nl_msg *msg;
@@ -625,7 +641,7 @@ static int query_nfsd_nl_cmd_policy(struct nl_sock *sock, int cmd,
 	nl_cb_err(cb, NL_CB_CUSTOM, error_handler, &ret);
 	nl_cb_set(cb, NL_CB_FINISH, NL_CB_CUSTOM, finish_handler, &ret);
 	nl_cb_set(cb, NL_CB_ACK, NL_CB_CUSTOM, ack_handler, &ret);
-	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, getpolicy_handler, max_nlattr);
+	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, getpolicy_handler, &policy);
 
 	while (ret > 0)
 		nl_recvmsgs(sock, cb);
-- 
2.54.0

