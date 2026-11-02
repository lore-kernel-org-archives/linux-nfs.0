Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.43
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793646928;
	b=NVAOYwbMTQsXLuZfd2Xpm8e5APo9w9FE1l8ZmTH/na+ss2Vb4tr2mSunkn6+uKyMp9uy
	 StLeMEMyldiot/A9ee/sfgAa6m8kWXNDnT2JR0+igfxli9pDOaTWLRSU6fOYyJyhQ8eQH
	 SbHFE+ezJR/3ToAEDJvDMCz//JVKXpPO7kgwZvBlZ8rtbgxkmn0syath8BmfQlEWRGozt
	 Uea37pgR63AuLBTM3OCWm58FSYBXnmKCFGV2tKzaQVXHykUgxzUq3UquXYSRjxgDcp5JB
	 EOGncpB1ZuQ6RN/qK0iwacJhun0AZp9ol7FgKLaVjsQqbOa4/GOBBPeUIUZDKV9jVNQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793646928;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:Received:MIME-Version:
	 From:Date:X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type;
	bh=wX6frGCKCGo2XcV0yHSpyoZp6rg/OSg2IUqZRFJfH5E=;
	b=vwdR50QTUBi29gHyNkyDzJ7X9tyIw1QFbNJpTz5QIK32rOhA0XaYMGKtwDaPnqWL7t3T
	 Fo3lmpNMnqNNy9M1J3pJYQnJdZ3dCFzUJi8OjU2ImQAmUu5KBbstPXTMCWagJV84ot8Ik
	 QMpnoMyXnLpZG+0Secy/dMt/AoinvMWwbdyQVWz50PgkYUNJ52WC/FuB56Kx/NN0LAqrf
	 Fm8vkj7yg4wcmNMULsfcEpW7LBRe9r5h5xFG21nRM5TAfmM1B07K9Sw24tSevu1PzHgbz
	 ql1G0OEkjJZvPV7MHW4Sfktjw3T97V7eT6At5d6S0SCDLVYOETEAjCnSNagwPwL7vsw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=grlab.org;
	spf=pass smtp.mailfrom=grlab.org;
	dkim=pass header.d=grlab.org header.i=@grlab.org header.a=rsa-sha256 header.s=google header.b=MoG67vIm;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.43
