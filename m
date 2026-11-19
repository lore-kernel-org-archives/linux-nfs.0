Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795109141;
	b=ayGyofarfwwwYRoBmdayFQfeJHwg2Tvqwj91TZkJeDLZBFQ7t1fYGrgjg9Uiq8x++WGZ
	 fQUq+/TGxu1ZPBgUU5KxywZc1PoabW1L5s7dSnX2jDZmGg9jpZKNMqSHmDYpWHTgfJHbW
	 GWu5jBdu0x19lrL+8I+mqt3p1KknvL/Y/tSovpkVV0+R95sdU4rCj95n+SSKvhpIumt6c
	 MbtjksIjO2/BU7Z7m5uc1hYWFYyGq8CFbqpzA6K78szvIRKU7VtfdlX5IDek2hIFP6kZu
	 tCRkpoaqzD3K0bwXAv122dQ1o/SLP70dasgCWRuJYdLJEZ47ebVPQo+dEXzSulRdlfw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795109141;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=bGQsOapv1goj1GRHYOPKsqcJh4s8/c1UOnTE9H6eLj4=;
	b=rbjqA9+n3wKgfpd8V1UjusjSExuwybMuK8A8d9uz0/nFEm1x5XIOFb8Re98ktM3genPh
	 PSsBSS13Xj+FRtZrwmCbllABBtk/mrBna64tj0Vk5NHS1uAmwaiko/Rz28lbhnmzdh0eO
	 /NgtJYQis2PQIV5Zj0mASvQiE33cBgusk78VJ6stM87zat9IAKl/hKQLhGngo3uxShfdI
	 C8Zm8dAhC/kvFTW1PBJe4Jto4kEguVRlekxacwMbapPaye2GgbtZ2w3ba5oPOhMyvumkD
	 s6KTR8xqomCiXCygiJzGJdV2iU6rKyY4lwKi+R3QkGCcJ594OMDs0ghZ2S3feffPAiA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=FXUOV60U;
	arc=none smtp.remote-ip=209.85.210.44
