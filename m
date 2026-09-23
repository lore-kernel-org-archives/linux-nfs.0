Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D996848035A;
	Wed, 23 Sep 2026 10:59:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790161174; cv=none; b=GDM3nP8oxcQy3HSTHb7C2Dqvxfhc48nT6Im9u4bDFvMGZUVml96vbhBOPCVI4rIjsfL7KfqjZwnSJjFE51Pje/Ye99hJvW3Xm4xygSm0qhw0OGsAYabyteo3/u97pCy6f+3tm37SPU5/vHFu9Wf6B4qHce7G1apQq60Kj3W+gXY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790161174; c=relaxed/simple;
	bh=xX9XhkpOXj1Cb9rbMympF2NdN69EjApoTlQ7aXuya04=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=u18bfnAOJkc3Jks/kUyQXGi9lOav5YAgNDQclp2g33sp2NkI7J+CVLJpWzhGmQJTqThMi4bWm+YqdIlWABypVIYSLPlf9uOEQduTDjfcL0U08UeP9b/CDH5YPBxIQSRDh7/yNGfT3e39iyWLCjTTaJwKEktOriRrLzt34Wi9Gxs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PgOR459u; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PgOR459u"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D3BDB1F00899;
	Wed, 23 Sep 2026 10:59:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790161163;
	bh=6ASRleEWYyVlo5W4I727TEqskFbsxMPvO1Pmz4MNgbM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PgOR459uWYRSctv+xW8bxeGtfyWnjmrZijGtJbH1ACCVyythjky21uHWeP7Jwb+JZ
	 nN5je9z7efjlx7yaC94Z09A968F1Ysg03OCf5Sb1nzURqbwgAe220FmAmHGBwuI7JC
	 fNfElPvazamUP+ZZo2gPw3+Pzpr6AMQ80IbMaZPnq/rp8T/XuAWE6VxJGFV642KRnr
	 +4GunG/PiwJxq7an2BcEQPXK7fIpBFGYv2XMJ9aOpCYfedWbJ+Yvt5RWDtsi4E2Ozw
	 aGNkOruWeD7geMFi395/OBgLus4asGRVKrHX4dzrBH8epnBv4nKmyc2JtK6Bu3SApH
	 o743/btzApSAQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 23 Sep 2026 06:58:56 -0400
Subject: [PATCH 1/2] lockd: allow SERVER_SET without a gracetime attribute
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260923-nfsd-testing-v1-1-a793f54a4dd1@kernel.org>
References: <20260923-nfsd-testing-v1-0-a793f54a4dd1@kernel.org>
In-Reply-To: <20260923-nfsd-testing-v1-0-a793f54a4dd1@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3157; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=xX9XhkpOXj1Cb9rbMympF2NdN69EjApoTlQ7aXuya04=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqs7EJacj5mH/yrwyt5daEWPrwtC1WeEK88mL3X
 o5g4BB43UaJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarOxCQAKCRAADmhBGVaC
 FZHvEAC6fUnc5zMr9pHNUCJZRRBJWBMjo8WaIm060qq/d9lwo8SibdpZObW76m12d6PFSsqMlFO
 /1iWXGC2HiOI64oLwonP/y+1u9pHul4QZnQHelnjQDcQaPzJ+Td1cPm4ogKnmGOjMH86dw1Faza
 oMhqMR8bQ3klQLntFkZC8rTvODEE5zkVGM/MaJwaQMRil/CaWPvmg3jjiUXAQNUSGva9n3Oa4ZY
 M/l/fVoh9+D2mcFp7lReO4mS6ZEIQX+Dkd7yPn/L0VrJqvjp/kDy9eKSSPThCvjLvqCnUG+jmcF
 XECR7hc5XVBCe3L9xOENn4dh/EGOU7jO8r15xaHgqADWW9BmXD9UuJ03STs3SPz/XVU/yWTrdbS
 VGNmlkh0GReHN9adZaJBpL5/Ui9uZVehMz929+pawCJICcmbg4wsbtfOuXouCh4hRpbHinU4ZKg
 KgAZDXYSUJFWiwE4CgZ5megHow/YU0jxjNt+AQ/KIpxrC+t72UkacQZA1nNcmIytKEcrqiyzvJB
 mbo6GfGSCmA+T+yaMyMjl7E0boq3HVe+oM8ckgnZtNd49KKxBR21wGwcGH82IIdA6yswyqSECsj
 ga2mlWHdWuCqFaXIlO2Dlfao4+RUap4RorEwK7MxUnv/P1Y8nq/riDlGTP2l83r6oAqrjbAAaQs
 SHBqOoOxGgbnR9w==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

