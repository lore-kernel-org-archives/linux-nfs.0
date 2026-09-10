Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3931657ED98
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 18:22:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789064533; cv=none; b=W+GutO8wMfcoppTNOoUf3ee7JrkiM5DG92ze8dYU9Ou7Sfpva5ZOGzMKqJv9fZ61DIdxu4jBXFe8V9IcFQVwWMf5MQ2Ykcsa7WaPFbXIuMIwc/Nap24h8c0aIJCmp00QlsHBnbn/XfuW9Tdk0oxKpV8zUOvAQlkZF9+tgwux++Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789064533; c=relaxed/simple;
	bh=oyO6/IZiK9I40S8IW6/rmDxBtg+cHTjcwQSxAZXtZ8Y=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=soJQFAtN/JdHa/Ffi/SbjKrS3TfladDg4JQ3lBG+5rMAjuiCXuP5EEwayDyfj0gJs4aiWZ7XkneTa9z+7W1Ud/Vrs1yNUUkXhipo6IR9j/gfeO7roPwkZqisbOEpiCkppQvPL1g9cn0286vuwsfHl9f6l9zjW1gm+Mvi37SF14c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CUi6DWtM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CUi6DWtM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3B9461F00893;
	Thu, 10 Sep 2026 18:22:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789064532;
	bh=ZaqJLHyyQ1ItuBge0pxld6vSMxyd9PDey7slQm2V6lY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=CUi6DWtM4nSLOcVpkBAlNcPdszifADjLNWAO/VB/4hql8SO8B5/cW182Seh35K1j3
	 3Q4Jyfl0U/7i6HA5e6Kg+7NAy11y2DX05T10+nmk46lrAAtzOLbTCkW3AvoUmj2LiT
	 eDk3UwmL+vyDBFz/1AAsZy49gCzUKW1XZKAGS3JYcgenxB9hpwTEEeiZpZcvggwPjf
	 5ALh3IwgaYApunAAZ/1A81ZDHIySSmTHlfUVYnIZ+3Ryye00e9PXEJR0iFJt+MJiNf
	 fnZ70cmK7zNPwwnEX+4BucDalAC2GAjD6W6iMW8+S5CopSiAEAtSW4JRnG0APssqGZ
	 ugqsaQmdxAPQw==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 10 Sep 2026 14:22:03 -0400
Subject: [PATCH RFC nfs-utils 2/7] nfsdctl: probe the policy of any command
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-nfsdctl-rpcb-v1-2-4bba1e7a3a43@kernel.org>
References: <20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org>
In-Reply-To: <20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2685; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=oyO6/IZiK9I40S8IW6/rmDxBtg+cHTjcwQSxAZXtZ8Y=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqovVPwMeUQUvoZ5R3TkXVaoFRzahngxf4M5x3u
 5LUY5a1PRyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqL1TwAKCRAADmhBGVaC
 FSkpD/9gqrPY6NxDmMHqCaqkFdWg+0/5Ix9zOZEpf4dhzwpFpShPynYiJsECHI4RBHUA9xGeFGG
 HvFx1gpl/6DehAE0+YzAPb/B3vY5/KGVnQ0Z4hy6bB5V+gRQyk0ze9FhAu8oJto8+K3MlJjjBVv
 +5XzxRB88esux4vvSkl1r9wwe7/s0WCe8n8dDkmY9TB3t+I6pA+eq+rVLBm0Vk7fj0z20dkgint
 2EA8lauE/4eTXop+Ur6p3WgWyPgCjfYNJUL8Grw/QnFxvMw1SJOt46pwcXCu7nvfs986Xc7E++J
 iBjBT51Cxxz1GmzTm7LER2bjHOw9cqazjnMpfMgmCz72spLw/ESy+ABc1A+XG11JXQHnTsWLdL/
 VTJ9blo+e6gVkMLCpbRUmmZcs4+mTBenXsSuiXF6WbH7oZIFupfm+Rn0Y08bd9yX3Nt4btGvJZ3
 HLxDgvTQB9qLLT4S6cj5MJkm2k1i1UM3x03OpX0A3fUCO0IDCS8L7XDGfFm23tLfiOHvE+gK4UU
 8gvKuc+v4kCAzP4/fORttzZztAn70qcZq9BAlX6gnSE2fE97tBIkLMybOI8pSu3emq+um+RqCOV
 lqNT02NwIhnsdVR42YotkBOyq49Y6JTTfb2o7UwcVwssNUTwMr3UYfE9j57IOSZffOs5ST6MEuM
 b262q5bCqVmVYqw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

