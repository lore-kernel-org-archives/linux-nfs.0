Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793275826;
	b=NfDlZaZ9jFVUi3ENYeYjAa+bRvTJJBdvFohDzvjjZY3yjQiKxanOlqORawJfvY6xs2YJ
	 CJnSl+lixoldRk39qtruTmwLyMuWspRgbHGXE4GEN1JdSil/biYI/ZMZYF/YNlFnpy/GL
	 EPxqsef9jQglNhZQ7Ixb8zb/9Qku4Rzs/nL7GJv5/dAGaG7usgGfKlVK3MLjq+2EKm4T2
	 zJ4bsSoF8MgwhSVsh+9lPqWALpwu6bQzHgo8gxfGEgXssxdIUX+WkeLizIXHK5C/Z/zlj
	 eX8kcftyZmKKKQgvBZKw0fEv/+hEl+KSgxBieD56B/WpRjEriC+4D4hW+u6EsYz5wrA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793275826;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=X4f3A1ORy0x7vrd+xR8bc7ok8qguF+03XH0uco0/AKw=;
	b=VZ4Qou15qKmtDOVrxYYcpGooialD3mN8Y+M3it0ze2MTzWed89XZnJzB6gCK9u2l2wLa
	 FrEWRnE+krIYIywFQRiNfi4Tq6AYiwM/HyxC6bck9Xr7R7kw95tDwgi1ZZaE+/4dBhS8Y
	 1+bRnBR8KtyaTk5nKWNtzock91IYar49Rq8HytS/TwPNsdirG/crQSPkPDbbBz70DQmIJ
	 OjQhU+DrIomGJHMmFAewZWIT5llTMmnlzmVCLi+HcQ/+hhtxOyySnmur9JLNUKFuFPnBa
	 pV4A0/WJXJ67E4QCMnAU8cPOCzmi2mJ5kPqG2VEL58rZl7soMSAOrHauv90iQLFIKSQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kkXU+SiJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 336A0606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 12:10:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kkXU+SiJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3B62C1F031E1;
	Thu, 29 Oct 2026 12:10:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793275826;
	bh=X4f3A1ORy0x7vrd+xR8bc7ok8qguF+03XH0uco0/AKw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kkXU+SiJsl7L8ri4oK4ZgDm4LB/KgZWXnfIho4u82FCW+Qx5aQMK5cCklQlu90ZM3
	 LcJ6lomFJVkGlSZWN2QCpKGDRR/4uyRsvamiaLuKkkYQMxzlf9bBbcATlfnKHNeDkQ
	 bzDwNEiRWRccFYOk4ezbcgwWuHNhg/98R8ea+9eIHgByZHZ0QJfzZTqrJQZJTVOYNS
	 kELt0o+umHLx0T9mRVVgn0hwOnbv2RGL7rNF2tm+SR+Va6nFfIhnn4aEjF+koN4hnU
	 IGmGzJ7RUS/af54VU7SAUBFOIirx513qRHQ9J4JqknCn6YVXdQPFThXbUDy+nCSa89
	 1+fP+xRAgdxow==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 29 Oct 2026 08:10:08 -0400
