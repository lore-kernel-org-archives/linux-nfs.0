Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8217D4A3D41
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 16:25:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789143946; cv=none; b=G4SRqfGdOjjbtOtwYHYuDEcvh+RCeORJzKN1oJpLdNbDu4DB20l0tCnr7BUnXd04LmiRdWsCaVEjMKXyFbsvd/Ay8H5AgUTsXgUgh6CATaG4iaz9obYYLTe5BFLjoC8iZSACzayh6TMUVJuFLoVn9zfA43cLpP+Zl7uZvdurAbE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789143946; c=relaxed/simple;
	bh=aXiDitaGzn1VNLw3vwqo6hx5kXeZiqb4k8+61VL2tpk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=r+hGLjVd3PGI8P9fqr8LW0rgSMxKzhOKldPpLP0Jcr08fYC6kzVp0FfGSZ6AJaGAXIhZ/i5TqJiwfN+2tvZepvSfhmmkpuT5IjwU4qTNkAExg+hxuDR/LjKnxHqs7RWFMKTeH8paKEJXkWz7bjJ6PAyKqeAQqeW72fn21JNCY7s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=f7b5XDEU; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="f7b5XDEU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 02D311F00893;
	Fri, 11 Sep 2026 16:25:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789143945;
	bh=Btk93KQriTOFNZOfD8tbPJRJ0mqXgUKHvobGhFly7J4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=f7b5XDEUe0FW8OZ1T3NFIT1Ks9H2cGmPpWKgGxfWwI+O00Wuo51fcV3Cj9BxWLCE2
	 K+jo9LODBpw2NVcIQjnRWz0wfBhw6FuwxQJuRtMAcdBVnqAqo5FNIjvS9Ml/OymlP/
	 N25OJ6nPSli4XkoPXbptHKCi39Q99ZN8jMVI2wTUd6mFc+Zo9i3Q6OqDAJORX6qBIz
	 fIkHW+vI9XUNf0T8fa8xlyzKgpP2Lb0hzthvIcotxhyigMB2mq/cz0USw3ViDpkduo
	 oMFnI8+Ae8rVQYzA0JPmkFcNG/4Id20lSYAApo1k8NwpwgzOROQbjQ32MLhFaUP+eI
	 k7oI+fF9DYBOA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 11 Sep 2026 12:25:31 -0400
Subject: [PATCH nfs-utils v2 06/10] mountd: bound the junction path before
 copying it into e_path
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260911-nl-crossmnt-v2-6-f4d869951c5e@kernel.org>
References: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
In-Reply-To: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1337; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=aXiDitaGzn1VNLw3vwqo6hx5kXeZiqb4k8+61VL2tpk=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqpCuEtIDMcN8md4073yDKWvZ/AbpqaczYqQl4r
 XF7phL/C42JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqQrhAAKCRAADmhBGVaC
 FVC8D/4zPhB0Y+9cInbhIrXBWNT7VIBQHQ1dmRT/6S5Zkkk2Zh32Rwed6p2fXOGLtdeo8cWxKQ5
 qwxxC+IvS4fPQBu+TrHvTYYP8Cw5w7PIhLrmsU+pQFHXCNTLr4Y3dpDPqHLY0n5Tbh4uDS9gTkM
 3lYYs8ptAY+FoPECD6Je+X6xW3sx2XwOPC4S5mvUHomoCtDKZ6eOA0TeHiS8Zrd0ddmXCT7m97y
 oeQaBh1HKmDXPCIeglrA0rWxJW00XzE+mxE/TfNKAtNvU8Tk2h46VoSBjsGtmtysIgeArNtny4v
 Xap8LJO7hZlu4qyKB2SDBZegrEVd1seSEG6rXXJWo1PVzrDQhLvBIQZJRV2e9KSabp5Y5DKukms
 J1Rornv7QjXaDe56aueipJAy5mrbNqhkkCq9sz+IDORG6uzQZNFpTTRCNqYV2SeowojnieO9M/N
 /OxlqZJquzJT8LvuPzaRdbYd+I4b4UGdELR6jwJWoUvZB0PVzJf40/7JKvu80ZpIvO8/815wKuZ
 F48LmdeE2DwN0GHWTQBiZ7rI2JeEDjzNf+wIm9bCJTu/qpZBfTtZU2n0qu0uWTVwazOtWLeX3wV
 k9+QPOZIkMBebztxj5fd2jJHFuoiOAZb5SeTXrCPdnh98jKk/uW8vbScnqwpFdVWIj0W7lb0gTO
 N9ja36eKT3eEhnA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

create_junction_exportent() strcpy()s the junction pathname into
exportent.e_path, a fixed char[NFS_MAXPATHLEN+1].  Neither downcall
bounds the path first:

 - nfsd_export() sizes it from the 32KiB pipefs channel buffer
 - the netlink path strdup()s it out of NFSD_A_SVC_EXPORT_PATH

A junction more than NFS_MAXPATHLEN bytes deep therefore corrupts the
heap.  Reaching it needs a trusted.junction.nfs xattr, so only server
root can set one up, but the copy should not depend on that.

Reject the path instead, as mkexportent() already does.  The callers
handle a NULL exportent: both downcalls answer negative.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
Assisted-by: LLM
---
 support/export/cache.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/support/export/cache.c b/support/export/cache.c
index 5d9384be2e38..78b050ae9d71 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -3379,6 +3379,12 @@ static struct exportent *create_junction_exportent(struct exportent *parent,
 {
 	static struct exportent *eep;
 
+	if (strlen(junction) >= sizeof(eep->e_path)) {
+		xlog(L_ERROR, "%s: junction path %s too long", __func__,
+		     junction);
+		return NULL;
+	}
+
 	eep = (struct exportent *)malloc(sizeof(*eep));
 	if (eep == NULL)
 		goto out_nomem;

-- 
2.55.0

