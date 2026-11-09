Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.151
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794185728;
	b=48qZRVoS66QKerWx4wJPlGd+EbEuapVfL8KLXeqrcyWY9g4zTm92z3hndl4167JqEKO0
	 UpucJlX8986mfBnYG+sK+4qqs7he47cLhRJ84bKe5PmwKVen48bc9Q/f55MX+ph2kPsx+
	 /ouPawROtrUtBDX8Vyg49s3A4swWpQf2gRorrP5kQY+IXbHl+AUYQdJh0SlPG5kB0hCZJ
	 tC70SErx1NgosgigAQ6Wk4w+S+Mmnmi0X+XEU7msUz/2x5au1Tl5Gg7l3NvM4yOdA5FdX
	 ZP+6RvMkDFf5Y4NtfvuKFgFWbclTFUYI2mklDDRjU/kNvl4kXTLQf/d3W9P/JDol3Mg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794185728;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=HQarN0BU43fLOpnShPSSmEsT7r+n0WS5QecPDHdlPis=;
	b=ihSqdt+tP65qsgcblv90nfT0pE8NV+qkaD8HCVP2iNA9oo8V30oQqFQJUow3W/LXByY0
	 ez/WraeynUoacGAX4cTxXfyLnJl0msJupt9URwCx/fv8uDsc+71OWCzQmPQ2x+bqgve6v
	 Tgl1e3oOo60FvsR89pnOLOpts6r/nXZ8uHjg2TLD+T3asg45OsQcPVguGwQM/mbSYzSyT
	 yYe7TgcRhHWBGBJx/R3T68FlL3Ddk0fxruzFZzTdZg+mWuuGn1TGSwI7yCOoRf/eWIdJl
	 CMxWRxyu7OSYTAKjqXuUWhYB1C3b/Aex80FRm+QG76yuohQeEQh87D1cq2I7jZXkhYQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=bP1gi2ks;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=bpBMlx6C;
	arc=none smtp.remote-ip=202.12.124.151
Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 06293606A320
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 00:55:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 06293606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=bP1gi2ks;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=bpBMlx6C
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.stl.internal (Postfix) with ESMTP id 51BE71D00044
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 19:55:27 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Sun, 08 Nov 2026 19:55:27 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1794185727;
	 x=1794272127; bh=HQarN0BU43fLOpnShPSSmEsT7r+n0WS5QecPDHdlPis=; b=
	bP1gi2ks2zAsBwEyGNvuQZPOrvaqC+9CLUg6jTOWP8LoP/AAd0KtyU+gvV+PKqNX
	m+AiB9S0NWk4PIKllZw8wEXUgdrwHoZ73wGmGz+C391LaG7yBUDbqV1IzqPpaVxe
	GAwv/dWEitAtF4crOw1GUTGoe544WzPa2LHwgDO0vnObnQ6CqGrzS8f3qyjVxLjW
	4JlElKIi5gUELm78V9QjDeM1flGCSmuamDYygY/gqYI2TcV/wE65BkAVWiEMoQ+e
	206cwxIiBfr83Eq431KDyQfhbdq0bAs9r69HAziM7xf/5UTVKj8E5tO5h//edw96
	sCT/2PjuY5XI9HAbTlnbLg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794185727; x=1794272127; bh=H
	QarN0BU43fLOpnShPSSmEsT7r+n0WS5QecPDHdlPis=; b=bpBMlx6CCITFHGT1w
	NlUFOS2SPy2T36HqONtgWVyv+Kj+2Wgka9Lgnqa7BAadw/1gZxXvidXVqF8A1mUZ
	L/cEbg+xTs2bad+Tz862smT5IdDKLAZ8b1P9QS5UXWtnE8S4N9An+jWFtB0jBPSB
	JtSLBU4Zolo0EaHBtVoRO9uAd8nWh9PuqiUY+E/XNlnUh26isPbfxJfPevFtiRR1
	8yFQyotyRqqytjM24GhVuFllBzLX9WSG3D+rEJpu/F1pcyD0VHxVXGht4Fcj+ro4
	EYfwtHELndPIoho2/FUS4Rfot7sOiOzkVZ4ExprFfBMHcw4bABSYJ7cb3ttj0XKe
	TU9/w==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794185727; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm3:rsa-sha256:WDiofDnB4/kQeMiC9snmSA0tnDKPzNIzgdqT3IxZH/PRcHb
	Bi+IB6X2bx1IiPtFEUYL6DYwISABk1ZJIS/eUfDUHUt66VU8r365lMVR+mBJkB1b
	fIKNG3V5hI9+XG8DktWdzG6DH6hts9MIoA4hkbK0KdZqzvgb6mMPbnZW8nYfFDcb
	D6iBuI3lN1FVfhIwwS+KcAI+NYiFkRMWeAFxKhrI6VI2DQuNdfoYtsz+Mj+ZeQhT
	O/U3Nj9Z4xmSMz/EDCFxE5aQG5HuFkDo1dGbSJmBAlK1J7wtJDYmA7zbd3sX1Y2h
	EF41iRgyCO7y33t2bqxGnXF5+l82EE2OYAZcPgA==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:sy+v74QftN92QOS4pUpe0WdnlULtzE8xWIi57Bgew4w=:+XrVf/kBH/OKnYzroHS3IrW1UhcMBtuaEGqYcdyzhAU=;
