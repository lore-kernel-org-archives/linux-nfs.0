Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.69
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795116201;
	b=YNZOSpHC61MHreE/9JTxjTJjqCIafTMGbCleITKdHVDWYw+Xth+OdyhRlhmCANpm/8KZ
	 YxD/aRqpQz2SYRuGKa+o/EziHN/DllTrKGzpxnsyWJBbav4hpqMEcAKwd4blXdMYDA5eL
	 oocgO0EWNxA0DIK/jsza6/h0CSTeESIjnlHa4JafUKVy8JJ/u+RmvBOc76c1qqXnP9dzq
	 E4ttvyncC1EHgPz9enN7exTC5ccnHgogKlzknM0sg2fmWnb7SjjrYy0ZUpj9ipC5e2q54
	 eHFMRYp0AFPlkLIErqNDiz4qedi9cg5VEo3oiLSSKXdFdC+2W1dCTXteYtoff/l1mwQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795116201;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:Mime-Version:
	 X-Mailer:Message-ID:Subject:From:To:Cc:Content-Type;
	bh=h4YJthMhqVB9D8F3jj1w/SnnmoOG5f7jlRAWDoCoDG4=;
	b=3yR8M1wqpGcHEp/c5GXBm8rB5U1QI/v49Zaa4MXwbYRUBCmez0xk313Pg8RwLCXQt7Me
	 IdRjQyQh3oUi5+mL2NYjrSiOiN4/2lkq17mLJbKo+DrxyIN49AXrsYBE/U9WmN6ATnRJx
	 twKSCv5cN4SGvUR7tabIKa7R25kPP1XlL8DHpLxQqLIo8LiQj48vTCWzFfdbidVcidiLF
	 bODAaVhOHDIi1j7i7A3kRo4ltet6UvElR//VZxWiXfWrJHCxZXPs3ChmI9BdJLL6h3v5Q
	 VJPudwbNQreUGjP6IV1fnBrBGxF18qXxXxn9IMW9tFrQf9yNlKINYO44nLnFRPq4PGQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=MhTGSC86;
	arc=none smtp.remote-ip=209.85.221.69
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BCD95606A324
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 19:23:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BCD95606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=MhTGSC86
Received: by mail-wr1-f69.google.com with SMTP id ffacd0b85a97d-48c6a1d4034so32401f8f.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 11:23:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795116199; x=1795720999; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=h4YJthMhqVB9D8F3jj1w/SnnmoOG5f7jlRAWDoCoDG4=;
        b=MhTGSC86y3kz/HqDnwjQWvrcI+sP7cvQXCvsTJrU4Qmvi4j+ntbptJTQ+PiHkgPWCX
         HSIV1pVtLJQaIHEsad9mPC87Qv2wT0fdwtOwnF8wgUMMegF5mWxZjq9WLB/+BP+U0om1
         x5TaWwn5CEP0yHB/OrZuFLK55BfwYp0Wa4K3w+DR3huKb/Bmih9Hh727nJGW6Nupni4S
         wfYXEAX4zPrZN+3lM5/gw3Nvbrmgpg6oz00MYt2dQLv+MgvqF4QaK0SM9hoCiXOi6D2p
         8532BkLMeXbfJ6s/niE1GVPX8PMYju9twAi9OjW8TXm+NZLmDeRPPHY6I51Nygyuy8hT
         4bnQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795116199; x=1795720999;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=h4YJthMhqVB9D8F3jj1w/SnnmoOG5f7jlRAWDoCoDG4=;
        b=On3iSX02RCm0T/+xpHr1m/dVwMbAwy/OoKJgZqvIsbdtQKnl8SdraPL4vXwplLQgna
         N55pb6uAslBl3vlqD4adOGc5023fDoiEzDZIhuPsFyC+tc9GrMGyCwGmbhMI4B1JMg0C
         Rh38qmWrZJXEWgLYQmzhBGWFn5MSMZfRVKTRPgAoWf/nhcWGuCumqpfF1WeN2sgNsXjD
         CJYKDVrV3KGAyul9t2zv55GUg7xBtqoSZK8SfJDCm0kLDTMpBEV9ll5NjBIia9Yu0Sgj
         5jpmqIWIqpO8GHtGmTj7fec/bdhi0+LALnifOSgJrDIfXlF38AcXDXfq7kDkmn5zPjtO
         3QKQ==
X-Forwarded-Encrypted: i=1; AL+hErHmnMdwvphxeMsjyBKXGOfZmpCKg6TIUYT4DrMa+5PIaVuL8FAYj3zqc492b25x5D+TywdOHhKcdpA=@vger.kernel.org
X-Gm-Message-State: APuU4Z+pZLLjyzTN7C83bmvMQwqDdxRm1PDogXBVkXwQY+SfGopRNfRC
	/t95lrUD13SvFwoPtoDHhL1PNgz/jxlD/s23qQCNKqiHkrA3JQEpk1Zz1cSCvOUD48j1MvPxoQ=
	=
