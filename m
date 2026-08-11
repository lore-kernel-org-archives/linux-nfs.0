Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D415F39A4DF
	for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2026 19:52:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786477937; cv=none; b=tXU6L9crSLyXGsLXelR5hcD3Na7UHuCCX4YJ/TJB1QwKt/9amvdk9gQ5Ev6UfUh9/zs0PcZ7sPC5YxUzt4wfj6+NwHaG1RLfJFukAoJIKWImfjJ5aQcdtd1ZNkFNjSISFSrTL7b+TQ3Nu/JX0foLTvORdRW5uDo20LLeAJSl5y8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786477937; c=relaxed/simple;
	bh=0in4Ax2goUIi92RZ669bQFXmx2GvATN4Ol6lL/N4kGo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ceVsOmNWyNJVAPpTD0YToCBnYf7xSSGfaaTlNWz81FtIVZDgWY36QZ9osOFZGk9K2AzZ5P4Y7zjIrqQ192baM/vEor/VeMulPNPXHFFgxMLVtJwxXCx0NGO27Is3FiN8wmR+DmQm6lsFwtSH/JlIU1kKUj3QcCiAnQtcYAnwF4Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eMbDjM+o; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eMbDjM+o"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F213F1F00A3E;
	Tue, 11 Aug 2026 19:52:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786477935;
	bh=dQL60BagKfwY8iFoqFTVXgGICu2R2/Wt0ZneckGnFTQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eMbDjM+ovnrEp/IhMjJ3KTfsSh6mih02v28JV3YWTwFAgrfGpnZtccL/UXmcy34+O
	 yqtwPDtfnZsHfLW/j9MV6JSNRqQ+aEp/nDGbC3xbGP4UK5TAbHwgY+XasuZgKslczh
	 3PIPFzOV7N63BMXz/tPeygkIuAFT55rKw5UryrcMrkdVQ4NByweq4iIjGpemojU+Xa
	 vZGKUjZALPmkJM4/tU3iLAPrSGvhWczFzWqPWafuXQWW5tfWccCCWL6eDsQyhm9u59
	 JsaoZ8XEVhXjXluFSRZMOH847GPXN+5bjCzf/4+Okp/ygSptNgwX4DIeYmgHCVChjQ
	 A1rYUYUm8Je+A==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 11 Aug 2026 15:52:03 -0400
Subject: [PATCH 2/4] NFSD: Count the delegations held by each client
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260811-recall-any-keep-count-v1-2-de9ca00493b7@kernel.org>
References: <20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org>
In-Reply-To: <20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2376; i=cel@kernel.org;
 h=from:subject:message-id; bh=0in4Ax2goUIi92RZ669bQFXmx2GvATN4Ol6lL/N4kGo=;
 b=kA0DAAoBM2qzM29mf5cByyZiAGp7fW2hiqYffWzjCZwR6yrjlVYlOITeuwWUAEj/pWzTU2dP5
 YkCMwQAAQoAHRYhBCiy5bASht8kPPI+/jNqszNvZn+XBQJqe31tAAoJEDNqszNvZn+XkzgQAKhK
 MrPwCfJsMwacDcXS3W003AZ4+gOwWL2BwOs7Fm1AntrNyYNI2sy5CHk9FkjM12yoyhBOQDZdmpQ
 b5v34w63H0vJvUyCxhJOeozQb39fs728REoEx9cUnyl8x4fs+/Ai6bohWcX+W34u+3Z4PzuK/uF
 Gf87UaTvnSJ90aEwHMcII9OFuP30Lmh+bvEd0iOk6BX3DjaVD5wR0cTOBVu8rkV9KFhc6Vct7pV
 At3vrWwFrqAYZY12z10jVlYfNkBAlNaiUTAixVxGUCFAm9Pf1h+NPNWvSMRfzwr1YrADONBfOxc
 jrZ6vQ1r82qu84sMrtzL2MkCaCb4jCAQMTUCG8RKoqAsbqIyQLGHas/VJL+vQffJyOY5MTz8O8k
 G9SgUw2v3rYsiy8O9E6GvUc0IdtXnOV5EjAtiQ+BCxJ2dbe3HY7syUnzYzaVxkcuutxVRqrlkMn
 3B6UUKM8yF+Yj2+v7cuqi9KDKKMU+O3j+4IRXMDCKjUFPHGLCl3P12a+NyCaSDT8ncOBnugjsFQ
 73dEqDZysynG+XH0i3x3Q/nJ7CpHOuJISSAOjcqsiJ/XNunoDbcwxhH9qf2IyXuZ83PA5FAIe7a
 2rJPOP0jbeGjKAmtZCDWp+GN7KMxSs24Ntc1yvPGmxdZEm8YUntu+MrTihtklnfvfSA/CchpSkb
 J5JvN
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
---
 fs/nfsd/nfs4state.c | 2 ++
 fs/nfsd/state.h     | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 09b1aa2914bc..2ddc77ac7312 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1521,6 +1521,7 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	dp->dl_stid.sc_type = SC_TYPE_DELEG;
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	list_add(&dp->dl_perclnt, &clp->cl_delegations);
+	clp->cl_deleg_count++;
 	return 0;
 }
 
@@ -1552,6 +1553,7 @@ unhash_delegation_locked(struct nfs4_delegation *dp, unsigned short statusmask)
 	++dp->dl_time;
 	spin_lock(&fp->fi_lock);
 	list_del_init(&dp->dl_perclnt);
+	dp->dl_stid.sc_client->cl_deleg_count--;
 	list_del_init(&dp->dl_recall_lru);
 	list_del_init(&dp->dl_perfile);
 	spin_unlock(&fp->fi_lock);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ff1c9fa731aa..10beeb851cf6 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -632,6 +632,8 @@ struct nfs4_client {
 
 	unsigned int		cl_state;
 	atomic_t		cl_delegs_in_recall;
+	/* Length of cl_delegations, updated under nn->deleg_lock */
+	unsigned int		cl_deleg_count;
 
 	struct nfsd4_cb_recall_any	*cl_ra;
 	time64_t		cl_ra_time;

-- 
2.54.0

