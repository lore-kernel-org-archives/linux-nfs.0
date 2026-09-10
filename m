Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6240D57F74E
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 18:22:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789064535; cv=none; b=OWBfNNQvFbBhkoJhjxmun9V6l/sbGL92eInQAZ1Vs6/9qjmlLWLBp0JjC7GaN56z5sW4lyPxBTfW/PzNSEVTKRKQzs3GV9JOWr3Pty7QmIZdVQyTb9MoMFo7NTWwOkCaLLrM3+qbPUwBAb8K0iZkSQYe7CO3qP8m8Qh+YricwbQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789064535; c=relaxed/simple;
	bh=p4ADDsgB3DJN8mXUFgtZOxKMYpZ3vyCRUXn9RkcZa2Q=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=oY2Ddo3v+YuZEgViq1DxOoWNmL6tHw0oiA0yRilqOpNjLPaL1IkuUWspufRkWhhzOPGhI3CksbHBzPMUmgBXe/3LRU/d0CJNijtIFGeYTAcO4U+KFbTJzhoRg6X5I0ZiEe9qrR4Bbxq6CWLhIEq2MtDnXxg29ZydL4NmOUEDyYw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Fc8TKyxG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Fc8TKyxG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 379221F00898;
	Thu, 10 Sep 2026 18:22:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789064533;
	bh=Z57JVhNcEl6KgiLi7tcOzVe+ljM7Pos9c5JV9JA3tD4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Fc8TKyxGGTs1rAvLXK7QWWi72amWaBtpQwUeNhR6W0JGBUggyOSQkXhK04gOB++Zb
	 RUAeq4FOBi27jhOc5KgrDIdq0kxvh/CSbsHceXeHT1IAlow+ARCmfUEi5Z5r70xaCb
	 6u0lqAqgnsl8qAFv7zjcUB3elLKeVKguHtdpDzYEVbJC/pgAhmY66B7cqF/+LQuJ5L
	 mYBhmI1WdNmvnEbkN2qFo7tXfJmNDiVFumAATHjt5NlH/9hYyzJmPoKLPIBhQBlEyv
	 7zDn3u83slybMHdmGSy5s53MXtfhErg6JCRzOAFyPPFqXov7UXSYiVs8w1SJmYp4gI
	 zeN4fc0ntKC9A==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 10 Sep 2026 14:22:04 -0400
Subject: [PATCH RFC nfs-utils 3/7] nfsdctl: share the listener nest parser
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-nfsdctl-rpcb-v1-3-4bba1e7a3a43@kernel.org>
References: <20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org>
In-Reply-To: <20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2415; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=p4ADDsgB3DJN8mXUFgtZOxKMYpZ3vyCRUXn9RkcZa2Q=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqovVP2lYnDN7FiLLd8k1uCZpZ1PEJZCU1higKU
 FuhGX7x7WOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqL1TwAKCRAADmhBGVaC
 FSv4D/96O3QCJiWGHmXX9O0c1M+fGUdg4O0kakY6mNIivbHeYW+tgbG+Ha16Ehqvrq7bOnsQ4pa
 FjuTNiPDu2E6gBzfCXuCiuFRrj6qUxUikKMGrRGsdydQStoQmIXLXIF+MNW9oPLqXEHSBCbAi1P
 quta2ijiYcN/HG65+Z72SxjC5CqGeb8E65dByTN53MGddhoGDaFESC5EAyXGD7smWF5KLEpDeCe
 8fjSTud5/ybV2g1Uta9lTvzFNUl5Kts93Jrk/e3svNOfRONPxh0QoDvFnKXSNst7daEjwAcoR5w
 plJ1eyRcryrAkZSEU7gpdP4Xd2frwETAHqyLFCdOYScAVUmIoRPPCVMdlh8cltuOOZkBNzpARV9
 9gzBiRTpi4LcaIZW7aMqpTj8FcUuv7Qc4XauNNLq9bZEBvlJvfyggnTXBv4IfmphLuukAW1H6ME
 7XzCA6y0w4uKS7e3HCQ8W6GzWQXztHBdt+nNpMuHFw7+fANuPeDauuTXow4yytjjbI5upwLhXJ5
 +ZfzZDww9WW/+rZGIltqZUoEF5YSToMyCzbXm4SakJcX9io6meR0+w0bIWsbwIykY+lAQRZ8pPo
 WTmxpyZFUqfHvOeGYQOXEQfaefTsr+PQLz1RjFsNgh+ybz8znIaQLEr5P0X0jNruD+rfLEL6pVb
 xUPVKmHd+R37B3g==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

parse_listener_get() unpacks a NFSD_A_SERVER_SOCK_ADDR nest inline. It
also treats every top-level attribute as one of those nests. A
LISTENER_GET reply carries nothing else, so the loop is correct today. A
reply that mixes attributes would count the other attributes as
listeners.

Move the nest walk into parse_sock_nest(). Skip an attribute that is not
a listener. Stop at MAX_NFSD_SOCKETS.

No functional change.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 utils/nfsdctl/nfsdctl.c | 45 +++++++++++++++++++++++++++------------------
 1 file changed, 27 insertions(+), 18 deletions(-)

diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index 8733f0377208..dd815ac53489 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -273,6 +273,28 @@ static void parse_version_get(struct genlmsghdr *gnlh)
 	}
 }
 
+/* Unpack one NFSD_A_SERVER_SOCK_ADDR nest. */
+static void parse_sock_nest(struct nlattr *attr, struct server_socket *sock)
+{
+	struct nlattr *a;
+	char *res;
+	int i;
+
+	nla_for_each_nested(a, attr, i) {
+		switch (nla_type(a)) {
+		case NFSD_A_SOCK_TRANSPORT_NAME:
+			res = strncpy(sock->name, nla_data(a),
+				      MAX_CLASS_NAME_LEN);
+			res[MAX_CLASS_NAME_LEN - 1] = '\0'; // just to be sure
+			break;
+		case NFSD_A_SOCK_ADDR:
+			memcpy(&sock->ss, nla_data(a), sizeof(sock->ss));
+			break;
+		}
+		sock->active = true;
+	}
+}
+
 static void parse_listener_get(struct genlmsghdr *gnlh)
 {
 	struct nlattr *attr;
@@ -283,24 +305,11 @@ static void parse_listener_get(struct genlmsghdr *gnlh)
 
 	nla_for_each_attr(attr, genlmsg_attrdata(gnlh, 0),
 			  genlmsg_attrlen(gnlh, 0), rem) {
-		struct nlattr *a;
-		char *res;
-		int i;
-
-		nla_for_each_nested(a, attr, i) {
-			switch (nla_type(a)) {
-			case NFSD_A_SOCK_TRANSPORT_NAME:
-				res = strncpy(nfsd_sockets[idx].name, nla_data(a),
-					      MAX_CLASS_NAME_LEN);
-				res[MAX_CLASS_NAME_LEN - 1] = '\0'; // just to be sure
-				break;
-			case NFSD_A_SOCK_ADDR:
-				memcpy(&nfsd_sockets[idx].ss, nla_data(a),
-					sizeof(nfsd_sockets[idx].ss));
-				break;
-			}
-			nfsd_sockets[idx].active = true;
-		}
+		if (nla_type(attr) != NFSD_A_SERVER_SOCK_ADDR)
+			continue;
+		if (idx >= MAX_NFSD_SOCKETS)
+			break;
+		parse_sock_nest(attr, &nfsd_sockets[idx]);
 		++idx;
 	}
 	nfsd_socket_count = idx;

-- 
2.55.0

