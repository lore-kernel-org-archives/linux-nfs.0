Received: from mail-yw1-f178.google.com (mail-yw1-f178.google.com [209.85.128.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2477D3876C5
	for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 22:25:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.178
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786746350; cv=none; b=EC3LExzaXUUnyfcZ8C8Kw1gyHBztG8ev6lOPifqt5rdLoFG+cHnr69wAY+Ftcwyp3szgRvGKY9BFaTzad52JIQboIc3sCJV5pKBXik2olhAXOLI9XD92m9xGGZLWme/4n3A+fG9ILkMmWh7XEXyvsga/UCdv2t4Pbh2DBfEvANo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786746350; c=relaxed/simple;
	bh=DMJdiSD5U8AT2cI2O4jUZQHb/eheBbmYTwpW++1+C3M=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=B/cItj3f+RQoP9eeD07BX0rshzaHy1gosatXvEfBddGGiIX43CXo1QYeHNkIun23tEGaMmytkOCHWVVbgfzbk32DZ3Id9skWDkLGzbJ8SowF8kSeBFKIJL83t4+dgjZ711Fi+d/vNhk87vgvaqBUoyZaKPFUcbRrhizxVtVtKeU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=dnATp4IR; arc=none smtp.client-ip=209.85.128.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="dnATp4IR"
Received: by mail-yw1-f178.google.com with SMTP id 00721157ae682-836cda225c1so22218187b3.2
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 15:25:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1786746344; x=1787351144; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=lrqsLvhg/CxOI86B6O3H4IhUbUiJfTNZpqsBInKvA+A=;
        b=dnATp4IRrMJVVidPos06Gdj2D7pRoLtzMvvXAVIPxPNb8FLRnHH6QWDcDvmnEZKr3O
         MnRpvlwUlVEdf+EcJfyTcLkl9LRz422C2Try1P9ztmSIsaED79SfXpHsWQP6VtowQ5op
         AK2EmopGCNqwVjFTeBp91pj3zv0vlcX3LG2tgKOTNRgWU39labLu61cSsNJ3TY9Lg245
         HgwgqA/c9JiB4i0NP6566rY2Q+n7fntODHcT5WpQ3r2tv8Jz1HpgC15wAPXvaMhQ8FOf
         azTVBBdS1BxdBwo0xOAqPDrqALZtLgmDM4mPEqRZvH6LNnDoFFjauRWQctMwQLd2slTr
         +R3Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786746344; x=1787351144;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=lrqsLvhg/CxOI86B6O3H4IhUbUiJfTNZpqsBInKvA+A=;
        b=gCZndUNy2P7ldMLYM9sTXKxASu6jITTRNNIzEMg6LxD4azRBndlM7Vw2enGmjocmsP
         cOL6Mg62M5TI9cv0YXwFviWVyYVe7B4KbYgGc4YVuu3ggF9yek/yc4hYrh1SlZMvGVZ2
         OumtonZIV8jQwktP3uYwDZvA8kWgTaj82JgySTKyMEOFNVEBPQSiOaW7bl/sJ89snAAo
         1zgvMZaTF/ac44B719/THnVo/4hZK5ToEsXvh/gOINsJJJgN6jneWgHIM5tPYZn//y4c
         lloxpkfkIYX86weeHA6zYsKLJd1F+3K79s9sR0GMr9nXIJc+2JBu1E0NYw1AUxNJYZh8
         6vMA==
X-Gm-Message-State: AOJu0YxIQbXzA5NwL1QXQAl52xWBGZM4kQbmmEjKQ3L5GZBhsdqZr+i0
	4JW19o9nhNywDl46uFCobDeWwl7ZeTNFP2mSXJ9craLrY//xtcFZ0yWeHMC66vzgfQ==
X-Gm-Gg: AR+sD11Qbvq4oWlPQ8SPcol8NEwklWr5pusQoWYBGftkXSpNkz+oMv4VtslzC3IWMKh
	qmgPm7aaIMhqDR+ebB8TrQLgXRJKzLlnPUQCrMHbqcIQmsF3Sjib3HPvaNLz9aa1a1rYHKY1CB0
	UMlR3uY2086zurbfbyWiv9goxQSeN0X1vNw7qIfMjWRPfVIV5Nww/YzahdruGvnbdhOVP9pmog0
	qYdxTE1SR7kNeioMg4dYVJMknG6gtFje3EQpx+kVeOTYxjTNYEzsJLCqOZbwxS5wG5bS2a+wWu/
	Uw48Qi1ncbadlpnlEea2YtYHZgrs+dhJp+iYGVNdPu2ab08Thp8IR7Naq+5AsfhOEVjnKX7TGJ3
	iv6Rs3RlgA6QK4XjnD5DuiS8V6IGi98QriuuizX+FkH7Y4vlcoDVXpv2mKz+I+jlh5mIexHsXRz
	lqXzWDWH1EzDpkt34/l6AVApwQnvwJDW1/3FXsPyW8ePPHOoKFmlqK6pZDU/Kz
X-Received: by 2002:a05:690c:e18:b0:81e:514b:1b98 with SMTP id 00721157ae682-8370cc30942mr39322467b3.7.1786746343905;
        Fri, 14 Aug 2026 15:25:43 -0700 (PDT)
Received: from hamza-PC ([124.29.197.38])
        by smtp.gmail.com with ESMTPSA id 00721157ae682-836c1777c5esm19859857b3.26.2026.08.14.15.25.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 14 Aug 2026 15:25:42 -0700 (PDT)
From: Ameer Hamza <ameer.hamza@truenas.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com,
	ameer.hamza@truenas.com
Subject: [PATCH v2 1/2] sunrpc: treat empty auth.unix.gid replies as negative entries
Date: Sat, 15 Aug 2026 03:19:52 +0500
Message-ID: <20260814221953.108837-2-ameer.hamza@truenas.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260814221953.108837-1-ameer.hamza@truenas.com>
References: <20260814221953.108837-1-ameer.hamza@truenas.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When rpc.mountd cannot resolve a uid (getpwuid() or getgrouplist()
failure, e.g. while winbind or sssd is briefly unreachable), it
answers the auth.unix.gid upcall with zero groups. unix_gid_parse()
installs that as a valid positive entry, and svcauth_unix_set_client()
then replaces the credential's group list with the empty one on
every request, RPCSEC_GSS included via svcauth_gss_set_client().
One failed lookup strips that uid of all supplementary groups on
every export for up to mountd's configured TTL (30 minutes by
default), long after the NSS backend has recovered.

mountd cannot send an empty list for a successful lookup, since
getgrouplist(3) always includes at least the user's primary group,
so a zero-group reply can only mean the lookup failed. Record it as
a negative entry: unix_gid_find() then returns -ENOENT and
svcauth_unix_set_client() keeps the groups the RPC credential
already carries. This is the fallback that
commit 3fc605a2aa38 ("[PATCH] knfsd: allow the server to provide a
gid list when using AUTH_UNIX authentication") promised when no
answer is available, and the same state try_to_negate_entry()
already creates when no listener holds the channel open.

Fixes: 3fc605a2aa38 ("[PATCH] knfsd: allow the server to provide a gid list when using AUTH_UNIX authentication")
Assisted-by: Claude:claude-fable-5
Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
---
Reproducer (any server with rpc.mountd --manage-gids; 'alice' is a
member of group 'proj' *supplementary*, /srv/proj is root:proj 0750):

    runuser -u alice -- cat /mnt/proj/data          # ok
    # the reply mountd sends when getpwuid()/getgrouplist() fail:
    echo "$(id -u alice) $(( $(date +%s) + 600 )) 0" \
        > /proc/net/rpc/auth.unix.gid/channel
    runuser -u alice -- cat /mnt/proj/data          # EACCES until
                                                    # refresh/flush/expiry

Applies unmodified (fuzz 0) to every maintained stable tree, 5.10.y
through 7.1.y. Tested on a live 6.12-based server over NFSv3 and
v4.0-v4.2, with sec=sys and sec=krb5.

 net/sunrpc/svcauth_unix.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index aebd97e7f66c7..2f592ba54a366 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -540,6 +540,13 @@ static int unix_gid_parse(struct cache_detail *cd,
 	if (ugp) {
 		struct cache_head *ch;
 		ug.h.flags = 0;
+		/*
+		 * mountd sends at least the user's primary group on
+		 * success, so an empty list can only mean the lookup
+		 * failed. Keep the credential's own groups instead.
+		 */
+		if (gids == 0)
+			set_bit(CACHE_NEGATIVE, &ug.h.flags);
 		ug.h.expiry_time = expiry;
 		ch = sunrpc_cache_update(cd,
 					 &ug.h, &ugp->h,
-- 
2.53.0

