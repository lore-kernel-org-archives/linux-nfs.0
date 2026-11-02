Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627821;
	b=O8z+i11wd/Rbg24qpP3gvwSSaCOSK4WlBjId1EUi9SHO2eNs60SU1miLGzO1wEMraSLz
	 eDccn1eQxn6f0Mpetb2WXHrpwTvsiE55qMplHRsXPP8LpACI5jpc0l3MfTCldoYPo8a5s
	 vZWE9nXq4RrQAqH1VUwbP35si8n95+N8NQFHMcq562mdV56pm264e3V6XX/IYMRtwII5i
	 dhGNqBhCmX+KWCHu9bx/0NMtd1vvLBsuK9l7cisIvRWVKRWAYO0veIjTDPsgwAJWrL5el
	 dw7vMeGGKAVCYXkWWrpBmyCdUCGCaCbCxkNrdrKzURBmaawxe9dbTgRB7n/LssuIf2A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627821;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=yKEoD2WnccSKIKjWMhLV0TgJJDrgekDC9vZ/Nxmeqh0=;
	b=KVGu9i0KU8OgY4NNVzwhcfp4cCmB2R2Dnth+p/N2bYyB7b9SWXW34/QYC4FFPVSOxg3f
	 68//flsV6Dn4/628Jl0x5o+xZ2p1qRfc+tQc4YgYXdHI2mhUCJ8uWHk/d5JQLpOkisdee
	 xnkpQ5wcY9dr7WV+syCLy0iMP2ZQr+F+UdRoWoOcpH+m4BHn22d05rs6Sqx35H9gttaJw
	 NANgDlFsRDc4D8N8ywom7goVzCRzl9OhQDG5i9IfUS77nT9nbyOF2/3yInt01gL+QpVk8
	 gkYa2hQcVkryGUOOIqN5HAn42R8jC3OpyK++VSVaTfSisakuRCwwofZPNdpfvtKNFAg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=X7wJzR8y;
	arc=none smtp.remote-ip=209.85.210.51
