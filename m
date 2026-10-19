Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 104654DAF89
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 11:46:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792410401; cv=none; b=OY8AuqRFgA9JONGIue8XAhTDthTQrbXtRa1/DYttoU55T3ZgUU9pMc4T1gt5d0jlI5mXIEIyjqKhdN+TyjpGIAXVIcTPyQYpBywgD2niRUjSIAACpZEHV1d9cGXBh1ckpzmSVmy0JJRTAiZXlPNPhUUKCQqZEoDyInAuhnLOrfs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792410401; c=relaxed/simple;
	bh=6QCMwKJ75OtgTVgHHRlt04pcYFgei4UvXPIUQkP+3a0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=IH2FNiMax2t2Sl/AbIZhL4QRgJ7SWiGojnaAi+Hr9ZyytmqJtIow8Tonohgu0vZvAGNXUS6XUzvAAHCgojo3GVCeT0E6h98BKRiULH/E9O5KfrmgQfSzdzWMx5Yppp98tRCm72vTtpD1Pqt0TRPliVyRwypbolkQMuhtRcqZuKg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KDcal0Mo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KDcal0Mo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9D73D1F000C7;
	Mon, 19 Oct 2026 11:46:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792410400;
	bh=A8fSptm9g6rm+J3zZwOPohwSTFiHtNaCpo95Kl1Iuo4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KDcal0MoY/l0oiJz4sbbjffXN3F2s9CsEg16Zdu5pAbIsRJGp5co2o0GueWoOMVgN
	 sU5twgbf8WNRPLnKtyFX11JLHcBoCKSNtYY/Y3Mmz/0iJ9YvGn6L/5UkxH+Pbmluu6
	 aaAVX3XUIZnJRvudLFbd1xxQTPz5g5JdaOBEhGMp6IjRKOBAvzhAd5UQkJGThpvcvo
	 pw1w8jgZudu2mHmVXueSPFUNe+tPIy6BbekFttI8WlaEwL1ZnzHicEHWBM7rUzX/pr
	 2T4IB+VPLLth40fG0MgMVCBEnmMggVYUA8brgUT8BnWoIhUmSnwAk7zsbspz1aciWD
	 Uoew9tA8Jb2PQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 19 Oct 2026 07:46:22 -0400
Subject: [PATCH nfs-utils v2 2/7] mountd: prime the kernel caches over
 netlink on MOUNT
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261019-netlink-noproc-v2-2-7d09a49b574b@kernel.org>
References: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
In-Reply-To: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
To: Steve Dickson <steved@redhat.com>
Cc: Ben Coddington <bcodding@hammerspace.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=6784; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=6QCMwKJ75OtgTVgHHRlt04pcYFgei4UvXPIUQkP+3a0=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq1gMdHLvKovqwPzf8ruJh2+66iNgpVcv2Oyfu+
 2pRduexQsaJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatYDHQAKCRAADmhBGVaC
 FT8ED/4uZmE8TPdMiLCWVWqSX1mOCueEh8Sm/+UkJ0xIIkvSMsjVKajFxHk0dhCsSZjUqWckSDn
 9Nf4N/EBJL+zBlKRJ/4FDxAfxblFEKKgfZ5pvdcbvoZswPTx1jRJIMmowJgmEy71h7FEqQMA4Vh
 4HM65TgLgJCECWP3gonhBkETxO6o9BWkAIkslpuLv53OYfooBly38k+Z9u1SJsJk2xUBqmRHWGm
 r81D6SvTppqj5mNmevcD/s+85RsfJb2FA9TdgKBNyksS72FR4j+86khmfbLoPQc4oY6ibtvPdLN
 1uMaCYlTxRIEp9mfKzubOTOU0aOFR5l4p2GuABZcddSW1QpuY5523WnWICSgwIJg29wxB3FeLEY
 N/OwQzCu7NUoJ9838jzBghMe1YQfX11Dh1ueYC1C8xop5yjWAFt35ZcIRcx2uiITArakJX2FyHy
 OvhjRDr/DcDheL05YOZp6tSLwMXgGEjy9Hp+g1sWRulkHRqWgJd2/iMnnwTZcFx4C+7Q3aHzMTi
 61eVYSLvRDgq3Gw0dCKaAlhFYf0So8BqnEI/scE+ENMyxwGst0Y+dOYRXWVT2V48Y/hnRH9YGAU
 AxyQqroek363zpJOuq4Rg6kyV1/LQ1H82i+UTxOYDDGCcDFzGtZlSM3dUXZNxFZhYTtO36ysK5L
 GSNH2Km1L50UXQA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