Received: from mail-ej1-f43.google.com (mail-ej1-f43.google.com [209.85.218.43])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CC3AA606D803
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:15:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CC3AA606D803
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=grlab.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=grlab.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=grlab.org header.i=@grlab.org header.a=rsa-sha256 header.s=google header.b=MoG67vIm
Received: by mail-ej1-f43.google.com with SMTP id a640c23a62f3a-c40f29667e6so519873966b.0
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 11:15:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1793646926; cv=none;
        d=google.com; s=arc-20260327;
        b=snORWHMvMRsYDTlmRiVSbc6M9nAs9YXkteY8Pd7SPZHbLQ10IVRFmLuNjGbeaNQqNi
         k1PeLBSOpE7iyCge2tnL/FRt48TA8erOVaHd0tf5kQXsDRv8QlNFc3VujuF5DJXiAO+i
         snZX4oPEkHy5Gz1kvNPVB8BVHyKlMfc8icNEKQfw6MYq+1ruH6nGWUjcH+6K1B1iaULE
         a/3ut6yX1kjVXFBT7q90HlOwtPMcsEWvu8G50SOgZS+zHyVW5vp00CUgFT1OPNj6Gsz2
         Sw4x0AMyAx8rcfcHTApQcBlgWWEZQammY32leZGKGFErbZKiKeNaZeE1SjvOmgBUe9eT
         WQUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=wX6frGCKCGo2XcV0yHSpyoZp6rg/OSg2IUqZRFJfH5E=;
        fh=6VFkAiLCmGwsu2bt8MjQZtK3HFhqP7irmRYwzjaO5lE=;
        b=ZbyV6u4cNmxqszJdt82xVkTPcnmOq4Ldjq9IffVTaGxUhTUhIQnaNZ1zXm71/SFD6l
         8T+vds0Ub7y/LwanisgWR8UPPuY9Kqr8SChZcxofQON8nT5VyUaA1xTG+GqG5P4Daw+h
         UpqZ7lEXruXqyzIWpACUBA89hjbZskgxr22SPFvqzxtEGqFDN6PA2sfDT6nJyZ/xvdfR
         Su2GznBSnnbLkCYcANmoIL4wAQHifLoGU8PVjbawxl241WE3mdKNuAd6xlt1gZAuDs1j
         kpKmYMz1IEdOpT0JiaRvJLhUKK2+av0BlWH7Oh1EIK59tiVyNA756UtXBsxkAbNNYTgJ
         Q38w==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=grlab.org; s=google; t=1793646926; x=1794251726; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:mime-version:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=wX6frGCKCGo2XcV0yHSpyoZp6rg/OSg2IUqZRFJfH5E=;
        b=MoG67vImth7tHdFdB/qWjBIsbRu/Vjb2QbZ5FBzXjA5MObaTjPXlIT99JF3p2oZmkS
         rkf7MytqZxBTxgNn5Ua9iiZToGzXgUIFCzb8sfaAPCIIzmMRputcT2nihQca1SaL4FhX
         Eazs1DAI+57W4/jFeHimpq+sJ6W0rdG5hUlZBrl52XuarPhHnyIkkKV1RiEw/tranFHX
         PDt8hpotPYJij41o6p06vBTcmp3HCz447+s9bnV4K1rw+zJGWwPkTA89AH1qQYRUhyW2
         H4u/ucBJE+WBvTtB5QPZyF0+V9uglQhJHrSmLL3Jt48pU4CZjQto45eldybKFSc+Oyt7
         S0ow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793646926; x=1794251726;
        h=content-type:cc:to:subject:message-id:date:from:mime-version
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=wX6frGCKCGo2XcV0yHSpyoZp6rg/OSg2IUqZRFJfH5E=;
        b=IO6yAsywbQv8z0wDjeaNQAh6e/URop4Mq+kuWbrCnGR7ie5NdoxR/JJ64GEg/bYPcq
         0bIITHeUHaUCdnoycHZ1oc4dy/jlIgts0HuY+xHEfNMNGxO2OsYrjOX9H5UVHZ8me/hr
         +nYlXj60JxP7lYDqkqFPeGJn6Wf4AV2p1jn3p1DQRBCUsT9zgeeIPMo6RCoyrR7HlrXo
         9UvXK6nYNL0+rcXfZtP5Rr5CBF7Qz9z5r/omsM424wu9WiVsJrDx96RKZKAq/Q7RShTZ
         08MXSyLU3j1vnqRuBs8ovRkC/vjpY+OL+6JJCySO0s3sCjQpfTvuKjDZo8VK5Alm3ZK2
         CzFg==
X-Gm-Message-State: AFq9FYI98E4Gx+GfvAnjOVnq2izLM59orxO7scNAolOrwN6H+VtJdAZB
	kg/ohOqE2nPXysD6l11TN83eb7KRkr3pNqfsSo7gNq95w6lQpfIXXuXAv5lKJJlZlzfcmguescU
	Da5IySQYInvmsjStJLH8V4yN9yLPLiiDUoHQdhATbMjzQSUJikXPK/9I=
X-Gm-Gg: AYBFou2rsPtvRwLTEHodyfyo833vBr5rJSyMfjxLS9bfWOELylbYbPsAgCOnQ302VtI
	qK8IEk1RHJMb8Jz3q83S33uaQKTb54C8yFSl5DaIv832ZleXbh4K9R3p82WpmplYPnDrVcHHpIC
	sev3NOR+1yDWtllja/YU3GDMyE6Vz3BBtDIwC/ZZdXSs9577bKZdSj9KNI/gvv8M3f45GV1kXdd
	TxmLxo4m8B5Y/bu1zk15Dp2rcylLlanxjKAEt3w+4N2KPoj43HMt+tOXsKfONaBuD+4gt9VZK5r
	rd7am5p9fMf4Y1PHmyq0ySjywyknDuXHvqwp+gBNZ2o5xAi+ltv+opXhdiaVltjzpva89lZ5cWw
	ZXSOca43DJNDGEukx2p68qzJBOxA7hIO1R+qDghnoeLa9PdmHpAuZVSWzgKt+zLlpKJRvrHEyPN
	2Lc4tVi2Nb8O3cmVaSu+ltGoOei0cqF35QrZiN3UQy9SX9XQr6Qy+386kkv3418kJdKLBft91Ox
	sysV7LanJnntsde7do=
