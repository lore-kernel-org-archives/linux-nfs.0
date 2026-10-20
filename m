Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792510539;
	b=VRKbyLy23tO+KRar0VHIOREdqQD0EofgxD+1cmXm2hylXp6+vVySy1jZAjuSKqK+8cT2
	 J/c1ihElRPkPtUfU/S+QseglGYWS+krZ/cuwJ4KIYFCcsDN6Mi0/Pu0O09nHK8aKyIRue
	 YWmutSPWOQVxChRxnqKdNacCgyCErct/OQ0tTIi3X6GDM4VHq98yh1rUiNpBjsqPufOsq
	 CJJodGqOt5tltTeKrpySiBWSdr/ZoIhmhT5ty0sT3gyECDqk66VjvtHFkhc07oznitmO3
	 z6lEUgjfQ//9Yp+p3LkN9Xob4691VhyJZx5vAPBV3v7tI7GW+4EP/6rlO0Wind5y67g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792510539;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=usDhQDjp+N/IXDhW1Q61ieuka97b6Og7Hw273SnFnFs=;
	b=T+ouSv6WU9SGB3Wko/wY8PSAaJU6Wz0jEpgZw0nlPhyojUBz9Zj9kuReTz/K0H0ikZ3l
	 NRVFcP3abqBfiO4vQDBvLhs4C1XfoUWsrVP0ndhPaBtnTGfCGtc9kqXBFxik+BbFbjq2O
	 UN5MmE6JTiVf9V7hcnZ8jTeUEudbhv2aQ7wCPRMpNWJfg2VgjrUlRCc5aDRdEosBUPovI
	 w5nfukFDrGG7POD7M3hoVMddP7nymUus9a0wEwUA4+mqNI7twjiGVmx5JUNX5txFm1673
	 Bdg3wKrCsMfHEb2+H+XfnemWqQc1tlLLHxni7neS3EzFKaeSQm/lf39G3BC2OOqezdg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XDwYlGGY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4B4B9606A31E
	for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 15:35:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XDwYlGGY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 94E181F000C4;
	Tue, 20 Oct 2026 15:35:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792510538;
	bh=usDhQDjp+N/IXDhW1Q61ieuka97b6Og7Hw273SnFnFs=;
	h=From:Date:Subject:To:Cc;
	b=XDwYlGGY/B/11Uy/rCAKxleBc/auyQ0aMyogWL1Dpw6QMwfiiv1KpWbmIUWPMNp1x
	 tpderX8G/DHoP5w0WS9kWhdvFv+pc5F4X4FI0aTEM24XrdvCjW4Kn1GAaCt+1cwVDx
	 RAbloq2XPMdFNzmKqp1ypEtgvjMbY+xZ+RN1kaR3N0uulp/zgf9QF+wI+DvnXJKwt3
	 MCku4lSnIUAwjQ5ZRlazrnI5Q8J0OVPtkuwPWqUDg6g9453PJZN+iukuTPdtjuofq1
	 Poc05UtfQxE95A82bJj8tVl9GGVRzgxO0mPxo9C2N1DqFeznOveP9xLC6ZQeNNHPKV
	 BekLgm7GU0aYA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 20 Oct 2026 11:35:12 -0400
Subject: [PATCH nfs-utils] mountd: fetch root filehandles over netlink
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
Message-Id: <20261020-nfsd-filehandle-get-v1-1-9161873b43b6@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x2MwQqDMBAFf0X23IVsxB76K6UHMS+6ENKSVSmI/
 +7icRhmDjI0hdGrO6hhV9NvdZBHR9My1hmsyZliiE8JMXDNljhrgdtUwDNWloA4yCj9hExe/hq
 y/u/rmzzgbdVi9DnPC1x5Ja1wAAAA
