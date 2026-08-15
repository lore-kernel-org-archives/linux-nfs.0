Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1EDA62DAFDE;
	Sat, 15 Aug 2026 04:28:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768124; cv=none; b=rYAxKbROdN3nmEXdepfKZ3v0sU7OZkxDM2uc+ou6sqvyiPEZ0hqJ4iCywWWVrcwIa1TIShPH+1LGA08sN6dN8k8ZmcvFgD0QhQVeHyVrE1Yi9xCk4sUdg9Ad4gDgteY2UExTdXdc/xdqNPfWv4ev7KQdb916sat5gjP2y+Og0lA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768124; c=relaxed/simple;
	bh=yIHtNJ55MhE2MaPIfXvzHiwBMs0J+NWpXiu+PMzC4oQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=drJQUt9JGZNt5xNzy4si8QRw2gxLX4CcL6De+m/eeiokTjS2pCmmC971dK/KJCmSnBi0XJLlBdZRjtmVgkz5xOxlo+8mGQDrfzjRC9yK7WtV3Sjw24dEKkCqZu4YLr9ojmEQEc3fSEnjsNg2PEAaO6zmYk44YbDi4EXmmcC7yyA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=bqjRfLkv; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=ZMt01d64; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="bqjRfLkv";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ZMt01d64"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.phl.internal (Postfix) with ESMTP id 4F59913803F8;
	Sat, 15 Aug 2026 00:28:42 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Sat, 15 Aug 2026 00:28:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768122;
	 x=1786775322; bh=QBxhcF/9xx0fJVzCRbVatWLSoovuhY6RZpsb7+BVY1I=; b=
	bqjRfLkvS3cbGxzlykjKRbh1Ksx3VDguHVHcxlQ3b6hF21VmVribKgPD8jPxh1dx
	SPdk6P4xXZqhaZJPPwT/UKP9MgSAxUD5InxteviMhw3hARMmxaCihN8B897Hpq/c
	7QR40flaUVf8s/pQHdcEcm6ZV5NTdQvLusWEp5bsFTiliEIADFO74dWtzaYgQBiO
	v0SEoxv0JJ4URdSXbkhQyBcIO7Zf+5NhvLYZ8nv39gN+aaYDSS8fAjtv9X1f8X4X
	K5z+vafIg44JmNw5ayuAHYmrU9DGJLqgmu/7qBc0zcztnEO2j+qm5dfBJU2Y3pYZ
	pyW/6AogP81G1CDVidfNdQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768122; x=1786775322; bh=Q
	BxhcF/9xx0fJVzCRbVatWLSoovuhY6RZpsb7+BVY1I=; b=ZMt01d64ylFJIe5sJ
	tvytFxduHgcYH5k4nG6D6q7eh7MG+D839nemg0C03zkCpmn3n7WT4/lNfZXYmUd/
	u5ROLa31WfTKkBaKvolW3LtHe7do1Yrx7Ko3YiVmA1o9eyW8202G3zLjT+zpjuHb
	qi9c7uez+OD20t60ADSuOM+Z8xb7Ajj2y2XfGHi3Hddfqzsz+FSujBkG/cEggkXA
	XiklcFIvpa0PS7ZT1PkvXxQn7l37/EuYo6zBPXZYvPj8CCGycHpMh6+6ImxKT1Vv
	NOIONFxeDpxsnCob64yL1fhgZEOkstMkAj4ZIHzwfI21Rvo5C7JPQGfsTeeoEP0n
	Ul7zA==
X-ME-Sender: <xms:-up_amHsTHXH9P44eklCHYkix4f53WmluCKwWhhUyqk5XF6KP6HKnw>
    <xme:-up_aiXcZ4c1ysrzozOibx_OOiHtrPK7HyRc3reSszIpKktOba0cFBYxgsyDSXfvD
    HTrTh5tNe8szZv3DK7KVyJk1T5BpFDRw1AqCoO1Lw74RvHrGg>