X-ME-Sender: <xms:_xnxah7fQm6drBF2VbhM26xXxh_H1P4kcY86rvFlJkD1wdmXQ3q4DQ>
    <xme:_xnxalzawtXY7giAT-9cTyB4kXLUpo2uevdaoM3ZpllqUgfA70YO_ZibfdR-CBO2_
    zhZX-S1wuVjG-AgEFdoE5nlfp0PulM9Mv4Lkfnkben5Fj3_ttk>
X-ME-Received: <xmr:_xnxagw0CMzuz5r6Ec4Q0ShvsGwwgJtqc_KEuKV6n6T7EwFWau3Knpndm7hRTW7nQqf1-VrEZ4xI1TVNsYS03PgviTsXsUo>
X-ME-Proxy-Cause: dmFkZTEPgGX5rX4Ucy9bGCLV0zpjHv/7YUdO1BRO67uZ1TFyuKYxCDG+4cdOWOhtgfjVze
    PVutz9cU629FCOHBFtt+de+rIg9CTtjPxcMAwoe89DxXO7xZ3r6p8v2MFYVVkYRHXDz9Mh
    gCqeLaxurlcJDCrh2IxfeOOcNpJi0oApyeWdeKNVmshFa8D5ijJLsAPSLpBjZTF8VS50oQ
    7YX9Mp9zFmAY/0AQPNMv7wQaDLZNFeJjTyFOACwXaYbK/XeBnGqeE9LlOcxaVXym2HhfGv
    R642p73EynQMSVnPBS0569H6Gxw1QWkN15W/8hF5kTbO3qt/StZeLJIrydtR7wkXRjnNPk
    x9BsBcC6xuacWPd4E0sZn4gXosXvyieXtfoZU0UixDXkSaXlib5nbV7V2q7c/wWNWgRCi5
    NhgsQwd1td+JXpWaRjtvekHuzDLIKXZ+MQ8va4QnxB1c89ALnkyhg1v1JQtEfT9oQDJQZR
    7Y5hTRzKQ4cHDqsz8s0loTEYTpAKOmzfntV3hbqV8EcxJx+1FHKynUp/YYkpko3Kld0BnG
    G2DAiW+/UGqEfnOvNjVErvL5/O99dDVIZBsjCn7ZLNSlZpiSbpm7LnSRJLPKPWpLQraiSa
    /1Xh6AX43f6gQJ/tZxChZ94v0oxWhADUkSVxeQ0Ay54sa/chc4f4B6wGttKw
X-ME-Proxy: <xmx:_xnxalwb8iZhgwp_Qju9-hqZyHkYEqXqsJkAsjTZEedWpz98msxoVA>
    <xmx:_xnxaiYLkE-tnB-gpBck_9wm867kP0MNJL1ymuIgQGS-rCMBTIEVsg>
    <xmx:_xnxauU8XYlE29lLN2OPYGOok_f69DXmLSfn7sSmzbZOrDAu0fyAog>
    <xmx:_xnxaojzvVDMGmcrpQoZZQID9CHXu6DjEXJxTMtQOHqDsBfpdiTghw>
    <xmx:_xnxah-5XbH8IdHl45aS6HwDvjCceJTDd1KbCKDlb0JKi6e8kPVll5Nz>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 8 Nov 2026 19:55:25 -0500 (EST)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 2/8] nfs: remove d_drop()/d_alloc_parallel() from nfs_atomic_open()
