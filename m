Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B2D239182E
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 14:16:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792160185; cv=none; b=F6odEpGf+ngInXP0y//z8J0Jp0XPH1wwnMPqjCqmoPTWURzhx3ZurebTrZJdUiNVkY+60V4NTv+eWSlTqYOJGbxeiZGdO3U5ApyeWOdqan1iky4R8zRMvAuO2YSgEVuBxJEVxzbSVhW7z+b+jDJfTsxrUu0n/GhQJYsD/71X7Ds=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792160185; c=relaxed/simple;
	bh=BH4gJuATNcYddvU2lPZAPTNkQ0dBA4NZfax3CBzp0y4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=egUgcXreAArc+TJLMoE8sS8W8ZCI30UFh2muZGOZjcQwnING3ewdS0LC5yBAGxeZXdQAP/+musjgBw1cu1vMmVLBerMJ0yq6PWCnHNcpBnLb9qbU6FP7OaIgx8CKM8TOFEwk717rtJIoh61GY+hz34rVzGRb8vjf80S5F5lu2vk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KyL6zEjS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KyL6zEjS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D32CB1F000C7;
	Fri, 16 Oct 2026 14:16:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792160180;
	bh=klG4K5wo8M1iwL5dSnj2adqhkA7AnokGQA74V1CunQ0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KyL6zEjSQ8hB4bzcoSrbFckK2aSX/oCku/k22GWqkUhwRx8GfI/VWzWeIGx5O5Gkf
	 VaF1iI1UEexUTcxIth5hdo41YdDpitwkzdGuRWMFsWyTvYLmzJNeqMiCWl9j8utu3F
	 2UgAWU5ZIatojWpj2prBhbaFFTJF3vELgPvCIl0jDEtYmzjn01rbePM8LmzL/L46Rr
	 LHDXyjf+phWKFnavBxv7nvQEjS1xoz97RsGkmva1FkqR4Uy72L/8mivHhxXmZu5JsW
	 Q8jq57ERXKuG7aruvAQCv0FxYYP5+qZB+YxBASCPx2fhCRvct5ihxrySdpHaMbUaL3
	 gmGaCSAfE3glg==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 16 Oct 2026 10:15:38 -0400
Subject: [PATCH nfs-utils 2/7] mountd: prime the kernel caches over netlink
 on MOUNT
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261016-netlink-noproc-v1-2-42791f4b6eb5@kernel.org>
References: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
In-Reply-To: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=6723; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=BH4gJuATNcYddvU2lPZAPTNkQ0dBA4NZfax3CBzp0y4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq0jGxgWYVuEdrXdi1WsmJW+oLUYgLYBoF6HMCa
 sZSjk9SVnCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatIxsQAKCRAADmhBGVaC
 FZX+D/9b0bovu4KM5DtU9sxx3pFH2dSatnkShNsJ8uxBfi18kSH5IPjofJ5UuzIGH++/gstrXtO
 4ZXw+2NAJ0kYa2hLmX7jFTtWNufP+c2Lbl34NP/H4QGhhF2l0yLbLJy1dZq0C3/VlsIeCm0FI9u
 3dAt2z7YVnLL1/H3ke87Z+WKhQpiB2OH2xB9hrhE4j5b0yILOI4i+hZ9thOO+Fjg1xqUvK3WFJH
 CYKJ0q9sRFR2xqpDu7utQGstjjrNqFYHWjv3sZfkrEotHfHHMztTpwREeIIxWttZOpECvkhZ9su
 kIZo8MJ9SJsXwhOubczTider+ozp3IXOCNXLem0uhv1mjFgRTxn/Luy9vxptzLK9ir2ntovD6J1
 k2MZCYd305rN54mL5Q7h7c2fRMB8oNuyJRbpCCkbmkwdcPOs5zi7XJM+BonRjfQs1PrUnd4THEN
 3Nu1W6iAhmXTr3WPbb8xTblZmlx13wTg7YT7DIKGsQcNr61SqXKhMaWdxkj2aSsyy3PAAsZmQ59
 pdhX26e8X2M+CJYBIL52C/eJpYJU1EHkEzP4KWNZV4+yjJiR910eHu9h4scjbZlKZJstw5Nb6lP
 7W9VeanMNK3XWWvnS5/NIxZwKlhbHZMa7351W8Q34Sh51oyJ7AA45Se4aIkIEYwDfhdW1KEGETq
 60G4O/VhwcPf9qg==
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