X-ME-Received: <xmr:-up_amxM5s25zWGa5onyhdbbVjbSjd2TLgt05geZ8jq5haNLqRR9l6C32pKwVRhkb0vZcfJnLrSyCVjh6N19Jxs5sgp_La0>
X-ME-Proxy-Cause: dmFkZTF9KskX6ORZkk2qDbanJAqhpO1c3Xju1rB/XGbwQvOGWemlAS7RTfehH6z/blxuZu
    ndq9JpuBON/sKJpHNFmlA8NZthzZuohefFsXvvzkhDLNc/boPY1CbYwGZ3ejocQdZP5Ev/
    BXLTdsGGIGk/QWYctoHjfRUZGHXRv5et6FUSLml8RkvDkfsb7WSgppX3LyXjWcFTLwfp/k
    XOfgf9r/SZsCIW4bEY4xzTmE8sCd1BMMrUIBiSLPUM5HPZAu9IGndquxD0N2k1kJS4EkJO
    uSSxartPr+p/2sBY7kb8VaiOyCHt8JoqHMJjX2cNsGCbf1T449z1owAvKjvcnWl37FvYZv
    xBkvdljat0cxOiVSTUjjCqHmk/A6Cs8PzDW3BOACcrmezftHMRKnBhGU6LNdRMB1S1EC9d
    d2SQHNJLexn4xqrIZSBv/ulS6vcZHMpj8ecULxFQYbpVaE0q+QaW2BimNl4kAYh+PTqdWN
    RAjy8/sdQJy3OlWJBRTCyXtMx/4jalL0aqRU4DKNs+PMmVujZWLb72fTBsjj0Y6FHn6Ox9
    P5g0qhXLsWnv694+ccz845f9Ihek1XQe0skjxYMjXVzXs8DvXC7jR93McY7PzSw8UrZBJb
    eVQPMK6P5hZjSLiQtyv7m5+LWGTosCyc+9J0KVZYHQnUkk+W8zkSdx/e1pUw
X-ME-Proxy: <xmx:-up_atujkK6H4g228RJKYLmHx8CErFxzAK9k-u1CX50bYHGCtI4sNw>
    <xmx:-up_anCsoY6C7whxI4nF2BDCWYPSDliBBToT2xE9q470i15mkuY3jA>
    <xmx:-up_apo6pWvkWMpb6uyufNSQE-t59ZwCmE_mCJbWChWP9BuhEeq1dg>
    <xmx:-up_auabQgK2TtUcezb_5pQvLT1WZsnXbZTGbpqYsq5O6ohMAFpvAw>
    <xmx:-up_ajt9zt9gdOj0znCs7wm4imu4uczwCIrIopaa4U6LQVsdE1EbAVlx>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:28:36 -0400 (EDT)
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
Subject: [PATCH v2 03/18] coda: don't take rcu_read_lock() in coda_flag_children()
Date: Sat, 15 Aug 2026 14:21:20 +1000
Message-ID: <20260815042707.2535717-4-neilb@ownmail.net>
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

As described in Documentation/RCU/whatisRCU.rst sections on
rcu_read_lock() and rcu_read_unlock(), spinlocks prevent the RCU grace
period from ending so there is no need to call rcu_read_lock/unlock
inside a spinlock protected section of code.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/coda/cache.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/coda/cache.c b/fs/coda/cache.c
index 245131296300..970f0022ec52 100644
--- a/fs/coda/cache.c
+++ b/fs/coda/cache.c
@@ -93,14 +93,12 @@ static void coda_flag_children(struct dentry *parent, int flag)
 	struct dentry *de;
 
 	spin_lock(&parent->d_lock);
-	rcu_read_lock();
 	hlist_for_each_entry(de, &parent->d_children, d_sib) {
 		struct inode *inode = d_inode_rcu(de);
 		/* don't know what to do with negative dentries */
 		if (inode)
 			coda_flag_inode(inode, flag);
 	}
-	rcu_read_unlock();
 	spin_unlock(&parent->d_lock);
 }
 
-- 
2.50.0.107.gf914562f5916.dirty