X-Received: from wmat14.prod.google.com ([2002:a05:600c:6d0e:b0:4a3:5d77:a650])
 (user=dmnk job=prod-delivery.src-stubby-dispatcher) by 2002:a05:600c:c168:b0:4bb:81b2:c801
 with SMTP id 5b1f17b1804b1-4bb889238f1mr11194355e9.20.1795116199146; Thu, 19
 Nov 2026 11:23:19 -0800 (PST)
Date: Thu, 19 Nov 2026 20:23:18 +0100
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
X-Mailer: git-send-email 2.56.1.809.ga0b61035b5-goog
Message-ID: <20261119192318.2689409-1-dmnk@google.com>
Subject: [PATCH] nfsd: require NFSD_MAY_EXEC when acquiring directory delegations
From: Dominik Maier <dmnk@google.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
	Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, dmnk+artist@google.com, 
	Dominik Maier <dmnk@google.com>
Content-Type: text/plain; charset="UTF-8"

nfsd_file_acquire_dir() opens a directory on behalf of
nfsd4_get_dir_delegation() with NFSD_MAY_READ | NFSD_MAY_64BIT_COOKIE,
omitting NFSD_MAY_EXEC, while nfsd_file_do_acquire() unconditionally
ORs NFSD_MAY_OWNER_OVERRIDE into may_flags even for S_IFDIR (unlike
nfsd_open(), which restricts NFSD_MAY_OWNER_OVERRIDE to S_IFREG).

On a directory that grants read permission without execute (search)
permission (for example mode 0744, where LOOKUP is denied with
NFS4ERR_ACCESS), an unprivileged NFSv4.1 client can still acquire a
directory delegation requesting NOTIFY4_ADD_ENTRY and
FATTR4_WORD0_FILEHANDLE. In addition, NFSD_MAY_OWNER_OVERRIDE causes
nfsd_permission() to return early before inode_permission() for the
directory owner, bypassing missing execute bits (such as mode 0400 on a
read-only or immutable directory) as well as POSIX ACL or LSM search
denials. When entries are subsequently created in that directory,
setup_notify_fhandle() constructs and signs valid child filehandles in
CB_NOTIFY callbacks, allowing the client to open child files without
search permission on the parent directory.

Add NFSD_MAY_EXEC to the access mask in nfsd_file_acquire_dir() and
restrict NFSD_MAY_OWNER_OVERRIDE in nfsd_file_do_acquire() to
type == S_IFREG, matching nfsd_open().

This issue was discovered by an AI-assisted code review tool (ARTIST)
and validated in QEMU against an unmodified v7.4-rc3 kernel without
kernel modifications or error injection. A standalone reproducer is
available on request. The fix was build-tested with KCFLAGS=-Werror and
checked with checkpatch.pl --strict.

Fixes: 544a0ee152f0 ("nfsd: allow filecache to hold S_IFDIR files")
Fixes: c10ce74117ad ("nfsd: add the filehandle to returned attributes in CB_NOTIFY")
Cc: stable@vger.kernel.org
Signed-off-by: Dominik Maier <dmnk@google.com>
---
 fs/nfsd/filecache.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 17a94e6..f9cf0bc 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -1183,13 +1183,14 @@ nfsd_file_do_acquire(struct svc_rqst *rqstp, struct net *net,
 	__be32 status;
 	int ret;
 
+	if (type == S_IFREG)
+		may_flags |= NFSD_MAY_OWNER_OVERRIDE;
 retry:
 	if (rqstp)
-		status = fh_verify(rqstp, fhp, type,
-				   may_flags|NFSD_MAY_OWNER_OVERRIDE);
+		status = fh_verify(rqstp, fhp, type, may_flags);
 	else
 		status = fh_verify_local(net, cred, client, fhp, type,
-					 may_flags|NFSD_MAY_OWNER_OVERRIDE);
+					 may_flags);
 
 	if (status != nfs_ok)
 		return status;
@@ -1457,7 +1458,8 @@ nfsd_file_acquire_dir(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		      struct nfsd_file **pnf)
 {
 	return nfsd_file_do_acquire(rqstp, SVC_NET(rqstp), NULL, NULL, fhp,
-				    NFSD_MAY_READ|NFSD_MAY_64BIT_COOKIE,
+				    NFSD_MAY_READ | NFSD_MAY_EXEC |
+				    NFSD_MAY_64BIT_COOKIE,
 				    NULL, S_IFDIR, false, pnf);
 }
 
-- 
2.56.1.750.gf70dc682cf-goog