lockd_nl_server_set_doit() required LOCKD_A_SERVER_GRACETIME via
GENL_REQ_ATTR_CHECK(), but all three attributes are optional in
lockd.yaml and each is applied independently below. The effect was that
the tcp and udp ports could not be set on their own.

nfsdctl hits this: with a [lockd] section that sets "port" but no
"grace-time", it sends SERVER_SET with only the two port attributes, and
"nfsdctl autostart" aborts with EINVAL before configuring anything.

Drop the check, along with the now-redundant outer test for "any
attribute present". The gracetime range check is unaffected.

Fixes: 9a28ac1762a7 ("lockd: add netlink control interface")
Assisted-by: LLM
Reported-by: Scott Mayhew <smayhew@redhat.com>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/lockd/svc.c | 50 ++++++++++++++++++++++----------------------------
 1 file changed, 22 insertions(+), 28 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index f0e1a58c9106..8e1b1735acaf 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -704,7 +704,8 @@ static struct svc_program	nlmsvc_program = {
  * @info: netlink metadata and command arguments
  *
  * This updates the per-net values. When updating the values in the init_net
- * namespace, also update the "legacy" global values.
+ * namespace, also update the "legacy" global values. Every attribute is
+ * optional; only the ones present in @info are changed.
  *
  * Return 0 on success or a negative errno.
  */
@@ -714,38 +715,31 @@ int lockd_nl_server_set_doit(struct sk_buff *skb, struct genl_info *info)
 	struct lockd_net *ln = net_generic(net, lockd_net_id);
 	const struct nlattr *attr;
 
-	if (GENL_REQ_ATTR_CHECK(info, LOCKD_A_SERVER_GRACETIME))
-		return -EINVAL;
+	attr = info->attrs[LOCKD_A_SERVER_GRACETIME];
+	if (attr) {
+		u32 gracetime = nla_get_u32(attr);
 
-	if (info->attrs[LOCKD_A_SERVER_GRACETIME] ||
-	    info->attrs[LOCKD_A_SERVER_TCP_PORT] ||
-	    info->attrs[LOCKD_A_SERVER_UDP_PORT]) {
-		attr = info->attrs[LOCKD_A_SERVER_GRACETIME];
-		if (attr) {
-			u32 gracetime = nla_get_u32(attr);
+		if (gracetime > nlm_grace_period_max)
+			return -EINVAL;
 
-			if (gracetime > nlm_grace_period_max)
-				return -EINVAL;
+		ln->gracetime = gracetime;
 
-			ln->gracetime = gracetime;
-
-			if (net == &init_net)
-				nlm_grace_period = gracetime;
-		}
+		if (net == &init_net)
+			nlm_grace_period = gracetime;
+	}
 
-		attr = info->attrs[LOCKD_A_SERVER_TCP_PORT];
-		if (attr) {
-			ln->tcp_port = nla_get_u16(attr);
-			if (net == &init_net)
-				nlm_tcpport = ln->tcp_port;
-		}
+	attr = info->attrs[LOCKD_A_SERVER_TCP_PORT];
+	if (attr) {
+		ln->tcp_port = nla_get_u16(attr);
+		if (net == &init_net)
+			nlm_tcpport = ln->tcp_port;
+	}
 
-		attr = info->attrs[LOCKD_A_SERVER_UDP_PORT];
-		if (attr) {
-			ln->udp_port = nla_get_u16(attr);
-			if (net == &init_net)
-				nlm_udpport = ln->udp_port;
-		}
+	attr = info->attrs[LOCKD_A_SERVER_UDP_PORT];
+	if (attr) {
+		ln->udp_port = nla_get_u16(attr);
+		if (net == &init_net)
+			nlm_udpport = ln->udp_port;
 	}
 	return 0;
 }

-- 
2.55.0

