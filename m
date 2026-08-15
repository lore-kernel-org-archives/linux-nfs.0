Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7934D2E888C;
	Sat, 15 Aug 2026 04:29:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768179; cv=none; b=RP/pIsHdXcCz4fRPr1D4/E10L7wfNiyE3vmJExzCnGfncOY2R9uEGtyYyBazjO0em7hyOIH9g7yunBcXrbXvkU1O6Qprxu6CYcjhcdTIQ6M2sLE6sBB+iw4eRnJMCh2SUhdgd5qwlFymedUwSMarLrpyTWYH4s0oNOpi2t6OhpA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768179; c=relaxed/simple;
	bh=5uGTVSye3mf5dZIRBjYy2z/ZTSIaYWwrRnaJjtdebsk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MkchFR/HbrOQYV/YkpM0Ee4mqkt6Ng2/0hnEw4tx4k5hJvLUF31ABaOlK+uF46TDcDDO6mcn+r748Ufjte26VmrYHfh/7/UqT8UyjO4KR+ugsRlZMy+10NoWpK5u84C2w0DLZ9yOybsSk/azC4XlZsh/A7SIvTY5dKFlqEhOe5Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=An9Hi3FR; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=MpOLJi1K; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="An9Hi3FR";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="MpOLJi1K"
Received: from phl-compute-11.internal (phl-compute-11.internal [10.202.2.51])
	by mailflow.phl.internal (Postfix) with ESMTP id 91F731380411;
	Sat, 15 Aug 2026 00:29:37 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-11.internal (MEProxy); Sat, 15 Aug 2026 00:29:37 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768177;
	 x=1786775377; bh=xugvkkdASQjNIkrgB5+lqBJ1a48J5bnIdSUDy+kkN7k=; b=
	An9Hi3FRGYa4y7NQfa94yik5YeDMPbgDFTdk4flDun4WXLa84v5x/YzKvILDLSZM
	jm+neQD3xXylmsHoiNRPJky3xmbZKvCSJoILUZMr2DTKDsPE1LvXQZ1ydT29btLg
	GzIvvnIJPjOLz8zKKtickGVHAhtv/UpDiHECPaAlG7WTcylwZJFExh23FIwkW0dZ
	rp9kwt69NLHfcbxxL/RPk383ozC9qPV1FV1+5lFRRzdVx9P9NuledAjb3kJ8XgSZ
	fXUTGXClRr+YWufeWopyTQXPgcvAzf5ywPFZwe6ECIK73mg/AlncfgVjtcu0fJEo
	GK8LuPGW5hLIuQWIqwwQVg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768177; x=1786775377; bh=x
	ugvkkdASQjNIkrgB5+lqBJ1a48J5bnIdSUDy+kkN7k=; b=MpOLJi1KWGhuLp1Jt
	Pxn3fGpoXpHFBJyXB3F7pxgmCm0RMAQCTZhz66s1uwyOt89C/P5PorZLCP0mHhIg
	GfgIzcNVcZUOua5EtCfHQCGevRlFrO8bpPL3HpMqbcTuyYM7yCTa0q23s8wrVuVo
	BXCiFz2qw5vr0BkqnpW0tUAwc+pa614ymYjtSBXUkcz7TeS/aqfknm3wIxH63w15
	TNdz4BCxSIh6SC7OO+GtzPVgd6LFIU6YgDnHLP0Yn4Q+DOUVuZ4GM6OYT5UkQAKt
	ToKy/RX9mIniQ4En+tjtTkTk0vuju3CUOn0jR2T8eLIE+IuLDxm7t2KM5KE5CBMd
	/rs4g==
X-ME-Sender: <xms:Met_aglgceQcPHufRCvpdyG4PTqkkJFmQkO4Z5jINMs6hPx4izThCA>
    <xme:Met_aq0KtujyuJ-JPAy0YK6O50wn120I4yhSLX6CC7Zg8OEOY__4tCM6rGlsn4C57
    hzi9G8S1qnkfjNS7ovGy9jn7kqkiy-cPnindWVzsU_TGFBz2Mw>
