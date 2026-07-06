Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DCAB6324B06
	for <linux-nfs@vger.kernel.org>; Mon,  6 Jul 2026 01:26:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783301164; cv=none; b=l1SVwD2QJ1Hb5MkhRK9ToxneIBUJlIkj7azlZIwnlA39XqXjN1qGRJJaCLOfwIIWC4IQ/xx5mSeD/3sfTDsr0pF4Qp2RuFWwPfot/FbOKgdX6n0eWbpvzs1hiL3IuOIq6z4W1bFWo722r++ully4qAZsEg4ScVoNdXtWN2GW25U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783301164; c=relaxed/simple;
	bh=sBlhj7cNGtlrgLnSwgGY/u7fcKi7iIMRgmsx/yollgw=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=udklZY72PHdGIw1BWGlpAbIbwYFL5VCIP3bZrqXYcq6T7cujWzNLJBX0ZZajz/1fJUyd3deNiWwBMZCs+NVl7olyGQ0bDk/znTtTZhWCiiviU/APKGlYNG8cxm2Jg2ljwQ//H6d3yTsqkHJS/xs2ec0V53cdgnHTuYyAWdEICpo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SjA4+9ZR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SjA4+9ZR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4EBC71F00A3A;
	Mon,  6 Jul 2026 01:26:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783301162;
	bh=hlwey/BbnN9e//TiSu4rodtQ1A6/sJVYMabCNhDUZAM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=SjA4+9ZRfHBzdiQDWWGJ+z+WI9o1T/hZxiwYu6r9iniSSWptv2w+TLp/+4l84oq+g
	 VQSkH6qu64aKGXD0QHIF6CbS6fc+pVGg2CFGazsHb8PYNGxS7hIH9DZOxxK/jqp/9r
	 7nE4yxnodxYb1PPr+S3QK1f5w6QuviaKvQQC6803BX5j2uC2hdSmcPGrpgY31tTUUF
	 kClf+tVxkAZ1dyGksFgtYGbwP9VihbOQaKPWnOZvZKw4A37PGyToKg2Kwa5lLwiqmv
	 kNcQSfN/m5GyaHH251Kz3W3jSzsbA2y1Yiyre3gmYCXWXc9H5Uyr0jQwuNQfWbbZxy
	 t3cHTYOhdcsSA==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 05 Jul 2026 21:25:41 -0400
Subject: [PATCH v2 5/6] NFSD: Prevent client use-after-free during NFSv4.0
 revoked-state cleanup
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260705-cel-v2-5-d88c3b68e8bc@kernel.org>
References: <20260705-cel-v2-0-d88c3b68e8bc@kernel.org>
In-Reply-To: <20260705-cel-v2-0-d88c3b68e8bc@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1809; i=cel@kernel.org;
 h=from:subject:message-id; bh=sBlhj7cNGtlrgLnSwgGY/u7fcKi7iIMRgmsx/yollgw=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqSwQmOzNAHm7SdgiU4qSn5ADwIGdYmuong7Ji6
 UTEG+6SgCmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaksEJgAKCRAzarMzb2Z/
 l993D/43+ckmTRVi82wXb6TLhgKoZ/AmADezkd81qp0sCub1AtZZ75X4kmifjmR1fimistH741H
 OnyMFxjyHyDh+z+SbfckCxFBPyWROMFv/aZo8ejbM8KtTuruScp4GsL+IdhHBpFdLzcWHDPV6I9
 BQD2q4JFjJjKx579e2/0WpVBKC0FoH2Eng7v8oXuB0/ovGF+8Ib7AXxqBhnD/EBhcew0qI1vyF7
 wOf/JVxAGFys1S5qatHp0/HpLOgvvgzc6e9cmIqmlB0xQ7yPzBzw5zNx47z9xy7xvMHWs19BLli
 3IiyDHEd5CQ654oiaYLZEvBMJ0SgnhKi0o69FDXxbkvIDw4ydl3mI9fIeptLz+9LbbX6/Nz+kMC
 OSr2wG8aohSgi1PGUL4zh7VbB7M6XPQXHYuPVIBQlNla14AcvZoLDjK7CE/XOZv4wxCdS/ecrE0
 iPXEpklxA/kvBwuqRgzAJirLQGwsoqtMGKS7NX++TPwEC5BciizQJ4qoIisicgB0DnIDfcw+YEI
 EiB7suijen+Vt1FFWKjx+1Aexyefm/u075am7x3Dzn0AUaOi6xyqMpV3Xe+QmFJh6igRNo4UT8z
 yo2PC67e0wP1KWrpqel4TZxelcW/wOHjBPmO+dGBw9A4JYmXD54oE7uItlXV/G29318lxf8ujL1
 aypT/HDi5WoJJRg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfs40_clean_admin_revoked() takes a stateid reference under
clp->cl_lock, drops nn->client_lock, and calls
nfsd4_drop_revoked_stid(), which dereferences the stateid's client
through s->sc_client->cl_lock.  The stateid reference does not pin the
client, so a teardown racing the dropped lock can free the client
while nfsd4_drop_revoked_stid() is still using it.

This cleanup runs from the laundromat, so a periodic sweep can race
force_expire_client() driven by a write to the clients/<id>/ctl file.

Skip a client that is already expiring and otherwise pin it with
cl_rpc_users under client_lock before dropping the lock, matching
nfsd4_revoke_states().

Fixes: d688d8585e6b ("nfsd: allow admin-revoked NFSv4.0 state to be freed.")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c7db2c249441..e80d4f97f020 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7447,16 +7447,22 @@ static void nfs40_clean_admin_revoked(struct nfsd_net *nn,
 
 		if (atomic_read(&clp->cl_admin_revoked) == 0)
 			continue;
+		if (is_client_expired(clp))
+			continue;
 
 		spin_lock(&clp->cl_lock);
 		idr_for_each_entry_ul(&clp->cl_stateids, stid, tmp, id)
 			if (stid->sc_status & SC_STATUS_ADMIN_REVOKED) {
 				refcount_inc(&stid->sc_count);
+				atomic_inc(&clp->cl_rpc_users);
 				spin_unlock(&nn->client_lock);
 				/* this function drops ->cl_lock */
 				nfsd4_drop_revoked_stid(stid);
 				nfs4_put_stid(stid);
 				spin_lock(&nn->client_lock);
+				if (atomic_dec_and_test(&clp->cl_rpc_users) &&
+				    is_client_expired(clp))
+					wake_up_all(&expiry_wq);
 				goto retry;
 			}
 		spin_unlock(&clp->cl_lock);

-- 
2.54.0

