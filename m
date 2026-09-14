Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF721336886
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 16:00:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789401655; cv=none; b=DZGsFxZ/TP2LGSE6jIekSEYRI62oj92Kn5X/6NuHoECXg0fximZUOsphBZU1Wfv0LbWi+hKZcuCh/LKgqtXtiTG5EAhEjssOptdbik/BdUVjneoOdevcR6uVsW7NUnJ8a/e3PXcLOOOnS7DZ8jaK80l/07PeAZHMZz95J+3ZscU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789401655; c=relaxed/simple;
	bh=oyO6/IZiK9I40S8IW6/rmDxBtg+cHTjcwQSxAZXtZ8Y=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=I38ZAw0sU9gBtK2lTFt0Wd9NdZzLbJr4AFuAmJpEOmNf1ZKcPv+A4RiNGabCuG35hPtkmsrJHk/tiAXpSrZWfsJSOFkod0qsBqiyhbW9OD7PQ73an0XNKs6Kub63GLt4ZbAzcPz02WrkbPE1eKpvwEXMi17LqcgjYx6TAjJvWlg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hau9aQhN; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hau9aQhN"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BE65F1F000FF;
	Mon, 14 Sep 2026 16:00:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789401653;
	bh=ZaqJLHyyQ1ItuBge0pxld6vSMxyd9PDey7slQm2V6lY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hau9aQhNkdc/Am6vkHUIoZ74sZHsnkj+TT7+aanhMihPvW+1DvMqo2m3kdW0hJD7f
	 kblnilGxtlhS6HjLQ/nolDw09+kAbOksMJtbaJ5dC3dbdCNUHdnnS/kfPPBwsqveA8
	 IXmOd9ntoQmAAJL74Al6bti/kc1psXo/EE39QJKHEvRNTEvnf61M44WcyvnfmN0KKR
	 B7eZ6GoREA9+do3Y7sKsKQZSn3wqhtaSbgH13O208vEmppK4JnJj1877s16Jw+iAKl
	 w97f8LozD89OJABmzIZ97VgvRPPP9yM+LcIXj4yb4HcOEZhnD2p39SJYR9JY3YXQHS
	 xhqKBb/fH08bw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 12:00:30 -0400
Subject: [PATCH RFC nfs-utils v2 02/10] nfsdctl: probe the policy of any
 command
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nfsdctl-rpcb-v2-2-b2c679ac0107@kernel.org>
References: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
In-Reply-To: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2685; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=oyO6/IZiK9I40S8IW6/rmDxBtg+cHTjcwQSxAZXtZ8Y=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBow3dTvh/rHueklhPricx3Hjnk9l70r8UxzZ
 eLZUMRIdxeJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgaMAAKCRAADmhBGVaC
 FbjED/0ZhRDyanvDssRmsD3gmU1USxV97Ij9ISRu4bGQ1KodGbh9PWoTmE8ItQAvypKEFxjLqNG
 p4CCWGozGtPdkWFBrTv/iQiInyT7FLUTenn+YkZ/AITMHrER/vTAAoKyD1QfDMZSiggKCFNmMdR
 NMI5KoMaddt+yoCn75SJJbM02DZXgpy/J1n0ibi0DNqGyJ0IA/pXVM78wVyH2e4GEJLNDSpxUSY
 yPA1dMfjqcvlHmaqTg+RNUGFmV/g8fPtJBNkOz1jaI+/koSeY+H0g3gkIic/i4Kt9Fi2Ky0RUfi
 9uKXu7+4DXXhfDhQEC99DSlq4pCjhVpV6z/BeQzpuFLZkdDyhbc/cIBYvjmwQwSZfj3Rg7hoYHt
 U6nwHBNSLHjJe4cEQE45Bz+qroGOhudYLvCmW55FhJ1S5w+v12QH+gfUfT++DfMjbCTCWR219Yt
 BLgPG6UEH8qswN6RqJcFC6mTdnfhFsYcq4YypJfdMUD9dKt66JTRsvzagsHLeoUejVGrJrubXFD
 Xtnb5pc1IblYIXtwuzegx+KM7ovD4Qf7tKhdxeFTEFb7lCupF1kk2NOypgQJZ295z5AMpDSF2n4
 QOzZu6k3SMvdAr9G4Mn/wVwTVgIJuPNX8hKFnSCcIQn+s7jKQPtsDPFtMnzeOv0jE59D+SaB+Rv
 h6K7Vat40CbKXFA==
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

