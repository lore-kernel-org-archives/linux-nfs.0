Received: from flow-b6-smtp.messagingengine.com (flow-b6-smtp.messagingengine.com [202.12.124.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0A1362E62B7;
	Mon,  3 Aug 2026 01:38:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785721090; cv=none; b=WhSEw5jK6g8iRWsUFtqJA+nDeDSlPj8wx9ETEaPXbjCGKK/w5CqdnyMmb/QL9rquGDUD9jJX+dt47AO71qUqf/x7gQG3Qs3FwbxXNBj7ymFdind55w8vmha8czqbQQYMH4MtsUcMoYpsHFUZRq7vmOYSkETPpYR7damfQh52Pr0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785721090; c=relaxed/simple;
	bh=aB5XCh3sI7aPq9H6AooS1XuOPKUD2qGI9YwuJoSTcww=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uCMVG2aneirHIYaam1B/Rs+4laydRD/mtM8yiZBvAUsq2j2a7Ra5sIB56b7wNiI6LppLxiMhl8lDoug1vfYAHrhBb8+bR7PjQiPxNIIHBuCwkesj+VTMveSuIyl2avyggrGqKWo2k/zmqk7l9fYEWK1alRHUJ/8WzkJSR3hNhDY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=NfV8h9Is; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=PUiEhnLW; arc=none smtp.client-ip=202.12.124.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="NfV8h9Is";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="PUiEhnLW"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailflow.stl.internal (Postfix) with ESMTP id CA8F51300104;
	Sun,  2 Aug 2026 21:38:07 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Sun, 02 Aug 2026 21:38:08 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1785721087;
	 x=1785728287; bh=GKZh/3B5CaR2ylbw+QK2bTTg4cFoSWL0/KYsAA3wzEQ=; b=
	NfV8h9IsOaCXlT8oULh0l35P5CvWujiXl3Y0oVKNnmb2/R7EkyOPyQ2m3yVBp+rS
	2dxf0pwaZMcUx33ycTlfLY9Vzu1y33jLKok5bJiL4M5Ge8G0kOoyh8gTORGi0e6r
	v4ElBosy3l+IGSmDCa+ju2LDLAyT9Kt5s/gIb+A3neTwnd+G4O3jutBAWy12hVa5
	vzSKWrIgAFIPCjQuRAVUVEs75OIRUtxojDzMgNdNgnvQiK945IFIAOfTfVMe6Hi4
	3NclvktRSwl+GSQa766ejuEUn3t+JNSdgNypiHHaAtymu71KrruIo7WRVvcobZb6
	IgM1+wO7eTULzEGiM8MWUw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1785721087; x=1785728287; bh=G
	KZh/3B5CaR2ylbw+QK2bTTg4cFoSWL0/KYsAA3wzEQ=; b=PUiEhnLWws3/Y5ArE
	NCBjZm8MArowNhlIFt7I82/rMrYH1u2lOUFalCqQNH9oTQwrSHvN+htF1TbU1HQj
	9gSWjCct/DCMsGUFWojxQe7+Xa54rVJVC32XwddL4Z+2w5aRJUUixUlpEtGuJH4f
	d/InlJKnidxhfdDGHGnE+O4aj14cDCn773jhKttg9FO0fYkiT4Pa7sO+Izka0gYu
	lHxHRde8496pK8I6cLo4O+bRWPZ3k+QGBE6XqMmyKsQJ1R2/k5OclIWVtvnBvMeu
	NJwqPRxc2SfjBVG4XJ9e6dnaXCEA6gMYXUrY80mRTsatQwxe+JsqnBHyYY+Ekxxg
	g2YWg==
X-ME-Sender: <xms:__Bval4L6gJXLfMjh3Q4dhd7KsWJx5KfBVj9HFpv1KbsMrxN6jzLsw>
    <xme:__Bvat5bYfTDpBss_4snbBa4-HboHwt1zDO_mFhl2-JLOGjWbLsLFOjCLDi4hB8u7
    rywCuVDA01O2IyKxSmovYxuSyPcDnGRE8A2YsvXu-IpOT8L7A>
X-ME-Received: <xmr:__BvajHkbYlAiN-gyYz5VcWTpigdX5d8M5joSDLl0iENTE-TLHNk1ulnLSwvHKU-CGo-JdhWoYzga04ZV5qhAAEKJAU5lZw>
X-ME-Proxy-Cause: dmFkZTEu0UNNG3Y5ooWE0RW0hb4az30oOOCqiR21A+NF5dBXRIXwF7e1ZQQcPeI1Y+2g3G
    2p5taGZPwiaaM3/xeTLW1FCz9U/vJJJskTdg41lYE8VUiZH3MPaQbRkjgX9sOC9ECG/cTt
    EsmfJCIwMKXkPJdCSK/JXV+uNx8CZDrRBVBEoFtsVP6zXAB6qeB8/w/DykMlOqIBtf3Btj
    xISH9DdsaZIjdYArnJRbVHFMU7yzbJxCLAWmCc9hUaSiSdlTAIOT4N2Kv8CS0tgpHV+N+f
    k8nNXssq6c7SmtuWSNjzKUGklZ3BjLsq0xMUopueJIhR+ZPYvLBJVSK2Tqb5Oui4sXj8pa
    LA+RA8It3pPbvsYOL+YUfdzRtKGoHHWwOx5L4zVveeCdJsXJwkSfFeTY+5F8NrJC5gBxDt
    WNl0jirfhS19W53+YqUyMEFomX6ldS5Cc2Mt4rDzyRlVO91iX/xoQH66zIH6s7FAyYN5B7
    WHRqLUk6XJQMCfTRjSzXQ+7VWJ9A1tdfj63/BnwvzxK3NIAhjUWJip9v99ioHdAEURDGG4
    IHZwCMe2vXUALOvG/xejUwMaf7gbfK1U6VS8vgoU6WTnpnCmmXWhHO7NtmthPuRAQiY/Kg
    dobJf8L9XSRliO3uilUmtZWfWnq0Vh3VMo9uzY5SNP8HsOGrziFp2JGMF59w
X-ME-Proxy: <xmx:__BvarxAQxlEMeOVfdCbUQ8PWue8duoqEQGixeqjZk8IDHVMubYSLg>
    <xmx:__Bvaj2eDDP5UEvFn4g0d-WQcwe2vpHjbxRDUnytYdaUFvF1DqmW9A>
    <xmx:__BvauNcaDFuU6EK9QN1Jdz7wxdmyldQjr1Xm04GaeVZ1p7tRF4yrA>
    <xmx:__BvavvKcXDjcS1EUGCVg_xAPDKzllkIJuHSSsJ7kfEuahzTRugL7A>
    <xmx:__BvapQ-TkJAbYp2P6CtNJpiD5A24keBKcBwKYozdqL6s87cYhCwFhvj>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 2 Aug 2026 21:38:00 -0400 (EDT)
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
Subject: [PATCH v1 06/12] libfs: change scan_positives() to use d_for_each_positive_child_continue()
Date: Mon,  3 Aug 2026 11:21:15 +1000
Message-ID: <20260803012648.2195405-7-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260803012648.2195405-1-neilb@ownmail.net>
References: <20260803012648.2195405-1-neilb@ownmail.net>
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
index 080ca615593c..c2369ea9196f 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -109,17 +109,9 @@ static struct dentry *scan_positives(struct dentry *cursor,
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
@@ -133,13 +125,12 @@ static struct dentry *scan_positives(struct dentry *cursor,
 			if (!hlist_unhashed(&cursor->d_sib))
 				__hlist_del(&cursor->d_sib);
 			hlist_add_behind(&cursor->d_sib, &d->d_sib);
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

