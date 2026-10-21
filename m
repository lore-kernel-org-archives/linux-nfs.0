Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552660;
	b=Er80l3MXmbnQ8tB7GKvmZqTpnVNSCAw4bG44trtZ131aISN0GNgXhVv4HzzzsNyQ+NCK
	 RHcCQyyBCJVMu7CVTMKwnZ4Ww5IDW2WUtPt6Ool+p4X01RYgcuORvR8nrnEi4qOohETL/
	 mtvQtMOiUic3bM8Ud8Wjyej9nwgR7xJNhhOKgu5uNLxQuUHm2cf2dWoo7qgcUOB49aWaE
	 RmUOJ2+BowBiMZrvVhJ57weFSrRmrhFtfvNeMod2b4hr++QOHUTR2yK6WWgm/rqoE0ntD
	 vg1mi1uRW2Dz2f0zKkRgONZIHIbNuNUFCKFend+F2yBqw4ZFsMsoLAzs3Jv0220hfWQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552660;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=kJ/z4fN+jhL2UrEVy38NBHksS0b8tNRC6wVC6bpLyJQ=;
	b=lCQr9MwSVpCmeSI2EvLy04deMRXinkKDmGUjWMRfdnXH5g2JEPr0QlpEsx9c7CEWTtUW
	 3L0AIC/PzH70wq8W3f+yfFl9vPVrhCWgP7LI5WLG3POKcvbWXnZqTfH/n93IJwmbA5MiX
	 xahNl065d8eclkArbJzHckxykNO4649dFaNhIDG1ffLNJWjt5eVWIEXzjAOh6gcMWpMsD
	 HBANXqxkoyS1ygm7Mk2YiPrNoK64z+Ydjn41C8Tzk8rzjLAH5iKQ3kfkKHlM/sQ5hashW
	 +VWbYkRpxJTV8WAfleVRB12DojuZhTviADUwPLX29xwNVpYnSmhCaDImhgh01RLQZQA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=Qq4LsrXj;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 031D1607BECA;
	Wed, 21 Oct 2026 03:17:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 031D1607BECA
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=Qq4LsrXj
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552658; bh=QW8LbkT+nkViiQX71YWd6kbfQdssPQxIMrbtTvX1pQE=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=Qq4LsrXjkWO1OgzDUpgcJvBgnVVy/H+deWsrOMez7u73k7YNpfyxf/wcs9UZJg4Nc
	 Yk6NlYfKAEfHLbuP+oiDPMOAVmsmeSEfOv570EbSV/L1tuxE+JRIB8QToG/olhbxA7
	 Do4S/upY9Z32cMtpGDFaM3mSWv8ae0nhRPcTrtj5gbV32zg97ClKOH3ceb5FwtdecT
	 PhvQ2O/Oj7/ThIQcHwBRQpC/a3bujIx98I8R3n4xbRWngTZ0NVeF4ZYVKsJRfOSzcQ
	 nsvW9dyM3Oym7agMVhT0c4/yD7kIDqSB5SpC7cRJMxHtRqUz+6C7KKmj25m83bayEj
	 CmKvztY98LR+g==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 378FE8A0912;
	Wed, 21 Oct 2026 05:17:37 +0200 (CEST)
Message-ID: <f444dffc8e6bf98bf44c02456adc2de40e4ecd95.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 40/41] nfsd, nfs: carry UUID and GUID owners as their
 text form
To: Christian Brauner <brauner@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>,
    "Theodore Y. Ts'o" <tytso@mit.edu>,
    Paul Moore <paul@paul-moore.com>,
    Arnd Bergmann <arnd@arndb.de>,
    linux-fsdevel@vger.kernel.org,
    linux-api@vger.kernel.org,
    linux-security-module@vger.kernel.org,
    linux-arch@vger.kernel.org,
    linux-ext4@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-cifs@vger.kernel.org,
    netdev@vger.kernel.org,
    audit@vger.kernel.org,
    keyrings@vger.kernel.org,
    linux-kernel@vger.kernel.org
Date: Wed, 21 Oct 2026 05:16:00 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

NFSv4 owners and ACL principals are strings. Classic ids go through
idmapd or, with id mapping disabled, as decimal numbers; a UUID or GUID
user or group (Documentation/userspace-api/uid_r.rst) has neither a
number nor an idmapd entry and showed as the overflow id.

