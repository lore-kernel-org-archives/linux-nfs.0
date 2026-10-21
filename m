Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.171
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792586548;
	b=4QssAqhO5F2qI0jAS+j1FrwTEuZdEw8I7RW5FbKwKUnrlGWpQ5kSm4G6udpyyLoyq6AT
	 WxaILNJJ15bphRz4w9588P+pLOLzxeWAikBfa5TZITZzIt4c4zCf2V6yPNCy4L+8/cacx
	 02yCcYQCOZYjK6HCKNcWibUkAZV25SeilZgPlwTJRjJu4r1rEVH3d+EPAgkDpUuZ4eLEr
	 1mcwALy1f/CKTw0luXrZs7+LsLGkDIN285cCj0+VdBF8C+4NCaBWGS93nhtWd/e8ui92n
	 1iwCqhAeUwJqqtOkR/DszN+LtUS2icmDl2GXVTJvJmoVAuk4ZyEaocK++UDI4n3Okow==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792586548;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=mOgsGiMnRqydr+A4ziFUgDnZIthLWMAhYc4fGHaFHTQ=;
	b=Yt8qkW5RKMfHMGLPLN5s/rtbcxTp1DY7QgyGMEbjXucubJLnL8DgMVjqXDYbSG9OcFFn
	 tw+ch1eqzIzQq3MHYLhxU+YVW1i2Q4D9UMRljQkdzqB7eGmbA/ErJ+yrxmAt+pAfA/Ng+
	 zdHwTjwiBQbmAe8Jh2V6OfrYy+T0IxhWSsakG5AdfRhfmPso1eut2F/+pBEYoaanYjiBP
	 c1TreCJYeTNpJWMCdZXkPHci+XnrdCJKVz/lxopuPJLkImlqp/bn8K7OvcqNUWQy/Cgkk
	 n8AEmdowJRcscPRyW0mfrSWHFnRdPoK2w9+0U3zfvs1x7HZs5yn6ARhfwZip6ngee+Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=b1lbUpmM;
	arc=none smtp.remote-ip=74.125.82.171
Received: from mail-dy1-f171.google.com (mail-dy1-f171.google.com [74.125.82.171])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B458606A31F
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 12:42:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5B458606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=b1lbUpmM
Received: by mail-dy1-f171.google.com with SMTP id 5a478bee46e88-36681e85e87so1317586eec.1
        for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 05:42:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792586547; x=1793191347; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=mOgsGiMnRqydr+A4ziFUgDnZIthLWMAhYc4fGHaFHTQ=;
        b=b1lbUpmMFxuTO6ij4qyGWtZQVHaQ9ydbs6I4vbnKpWBSL23FPOwrIeWI3TQNqjqsKk
         Ey1NalXyLjQLczURc7Oa/9ARsdlO/eEFNRfxwAr4y7DvX0qdyRuP9O+AIqle8w4xLwNU
         daPUcaK8trj+NKhyTaOFM8SagW9qIvk0NB9RUtGD+WfzZxRhWRze0OgfUkFZ23GPXuZ5
         YJ6xnto+3zV/TCfruncP0/fcqWYPiRpuNxfTIjELpsG6YLBMN1ASScs6PUJrJwzZs8WV
         80FSM9M0PEz9jLf6qZ06Urmk3idTgwFzICii/VX4eDOqSkR05l3LdYO7MX4JuzO3TJsk
         fyIg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792586547; x=1793191347;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=mOgsGiMnRqydr+A4ziFUgDnZIthLWMAhYc4fGHaFHTQ=;
        b=uEAE4sCDKs51X5EQ9i0plI0OwMPn+WMgHIGIz4e3zCgT2bMlf8N7sAm9Ohd8jvepQB
         DrbqIdklNTvI8HefpJCxQhhYa3jzAU7wbqot1+iBNJ6/xPo8SQyxLBMyhoQrnRtmRL2r
         Zk0zOQgkTVN0wbz0sDP0ydmkfU/Qln1J8U8QO9ELXCaHIKiNbOR0c/ncPfg67GnoyYFy
         UJVFV6oGkNWefrsDPzjFvOOIXKBQ1xdsE6M/ZubwyABnJywttrlFVOI+hXIuT8g3kUA6
         2W6XYjESAnEUqbJ8cbQ84Qicv4OSxwUC50P64SG8WoJsladZYAELZ0k9/QLJnC9Kzej4
         F0nQ==