query_nfsd_nl_policy() asks CTRL_CMD_GETPOLICY about NFSD_CMD_THREADS_SET
only. getpolicy_handler() writes the highest attribute straight into a
global. A second command cannot use either function.

query_nfsd_nl_cmd_policy() now takes the command number.
getpolicy_handler() now writes through its callback argument.
query_nfsd_nl_policy() keeps its name and still probes THREADS_SET.

No functional change.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 utils/nfsdctl/nfsdctl.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index c7126748dac9..8733f0377208 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -500,6 +500,7 @@ static int nfsd_nl_family_setup(struct nl_sock *sock)
 static int getpolicy_handler(struct nl_msg *msg, void *arg)
 {
 	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
+	int *max_nlattr = arg;
 	struct nlattr *attr;
 	int rem;
 
@@ -512,8 +513,8 @@ static int getpolicy_handler(struct nl_msg *msg, void *arg)
 				nla_for_each_nested(b, a, j) {
 					int idx = nla_type(b);
 
-					if (nfsd_threads_max_nlattr < idx)
-						nfsd_threads_max_nlattr = idx;
+					if (*max_nlattr < idx)
+						*max_nlattr = idx;
 				}
 			}
 		}
@@ -521,7 +522,8 @@ static int getpolicy_handler(struct nl_msg *msg, void *arg)
 	return NL_SKIP;
 }
 
-static int query_nfsd_nl_policy(struct nl_sock *sock)
+static int query_nfsd_nl_cmd_policy(struct nl_sock *sock, int cmd,
+				    int *max_nlattr)
 {
 	struct genlmsghdr *ghdr;
 	struct nlmsghdr *nlh;
@@ -549,7 +551,7 @@ static int query_nfsd_nl_policy(struct nl_sock *sock)
 	}
 
 	nla_put_u16(msg, CTRL_ATTR_FAMILY_ID, nfsd_nl_family);
-	nla_put_u32(msg, CTRL_ATTR_OP, NFSD_CMD_THREADS_SET);
+	nla_put_u32(msg, CTRL_ATTR_OP, cmd);
 
 	ret = nl_send_auto(sock, msg);
 	if (ret < 0)
@@ -559,7 +561,7 @@ static int query_nfsd_nl_policy(struct nl_sock *sock)
 	nl_cb_err(cb, NL_CB_CUSTOM, error_handler, &ret);
 	nl_cb_set(cb, NL_CB_FINISH, NL_CB_CUSTOM, finish_handler, &ret);
 	nl_cb_set(cb, NL_CB_ACK, NL_CB_CUSTOM, ack_handler, &ret);
-	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, getpolicy_handler, NULL);
+	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, getpolicy_handler, max_nlattr);
 
 	while (ret > 0)
 		nl_recvmsgs(sock, cb);
@@ -574,6 +576,12 @@ out:
 	return ret;
 }
 
+static int query_nfsd_nl_policy(struct nl_sock *sock)
+{
+	return query_nfsd_nl_cmd_policy(sock, NFSD_CMD_THREADS_SET,
+					&nfsd_threads_max_nlattr);
+}
+
 static void status_usage(void)
 {
 	printf("Usage: %s status\n", taskname);

-- 
2.55.0