Date: Mon,  9 Nov 2026 11:52:31 +1100
Message-ID: <20261109005504.1804605-3-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20261109005504.1804605-1-neilb@ownmail.net>
References: <20261109005504.1804605-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
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

From: NeilBrown <neil@brown.name>

It is important that two non-create NFS "open"s of a negative dentry
don't race.  They both have only a shared lock on i_rwsem and so could
run concurrently, but they might both try to call d_splice_alias() at
the same time which is confusing at best.

nfs_atomic_open() currently avoids this by discarding the negative
dentry and creating a new one using d_alloc_parallel().  Only one thread
can successfully get the d_in_lookup() dentry, the other will wait for
the first to finish, and can use the result of that first lookup.

A proposed locking change inverts the order between i_rwsem and
d_alloc_parallel() so it will not be safe to call d_alloc_parallel()
while holding i_rwsem - even shared.

We can achieve the same effect by causing ->d_revalidate to invalidate a
negative dentry when LOOKUP_OPEN is set.  Doing this is consistent with
the "close to open" caching semantics of NFS which requires the server
to be queried whenever opening a file - cached information must not be
trusted.

With this change to ->d_revalidate (implemented in nfs_neg_need_reval())
we can be sure that we have exclusive access to any dentry that reaches
nfs_atomic_open().  Either O_CREAT was requested and so the parent is
locked exclusively, or the dentry will have DCACHE_PAR_LOOKUP set.
[Note that when nfs_neg_need_reval() returns 1, ->d_revalidate returns 0
 which triggers invalidation].

This means that the d_drop() and d_alloc_parallel() calls in
nfs_atomic_lookup() are no longer needed to provide exclusion

There is still a d_drop() which allowed d_splice_alias() to succeed.
This will be removed in a future patch.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 30 +++++++-----------------------
 1 file changed, 7 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index cee2d1dbb84a..de8d0be9a8a6 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1656,6 +1656,13 @@ int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
 {
 	if (flags & (LOOKUP_CREATE | LOOKUP_RENAME_TARGET))
 		return 0;
+	if (flags & LOOKUP_OPEN)
+		/* close-to-open semantics require we go to the server
+		 * on each open.  By invalidating the dentry we
+		 * also ensure nfs_atomic_open() always has exclusive
+		 * access to the dentry.
+		 */
+		return 1;
 	if (NFS_SERVER(dir)->flags & NFS_MOUNT_LOOKUP_CACHE_NONEG)
 		return 1;
 	/* Case insensitive server? Revalidate negative dentries */
@@ -2129,7 +2136,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 	struct inode *inode;
 	unsigned int lookup_flags = 0;
 	unsigned long dir_verifier;
-	bool switched = false;
 	int created = 0;
 	int err;
 
@@ -2174,17 +2180,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 		attr.ia_size = 0;
 	}
 
-	if (!(open_flags & O_CREAT) && !d_in_lookup(dentry)) {
-		d_drop(dentry);
-		switched = true;
-		dentry = d_alloc_parallel(dentry->d_parent,
-					  &dentry->d_name);
-		if (IS_ERR(dentry))
-			return PTR_ERR(dentry);
-		if (unlikely(!d_in_lookup(dentry)))
-			return finish_no_open(file, dentry);
-	}
-
 	ctx = create_nfs_open_context(dentry, open_flags, file);
 	err = PTR_ERR(ctx);
 	if (IS_ERR(ctx))
@@ -2235,10 +2230,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 	trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
 	put_nfs_open_context(ctx);
 out:
-	if (unlikely(switched)) {
-		d_lookup_done(dentry);
-		dput(dentry);
-	}
 	return err;
 
 no_open:
@@ -2261,13 +2252,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 			res = ERR_PTR(-EOPENSTALE);
 		}
 	}
-	if (switched) {
-		d_lookup_done(dentry);
-		if (!res)
-			res = dentry;
-		else
-			dput(dentry);
-	}
 	return finish_no_open(file, res);
 }
 EXPORT_SYMBOL_GPL(nfs_atomic_open);
-- 
2.50.0.107.gf914562f5916.dirty