X-Forwarded-Encrypted: i=1; AKwUvBxbPO7ENPO9Gh0T1SzXG/I0nFT/kZ+Y5+2Buv3m4HTqPnvOlaOIyCEpH1PAr3l6RNk1/Zu1OKqB5Ko=@vger.kernel.org
X-Gm-Message-State: AFq9FYKB0++cKujeOGdMDAq8rfbOfwADFB0M9ZfeuL7SrzZSQiEPzS0a
	l1wpC5tbSSKNVizjmf5aSCQBJJNemGTCmSPrAvWVfMSNZV25Ok97QaJ/
X-Gm-Gg: AYBFou1qZaTNOOSD86n5GM4WZKn6TE1qdJW9KjVbsKVdfirkbDzgzT2DhRGCSQ16tl+
	UGfAJAW9Q3egtJQPtt6rwR4Ikm7+26Pg0tGp0yiT0qFMEq4Kmn9w/Si+Wd15bWKIKIknjllq5eK
	UJIMbqz3ciUZ5FA45USwU35gpOCl6rJNTh+YLnjxjvYHXISBfrdbvq69e7+GB6dl6LUZ07+ZmeP
	3xomSrbPJWIbOBv86DTDN+UVa7EsAEfpGwV8w7x51h2WvcVJT/iVFQ8D20cWx0a0W6kLc/YcS/d
	36uHzEv+tIqI7pTUO25i3xaDhbjqb71Ok8uN1A3x1f8pVQyJqhiOFp3wW5K0x38KFIyX9gdd9nd
	3c0rePxcxglkWDnKNjNy5+Dszwz5DkqxxkkTkKt0sgXKDQNZjkj5BBQI+UmgMN8hiRsbqPxksNT
	GZfTuZXbxXVPEX0ABUvi3GJsLLCpPOtIG5T7sCqVTu+mQs3h65N43BG/VL6jfilp9v571fxf/ip
	WdnToHG09Z3rb23V+8oEaZayClJShX4hmI/AOe4XVw7oaSF3YTDRWw1wjaNqo9wM0/z6ewyu8fR
	OhDezDchg021e+YDT/xS++FUG0M5URU+k8CoYH0XoeWp
X-Received: by 2002:a05:7300:d0a:b0:361:7ab9:479d with SMTP id 5a478bee46e88-3674e8400femr4275517eec.27.1792586546917;
        Wed, 21 Oct 2026 05:42:26 -0700 (PDT)
Received: from deepanshu-Legion-Pro-5-16AFR10.. ([2405:201:682f:383f:910:a1c0:2063:d1bd])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-36741f753f7sm6951759eec.27.2026.10.21.05.42.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Oct 2026 05:42:25 -0700 (PDT)
From: Deepanshu Kartikey <kartikey406@gmail.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	trondmy@kernel.org,
	anna@kernel.org,
	davem@davemloft.net,
	edumazet@kernel.org,
	kuba@kernel.org,
	pabeni@redhat.com,
	horms@kernel.org
Cc: bfields@fieldses.org,
	skinsbursky@parallels.com,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Deepanshu Kartikey <kartikey406@gmail.com>,
	syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com
Subject: [PATCH v3] nfsd: store net in svc_serv instead of deriving it from sv_permsocks
Date: Wed, 21 Oct 2026 18:12:13 +0530
Message-ID: <20261021124213.6288-1-kartikey406@gmail.com>
X-Mailer: git-send-email 2.43.0
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

nfsd() derives its struct net from the first entry of
serv->sv_permsocks using list_entry() without checking that the list
is non-empty. If the list is empty, list_entry() returns a bogus
svc_xprt computed from the list head embedded in struct svc_serv, and
the following perm_sock->xpt_net load reads past the end of the
svc_serv allocation:

  BUG: KASAN: slab-out-of-bounds in nfsd+0x118/0xbc0 fs/nfsd/nfssvc.c:894
  Read of size 8 at addr ffff88802d423f50 by task nfsd/5988