cache_export() writes the ip_map and svc_export entries for a MNT
request to the /proc channels even when mountd is using netlink. Any
export state that only netlink can carry is then lost: the /proc
write replaces the entry the netlink upcall filled.

When the netlink command sockets are open, send both entries as
unsolicited SET_REQS instead. The kernel's doit handlers look up or
create the entry, so they do not need a pending request.

- nl_add_ip_map() takes the expiry ttl, so the MOUNT path keeps using
  the export's e_ttl.
- crossmnt submounts go over netlink too.
- The /proc path is unchanged for no-netlink and fallback.

Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/cache.c | 113 +++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 99 insertions(+), 14 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index a5e95afd37ba..d9540ef7fcfb 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -2877,7 +2877,7 @@ static int cache_nl_get_ip_map_reqs(struct ip_map_req **reqs_out,
 }
 
 static int nl_add_ip_map(struct nl_msg *msg, char *class, char *addr,
-			 char *domain)
+			 char *domain, int ttl)
 {
 	struct nlattr *nest;
 	time_t now = time(0);
@@ -2888,8 +2888,7 @@ static int nl_add_ip_map(struct nl_msg *msg, char *class, char *addr,
 
 	if (nla_put_string(msg, SUNRPC_A_IP_MAP_CLASS, class) < 0 ||
 	    nla_put_string(msg, SUNRPC_A_IP_MAP_ADDR, addr) < 0 ||
-	    nla_put_u64(msg, SUNRPC_A_IP_MAP_EXPIRY,
-			now + default_ttl) < 0)
+	    nla_put_u64(msg, SUNRPC_A_IP_MAP_EXPIRY, now + ttl) < 0)
 		goto nla_failure;
 
 	if (domain) {
@@ -2964,7 +2963,8 @@ static void cache_nl_process_ip_map(void)
 			}
 		}
 