X-Change-ID: 20261020-nfsd-filehandle-get-10e251a13cef
To: Steve Dickson <steved@redhat.com>
Cc: Ben Coddington <bcodding@hammerspace.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=8897; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ujd1TnKxVzoDDTVtMiHGd8R6ltY6gqw+Yx5j+k/DGHg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq14pKWFv7vnTAofIqrJKMH5F5QXqsmxLVfwCtZ
 vQI9NLTWmiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCateKSgAKCRAADmhBGVaC
 FfqoEACtr7yLC/MhlYhXPoy3hKntwMzFvyI3/fiR/LvrkI9hPN0Mqnd7P1lb9+zAL1dl9kp+/vC
 sBNQ6attDMTztXmBTEy7+9dcX9k2L2nSGDgANnqm0sqInYTso5K7nIcXQ941blybH5D7dFd9Okw
 Yi+MmpXL1Lvq+t/3qJjpbAhd/UOr1GJB8bQJD8+mMJ4WC5kcKyLqtF4+G/gqcElbmJZ45BC+dpg
 LALKER6Y2S6/iUfbQnwlSi/lFaZji9h61L7zfYfxZU6Xwq5xC5UR7BxcDr/opcsn0uKOwyoYq+v
 trhlfNYm9ul0vk2KqJPGX/IpM3EeGLq5Ki00468BvKeW8qJ4rFhcSp3z+iIGK2MwiqALTPUi5iZ
 MUMDLU+ziLxgSJvSFc00slEVWb6SzEFSJzjMturMgBLLpOytfPNnOYOmR3I87Ay9JnUwpkS7cTd
 pA4DwZ+sbY4SBPQPLcV1TPAPu1Z4d2/rcSDEUxYUVXmGjmyobnKXMSEuVv2+XkNzMXibLP3AIA7
 OsZi+YxtM68V8QUslGfPU1Ba5l6yXlO9Mgh6t3qkPMTdvF8IvN1kJu1g9q5z69YYeXsSn++L3Ag
 xOHm9XaMT6lI2HGYi3sAmZqdaaBrNhFfhnge10gVB3r4q77J3pgmw2FL9HlksAWe8ObpI8OSrOL
 hj9NxHqovzmhnWA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Try NFSD_CMD_FILEHANDLE_GET first in cache_get_filehandle(), falling
back to /proc/fs/nfsd/filehandle when netlink is unavailable or the
kernel predates the new command. Sync the bundled nfsd_netlink.h with
the new command and attributes, and require them in the configure
probe.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
This requires the kernel support posted here: https://lore.kernel.org/linux-nfs/20261020-nfsd-filehandle-get-v1-1-8c54f625800b@kernel.org/
---
 configure.ac                    |   2 +-
 support/export/cache.c          | 168 ++++++++++++++++++++++++++++++++++++----
 support/include/lockd_netlink.h |   1 +
 support/include/nfsd_netlink.h  |  15 +++-
 4 files changed, 168 insertions(+), 18 deletions(-)

diff --git a/configure.ac b/configure.ac
index 76d7b72fa9d4..2c13292961bf 100644
--- a/configure.ac
+++ b/configure.ac
@@ -283,7 +283,7 @@ AC_CHECK_HEADERS(linux/nfsd_netlink.h)
 
 # ensure the system netlink headers have the latest features
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/nfsd_netlink.h>]],
-			                   [[int foo = NFSD_A_SERVER_SOCK_USERSPACE_RPCBIND;]])],
+			                   [[int foo = NFSD_CMD_FILEHANDLE_GET;]])],
 			   [AC_DEFINE([USE_SYSTEM_NFSD_NETLINK_H], 1,
 				      ["Use system's linux/nfsd_netlink.h"])])
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/lockd_netlink.h>]],
diff --git a/support/export/cache.c b/support/export/cache.c
index 2724dd3befbb..36d2b356a373 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -4128,30 +4128,135 @@ int cache_export(nfs_export *exp, char *path)
 	return cache_export_ent(buf, sizeof(buf), domain, &exp->m_export, path);
 }
 