X-Received: by 2002:a17:906:c142:b0:c46:8063:220c with SMTP id
 a640c23a62f3a-c4ca7a09d81mr878047666b.11.1793646925760; Mon, 02 Nov 2026
 11:15:25 -0800 (PST)
Received: from 582193829177 named unknown by gmailapi.google.com with
 HTTPREST; Mon, 2 Nov 2026 19:15:24 +0000
Received: from 582193829177 named unknown by gmailapi.google.com with
 HTTPREST; Mon, 2 Nov 2026 19:15:19 +0000
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: Oleksandr Kulkov <oleksandr.kulkov@grlab.org>
Date: Mon, 2 Nov 2026 19:15:24 +0000
X-Gm-Features: AclHuK-WpNOZcItBUnbr5RwjBM0jqD2NdYx1NJjgLH-b8wnmXX8rOdobSrZidKE
Message-ID: <CAL57+vCMgqj6F_Ws2xWY-yX1Zb+fqsbAX3W98FayrsBoqk6HBQ@mail.gmail.com>
Subject: [PATCH nfs-utils v2] mountd: limit caching after managed-group passwd
 lookup errors
To: linux-nfs@vger.kernel.org
Cc: Steve Dickson <steved@redhat.com>
Content-Type: text/plain; charset="UTF-8"

With --manage-gids, a getpwuid() error produces an empty supplementary
group list cached for the normal TTL. Access that needs those groups can
remain denied after the directory service recovers.

Clear errno before the lookup and cap the reply lifetime at five seconds
when it reports an error. Preserve the usual not-found errno values,
successful lookups, and configured TTLs shorter than five seconds. Apply
the same policy to procfs and netlink, including netlink batch retries.

Keep the existing empty-group reply rather than leave an upcall pending.
This does not deny all access: UID, primary-group and other permissions
still apply. Failures hidden by NSS and getgrouplist() error handling are
outside this change.

Assisted-by: LLM
Signed-off-by: Oleksandr Kulkov <oleksandr.kulkov@grlab.org>
---

Notes:
    v2:
    - Sent inline with my Signed-off-by, and CC to the maintainer.
    - The RFC was
<CAL57+vDXDLynn3Xw1YNXokapyzEc7awdHAObeq0YQwFZhvZ0JA@mail.gmail.com>.
    - Master has not changed since the RFC, so the code change is the same.
    - Dropped the tests/cache-gid.c handler test to keep the patch small.
      I can send it as a separate patch if you want it.
      On current master it fails 27 of 66 checks.
      With this patch it passes all 66.

    Open question from the RFC: is a five-second lifetime acceptable?
    The alternative is to leave the upcall unanswered, as mountd now does
    for export errors that may clear up.

 support/export/cache.c | 42 +++++++++++++++++++++++++++++++++++-------
 1 file changed, 35 insertions(+), 7 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index a5e95afd..d7c0ea46 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -108,6 +108,7 @@ static bool path_lookup_error(int err)
  */

 #define INITIAL_MANAGED_GROUPS 100
+#define MANAGED_GROUPS_ERROR_TTL 5

 extern int use_ipaddr;
 extern int manage_gids;
@@ -187,6 +188,27 @@ static void auth_unix_ip(int f)

 }

