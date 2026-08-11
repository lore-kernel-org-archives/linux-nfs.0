Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB459442B1B;
	Tue, 11 Aug 2026 12:03:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786449794; cv=none; b=NoMtoE+sw13FCNFcKRp0o9dV8W8UH3BBgqz9+yF7kWHfk0TRpB+RwhkfMl1KmsaHTJ8+nEh5rqv3+bhy5rMjP9Avt48lk/364lVBX3tH4eicBBVJI6Q2EejaKK4OPNK+GNzsXcFFYYMTt6du6CXCGe3YOlf+LrJOhB+hCVEiZCc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786449794; c=relaxed/simple;
	bh=5rSg4dAcvVQv/gwh6ajdjqTKnjmHWmRK73iIdvgeZj0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=nfVp7XmIrQzNwJsmKz4mH1QRJ0eFhW4QkhTfpJ1FX8BS5xrkP9T3wEPknaGBL7RI597merr4HGtQovXQ4pVqKbjJcUlj1hP94cXcLqhRFIAsCZt1NdmFhsmHlhLf5Ji9GJkVbyGoLQ9w4UcJm0kH2YsNkEfZxKAdrqfHFq8gZOE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=a3FtI9uS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="a3FtI9uS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E2CE11F00A3A;
	Tue, 11 Aug 2026 12:03:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786449793;
	bh=q9kotpnhc3C3OSb7dmtZK9XgIYyfRPrPIg0cQGtxKB0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=a3FtI9uSq4+QlpfOi/sG8KFmljaR7k5HyLNSe1hBtUZfqKKr5+Wcg0/dZ3u7+Gdh+
	 My3I8vxK9pQuhONkAJBG8t0O8w5kQYiaAmFr15bOb03KF6yVioYDqZNPYgfb1tDj4Y
	 RUzZCkhFGtjd2cvaAb91t+uWGL5LLsUQ2ii7jhkLUvp1IFSMPM67CzbaX+sh+j/yij
	 +FtES12gwc1+tpSP2K/yF30l28YVH5b3UhMWsP+mV3OSidInZhsLfT30HN4p9gRP/T
	 vWkWjmwNyAo0Cf2PwQMfledQORqLcdJ0GG7Ln9pPJf/dL+GDvtni7GSfhthZYJg3Fw
	 qTEnmdm63K37g==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 11 Aug 2026 08:03:00 -0400
Subject: [PATCH v2 1/8] NFSD: validate transport name in listener_set
 before serv creation
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260811-nfsd-nl-hang-v2-1-c0c92b3953c3@kernel.org>
References: <20260811-nfsd-nl-hang-v2-0-c0c92b3953c3@kernel.org>
In-Reply-To: <20260811-nfsd-nl-hang-v2-0-c0c92b3953c3@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 "J. Bruce Fields" <bfields@fieldses.org>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, Trond Myklebust <trondmy@gmail.com>, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2981; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=5rSg4dAcvVQv/gwh6ajdjqTKnjmHWmRK73iIdvgeZj0=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqew98cqbUEml+nrQcyt4CLQwFwc/dSd408L7xi
 hsc1X+aIcCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCansPfAAKCRAADmhBGVaC
 FQHgEACEMbOWPsNYfHKRaxjwnybKG3uRSazAlvcOsRI05qbUxbhvcV5uSLxKNyzHEwP1dSho3ld
 r5aOJkjj+J0er3z6SqIkA5/jDKvUVmFeqqvUlXA1dNHD5HrsHK8BoDFbaHg5N839JHgxd36xH4K
 4ZmQWvrBbJPAVKztEZxx5MShzbQmmP/snuQWrlouyqsw6IL3J6YWTsMwegU1lZEhAx90CVLtgAc
 MFJxfs9kO5C6aiB/vuFMTWU6b+tsqFX3+ym/kvnsJTarFJm4XWfZNaPIMDrcJILoYjgrpqMdy3g
 INvKeGoTjeklp5lfkqnvDLPDlIGAREzH2IseaNxr3TTemqWUfq8pgPkbaTlGttCicYJMOBr+vPg
 5ZLutSlw0gJHFk082YURk7Gq+9MTOU5dEl9oM0hbjmkU5knjTn9DHGbGy+xsE7wenQiLy7/U3G7
 FgBqukeadKf8/dLf4R9zkpyF4vHEC1F6hN4R3T2f130qisM+nBX31ogGrYK2xLb0mTBo+/qAiIu
 Dl6RcPp+c6M24yK+/MkMlBGhtxP0nrr5vC6J+vB/m+YWFCs1erzt2Pv9bMt5XwGpETRTlD85PuE
 QHL6HFWW+LDJIGJInN9jguCqXCXEGKEuw5dqeFjjbGPkq+mCJwqaSNV6Paso/TTnBvmKHDfhp1q
 mA93ipKDIim3+1A==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_nl_listener_set_doit() holds nfsd_mutex across the whole listener