-/**
- * cache_get_filehandle - given an nfs_export, get its root filehandle
- * @exp: target nfs_export
- * @len: length of requested file handle
- * @p: NUL-terminated C string containing export path
+struct filehandle_get_data {
+	struct nfs_fh_len	*fh;
+	int			got_reply;
+	int			kern_err;
+	int			done;
+};
+
+static int filehandle_get_valid_cb(struct nl_msg *msg, void *arg)
+{
+	struct filehandle_get_data *data = arg;
+	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
+	struct nlattr *tb[NFSD_A_FILEHANDLE_MAX + 1];
+	int len;
+
+	if (nla_parse(tb, NFSD_A_FILEHANDLE_MAX,
+		      genlmsg_attrdata(gnlh, 0),
+		      genlmsg_attrlen(gnlh, 0), NULL) < 0 ||
+	    !tb[NFSD_A_FILEHANDLE_HANDLE]) {
+		data->kern_err = -EBADMSG;
+		return NL_SKIP;
+	}
+
+	len = nla_len(tb[NFSD_A_FILEHANDLE_HANDLE]);
+	if (len <= 0 || len > NFS3_FHSIZE) {
+		data->kern_err = -EBADMSG;
+		return NL_SKIP;
+	}
+
+	memset(data->fh->fh_handle, 0, sizeof(data->fh->fh_handle));
+	memcpy(data->fh->fh_handle,
+	       nla_data(tb[NFSD_A_FILEHANDLE_HANDLE]), len);
+	data->fh->fh_size = len;
+	data->got_reply = 1;
+	return NL_SKIP;
+}
+
+static int filehandle_get_ack_cb(struct nl_msg *UNUSED(msg), void *arg)
+{
+	struct filehandle_get_data *data = arg;
+
+	data->done = 1;
+	return NL_STOP;
+}
+
+static int filehandle_get_error_cb(struct sockaddr_nl *UNUSED(nla),
+				   struct nlmsgerr *nlerr, void *arg)
+{
+	struct filehandle_get_data *data = arg;
+
+	data->kern_err = nlerr->error;
+	data->done = 1;
+	return NL_STOP;
+}
+
+/*
+ * Fetch an export's root filehandle over netlink.
  *
- * Returns pointer to NFS file handle of root directory of export
+ * Returns 0 with @fh filled in, -EOPNOTSUPP when the running kernel
+ * does not implement FILEHANDLE_GET, or another negative errno.
+ */
+static int nl_cache_filehandle(char *domain, char *path, int len,
+			       struct nfs_fh_len *fh)
+{
+	struct filehandle_get_data data = { .fh = fh };
+	struct nl_msg *msg;
+	struct nl_cb *cb;
+	int ret;
+
+	msg = cache_nl_new_msg(nfsd_nl_family, NFSD_CMD_FILEHANDLE_GET, 0);
+	if (!msg)
+		return -ENOMEM;
+
+	if (nla_put_string(msg, NFSD_A_FILEHANDLE_DOMAIN, domain) < 0 ||
+	    nla_put_string(msg, NFSD_A_FILEHANDLE_PATH, path) < 0 ||
+	    nla_put_u32(msg, NFSD_A_FILEHANDLE_MAXSIZE, len) < 0) {
+		nlmsg_free(msg);
+		return -ENOMEM;
+	}
+
+	cb = nl_cb_alloc(NL_CB_DEFAULT);
+	if (!cb) {
+		nlmsg_free(msg);
+		return -ENOMEM;
+	}
+
+	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, filehandle_get_valid_cb, &data);
+	nl_cb_set(cb, NL_CB_ACK, NL_CB_CUSTOM, filehandle_get_ack_cb, &data);
+	nl_cb_err(cb, NL_CB_CUSTOM, filehandle_get_error_cb, &data);
+
+	ret = nl_send_auto(nfsd_nl_cmd_sock, msg);
+	nlmsg_free(msg);
+	if (ret < 0) {
+		nl_cb_put(cb);
+		return ret;
+	}
+
+	while (!data.done) {
+		ret = nl_recvmsgs(nfsd_nl_cmd_sock, cb);
+		if (ret < 0)
+			break;
+	}
+	nl_cb_put(cb);
+
+	if (data.kern_err)
+		return data.kern_err;
+	if (!data.got_reply)
+		return ret < 0 ? ret : -EIO;
+	return 0;
+}
+
+/*
+ * Fetch an export's root filehandle via /proc, for kernels that predate
+ * FILEHANDLE_GET.
  *
- * { 
- *   echo $domain $path $length 
+ * {
+ *   echo $domain $path $length
  *   read filehandle <&0
  * } <> /proc/fs/nfsd/filehandle
  */