Received: from mail-ot1-f51.google.com (mail-ot1-f51.google.com [209.85.210.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2999360A2606
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 13:57:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2999360A2606
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=X7wJzR8y
Received: by mail-ot1-f51.google.com with SMTP id 46e09a7af769-854b6e2e41fso1939110a34.3
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 05:57:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793627820; x=1794232620; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=yKEoD2WnccSKIKjWMhLV0TgJJDrgekDC9vZ/Nxmeqh0=;
        b=X7wJzR8yIBe4PlI204Ft+HJhfgCS1+1PWAFsLA8vGXWhSX2py2cWbup3DaNlT5skAb
         lci3LCecUPWv0K7pAdxw9njSQGhz6txD0D2Wuv9AMGYPVyrE9y24l5F1NMOlUKTFwI7q
         RbgCfWzM9qd7gRRRRNhHC1SpYC8yeYTCo56cEoXpzX/Pugtoi24yA7zNdsGzo7uvKqsn
         rUVFp3tktMufUY2wresKfqkujtumgVfvjYE4JEReMeHfvuX92K98Y2Y7+gpsB/1m3PRq
         aszTiir/gnZYWxFOx+m/rE8XlLc/Ox1nWjcAxaV9zk2nyKKUi6kcTc4XuJf1HDwNwj3o
         vJlA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793627820; x=1794232620;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=yKEoD2WnccSKIKjWMhLV0TgJJDrgekDC9vZ/Nxmeqh0=;
        b=QFAHkRRyYZll6MTWNXG7a0vFJxkpisIKoO/wtrgnCcy7C7lljvZv9YFAnCihMCKb/u
         S0CPJAB0hPIvaENLSsQmUbaGeC236HAd1JeRfbettKbLG3QdZjSN4AdJEG5NgUPNL2xS
         4m6m5vXWAr58Vxhd9xRiJh+VdG/tdz7QuXuApblNw3yghotaNbh4gq4+OGfyZc6fZepE
         w4r/kBwh4EPL6+YVl9+0ovHEOLn0lUneyhsLP4HtIG66hls7QLfY/wiUOgfxbhh5xcCx
         r/PNe6P4k0LoPPEtmHkIE2ARuQ1fxQdt22JdqSHIetcevUWqh3RECjUAZaQ561jSglb3
         +rlw==
X-Gm-Message-State: AFq9FYIy0Iy1aUJ5uLAa2dB5H/Mp0+7su6+ATt3i6fXHWd7K2CA/QXBI
	8j0ejQZDW3Sz1W5j8/ZGk7y9nVkPHC+ihPj0pHkJq+69sLueWq8h6Aq8DHx9vSq/Tw4=
X-Gm-Gg: AYBFou23zRCZQ6nD0EId8lhP16pSI1DRUxu9sbUyVg1RudmWiW3VYWi2LBYudr0+zM/
	5etG4Xd/d04PCfDXRPct1ll8nfC0TtWNzzALmcppMHg+YR9BX45RgGssnJgIvzTimm73/VUd3tW
	e/8r+2r4G10uOv0roCvnPwBSTLoGurvQ+sPUyb0wOUhLATd4ybZO3J1mljsTOVdO63Hc7Y+A8HL
	UIGsS1gMe77FaTPzA+JsqUPLYL4up2As3TzpXgeZGoKhu1rhJWwsD5zqkEe2QV04ZmfU5m4fhKA
	250fA+ygERxTzZ9iJjG2NmdKF2AANhgIuK6tZzbsXpqgVZHANbihUrNqsPqQqOCH1zhgxEmtuD/
	WMjB8oSEhxy05JPh6GL3LVDqu9BtIkOtu/2iAisC3VUc7fWuggE7+LTNMIEroK7TRvMIbDyosVy
	rWZax1zXQIodNAafBRZZRT/SdqYqmb8zv8S+dO1904f1BKlQjAxdelwADdJUc+IRdXyzdXKAgNB
	9wzXyWSCHWgaBdSMEobANlHxSGIQCBiVHbOz9qtsGNffHEuNUH5yqapkHfmVExprgFFkMDC6WNd
	7h18FqLwW/fQCWEMwLM9fjluOoExHVABAtscIMG7O3MzImFaK2A+C+vl0M2Uz076ht6K2Hc4
X-Received: by 2002:a05:6808:198f:b0:4bd:c8be:1e00 with SMTP id 5614622812f47-5640dce8abcmr7761101b6e.13.1793627819881;
        Mon, 02 Nov 2026 05:56:59 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fd95562sm7980806b6e.4.2026.11.02.05.56.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 05:56:59 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 4/6] pNFS: don't send _NOMATCHING_LAYOUT if still doing IO on a layout
Date: Mon,  2 Nov 2026 08:56:51 -0500
Message-ID: <5f2d55cf0b37301ebe0a14427ded84767daaeffa.1793627813.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793627813.git.bcodding@hammerspace.com>
References: <cover.1793627813.git.bcodding@hammerspace.com>
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

When a bulk CB_LAYOUTRECALL finds layout segments still referenced by
outstanding I/O, pnfs_layout_free_bulk_destroy_list() invalidates the
layout stateid, sets NFS_LAYOUT_BULK_RECALL, and the client replies
NFS4ERR_DELAY.  If the server resends the recall, then
pnfs_layout_bulk_destroy_byserver_locked() can skip layouts with an invalid
stateid, so the resend finds nothing and the client replies
NFS4ERR_NOMATCHING_LAYOUT with the I/O still in flight.  The server then
treats the layout as gone, and that I/O can reach the storage device after
the recall has completed.  The same happens on the first recall if another
path, such as a DS error, invalidated the layout stateid while I/O was
outstanding.

When answering a bulk recall, don't skip an invalid layout that still has
segments.  pnfs_mark_layout_stateid_invalid() reports them, and the recall
is answered with NFS4ERR_DELAY until the last segment is freed.
CB_RECALL_ANY takes the same path, so it also blocks LAYOUTGET on these
layouts until they drain.  This relies on "pNFS: clear
NFS_LAYOUT_BULK_RECALL when an invalid layout's last segment is freed"
to clear the flag once the layout drains.

The other walkers, used by reboot recovery and when recallable state is
revoked, keep skipping these layouts.  They send no reply to the server,
and reboot recovery would otherwise retry on -EAGAIN without sleeping
until the I/O completed.

Fixes: b85f562049cc ("pNFS: Skip invalid stateids when doing a bulk destroy")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
v3: test for remaining segments instead of NFS_LAYOUT_BULK_RECALL, so a
    layout invalidated by another path with I/O outstanding is also
    answered with NFS4ERR_DELAY.
v2: only revisit these layouts when answering a bulk recall, so that
    reboot recovery doesn't loop on -EAGAIN while the I/O is outstanding.
---
 fs/nfs/pnfs.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 08deb4d811e4..2d2904eb7d34 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -846,7 +846,8 @@ pnfs_layout_add_bulk_destroy_list(struct inode *inode,
 static int
 pnfs_layout_bulk_destroy_byserver_locked(struct nfs_client *clp,
 		struct nfs_server *server,
-		struct list_head *layout_list)
+		struct list_head *layout_list,
+		enum pnfs_layout_destroy_mode mode)
 	__must_hold(&clp->cl_lock)
 	__must_hold(RCU)
 {
@@ -854,7 +855,9 @@ pnfs_layout_bulk_destroy_byserver_locked(struct nfs_client *clp,
 	struct inode *inode;
 
 	list_for_each_entry_safe(lo, next, &server->layouts, plh_layouts) {
-		if (test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) ||
+		if ((test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) &&
+		     (mode != PNFS_LAYOUT_BULK_RETURN ||
+		      list_empty(&lo->plh_segs))) ||
 		    test_bit(NFS_LAYOUT_INODE_FREEING, &lo->plh_flags) ||
 		    !list_empty(&lo->plh_bulk_destroy))
 			continue;
@@ -933,7 +936,7 @@ int pnfs_layout_destroy_byfsid(struct nfs_client *clp, struct nfs_fsid *fsid,
 			continue;
 		if (pnfs_layout_bulk_destroy_byserver_locked(clp,
 				server,
-				&layout_list) != 0)
+				&layout_list, mode) != 0)
 			goto restart;
 	}
 	rcu_read_unlock();
@@ -943,7 +946,8 @@ int pnfs_layout_destroy_byfsid(struct nfs_client *clp, struct nfs_fsid *fsid,
 }
 
 static void pnfs_layout_build_destroy_list_byclient(struct nfs_client *clp,
-						    struct list_head *list)
+						    struct list_head *list,
+						    enum pnfs_layout_destroy_mode mode)
 {
 	struct nfs_server *server;
 
@@ -952,7 +956,7 @@ static void pnfs_layout_build_destroy_list_byclient(struct nfs_client *clp,
 restart:
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		if (pnfs_layout_bulk_destroy_byserver_locked(clp, server,
-							     list) != 0)
+							     list, mode) != 0)
 			goto restart;
 	}
 	rcu_read_unlock();
@@ -963,7 +967,7 @@ static int pnfs_layout_do_destroy_byclid(struct nfs_client *clp,
 					 struct list_head *list,
 					 enum pnfs_layout_destroy_mode mode)
 {
-	pnfs_layout_build_destroy_list_byclient(clp, list);
+	pnfs_layout_build_destroy_list_byclient(clp, list, mode);
 	return pnfs_layout_free_bulk_destroy_list(list, mode);
 }
 
@@ -1000,7 +1004,7 @@ static void pnfs_layout_build_recover_list_byclient(struct nfs_client *clp,
 		if (!(server->caps & NFS_CAP_REBOOT_LAYOUTRETURN))
 			continue;
 		if (pnfs_layout_bulk_destroy_byserver_locked(clp, server,
-							     list) != 0)
+					list, PNFS_LAYOUT_INVALIDATE) != 0)
 			goto restart;
 	}
 	rcu_read_unlock();
-- 
2.53.0

