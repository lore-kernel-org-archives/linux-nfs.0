Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A0D732857EA
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 01:08:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787015329; cv=none; b=Yd45dFOCEqgROEEd4oW2JGVKki1CC5QUgOU+c8vUiUB9DpMh+8592g3NcllrocUYzR1G79BaPVMk8+Th6xB8SX3PwZAJrQrjnP9OvkVzxAlSKjR+3mRdzpaDXFjSU+NgKJsKTkzbkaIJHLtgVoJOt5zLRjMLo9gUNohGIQ51dBU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787015329; c=relaxed/simple;
	bh=hjyOXY1iaXHyiyONmrxdckfkarREO/QB+c2QXeKqq5M=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ronq1yGyzAGy9BuXEllpvugJKqJvkZOWDLhnN5rjyxEG8oXdFhvuXcUb7N/oYz6nYZ/lZ2yO5MBUFZMgkI76atUz8QITMYFQVl2ZQlBSeK8CobGg0mCFpVAge9HFySG/1FovBZrou9SmP7KBRuY+koPHbfhKK+1xbKXEjlFeW+c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EZiDVeO3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EZiDVeO3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BD6871F00A3A;
	Tue, 18 Aug 2026 01:08:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787015328;
	bh=RdRWcaBu2AveqfSV3Ha9LbjLuI8aaubrGdqQvdRiaw4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=EZiDVeO3nE02k4fGfh/7Mg9ln2BcFjcbONISCaUiBwZdzoMfHvnnz1XGPoQg7YguF
	 5Q9HgiN2y0WXbcV45pNhRsvPj9AFN/ul1/fGiLcPWXfmzw5q2VOijZfE0W1pVr5HGl
	 xM31kNBeFmagdsDnP+metpA7a0v+EmWS7Yz2jmkw3EyK1pIW8jYH3hRNCCyDP8QFWx
	 piLUlEX6amSDKIH2JhKsgtA63gf2dYMAumlhvaAYs+nLGvAOKGThNcSFGLm27DHFbZ
	 IlXaFIxbSp50MRusc0msFsmZhv9BTfbXBCO4opZrhxQOxIg8+/pogA7JWUM06U+s2T
	 R7NIupB9fb06g==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 17 Aug 2026 21:08:37 -0400
Subject: [PATCH v5 2/8] NFSD: Count the delegations held by each client
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260817-recall-any-keep-count-v5-2-3b2cffce701e@kernel.org>
References: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
In-Reply-To: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2423; i=cel@kernel.org;
 h=from:subject:message-id; bh=hjyOXY1iaXHyiyONmrxdckfkarREO/QB+c2QXeKqq5M=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqg7Cd4kLeZRRoEqGwOh1UOwTcJIWl47fK9z5BS
 EPu1eKTmqaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoOwnQAKCRAzarMzb2Z/
 l8dSD/0YBhWPMS8PoXdsgdhNnemf15LyzV/R/nFqD9NdIB3ZALySANpZE5M6vkBCg3g23552JPB
 93tGwPjLY1P/+noNnYFz5c2/m2wOr/Mc7LJRYPTPHRZyYcDfiVbplma9frELXXb2QQ8Jcuo+Hrd
 yys4tHDZ+G5mHqJmlzWcL3RV4adlBocwoUNV6IfGDzi3yPvG1FbieWLha3clwj3CTw05yDEwS9B
 hjX//1XSAoclby8k3FyJpZbco0Wl07PC9a/GOBJulqbryxeCNkO07CusyBFGHVIAARswZRRAbCy
 ySuCKX1ne1u9keclVLvY91leCAy+r4gqd/F/05+R2SNHhhaRsGFvlI84JuL2UYT23xzsNIYGyMt
 +BzbJ5bImAybj5c5QdNwQuliY8Mp1VTFask19uFw4lib1A5fZlJanjWJ8rSfmLQNS0YXP+eSDhN
 pEFHfw0DPTH7VHen70SBR+jaIB/1XurNEkbm1g4/goqaQ0Ek54NuUZyViB9v36qy3eRWVVxvHff
 /lGq9GYDwcDzEp6722l6iYGW6xxDGBgNUTdXj6hQZ574KX6aVZWG8LI2jHCumPDKlBkJcjSUXAu
 AMUqpM+yZCrgJV72y9Ay1y1hPH4fTsSNOQDWrgzejClvCUCwleOtq0PLnpTToRtSzfK3D5cUsCV
 aCKTLIgryB1u+VA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

struct nfs4_client records the delegations it holds on cl_delegations
but keeps no count of them. deleg_reaper() walks nn->client_lru under
nn->client_lock, but cl_delegations is serialized by nn->deleg_lock,
which nests outside nn->client_lock. A caller there cannot take
nn->deleg_lock to count the list. The cost tells against the walk as
well: an O(n) count per client, on a pass that already visits every
client.

Add cl_deleg_count, maintained at the two sites that mutate
cl_delegations. Both hold nn->deleg_lock, so the counter is already
serialized against itself and needs no atomic of its own. The decrement
sits below the delegation_hashed() test, next to the list_del_init it
pairs with, so it runs only when the delegation really leaves the list.

A reader that holds only nn->client_lock is not synchronized against
either update site, so it can see a count that does not match the
list. Such a reader marks the access with data_race() and may not
depend on the value for correctness.

No functional change.

Signed-off-by: Chuck Lever <cel@kernel.org>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 2 ++
 fs/nfsd/state.h     | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9a3574b853ad..fbe073ee5225 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1527,6 +1527,7 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	dp->dl_stid.sc_type = SC_TYPE_DELEG;
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	list_add(&dp->dl_perclnt, &clp->cl_delegations);
+	clp->cl_deleg_count++;
 	return 0;
 }
 
@@ -1558,6 +1559,7 @@ unhash_delegation_locked(struct nfs4_delegation *dp, unsigned short statusmask)
 	++dp->dl_time;
 	spin_lock(&fp->fi_lock);
 	list_del_init(&dp->dl_perclnt);
+	dp->dl_stid.sc_client->cl_deleg_count--;
 	list_del_init(&dp->dl_recall_lru);
 	list_del_init(&dp->dl_perfile);
 	spin_unlock(&fp->fi_lock);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c65b604e29f1..cd9294f024bb 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -633,6 +633,8 @@ struct nfs4_client {
 
 	unsigned int		cl_state;
 	atomic_t		cl_delegs_in_recall;
+	/* Length of cl_delegations, updated under nn->deleg_lock */
+	unsigned int		cl_deleg_count;
 
 	struct nfsd4_cb_recall_any	*cl_ra;
 	time64_t		cl_ra_time;

-- 
2.54.0

