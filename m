Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE659445AD8;
	Tue, 11 Aug 2026 12:03:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786449800; cv=none; b=t+zMI8FFvOr/uXpGVgzewh4BA+PSFiyIm1RCnxtVUmO0NskHjkpkvwxlxv5DHqCKYnwCGrZLEsAEFu08dwGz0sGArW6brYB8lcO+1CvDV2a4HFuUIH3Sy8ns7ovAttEjc1/tlVePAmueAQI8IMb8dNCzGBobB++ah7GtL3re3zk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786449800; c=relaxed/simple;
	bh=zDvMd0/cF3eAxO6o93Lh5KASDEwmgY2G8v3OOvtVWeQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=qYZzpoRvtdoI10NB/KiUmCIcXoDTuQjkaaL6DisbszuLR7AXnxbbpNe2NveZ/QAguTS6GG3CsEXfMnT+svKBz0wTnapQHOgxI90k6hBAYBextA4dANOrLjxLKnn5XQtjd2iNLFVE9ECUh/1NPWhifmYh01WYdOPNIM163Li5QkM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ESmMghcd; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ESmMghcd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F24FD1F00A3E;
	Tue, 11 Aug 2026 12:03:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786449798;
	bh=DOEfXMILkJ6R9NhbSPOTiA08U6fkuoNTet7R9sVrP2c=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ESmMghcdKSshFjugD6qeLxdro008fq696MMG/eG8T67ZlT3Zp9SNek3drHb1ErtO8
	 iSUU6IOumrS4eOOAh5wm1/LPAFmM+Ah9RLlsw6W1z+p2Ek9p7ncpvnZMwrXC7fr5it
	 AwoDH1bmKDPJW4ErAqvzED5XkaUf8Vi8VNLlJQkHTX1kYpYTAizwOVSMb84LBp48F7
	 wB5dlq2fIeffyCPWoTIqqJFcAJBGes6Gp7fbdYrwxOYxOC2TlWdbeX3y2J5bkavTMu
	 fzpr3k2W/B4RPHlkQXXHGzE8xs5Bw+OwVDPQSJiaZAFkK6WvQ4THvJrkOP3KC7jVp9
	 2J0R0En2qYk2g==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 11 Aug 2026 08:03:03 -0400
Subject: [PATCH v2 4/8] SUNRPC: undo partial rpcbind registrations when
 svc_register() fails
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260811-nfsd-nl-hang-v2-4-c0c92b3953c3@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3049; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=zDvMd0/cF3eAxO6o93Lh5KASDEwmgY2G8v3OOvtVWeQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqew98bGlJv+eJ5TSRvY6rSytjS1VVTBsWGv9DK
 QVnvVGFOMiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCansPfAAKCRAADmhBGVaC
 FTzaEADHOhLoijQXb9De3bztd4I6DKODesrlicRtQx+mxUMdWUFhnxBnVGLf5eR7gBsqlbYE4kE
 ddKyRkyo0VRDjlZwjeB6Y75UPAKaM49Wo6NqClzKjqWhFUejT7dWl9C4MM//Kcl/ymjDWJXmwFU
 CNK+KbmySc+eru3lmcxegOJdfdbdGXTq8twOvLUS9JYJE2jecD+4p08J/FGQXoL4Rq+Bm8e6kV6
 DvPygjJBuCFCKLuQin8j7t38clv7qKL1VSygJZD/eqyrgkkr6IpcO4NNT4FDk2RUXUljJPXl2vM
 lMyTl0DxKvWDFzbUHMdG2453sktTsyZu6SQWTQQxIm/Jqi21eIeNFEYvcabfamSa95CwcJ1UcDv
 SEw18MK2e8PEbzHE67ik318v0YukLlQKJqyfVkeb17fyXzS6UQjxJh5jIL359KLJSREarGtZYfZ
 XlemDoz5dy2eNIlCo1g8FNXHELLhiimqScVgL0W68jcqk6dx4oTqt3sgtJ/f3hjR7EDdch9kcp2
 hobNT3aB61LnliUfKmFU+a4C7zwH4r2qmMc292DHMyTR0/QDUZCwQ2Qwk6VtUSZqE/UkmtF6JRZ
 K/MDFT5C5pce/Fc8q2xWY6q0Eg6WNwvT7th2/4e43rQjxZbJTL6XZuE9nw3yWgMHAw/GbUEybpc
 bXGfCivG46OOZgA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_register() registers each [program, version] in turn. On failure the
caller tears the listener down -- svc_setup_socket() frees the svc_sock and
svc_create_socket() releases the socket -- but the entries that were already
set stay in rpcbind, now pointing at a closed port. XPT_RPCB_UNREG is set
later, in svc_udp_init()/svc_tcp_init(), so svc_delete_xprt() never runs for
this transport and nothing clears them.

Unwind on failure, and stop the walk there rather than registering the
programs after it. rpcbind matches RPCBPROC_UNSET on
[program, version, netid] and ignores the address, so the unwind clears the
netid, not just the port -- the same granularity svc_delete_xprt() already
unregisters at.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/svc.c | 31 ++++++++++++++++++++++++++++++-
 1 file changed, 30 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 4f402bbf97ba..9ffa87007004 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1183,6 +1183,29 @@ int svc_generic_rpcbind_set(struct net *net,
 }
 EXPORT_SYMBOL_GPL(svc_generic_rpcbind_set);
 
+/*
+ * Undo the [program, version] registrations that this svc_register() call
+ * already made, stopping at version @nvers of program @nprog.
+ *
+ * Note that rpcbind matches RPCBPROC_UNSET on [program, version, netid] and
+ * ignores the address, so this clears the netid rather than the one port.
+ * That is the granularity svc_delete_xprt() unregisters at as well.
+ */
+static void svc_unwind_register(const struct svc_serv *serv, struct net *net,
+				const int family, const unsigned short proto,
+				unsigned int nprog, unsigned int nvers)
+{
+	unsigned int p, i;
+
+	for (p = 0; p <= nprog; p++) {
+		struct svc_program *progp = &serv->sv_programs[p];
+		unsigned int last = p < nprog ? progp->pg_nvers : nvers;
+
+		for (i = 0; i < last; i++)
+			progp->pg_rpcbind_set(net, progp, i, family, proto, 0);
+	}
+}
+
 /**
  * svc_register - register an RPC service with the local portmapper
  * @serv: svc_serv struct for the service to register
@@ -1191,7 +1214,8 @@ EXPORT_SYMBOL_GPL(svc_generic_rpcbind_set);
  * @proto: transport protocol number to advertise
  * @port: port to advertise
  *
- * Service is registered for any address in the passed-in protocol family
+ * Service is registered for any address in the passed-in protocol family.
+ * A @port of 0 unregisters instead, and then every program is attempted.
  */
 int svc_register(const struct svc_serv *serv, struct net *net,
 		 const int family, const unsigned short proto,
@@ -1216,6 +1240,11 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 				printk(KERN_WARNING "svc: failed to register "
 					"%sv%u RPC service (errno %d).\n",
 					progp->pg_name, i, -ret);
+				if (port) {
+					svc_unwind_register(serv, net, family,
+							    proto, p, i);
+					return ret;
+				}
 				if (!error)
 					error = ret;
 				break;

-- 
2.55.0