Rather than validating the list head before referencing it, store the
net in the svc_serv when it is created. svc_create_pooled() is only
used by nfsd, so add a struct net argument to it and record it in a
new sv_net field, then use that in nfsd().

Fixes: 88c476661719 ("nfsd: pass proper net to nfsd_destroy() from NFSd kthreads")
Reported-by: syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=561b859d032c8bf2fb53
Suggested-by: NeilBrown <neil@brown.name>
Tested-by: syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com
Reviewed-by: NeilBrown <neil@brown.name>
Signed-off-by: Deepanshu Kartikey <kartikey406@gmail.com>
---
v3: reword commit message, fix stray whitespace in svc_create_pooled()
    prototype (Neil)
v2: store the net in svc_serv via svc_create_pooled() instead of
    walking sv_permsocks under sv_lock (Jeff, Neil)
---
 fs/nfsd/nfssvc.c           | 5 ++---
 include/linux/sunrpc/svc.h | 2 ++
 net/sunrpc/svc.c           | 3 +++
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 2edf716ea022..06a756d5636c 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -620,7 +620,7 @@ int nfsd_create_serv(struct net *net)
 		nfsd_max_blksize = nfsd_get_default_max_blksize();
 	nfsd_reset_versions(nn);
 	serv = svc_create_pooled(nfsd_programs, ARRAY_SIZE(nfsd_programs),
-				 &nn->nfsd_svcstats,
+				 &nn->nfsd_svcstats, net,
 				 nfsd_max_blksize, nfsd);
 	if (serv == NULL) {
 		percpu_ref_exit(&nn->nfsd_net_ref);
@@ -890,8 +890,7 @@ nfsd(void *vrqstp)
 {
 	struct svc_rqst *rqstp = (struct svc_rqst *) vrqstp;
 	struct svc_pool *pool = rqstp->rq_pool;
-	struct svc_xprt *perm_sock = list_entry(rqstp->rq_server->sv_permsocks.next, typeof(struct svc_xprt), xpt_list);
-	struct net *net = perm_sock->xpt_net;
+	struct net *net = rqstp->rq_server->sv_net;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	struct nfsd_thread_local_info ntli = { };
 	bool have_mutex = false;
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 2db1b9ec5658..49a5052b2670 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -72,6 +72,7 @@ enum {
 struct svc_serv {
 	struct svc_program *	sv_programs;	/* RPC programs */
 	struct svc_stat *	sv_stats;	/* RPC statistics */
+	struct net *sv_net;		/* only set for pooled (nfsd) services */
 	spinlock_t		sv_lock;
 	unsigned int		sv_nprogs;	/* Number of sv_programs */
 	unsigned int		sv_nrthreads;	/* # of running server threads */
@@ -461,6 +462,7 @@ void		   svc_exit_thread(struct svc_rqst *);
 struct svc_serv *  svc_create_pooled(struct svc_program *prog,
 				     unsigned int nprog,
 				     struct svc_stat *stats,
+				      struct net *net,
 				     unsigned int bufsize,
 				     int (*threadfn)(void *data));
 int		   svc_set_pool_threads(struct svc_serv *serv, struct svc_pool *pool,
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 8297bad2b177..810c2db27fe3 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -481,6 +481,7 @@ EXPORT_SYMBOL_GPL(svc_create);
  * @prog:  Array of RPC programs the new service will handle
  * @nprogs: Number of programs in the array
  * @stats: the stats struct if desired
+ * @net: network namespace the service belongs to
  * @bufsize: maximum message size for @prog
  * @threadfn: a function to service RPC requests for @prog
  *
@@ -489,6 +490,7 @@ EXPORT_SYMBOL_GPL(svc_create);
 struct svc_serv *svc_create_pooled(struct svc_program *prog,
 				   unsigned int nprogs,
 				   struct svc_stat *stats,
+				   struct net *net,
 				   unsigned int bufsize,
 				   int (*threadfn)(void *data))
 {
@@ -502,6 +504,7 @@ struct svc_serv *svc_create_pooled(struct svc_program *prog,
 	if (!serv)
 		goto out_err;
 	serv->sv_is_pooled = true;
+	serv->sv_net = net;
 	return serv;
 out_err:
 	svc_pool_map_put();
-- 
2.43.0