Encode such an id as its text form -- "xxxxxxxx-xxxx-xxxx-xxxx-
xxxxxxxxxxxx" for a UUID, the same in braces for a GUID -- in both
directions on the server and the client, and take such a string (it
has no '@', so it can't be a user@domain name) as that id again. NFSv4
superblocks set SB_I_UID_R, so the client can chown to such owners.

RPC credentials stay classic: AUTH_SYS has a 32 bit uid, so a UUID or
GUID user on a client still reaches the server as the overflow id.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/nfs/nfs4idmap.c  | 53 +++++++++++++++++++++++++++++++++++
 fs/nfs/super.c      |  2 ++
 fs/nfsd/nfs4idmap.c | 68 +++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 121 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index bc397110d9..0ca50bf8f3 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -729,11 +729,44 @@ idmap_release_pipe(struct inode *inode)
 		nfs_idmap_complete_pipe_upcall(data, -EPIPE);
 }
 
+/*
+ * UUID and GUID owners (Documentation/userspace-api/uid_r.rst) travel as
+ * the id's text form, which has no '@' and no number for idmapd.
+ */
+static bool nfs_id_r_name(const char *name, size_t namelen, char *buf)
+{
+	if (namelen != 36 && !(namelen == 38 && name[0] == '{'))
+		return false;
+	memcpy(buf, name, namelen);
+	buf[namelen] = '\0';
+	return true;
+}
+
+static int nfs_id_r_to_string(const char *str, char *buf, size_t buflen)
+{
+	size_t len = strlen(str);
+
+	if (len > buflen)
+		return -ERANGE;
+	memcpy(buf, str, len);
+	return len;
+}
+
 int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_t namelen, kuid_t *uid)
 {
 	struct idmap *idmap = server->nfs_client->cl_idmap;
 	__u32 id = -1;
 	int ret = 0;
+	char idbuf[KID_STR_LEN];
+
+	if (nfs_id_r_name(name, namelen, idbuf)) {
+		kuid_t k = make_kuid_str(idmap_userns(idmap), idbuf);
+
+		if (uid_valid(k) && !uid_is_legacy(k)) {
+			*uid = k;
+			return 0;
+		}
+	}
 
 	if (!nfs_map_string_to_numeric(name, namelen, &id))
 		ret = nfs_idmap_lookup_id(name, namelen, "uid", &id, idmap);
@@ -751,6 +784,16 @@ int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size
 	struct idmap *idmap = server->nfs_client->cl_idmap;
 	__u32 id = -1;
 	int ret = 0;
+	char idbuf[KID_STR_LEN];
+
+	if (nfs_id_r_name(name, namelen, idbuf)) {
+		kgid_t k = make_kgid_str(idmap_userns(idmap), idbuf);
+
+		if (gid_valid(k) && !gid_is_legacy(k)) {
+			*gid = k;
+			return 0;
+		}
+	}
 
 	if (!nfs_map_string_to_numeric(name, namelen, &id))
 		ret = nfs_idmap_lookup_id(name, namelen, "gid", &id, idmap);
@@ -769,6 +812,11 @@ int nfs_map_uid_to_name(const struct nfs_server *server, kuid_t uid, char *buf,
 	int ret = -EINVAL;
 	__u32 id;
 
+	if (!uid_is_legacy(uid) && kuid_has_mapping(idmap_userns(idmap), uid)) {
+		char str[KID_STR_LEN];
+
+		return nfs_id_r_to_string(kuid_str(uid, str), buf, buflen);
+	}
 	id = from_kuid_munged(idmap_userns(idmap), uid);
 	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
 		ret = nfs_idmap_lookup_name(id, "user", buf, buflen, idmap);
@@ -783,6 +831,11 @@ int nfs_map_gid_to_group(const struct nfs_server *server, kgid_t gid, char *buf,
 	int ret = -EINVAL;
 	__u32 id;
 
+	if (!gid_is_legacy(gid) && kgid_has_mapping(idmap_userns(idmap), gid)) {
+		char str[KID_STR_LEN];
+
+		return nfs_id_r_to_string(kgid_str(gid, str), buf, buflen);
+	}
 	id = from_kgid_munged(idmap_userns(idmap), gid);
 	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
 		ret = nfs_idmap_lookup_name(id, "group", buf, buflen, idmap);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index cb19f1540d..2d292e4418 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1100,6 +1100,8 @@ static void nfs_fill_super(struct super_block *sb, struct nfs_fs_context *ctx)
 		break;
 	case 4:
 		sb->s_iflags |= SB_I_NOUMASK;
+		/* owners are strings: UUIDs and GUIDs in their text form */
+		sb->s_iflags |= SB_I_UID_R;
 		sb->s_time_gran = 1;
 		sb->s_time_min = S64_MIN;
 		sb->s_time_max = S64_MAX;
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index e9faf8b78f..8c3e908b32 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -644,6 +644,33 @@ static __be32 encode_name_from_id(struct xdr_stream *xdr,
 	return idmap_id_to_name(xdr, rqstp, type, id);
 }
 
+/*
+ * UUID and GUID users and groups (Documentation/userspace-api/uid_r.rst)
+ * have no number for idmapd or for numeric owner strings: their owner
+ * string is the id's text form, "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" or
+ * "{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}", in either mode. Such a string
+ * (it has no '@') is taken as that id again; classic ids are unchanged.
+ */
+static bool id_r_name(const char *name, size_t namelen, char *buf)
+{
+	if (namelen != 36 && !(namelen == 38 && name[0] == '{'))
+		return false;
+	memcpy(buf, name, namelen);
+	buf[namelen] = '\0';
+	return true;
+}
+
+static __be32 encode_id_r(struct xdr_stream *xdr, const char *str)
+{
+	size_t len = strlen(str);
+	__be32 *p = xdr_reserve_space(xdr, len + 4);
+
+	if (!p)
+		return nfserr_resource;
+	xdr_encode_opaque(p, str, len);
+	return 0;
+}
+
 /**
  * nfsd_map_name_to_uid - Map user@domain to local UID
  * @rqstp: RPC execution context
@@ -672,6 +699,16 @@ __be32 nfsd_map_name_to_uid(struct svc_rqst *rqstp, const char *name,
 	if (name == NULL || namelen == 0)
 		return nfserr_inval;
 
+	{
+		char buf[KID_STR_LEN];
+
+		if (id_r_name(name, namelen, buf)) {
+			*uid = make_kuid_str(nfsd_user_namespace(rqstp), buf);
+			if (uid_valid(*uid) && !uid_is_legacy(*uid))
+				return nfs_ok;
+		}
+	}
+
 	status = do_name_to_id(rqstp, IDMAP_TYPE_USER, name, namelen, &id);
 	if (status)
 		return status;
@@ -709,6 +746,16 @@ __be32 nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name,
 	if (name == NULL || namelen == 0)
 		return nfserr_inval;
 
+	{
+		char buf[KID_STR_LEN];
+
+		if (id_r_name(name, namelen, buf)) {
+			*gid = make_kgid_str(nfsd_user_namespace(rqstp), buf);
+			if (gid_valid(*gid) && !gid_is_legacy(*gid))
+				return nfs_ok;
+		}
+	}
+
 	status = do_name_to_id(rqstp, IDMAP_TYPE_GROUP, name, namelen, &id);
 	if (status)
 		return status;
@@ -721,13 +768,30 @@ __be32 nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name,
 __be32 nfsd4_encode_user(struct xdr_stream *xdr, struct svc_rqst *rqstp,
 			 kuid_t uid)
 {
-	u32 id = from_kuid_munged(nfsd_user_namespace(rqstp), uid);
+	u32 id;
+
+	/* (outside the initial user namespace: the overflow id below) */
+	if (!uid_is_legacy(uid) &&
+	    kuid_has_mapping(nfsd_user_namespace(rqstp), uid)) {
+		char buf[KID_STR_LEN];
+
+		return encode_id_r(xdr, kuid_str(uid, buf));
+	}
+	id = from_kuid_munged(nfsd_user_namespace(rqstp), uid);
 	return encode_name_from_id(xdr, rqstp, IDMAP_TYPE_USER, id);
 }
 
 __be32 nfsd4_encode_group(struct xdr_stream *xdr, struct svc_rqst *rqstp,
 			  kgid_t gid)
 {
-	u32 id = from_kgid_munged(nfsd_user_namespace(rqstp), gid);
+	u32 id;
+
+	if (!gid_is_legacy(gid) &&
+	    kgid_has_mapping(nfsd_user_namespace(rqstp), gid)) {
+		char buf[KID_STR_LEN];
+
+		return encode_id_r(xdr, kgid_str(gid, buf));
+	}
+	id = from_kgid_munged(nfsd_user_namespace(rqstp), gid);
 	return encode_name_from_id(xdr, rqstp, IDMAP_TYPE_GROUP, id);
 }
-- 
2.56.0