teardown/rebuild. NFSD_A_SOCK_TRANSPORT_NAME is only checked for
presence, not content, so an arbitrary name reaches
svc_xprt_create_from_sa(), where a name matching no registered class
triggers request_module("svc%s", name) -- a TASK_KILLABLE usermode-helper
upcall run under nfsd_mutex.

Vet the name against the classes NFSD can instantiate (tcp, udp, rdma) in
nfsd_nl_validate_listeners(), which runs before nfsd_mutex is taken.

This narrows the upcall rather than removing it. "rdma" is accepted
unconditionally, so on a kernel where svcrdma is not built it still
reaches request_module("svcrdma") under nfsd_mutex -- as it must for the
modular case, where autoloading is legitimate.

Assisted-by: LLM
Link: https://syzkaller.appspot.com/bug?extid=c7eae0eb80858a2dba0f
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 4e5e083d8477..e5844d8454b8 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1975,14 +1975,31 @@ int nfsd_nl_version_get_doit(struct sk_buff *skb, struct genl_info *info)
 	return err;
 }
 
+/*
+ * Transport classes NFSD knows how to instantiate. Vetting the name here
+ * keeps a bogus string from reaching svc_xprt_create_from_sa(), where an
+ * unknown name triggers a request_module("svc%s", name) upcall under
+ * nfsd_mutex.
+ */
+static bool nfsd_nl_transport_supported(const char *name)
+{
+	static const char * const supported[] = { "tcp", "udp", "rdma" };
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(supported); i++)
+		if (!strcmp(name, supported[i]))
+			return true;
+	return false;
+}
+
 /**
  * nfsd_nl_validate_listeners - sanity-check the listener list from userland
  * @info: netlink metadata and command arguments
  *
  * Walk every NFSD_A_SERVER_SOCK_ADDR attribute and confirm that each entry
  * is well-formed: it parses against the policy, carries both an address and
- * a transport name, and the address is long enough for its family. Doing
- * this up front lets the callers below assume every entry is valid and
+ * a supported transport name, and the address is long enough for its family.
+ * Doing this up front lets the callers below assume every entry is valid and
  * guarantees we make no changes when the request is malformed.
  *
  * Return: 0 if every entry is valid, or a negative errno otherwise.
@@ -2006,6 +2023,9 @@ static int nfsd_nl_validate_listeners(struct genl_info *info)
 		if (!tb[NFSD_A_SOCK_ADDR] || !tb[NFSD_A_SOCK_TRANSPORT_NAME])
 			return -EINVAL;
 
+		if (!nfsd_nl_transport_supported(nla_data(tb[NFSD_A_SOCK_TRANSPORT_NAME])))
+			return -EPROTONOSUPPORT;
+
 		sa = nla_data(tb[NFSD_A_SOCK_ADDR]);
 		if (nla_len(tb[NFSD_A_SOCK_ADDR]) < sizeof(sa->sa_family))
 			return -EINVAL;

-- 
2.55.0