Subject: [PATCH nfs-utils v2 1/4] exportfs/mountd/exportd: track the
 svc_export policy highest attribute
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
Message-Id: <20261029-master-v2-1-32bfc6ac16da@kernel.org>
References: <20261029-master-v2-0-32bfc6ac16da@kernel.org>
In-Reply-To: <20261029-master-v2-0-32bfc6ac16da@kernel.org>
To: Steve Dickson <steved@redhat.com>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2251; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=K1+quiOCFzxm6ulbw4AtHIuR/uILoCs7iUd/bbYBetU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4zevVmwrRo3VTIKMECO7rMWQ3uDdj5uI2UnQh
 K0YXXxmkfyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauM3rwAKCRAADmhBGVaC
 FYSID/wIkJ5256OlNbvqRqrPlfTypVSl5tyxwy2kAiv3WprFtSOdbP6aedEUS7oGZPhzlUXRLR+
 LClMlXTbjwVtVgQndZfZ+6QM3sSTQ68IXYJ/zT0H57Tc9lwkTyFO472oJaNwMkgTf+cDsBAqVEf
 rg8LRsu3KpCKkpB1wVKmr+TKjAJweojxPolpPu9yKjcBXyIHmSSgOi6PXadcrJqIhuYjoO5gFR1
 aVsnE2cY0c1okkD+iUeASqdTcISXNFx6IK6myKtYeTXyDfqA4E7//mLD3cw97ZKMRVG/cqR7A92
 RiL4wuGGsa5ptIFUo+/m9IpV33QENJrooN8zkQfsCewLYE5qKM9eF7ru3FdsixJPhyw148oDLZZ
 StiXGLQtaSZ0BhxBRBvPQerlhvvsj99nzI+774/RgXJUQtrFrq2ZasbOnsrybYHLFrqs84Yekmx
 OWP+LAspIF2llPmOO+4r5R0oTlo0cetyV2bRy6+Eer9SnoZDTt7H2oT97XG8nDrZrE1P1SdaoEc
 j2IdQSC5xOesOfzk3nd1Rb+1MECULhkIUGolquzjAFqDzgwim9QoAUtU7MdoxNNsKtetn8WtfmR
 GdKgUAaeuI9Xo9Lcho7FPzsS8HuUxsu2fTZ8XXLJ7p9smwCqcw8caHBj9SzyCgBgj47wwWlGCFk
 y/RLyRvsZDIFqbQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Record max_attr, the highest attribute in the kernel svc_export netlink
policy, in struct nfsd_export_policy. Follow-on work needs it to avoid
sending attributes that an older kernel would reject the whole entry
over.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/export_policy.c | 7 ++++++-
 support/include/exportfs.h     | 2 ++
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/support/export/export_policy.c b/support/export/export_policy.c
index 9c0a099fb0c2..a0170cb87f91 100644
--- a/support/export/export_policy.c
+++ b/support/export/export_policy.c
@@ -40,6 +40,7 @@ struct export_policy_dump {
 	int		done;
 	int		do_idx;		/* the op's own policy */
 	/* per policy: */
+	int		max_attr[NL_POLICY_SLOTS];
 	int		reqs_idx[NL_POLICY_SLOTS];	/* REQUESTS nests this */
 	uint64_t	flags_mask[NL_POLICY_SLOTS];	/* mask of FLAGS */
 };
@@ -106,6 +107,8 @@ static void nl_policy_attrs(struct export_policy_dump *d, struct nlattr *attr)
 		nla_for_each_nested(a, pol, arem) {
 			int type = nla_type(a);
 
+			if (d->max_attr[idx] < type)
+				d->max_attr[idx] = type;
 			nla_for_each_nested(p, a, rem)
 				nl_policy_type_attr(d, idx, type, p);
 		}
@@ -219,8 +222,10 @@ int nfsd_export_policy_query(struct nfsd_export_policy *pol)
 	 * every kernel with the netlink export interface.
 	 */
 	cached.secinfo_flags = NFSEXP_SECINFO_FLAGS;
+	cached.max_attr = d.max_attr[svc];
 	have_cached = true;
-	xlog(D_NETLINK, "svc_export policy: flags 0x%x", cached.flags);
+	xlog(D_NETLINK, "svc_export policy: max attribute %d, flags 0x%x",
+	     cached.max_attr, cached.flags);
 	*pol = cached;
 	ret = 0;
 out:
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index d762e4533560..a7c145543075 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -170,6 +170,8 @@ struct nfskey *			key_lookup(char *hname);
 struct nfsd_export_policy {
 	unsigned int	flags;		/* export flags it knows */
 	unsigned int	secinfo_flags;	/* flags that may vary per flavor */
+	int		max_attr;	/* highest svc_export netlink attribute,
+					 * 0 if it did not say */
 };
 
 struct nfsd_export_policy *get_export_features(void);

-- 
2.56.0