Received: from mail-ot1-f44.google.com (mail-ot1-f44.google.com [209.85.210.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 46E53606A32C
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 17:25:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 46E53606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=FXUOV60U
Received: by mail-ot1-f44.google.com with SMTP id 46e09a7af769-8490a7d6696so2355a34.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 09:25:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795109139; x=1795713939; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=bGQsOapv1goj1GRHYOPKsqcJh4s8/c1UOnTE9H6eLj4=;
        b=FXUOV60Ubqi64mlYuJYI4RhkqY4ONP6fp8ME8XUCuugP9HRAtcyJQMNxvWzWhKuU88
         LefWZW5AgVgBmK0XtVFqZjTRXrcOJnPX+TZwI3MbA7qlSicUw+QjLyDVVhadaTjfuBPI
         8sSYo1OTh98GjlYmC0zQuZguT6mvTP78rE53GlAtyryD1jyaZ8CJUUknZQs1OpdvlM8l
         pIaDYwt1vdgl0smQ/CsOmATkVNT5KgpaVKtfG5w6fe93gqro0Flgr/nTCDAg1hUQT2EI
         ayVMmrotl/a6xTMn+IADoLlKEsLGw6KfitB8MXtjv1ASu7OYqy/TblBuy5Ke16FVeiiV
         jflQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795109139; x=1795713939;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=bGQsOapv1goj1GRHYOPKsqcJh4s8/c1UOnTE9H6eLj4=;
        b=uyokTnG3gtQKBWd1rgohYBzF5Yvnsi4D/boOW91wW/bvbqP/xEG3ARlUjuBbpzgnOO
         D2uE0PxNrmuMHrQbYY5SpZ6zBcAkUVDl0s1iEbR0N8Kq4HQvN9qWU4Z3sXt0eCH6xvK3
         cQHQ6YshaKZxYPIpHc89B7BJLxyZt0wKQgM77UqiTTkgoXjlrF2M0LS94Ca9gaVWKQ82
         qJbV88Y+NdpnCyfVc08dqYoRgMw2ww/qgNe+12DFbHA8XgFINPUudaGKTds0tZKkOpk9
         ezYz894iaNsuyRMEFbQ0XzAUjw3IUQ1nqYiIpamwtvWcNW97dr+FHzCcuJH3eoWGXgQL
         1XUQ==
X-Gm-Message-State: APuU4Z/mzwBTL8dBV5+E+4qNIXSpbqLVZvpWUalNDbD65mT63kmzt0Jo
	SfhfnKNtmzbEw2+9uWFXj38XNvK91h0HlKbEPvWRKfxRmOhhgzuIIVKVJ5bB5NlxgIs=
X-Gm-Gg: AYBFou0plw843L8OC1Y4qV6krur5D7TkBaSYkV8LYTLfXJQYAp7n4QhGyPys9Q/aSd9
	adOZnMMxElu0LH+LucZHK3r0ovi20hjJUzgDKTur6gojzNfoTO9IXj6EzdaVKRoigB1/azMxET9
	ucz3UtbnG14WIOdYsImCXDRon9OqaO0Ue+UnmxBlLOb6jrRY8QEN/ziKLHNytOGP0NviuMpp3U1
	folqFU6uqEiILWJkjRA6fEsf3cSVkZ4lDXtg5tXMVSJz020CqNu4Hd1qqXKIjbe3okQWAPmLBqR
	dlyFFmbL/3trHpyEkXsQgLcYuCFFAWPAl1KDG9W05rLdJ5d1N61ARi6jq51Yaqjh2fEtSmoQka9
	LK0E5ouq4Dh/Hjc/Q+bCH+tyfGDZGbxRQ7aptoXFCTIQ29pm7PKHqN0OBPX5oADLNasmquR1kq0
	A3o6r4qd3mzhcAyCNTDZSIgXZU6chWtoIK1iPZVvYbvdgbGFJF9K/oN3X7YyAaKRhjtxjMSsGzo
	ECRv9T3qq+EiQe7Ua5V4om9TDygvIlc6gZZadOCzT8AyF8kVl878iAAZk0zE+INpvOA3urE8CqF
	t1ySj96vivkcZkaHsk0oId6G6URmz3PdrXa6vEHPyeq/11Zz8pZ978o97LpG2PqWnKgjKpbNgFk
	g
X-Received: by 2002:a05:6830:913:b0:862:9ff6:53b6 with SMTP id 46e09a7af769-86315a6d2aemr784812a34.23.1795109139054;
        Thu, 19 Nov 2026 09:25:39 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-863168dd6besm102897a34.11.2026.11.19.09.25.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 09:25:38 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: restart a write that the DS error handler retries
Date: Thu, 19 Nov 2026 12:25:36 -0500
Message-ID: <8ee107c9d0c68b6d0ee7305605ff7edbe0ffa160.1795108832.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

When ff_layout_async_handle_error() returns -EAGAIN for a write,
ff_layout_write_done_cb() passes it up without restarting the call.
The v4 handler doesn't restart it either: its out_retry path, taken for
NFS4ERR_DELAY, NFS4ERR_GRACE and the session errors among others, only
clears tk_status and returns -EAGAIN, after an rpc_delay() for DELAY
and GRACE.  nfs_pgio_result() returns early on -EAGAIN, so the task
exits without resending the WRITE, and nfs_write_completion() queues
its pages for COMMIT as if they had been written.  They are written
again only when that COMMIT returns a verifier that doesn't match the
zeroed one the failed WRITE left behind.

Restart the call on -EAGAIN, as ff_layout_read_done_cb() and
ff_layout_commit_done_cb() do.

Fixes: c22eeb869735 ("pnfs/flexfiles: do not mark delay-like status as DS failure")
Cc: stable@vger.kernel.org # v4.5+
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 5c289737366f..41cd9254bdd5 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1922,6 +1922,7 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 		set_bit(NFS_IOHDR_RESEND_MDS, &hdr->flags);
 		return task->tk_status;
 	case -EAGAIN:
+		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	case -NFS4ERR_FATAL_IOERROR:
 		task->tk_status = -EIO;
-- 
2.53.0