-struct nfs_fh_len *
-cache_get_filehandle(nfs_export *exp, int len, char *p)
+static int proc_cache_filehandle(nfs_export *exp, int len, char *p,
+				 struct nfs_fh_len *fh)
 {
-	static struct nfs_fh_len fh;
 	char buf[RPC_CHAN_BUF_SIZE], *bp;
 	int blen, f;
 
 	f = open("/proc/fs/nfsd/filehandle", O_RDWR);
 	if (f < 0) {
 		f = open("/proc/fs/nfs/filehandle", O_RDWR);
-		if (f < 0) return NULL;
+		if (f < 0) return -1;
 	}
 
 	bp = buf, blen = sizeof(buf);
@@ -4161,18 +4266,49 @@ cache_get_filehandle(nfs_export *exp, int len, char *p)
 	qword_addeol(&bp, &blen);
 	if (blen <= 0 || cache_write(f, buf, bp - buf) != bp - buf) {
 		close(f);
-		return NULL;
+		return -1;
 	}
 	bp = buf;
 	blen = cache_read(f, buf, sizeof(buf));
 	close(f);
 
 	if (blen <= 0 || buf[blen-1] != '\n')
-		return NULL;
+		return -1;
 	buf[blen-1] = 0;
 
-	memset(fh.fh_handle, 0, sizeof(fh.fh_handle));
-	fh.fh_size = qword_get(&bp, (char *)fh.fh_handle, NFS3_FHSIZE);
+	memset(fh->fh_handle, 0, sizeof(fh->fh_handle));
+	fh->fh_size = qword_get(&bp, (char *)fh->fh_handle, NFS3_FHSIZE);
+	return 0;
+}
+
+/**
+ * cache_get_filehandle - given an nfs_export, get its root filehandle
+ * @exp: target nfs_export
+ * @len: length of requested file handle
+ * @p: NUL-terminated C string containing export path
+ *
+ * Returns pointer to NFS file handle of root directory of export
+ *
+ * The handle is fetched over netlink whenever the command socket is up
+ * and the kernel implements FILEHANDLE_GET, and via /proc otherwise.
+ */
+struct nfs_fh_len *
+cache_get_filehandle(nfs_export *exp, int len, char *p)
+{
+	static struct nfs_fh_len fh;
+	int err;
+
+	if (nfsd_nl_cmd_sock) {
+		err = nl_cache_filehandle(exp->m_client->m_hostname, p,
+					  len, &fh);
+		if (!err)
+			return &fh;
+		if (err != -EOPNOTSUPP)
+			return NULL;
+	}
+
+	if (proc_cache_filehandle(exp, len, p, &fh) < 0)
+		return NULL;
 	return &fh;
 }
 
diff --git a/support/include/lockd_netlink.h b/support/include/lockd_netlink.h
index 21c65aec3bc6..2d766a0fa6ea 100644
--- a/support/include/lockd_netlink.h
+++ b/support/include/lockd_netlink.h
@@ -2,6 +2,7 @@
 /* Do not edit directly, auto-generated from: */
 /*	Documentation/netlink/specs/lockd.yaml */
 /* YNL-GEN uapi header */
+/* To regenerate run: tools/net/ynl/ynl-regen.sh */
 
 #ifndef _UAPI_LINUX_LOCKD_NETLINK_H
 #define _UAPI_LINUX_LOCKD_NETLINK_H
diff --git a/support/include/nfsd_netlink.h b/support/include/nfsd_netlink.h
index 400322857d16..dcd2126d848b 100644
--- a/support/include/nfsd_netlink.h
+++ b/support/include/nfsd_netlink.h
@@ -51,7 +51,9 @@ enum nfsd_xprtsec_mode {
 };
 
 /*
- * Constraints that apply to an rpcbind registration.
+ * Constraints that apply to an rpcbind registration. no-udp means the kernel
+ * would not have registered this program and version over UDP, so the caller
+ * must skip the udp and udp6 netids for it.
  */
 enum nfsd_rpcbind_flags {
 	NFSD_RPCBIND_FLAGS_NO_UDP = 1,
@@ -278,6 +280,16 @@ enum {
 	NFSD_A_SERVER_STATS_MAX = (__NFSD_A_SERVER_STATS_MAX - 1)
 };
 
+enum {
+	NFSD_A_FILEHANDLE_DOMAIN = 1,
+	NFSD_A_FILEHANDLE_PATH,
+	NFSD_A_FILEHANDLE_MAXSIZE,
+	NFSD_A_FILEHANDLE_HANDLE,
+
+	__NFSD_A_FILEHANDLE_MAX,
+	NFSD_A_FILEHANDLE_MAX = (__NFSD_A_FILEHANDLE_MAX - 1)
+};
+
 enum {
 	NFSD_CMD_RPC_STATUS_GET = 1,
 	NFSD_CMD_THREADS_SET,
@@ -298,6 +310,7 @@ enum {
 	NFSD_CMD_UNLOCK_FILESYSTEM,
 	NFSD_CMD_UNLOCK_EXPORT,
 	NFSD_CMD_SERVER_STATS_GET,
+	NFSD_CMD_FILEHANDLE_GET,
 
 	__NFSD_CMD_MAX,
 	NFSD_CMD_MAX = (__NFSD_CMD_MAX - 1)

---
base-commit: 9b32b60f7b7b9e79df9e3650ec1b90df354fe61a
change-id: 20261020-nfsd-filehandle-get-10e251a13cef

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