-		if (nl_add_ip_map(msg, class, ipaddr, domain) < 0) {
+		if (nl_add_ip_map(msg, class, ipaddr, domain,
+				  default_ttl) < 0) {
 			cache_nl_flush_reqs(sunrpc_nl_cmd_sock, msg, "ip_map");
 			nlmsg_free(msg);
 			msg = cache_nl_new_msg(sunrpc_nl_family,
@@ -2975,7 +2975,8 @@ static void cache_nl_process_ip_map(void)
 				nfs_freeaddrinfo(tmp);
 				goto out_free;
 			}
-			if (nl_add_ip_map(msg, class, ipaddr, domain) < 0)
+			if (nl_add_ip_map(msg, class, ipaddr, domain,
+					  default_ttl) < 0)
 				xlog(L_WARNING, "%s: skipping oversized "
 				     "entry for %s", __func__, ipaddr);
 		}
@@ -3952,14 +3953,61 @@ int cache_process(fd_set *readfds)
  * % echo $domain $path $[now+DEFAULT_TTL] $options $anonuid $anongid $fsid > /proc/net/rpc/nfsd.export/channel
  */
 
+/*
+ * Push one positive svc_export entry over netlink.  The kernel takes an entry
+ * it did not ask for, so a MOUNT can prime the cache without /proc.
+ *
+ * Returns 0, or -1 if the kernel refused the entry or never saw it.
+ */
+static int nl_cache_export(char *domain, char *path, struct exportent *exp)
+{
+	struct export_attrs ea;
+	struct nl_msg *msg;
+	int ret;
+
+	if (export_attrs_build(&ea, path, exp) < 0)
+		return -1;
+
+	msg = cache_nl_new_msg(nfsd_nl_family,
+			       NFSD_CMD_SVC_EXPORT_SET_REQS, 0);
+	if (!msg)
+		return -1;
+
+	if (nfsd_nl_add_export(msg, domain, path, exp, &ea, 0) < 0) {
+		nlmsg_free(msg);
+		return -1;
+	}
+
+	ret = cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, NULL);
+	nlmsg_free(msg);
+	if (ret < 0)
+		return -1;
+
+	xlog(D_AUTH, "granted access to %s for %s",
+	     path, *domain == '$' ? domain+1 : domain);
+	return 0;
+}
+
+/* @f is the nfsd.export channel, or -1 when netlink is in use */
+static int export_to_kernel(int f, char *buf, int buflen, char *domain,
+			    char *path, struct exportent *exp)
+{
+	if (f < 0)
+		return nl_cache_export(domain, path, exp);
+	return dump_to_cache(f, buf, buflen, domain, path, exp, 0);
+}
+
 static int cache_export_ent(char *buf, int buflen, char *domain, struct exportent *exp, char *path)
 {
-	int f, err;
+	int f = -1, err;
 
-	f = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
-	if (f < 0) return -1;
+	if (!nfsd_nl_cmd_sock) {
+		f = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
+		if (f < 0)
+			return -1;
+	}
 
-	err = dump_to_cache(f, buf, buflen, domain, exp->e_path, exp, 0);
+	err = export_to_kernel(f, buf, buflen, domain, exp->e_path, exp);
 	if (err) {
 		xlog(L_WARNING,
 		     "Cannot export %s, possibly unsupported filesystem or"
@@ -4000,16 +4048,42 @@ static int cache_export_ent(char *buf, int buflen, char *domain, struct exporten
 				continue;
 			dev = stb.st_dev;
 			path[l] = 0;
-			dump_to_cache(f, buf, buflen, domain, path, exp, 0);
+			export_to_kernel(f, buf, buflen, domain, path, exp);
 			path[l] = c;
 		}
 		break;
 	}
 
-	close(f);
+	if (f >= 0)
+		close(f);
 	return err;
 }
 
+/*
+ * Push the IP address -> domain mapping for a MOUNT over netlink.
+ *
+ * Returns 0, or -1 if the kernel refused the entry or never saw it.
+ */
+static int nl_cache_ip_map(char *addr, char *domain, int ttl)
+{
+	struct nl_msg *msg;
+	int ret;
+
+	msg = cache_nl_new_msg(sunrpc_nl_family,
+			       SUNRPC_CMD_IP_MAP_SET_REQS, 0);
+	if (!msg)
+		return -1;
+
+	if (nl_add_ip_map(msg, "nfsd", addr, domain, ttl) < 0) {
+		nlmsg_free(msg);
+		return -1;
+	}
+
+	ret = cache_nl_set_reqs(sunrpc_nl_cmd_sock, msg, NULL);
+	nlmsg_free(msg);
+	return ret < 0 ? -1 : 0;
+}
+
 /**
  * cache_export - Inform kernel of a new nfs_export
  * @exp: target nfs_export
@@ -4019,23 +4093,34 @@ int cache_export(nfs_export *exp, char *path)
 {
 	char ip[INET6_ADDRSTRLEN];
 	char buf[RPC_CHAN_BUF_SIZE], *bp;
+	char *domain = exp->m_client->m_hostname;
+	char *addr;
 	int blen, f;
 
+	addr = host_ntop(get_addrlist(exp->m_client, 0), ip, sizeof(ip));
+
+	if (sunrpc_nl_cmd_sock) {
+		if (nl_cache_ip_map(addr, domain, exp->m_export.e_ttl) < 0)
+			return -1;
+		return cache_export_ent(buf, sizeof(buf), domain,
+					&exp->m_export, path);
+	}
+
 	f = open("/proc/net/rpc/auth.unix.ip/channel", O_WRONLY);
 	if (f < 0)
 		return -1;
 
 	bp = buf, blen = sizeof(buf);
 	qword_add(&bp, &blen, "nfsd");
-	qword_add(&bp, &blen, host_ntop(get_addrlist(exp->m_client, 0), ip, sizeof(ip)));
+	qword_add(&bp, &blen, addr);
 	qword_adduint(&bp, &blen, time(0) + exp->m_export.e_ttl);
-	qword_add(&bp, &blen, exp->m_client->m_hostname);
+	qword_add(&bp, &blen, domain);
 	qword_addeol(&bp, &blen);
 	if (blen <= 0 || cache_write(f, buf, bp - buf) != bp - buf) blen = -1;
 	close(f);
 	if (blen < 0) return -1;
 
-	return cache_export_ent(buf, sizeof(buf), exp->m_client->m_hostname, &exp->m_export, path);
+	return cache_export_ent(buf, sizeof(buf), domain, &exp->m_export, path);
 }
 
 /**

-- 
2.56.0

