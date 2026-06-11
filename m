Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F0DBA481259;
	Thu, 11 Jun 2026 17:50:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781200235; cv=none; b=p4+R6at/oiufHp51BL6u18EVhIMeOQwWKPxzqdCyVjLAmmYEH2RTiJ9pXxRXCORQGp9praj4nBcWROm9/2zcUPSooq0fVsX+nxca2uh9i9eDjq7JPeYiJ2tcaOzvhne7LbghWt3i9QPBmC46ZeT1GZJci1G7kjBHGue7Bb3cqro=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781200235; c=relaxed/simple;
	bh=grNZpmtqtDrOl1PmFZLq1MU0od9JE2hW7Jg3j0BFn9Q=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=IdnHPxZ10GqXp8hzcgMPQoG9YpZCOgx3hbYtbrM5MZHGxu6i99Y9G90O6qwr/Gr84dLryyShmbS75H9PKNEHxcetMquau2NKIWqLg4Nry8hqLusKaOVqbfwiybP2JM23YB7WNSTmxy9r1O0c2qWWHlO1cyYc87V+dbXYWIzfrsA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KBxH4/DW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KBxH4/DW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 313CE1F00899;
	Thu, 11 Jun 2026 17:50:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781200233;
	bh=Da+Ni315UI6dQ7ZRwAdfmDwUEFlmAVsmtvo5KbaH9So=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KBxH4/DWNDaCg1Oyrc01RI/w80L192702Iy7injNz+Rk9KRvElRXzA/ANmLeBxodo
	 mFJYVZm6Kvq3cG3r9iL48t+Py4c3Koz3pA0aiH3wqqSWq59FtzbB2blRpejYvAyjSk
	 qJ1v4Qf27vhMu+EcIf5BULLqfH8cHlL6Qupe5nowfIH40VW61Lni7WpVwxog14r8/U
	 X2MmJWQpCPYT3ZycAp6ZFNFf66PJ2jnqDEamrQc2y2jJjHuQs5oXEuyOHB22+Fbt2g
	 pFXXT0sJs6lA4J/kmUWWXen5UPfByfzOcAB1ycBsOh7W0/vCayPIlfPYDG8L3T1N4p
	 /l7unjU6Il+Og==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 11 Jun 2026 13:50:07 -0400
Subject: [PATCH v6 01/20] nfsd: check fl_lmops in nfsd_breaker_owns_lease()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260611-dir-deleg-v6-1-4c45080e5f3f@kernel.org>
References: <20260611-dir-deleg-v6-0-4c45080e5f3f@kernel.org>
In-Reply-To: <20260611-dir-deleg-v6-0-4c45080e5f3f@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Chuck Lever <cel@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, 
 Alexander Aring <alex.aring@gmail.com>, Amir Goldstein <amir73il@gmail.com>, 
 Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, 
 Calum Mackay <calum.mackay@oracle.com>, linux-kernel@vger.kernel.org, 
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1106; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=grNZpmtqtDrOl1PmFZLq1MU0od9JE2hW7Jg3j0BFn9Q=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKvVdYGu7Jdkc6xx3QwrXf6l8NohT7L2yuv+/a
 ij60//2s9SJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCair1XQAKCRAADmhBGVaC
 FfFbD/9RtUHEy5xl74cWNpiAO7z9Ehwib7RvM2PECsj/ehgy8XvAxRs4lGcmIXodwcbNv8Q5c67
 MBf5u8uZDxICfrYPEyl0YyxSss7wWPL1Rge1klQQFq9Q5CH0nui8ZFFZCvSBr+6ATy3gnjLKNo9
 3JeLOxHU6vbisWPfSVhcgCpOnVyWGJMB2G0QV+8x0tMqun0SUz4hYz+tlnGCKsMFKBuKxwZPxwB
 fFhHqcIjjaEKKSDTWa5MDbQVKZ675LPnFlQWMMQXdlH1MP4/f85EtK0l6hKx5PJjhWGmCWhJr03
 kR/HVYKG+RzFHYHMsE5h87Zpv3BRmkVkqcoBls4e8abTOz3YA5u0u8vJpu99rVwU0kjI+bEcrMG
 6Mq2rL9v4QhkyEBDdnMENqNshZaToKFZ2R+IYI4qi8cAlkDJB37RiUQHPkCUk1QmzBBdk/YanTa
 69qKVrGo6suzcDU/HMZ6PfBatAVkjtwmucR3dHbHUSo+znLtR3bVRgtUlTn50BbEjM+MDAoIMQ+
 5JH6hzH14cqLmRJvPXbNBqHhwVKdmEOQ0Xmi+rqo/MmmmHMTKGbiQrypBhMUMyPZSHg7eiT8mRi
 OHLfEWQg1Fhefizw+hHD9yCNp7R9ovuop6z6XRPTuutUOPrkAa6hl72zX4J7DJA4/C8ercVecwh
 36JYqobWYsxrvHA==
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
index e59aec57e9e8..489558bf124c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -91,6 +91,8 @@ static void _free_cpntf_state_locked(struct nfsd_net *nn, struct nfs4_cpntf_stat
 static void nfsd4_file_hash_remove(struct nfs4_file *fi);
 static void deleg_reaper(struct nfsd_net *nn);
 
+static const struct lease_manager_operations nfsd_lease_mng_ops;
+
 /* Locking: */
 
 enum nfsd4_st_mutex_lock_subclass {
@@ -5734,6 +5736,10 @@ static bool nfsd_breaker_owns_lease(struct file_lease *fl)
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

