Received: from flow-a8-smtp.messagingengine.com (flow-a8-smtp.messagingengine.com [103.168.172.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47EAE2E888C;
	Sat, 15 Aug 2026 04:30:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786768260; cv=none; b=loEita5q4P2txNtLQurzvjiKjRoeuEX848blF3Bd2EX5COpxBOsE8DM6+uqndUYhajWt4A7nIIAgTy63ecvSCHYboqqXOk0QVfVXu5w4D+IlAY2hoZJRQr263z/H4r/24qASRRcre5O1ikG0XXT/ETZ7imT14Z5yKTXxMsbdVu4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786768260; c=relaxed/simple;
	bh=YV9knnvzcy0sLsdJqwl6xSbTKsoY0oX+VX8+4U3n+kY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=f7QwNQSACRwvBVSvH8kllcDKRZSCXcaeasMTXMwJk1vMBFZkyyjZS5rpNBsbaoCvtZDG5VAoRpqEu5J4+Xs48EsSyYlsOXMqFr0zREHxBHx1mpKdbCuLQZ/LdM3LJaIKobe1TFLaHr082kUOIBb5LlZ7AH6Mt3gmHoVvUTqEjwg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=FHY+w+en; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Z+ExhmSx; arc=none smtp.client-ip=103.168.172.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="FHY+w+en";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Z+ExhmSx"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailflow.phl.internal (Postfix) with ESMTP id 8E0A5138041A;
	Sat, 15 Aug 2026 00:30:58 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Sat, 15 Aug 2026 00:30:58 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1786768258;
	 x=1786775458; bh=0ZUxo0XVQx0MV+TeT0L+0fmPiUoaYbXc2QhN9arTG7Q=; b=
	FHY+w+enKFJX7PjH+lZze3Mfeh/ZaKJy/jW6hXeeOVM5l1fnQ6Nd1qEaTJwME8AY
	7hQSSRCXdLSbESlcGtmfQieH7X27cMbHpsV9hgBDtRtcMCq+KtAU2gXG545hn++Z
	Fl/7CJQDJmk3qoKwc/uuEuMJz4e40UrDzOQ6n/Qn/SHqNbAMR+kT6ahgPl85aRA+
	mOAojliI+UUNMDWkhhpxV/skJtBGj35JEZuGFVCfwamFovBiy6cXwSPjGmh3YuGI
	dMgfWcApfbFvJQLMfD6gexh2nTLzs3ak0INjcvsRjey8LMnZeFCODkDGHY6IZvkZ
	8U0ZqhD3aq3s6xvC1YVLKg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1786768258; x=1786775458; bh=0
	ZUxo0XVQx0MV+TeT0L+0fmPiUoaYbXc2QhN9arTG7Q=; b=Z+ExhmSxiVIQSQoNW
	TxNPAzU261hSZivA+gXbGYsAF3O2grDiwGRekTHbYN57A72RISucqOv9EYpDtM0R
	eMPvpHQocYLuyACpV/in0DaOfqxaT777zC2ufOKdABqbq7uaTwvtECzCGHWLBpeR
	wylhxGevTZ03hMVpKwHkq5KUhycbpxbMO2OLm8j+j7FqKJoWhTE1JjR+LmsGkBfu
	zG9uHtQT3S3SyyhSRlek9jZIP+5fDbsvL3aPj6VE78cHWRRp4M3SILPz/i8PzLnU
	Qh5fi263rCxfFfjqlp6bjmxYaWrYKaUasSwqlD9ugnrmICsWUU8DYnn6M6/egURo
	aVaiw==
X-ME-Sender: <xms:gut_avyyvgabmoSF-faUUhwuqqaSP49EaaptwLawDD_DnZFZIb-Yvw>
    <xme:gut_aiSuLC6PmYCNs0BYc8A6OxnXbE7fFEwgHqstVg2fvCnuhUhcZbWOqAG7UI6o8
    WtbgoMIkGyPbqb6EMee1LvgqwH8sgvwHcp3DljnQPsbO-_osA>
X-ME-Received: <xmr:gut_av_Pcl2i7zuxJt5_cipINISDrp6dJiKTi654XO6EJzlkaYTKaIwdMaJkXIQv1ilxTjlWgX963QTf9g_AI3hOVjRcbV4>
X-ME-Proxy-Cause: dmFkZTEEgxiDAqI+NKGka33XJgpMBO/DGhYs8Flsqa2Km3b0PepQC7/8GfuyeA5jzmyQep
    aCi2aiis434mC/Tk7pwKgVxFObE3aixAuCoIjL6gdxAHLjW6IL1yYbTLlt/BEgF+UU2fSt
    hWlHFXw2KP7X4V9Aq3bD/0eXRW3pMpKxT8FIezDpG0wWpCM2a99aOq5iO64uy/c1sM2cBv
    H5X7K0w7/OYrN3gw0/vYCnPslouZWIDUiEgmIdpWMf56spVmUxFemTMS3TY/x0M7Lp5VqK
    b4Lcg+LhJCZnsVAUnm2IimP+mdAF1j5AUJI2N7qOkUPtZJq90cLj/zsW4WqsUz129GUmBo
    UiRMFGhu11BHa8HJuNwLX2zX9ZNXPScWQ2CNccGqZ7GkQeESbMn5ZOcUdLgyk6LR2ou72l
    q4fBZHkplUiccK8dZr6NdgidMUhFWLj+mloN53jWkLfZzii4Cgd6J+RWdOUae9VIzNL2RQ
    sGSfC+ENz8y5Z8ACDdAIrJQLZdTstam+gOgNASBuIjrBCPkZ/A3hNU747/fZj+IVV2lv7u
    RGX5KGce9V2IvzlioJRsX5jqFpsZrkJAuvBLg+UEo3UN4RBxJDixWZ/sgsFdZIPxqRqs7L
    IuuvTqXESa5Vl6CK2Rq7tVVCg7Og0KZfYZFW1/4kzoffZ2mGmofeFONsyWuw
X-ME-Proxy: <xmx:gut_anK7HtHiitiSg0iXiN0AvXnwVsRsXs-qKXCSwC1bAtykeuWSrw>
    <xmx:gut_arthh59f-ksyuw-CE5PHhO9lwGb6JL5pojj22d8bcRnJ1MQiqQ>
    <xmx:gut_aonNeCnz7Ir_qgBJtdGvh9WuriuweOgO16VyYYAvgRiGbrwklw>
    <xmx:gut_aqnlrqGeZ6JCd4GJurkC-eq5FlZ60N9I1lcvtbqyGxJrI52WFg>
    <xmx:gut_apqwPZJaRPn-7JiSG9C52thVEZYzAtaDHgBYdfmvh_HBNAdAWoLA>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 15 Aug 2026 00:30:52 -0400 (EDT)
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
Subject: [PATCH v2 18/18] autofs: change get_next_positive_dentry() to NOT accept NULL for start-up
Date: Sat, 15 Aug 2026 14:21:35 +1000
Message-ID: <20260815042707.2535717-19-neilb@ownmail.net>
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

Rather than passing NULL to get_next_positive_dentry() to first time
round, change callers to use a for loop which does the dget() explicitly
to start the loop.

I think this makes the code clearer.  Looking at
get_next_positive_dentry() it isn't immediately obvious what that code
is doing there.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/autofs/expire.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/autofs/expire.c b/fs/autofs/expire.c
index 277d9129754e..2a1844ba48c6 100644
--- a/fs/autofs/expire.c
+++ b/fs/autofs/expire.c
@@ -83,9 +83,6 @@ static struct dentry *get_next_positive_dentry(struct dentry *prev,
 {
 	struct dentry *ret = NULL;
 
-	if (prev == NULL)
-		return dget(root);
-
 	while ((ret = d_scan_positives(prev, ret, 0)) == NULL &&
 	       prev != root) {
 		ret = prev;
@@ -148,7 +145,7 @@ static int autofs_tree_busy(struct vfsmount *mnt,
 		return 1;
 
 	p = NULL;
-	while ((p = get_next_positive_dentry(p, top))) {
+	for (p = dget(top); p; p = get_next_positive_dentry(p, top)) {
 		pr_debug("dentry %p %pd\n", p, p);
 
 		/*
@@ -201,8 +198,7 @@ static struct dentry *autofs_check_leaves(struct vfsmount *mnt,
 
 	pr_debug("parent %p %pd\n", parent, parent);
 
-	p = NULL;
-	while ((p = get_next_positive_dentry(p, parent))) {
+	for (p = dget(parent); p; p = get_next_positive_dentry(p, parent)) {
 		pr_debug("dentry %p %pd\n", p, p);
 
 		if (d_mountpoint(p)) {
-- 
2.50.0.107.gf914562f5916.dirty