X-ME-Received: <xmr:Met_alRMXk_JQUIfDR5ePBWnSV32jv5O5FHHoc3xdZzlozAj3QJjME2R0CY9SJQMu4cfwL2cZehzWbMXoBgraR_-NLXQabE>
X-ME-Proxy-Cause: dmFkZTEYOd3tLu5dATIbifwhlYvY0qyYOt7s1LgDprEXebOtP02E/NfWDhmB6dUHRD18Mw
    M/OVd5zhrG+UTD+zvSQphReiWNJaCd0AqwUD63tHfAJF2OAEGvFg1iC8SkfXHW4Cbq3Pnv
    XZPdOI+4XvyfDrMe9ntOWfnHEDm7Vl4MwVM6/98uzVFr9W5lPBzuk8llcQfOSsZLGGgf8M
    1akEE1al0EFoJJ4d9fnySO8LzXZFHrFib9IETFD1LEL7DAdqppQ7UcHFMAN4HHBzYumdeq
    UmiiM2nwa1tgBmTDGFT6cgwcylPb6+Qw0oEVRuLdEgoMQRjiQsSj7nR2Cv5Z5tDGgputOo
    kZ6J9sqBzCor7Zdx1pNuXjfKxQm5HAp1Iwc3l3RQQ89v72cA5wAIMhytU0LGNbulNUIj5K
    zwufoLCPJY9GPR96ITIx3uYtGZ3wM4gQBKR9yY5KhXBkEzsucIYfm9a9m0ZvDSbF/qkcLf
    8nz8u+7lS2nFeEa+8oKeb880/oU29jA4XiKcNMi6Kj3fEKOA9MEZiSH4mPlALmSZLpSL4D
    VE0GwLdfOTQZlr/hukwLqfiKM+6IUUg3If59HXotEfjK3dDmB9hqKw/CGarUSeex07Kvff
    qBpt7jZC+6ggK9JJYXXEbXhXv9URF+1KIT/1knbn7EPoxMe9F49OcxbaIA3A
X-ME-Proxy: <xmx:Met_aqMJc7iSsIbtInQ-xOfgXeMQCFitOfpd8MP_O0Ly3CKx3DIvug>
    <xmx:Met_apiy2G_H4uzEQPL6vZQ2hlX3MbELHhhMkMeLjIm2uMMViKKaMQ>
    <xmx:Met_aqLJehwwvfidrMTpQnVk2iQnpGGvKHgSd60nvhB_5jxs4dO7ww>
    <xmx:Met_ak6yEfdgyNgSKelPsdIZGyx_y3UyP3Wl7_7Q4634OuwOffN8Mg>
    <xmx:Met_asOw85uH6L3johhYNB92_DbubcSXp9edG0hnvImlNrmmIw_v4XXa>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:29:31 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Ian Kent <raven@themaw.net>,
	Chuck Lever <cel@kernel.org>,
	Jake Edge <jake@lwn.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	Jan Harkes <jaharkes@cs.cmu.edu>,
	coda@cs.cmu.edu,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Miklos Szeredi <mszeredi@redhat.com>
Cc: autofs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	codalist@coda.cs.cmu.edu,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2 09/18] libfs: change scan_positives() to use d_for_each_positive_child_continue()
Date: Sat, 15 Aug 2026 14:21:26 +1000
Message-ID: <20260815042707.2535717-10-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260815042707.2535717-1-neilb@ownmail.net>
References: <20260815042707.2535717-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Using d_for_each_positive_child_continue() simplifies this code
slightly and make is easier to read.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/libfs.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index c2b09e72cbd8..398fae675207 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -112,17 +112,9 @@ static struct dentry *scan_positives(struct dentry *cursor,
 				     loff_t count)
 {
 	struct dentry *dentry = cursor->d_parent, *found = NULL;
-	struct dentry *next;
+	struct dentry *d = last;
 
-	spin_lock(&dentry->d_lock);
-	next = last ? d_next_sibling(last) : d_first_child(dentry);
-	while (next) {
-		struct dentry *d = next;
-
-		next = d_next_sibling(next);
-		// we must at least skip cursors, to avoid livelocks
-		if (d->d_flags & DCACHE_DENTRY_CURSOR)
-			continue;
+	d_for_each_positive_child_continue(d, dentry) {
 		if (simple_positive(d) && !--count) {
 			spin_lock_nested(&d->d_lock, DENTRY_D_LOCK_NESTED);
 			if (simple_positive(d))
@@ -134,13 +126,12 @@ static struct dentry *scan_positives(struct dentry *cursor,
 		}
 		if (need_resched()) {
 			hlist_move_behind(&cursor->d_sib, &d->d_sib);
+			d = cursor;
 			spin_unlock(&dentry->d_lock);
 			cond_resched();
 			spin_lock(&dentry->d_lock);
-			next = d_next_sibling(cursor);
 		}
 	}
-	spin_unlock(&dentry->d_lock);
 	dput(last);
 	return found;
 }
-- 
2.50.0.107.gf914562f5916.dirty