+/* A directory-service error is not authoritative evidence of a
missing user. */
+static int passwd_lookup_ttl(const struct passwd *pw, int err)
+{
+	if (pw)
+		return default_ttl;
+
+	/* getpwuid() implementations use these values for "not found". */
+	switch (err) {
+	case 0:
+	case ENOENT:
+	case ESRCH:
+	case EBADF:
+	case EPERM:
+		return default_ttl;
+	}
+
+	/* Answer the upcall, but let an active client trigger a new lookup soon. */
+	return default_ttl < MANAGED_GROUPS_ERROR_TTL ?
+		default_ttl : MANAGED_GROUPS_ERROR_TTL;
+}
+
 static void auth_unix_gid(int f)
 {
 	/* Request are
@@ -201,6 +223,7 @@ static void auth_unix_gid(int f)
 	gid_t *more_groups;
 	int ngroups;
 	int rv, i;
+	int ttl;
 	char buf[RPC_CHAN_BUF_SIZE], *bp;
 	int blen;

@@ -222,7 +245,9 @@ static void auth_unix_gid(int f)
 	if (qword_get_uint(&bp, &uid) != 0)
 		return;

+	errno = 0;
 	pw = getpwuid(uid);
+	ttl = passwd_lookup_ttl(pw, errno);
 	if (!pw)
 		rv = -1;
 	else {
@@ -242,7 +267,7 @@ static void auth_unix_gid(int f)

 	bp = buf; blen = sizeof(buf);
 	qword_adduint(&bp, &blen, uid);
-	qword_adduint(&bp, &blen, time(0) + default_ttl);
+	qword_adduint(&bp, &blen, time(0) + ttl);
 	if (rv >= 0) {
 		qword_adduint(&bp, &blen, ngroups);
 		for (i=0; i<ngroups; i++)
@@ -3113,7 +3138,7 @@ static int cache_nl_get_unix_gid_reqs(struct
unix_gid_req **reqs_out,
 }

 static int nl_add_unix_gid(struct nl_msg *msg, uid_t uid, gid_t *groups,
-			   int ngroups)
+			   int ngroups, int ttl)
 {
 	struct nlattr *nest;
 	time_t now = time(0);
@@ -3124,7 +3149,7 @@ static int nl_add_unix_gid(struct nl_msg *msg,
uid_t uid, gid_t *groups,
 		return -1;

 	if (nla_put_u32(msg, SUNRPC_A_UNIX_GID_UID, uid) < 0 ||
-	    nla_put_u64(msg, SUNRPC_A_UNIX_GID_EXPIRY, now + default_ttl) < 0)
+	    nla_put_u64(msg, SUNRPC_A_UNIX_GID_EXPIRY, now + ttl) < 0)
 		goto nla_failure;

 	if (ngroups >= 0) {
@@ -3181,9 +3206,12 @@ static void cache_nl_process_unix_gid(void)
 		int ngroups;
 		int rv;
 		int ret;
+		int ttl;

 		ngroups = groups_len;
+		errno = 0;
 		pw = getpwuid(uid);
+		ttl = passwd_lookup_ttl(pw, errno);
 		if (!pw) {
 			rv = -1;
 		} else {
@@ -3207,9 +3235,9 @@ static void cache_nl_process_unix_gid(void)
 		}

 		if (rv >= 0)
-			ret = nl_add_unix_gid(msg, uid, groups, ngroups);
+			ret = nl_add_unix_gid(msg, uid, groups, ngroups, ttl);
 		else
-			ret = nl_add_unix_gid(msg, uid, NULL, -1);
+			ret = nl_add_unix_gid(msg, uid, NULL, -1, ttl);

 		if (ret < 0) {
 			/* Flush current message and retry with a fresh one */
@@ -3221,9 +3249,9 @@ static void cache_nl_process_unix_gid(void)
 				goto out_free;

 			if (rv >= 0)
-				ret = nl_add_unix_gid(msg, uid, groups, ngroups);
+				ret = nl_add_unix_gid(msg, uid, groups, ngroups, ttl);
 			else
-				ret = nl_add_unix_gid(msg, uid, NULL, -1);
+				ret = nl_add_unix_gid(msg, uid, NULL, -1, ttl);
 			if (ret < 0)
 				xlog(L_WARNING, "%s: skipping oversized entry for uid %u",
 				     __func__, uid);
