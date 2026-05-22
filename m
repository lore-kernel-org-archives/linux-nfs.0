Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4EF6837BE80;
	Fri, 22 May 2026 19:42:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779478953; cv=none; b=nR8QO4Rw7nGJtKN3stkimqlWq9XCfWe7Ej8q8abx1JDqeswde+ycs2DQFWVmRjHeLlOg0lSzRKn8karMZsMANmKYBj5APRQB/1pYvy0rjKUZJBItan7iiD//4goyN3R8wXTz5W0Gmb38L1Hh+UYl0rKAg5TKBpkfAa/diBQKew0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779478953; c=relaxed/simple;
	bh=ZKSdExH//yHPrO+bh/Uj+4YIl81jFCLLy6kU97jewL8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=uvewBs7QKQ0Xl3qDYbTzuJsz7+ncHBEmKEpTE8xxzYOC2PDawzO2iz7lQN6JSDesyGBFAXjCNhW3PmyCh1K2UDG0Q67r0no53xkdH9NEojRWjFtsZA892aFWg5skIL1S6cvN04gToYz86SzvluIlJFdDUvgTOBlCewwL+eQVEbI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JDTolst7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JDTolst7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 48DF11F00A3D;
	Fri, 22 May 2026 19:42:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779478952;
	bh=tS3ewl/RblzPq0s0br2Ku7A8Mpy7aLrtToStoyvDFrA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JDTolst7Da5QxDQrmw08wDSUlzLgQNjZNt2IB5YB+oSWpbqro4fCt4xfbR+HhOqp7
	 IOSTDCbOKhXsgscKCslOo5UOsRPLCNSsEerU9wEmpmvIu/M4wxnkiDQJDVn3VdIL7B
	 jhy2r4KXCNSX7pUyoQ6wiFWMziR6SGYzv2nArVI6mEAqKHNVTH4pJzS4Sdi0P6JGJH
	 F0mO9x1YCyBniIxv6BbLz+0HA2/4/s45glzcqcU369dQGHyC/gIzyCk0tk3/MlzWZu
	 +knJUzzQ+fqgaeHW19i7N82G0OWo7VsEC9IaumYmqRFPafI+yvV6hdNbHllK3VpMNS
	 XFHyh+LWJ8x2w==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 22 May 2026 15:42:06 -0400
Subject: [PATCH v5 01/21] nfsd: check fl_lmops in nfsd_breaker_owns_lease()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260522-dir-deleg-v5-1-542cddfad576@kernel.org>
References: <20260522-dir-deleg-v5-0-542cddfad576@kernel.org>
In-Reply-To: <20260522-dir-deleg-v5-0-542cddfad576@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Shuah Khan <skhan@linuxfoundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, 
 Alexander Aring <alex.aring@gmail.com>, Amir Goldstein <amir73il@gmail.com>, 
 Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, 
 Calum Mackay <calum.mackay@oracle.com>, linux-kernel@vger.kernel.org, 
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1106; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ZKSdExH//yHPrO+bh/Uj+4YIl81jFCLLy6kU97jewL8=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqELGciCVEOBfhd6IsQqcKVVVVlC9dE5yVsKEy4
 TdN/Cv2SyCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCahCxnAAKCRAADmhBGVaC
 FRZVD/0Uwq6bdtD2qIN7pwQLS2CgbgvUmw4+LgbHqbhbZdim4yghqWYGmeNOq4BH0YGcVzv51VD
 sgRfWDSIwCal5ObWni2aGO5AAMgUomYcK8v+eJikkIKMyssEEDv+V6L6/TZeQRgcVPyUJZcbMKM
 FLdF/bGkj7wbZRy/b6f/6SwRJougWS8XIs1rVwHylg4OlhrYYW0BHqq+T+aXubIU+OzAft0aAdW
 y08JD3lQqBL+xTUyxX7MJDyk4UZt9UUSkFuLvOP06dmG17pk06oMjCcF8uQhabl9/TiqnsLR80Q
 YklvpQ8iuTlbz0iBF4MrfMgAKdSJk+PhPLgpJnTJnD3qOvrod5XWHUkmrL4Ymsr6+te+7jDfnfv
 I60ObhOSKGdcy31b+7njpFFpnGZ78fVONz+q2Pvj4Mxuh3mHw8/Zrsdig71SA0mWEFo7u01vxaa
 MnjRV2Z+HksEOZNr4ZvLEWUZYu8mui9Ztbh7lgqotZh0YYDlFYgYBR2jYR5296BlitV4FVD+mK1
 kx/QzhyQBwXHxn/rmPcGK7iRK73KcH40PEeJjQ3HESTgchAjusKC3X88nP5KkhhMCvKdq/6NZXs
 droNeTsla+fWlnXCQIgjg7C+6Hk6OxuxDY55j9ziZZGHfEtTTEc7rClqf5Vxr4cnCQzIjlJqIpY
 BG5O7PcjBnqH7pg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Any lease created by nfsd will have its fl_lmops set to
nfsd_lease_mng_ops. Do a quick check for that first when testing whether
the lease breaker owns the lease.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2cf021b202a6..67e163ee13a2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -91,6 +91,8 @@ static void _free_cpntf_state_locked(struct nfsd_net *nn, struct nfs4_cpntf_stat
 static void nfsd4_file_hash_remove(struct nfs4_file *fi);
 static void deleg_reaper(struct nfsd_net *nn);
 
+static const struct lease_manager_operations nfsd_lease_mng_ops;
+
 /* Locking: */
 
 enum nfsd4_st_mutex_lock_subclass {
@@ -5663,6 +5665,10 @@ static bool nfsd_breaker_owns_lease(struct file_lease *fl)
 	struct svc_rqst *rqst;
 	struct nfs4_client *clp;
 
+	/* Only nfsd leases */
+	if (fl->fl_lmops != &nfsd_lease_mng_ops)
+		return false;
+
 	rqst = nfsd_current_rqst();
 	if (!nfsd_v4client(rqst))
 		return false;

-- 
2.54.0

