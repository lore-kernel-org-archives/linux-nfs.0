Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E2CF93B775E;
	Thu,  9 Jul 2026 18:47:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783622877; cv=none; b=k/6dCOPW3ZvxNSeJnE/qB+R9WUBl2zbF+QcnBDpFXXVme3Q9rRZePbcK+Iy8CwFeAV1uR4EMdKpghrRDlZi/yYbFIlFJehypNNnQ3o1qJ6Oa1LXmWVukx53I+TmNCYROx1zX+XGGOKpYLSssRUzwgbUks86GfHbpdZfzv4whKGE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783622877; c=relaxed/simple;
	bh=Aj6AWM8thjsX1KTVRFZtBs2SfKFBGlKud+4l4jZ6K2o=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=R/ye6cw9n0FOSlcM/eTLYK/sm6ZmRt6SWI/xYIjsotwyoqBnsnIlr69Ei3BVfFQrJMVVK1VHdxBFBz9EkGsou7B/aD8JJ9/kAeIeSgTVH+bCMHVNIijjN+EU5lcUhf/6tbTlm2KXPUgqYscYnrBoDJW7G6OrQCbe7pYFdniRrlo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LDWkP85Q; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LDWkP85Q"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C818C1F00A3D;
	Thu,  9 Jul 2026 18:47:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783622875;
	bh=dwoZyPgRZPre9Ucpe45bLI/BlbchiiScGb6Zm87JsMA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LDWkP85QkDulIF8zUYxoLdfxNFKWD1KOAllTqw19MrFg5z+IIajhnR5k9koT/pYdt
	 VKHvWL8hollQmCIIE61i8eRl6VC7BIqsVTZcf+8UiExGe9mRRo5gugkwdXIqaX+g/n
	 m/+S/JqJ9e6ycH9l+u6ivDtQXPB2Y1wulvc8m4h7CUGt1WGlqf/+UBl/qnDZbsK9xs
	 Z/u+v73QYR4aSP7Up31OaAZ7HI9Tols3s8UyGW/Tsmvfk1ouYcTDmNba2lWPj4Gbip
	 Pj2hUXtJxN0ibka7GZn7OF8cg8qVErlupsIFmq9dmkg0jPIl7wpYb5E7JT3I8cflg+
	 ZwxW7qTdF168g==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 09 Jul 2026 14:47:41 -0400
Subject: [PATCH v2 04/10] nfsd: initialize copy-notify stateid before
 publishing it
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260709-nfsd-testing-v2-4-0a1ba233bf87@kernel.org>
References: <20260709-nfsd-testing-v2-0-0a1ba233bf87@kernel.org>
In-Reply-To: <20260709-nfsd-testing-v2-0-0a1ba233bf87@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Andy Adamson <andros@netapp.com>
Cc: Chris Mason <clm@meta.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4391; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Aj6AWM8thjsX1KTVRFZtBs2SfKFBGlKud+4l4jZ6K2o=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqT+zV1Z3sVLRMUGsRD2o9FIUlBwwsT3t/z2pqS
 trAnUYkd1KJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCak/s1QAKCRAADmhBGVaC
 FetKEADCXhlcTOnf+Ab5WltUGDwylzDqzuuh2PbNxpNTOvTJ3OKp2jxZqne5My9PmAhCDN55qWO
 QmJU0+GlACdxPIEImxeo/WDGIbrXw4qYkvwIBbYRPgnxlfD4Jo7BXBWqBtM8789KrvJdqALNTLu
 WMZ1Le67HIyOejVm/Alh0RP+cPlJ7A8Ir1a28M/pM4wwCja+DY8518+9Jl4m0U2ENcm54rLJ/g8
 yeJFwwPzbUPmjGQVlAGrTAyuvZJzPCDFLFFG3dWavhe1k/eNIQV+ffI3xefxbKqDCV8aKtADFmV
 hNnGekD3TM1cCPgiAn316sso4t8N/PeLhAEp7rqkOmU1NCYJdIBU0kIDGPwcB7md1UbIxIaI4UP
 2X7xobH/kaxZc8PjruzQ8wHL/0Xl4S3JZP868EbViFHoZeZ28Jukg+FHUfssltAJNYfesRGBb5u
 8iqY5xulKruiMjvjrVF8t9yEX0k4fcBp01RMOgXBt1mOOe6+SU/21FEHFUhpI/dsRY3TiDZ1BDE
 tCdt++kFk2F3ztX+f3GRgBZpnEX0SlEBBjxCIeNhgr+Wq4f9Ev0KeZkKNI7xgnJfgYBtUquf2aq
 P+0LmeTjOFvVXjbrhMcZWatp+deEAULbiZbE46s0xtPqOoGNG3T59HC564KJCPu+LsgtGUUQdRc
 ofvO8t/Rrq7mwtw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_copy_notify() finished initializing the cpntf state after
nfs4_alloc_init_cpntf_state() had already linked it into the
s2s_cp_stateids IDR and the parent's sc_cp_list, with cs_count == 1 (the
membership reference) and none held for the caller. A racing
OFFLOAD_CANCEL (crafted cl_id == nn->s2s_cp_cl_id plus the guessable
so_id) could reach manage_cpntf_state() and free the entry, turning the
caller's subsequent cpn_cnr_stateid read and cp_p_stateid/cp_p_clid
writes into use-after-free. The owning clientid was also only recorded
after publication, so it could not gate an ownership check in that window.

Record cp_p_stateid and cp_p_clid inside nfs4_alloc_init_cpntf_state()
before nfs4_init_cp_state() publishes the entry, and return it with an
extra reference. The caller reads the stateid under that reference and
drops it with nfs4_put_cpntf_state(); on a late error the laundromat
reaps the entry.

Fixes: 624322f1adc5 ("NFSD add COPY_NOTIFY operation")
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c  | 19 ++++++++++++-------
 fs/nfsd/nfs4state.c | 14 +++++++++++++-
 2 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1c674479d4ca..2dbc99e76837 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2425,7 +2425,6 @@ nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 	struct nfs4_stid *stid = NULL;
 	struct nfs4_cpntf_state *cps;
-	struct nfs4_client *clp = cstate->clp;
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					&cn->cpn_src_stateid, RD_STATE, NULL,
@@ -2439,12 +2438,15 @@ nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	cn->cpn_lease_time.tv_nsec = 0;
 
 	status = nfserrno(-ENOMEM);
+	/*
+	 * The returned cps is already published in s2s_cp_stateids and
+	 * fully initialized (including cp_p_stateid/cp_p_clid). It carries
+	 * an extra reference for us; drop it once we are done touching cps.
+	 */
 	cps = nfs4_alloc_init_cpntf_state(nn, stid);
 	if (!cps)
 		goto out;
 	memcpy(&cn->cpn_cnr_stateid, &cps->cp_stateid.cs_stid, sizeof(stateid_t));
-	memcpy(&cps->cp_p_stateid, &stid->sc_stateid, sizeof(stateid_t));
-	memcpy(&cps->cp_p_clid, &clp->cl_clientid, sizeof(clientid_t));
 
 	/* For now, only return one server address in cpn_src, the
 	 * address used by the client to connect to this server.
@@ -2453,10 +2455,13 @@ nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfsd4_set_netaddr((struct sockaddr *)&rqstp->rq_daddr,
 				 &cn->cpn_src->u.nl4_addr);
 	WARN_ON_ONCE(status);
-	if (status) {
-		nfs4_put_cpntf_state(nn, cps);
-		goto out;
-	}
+	/*
+	 * Drop the extra reference taken by nfs4_alloc_init_cpntf_state().
+	 * On success the entry stays on the parent's sc_cp_list for a later
+	 * inter-server READ; if status is set the client discards it and the
+	 * laundromat reaps it once it expires.
+	 */
+	nfs4_put_cpntf_state(nn, cps);
 out:
 	nfs4_put_stid(stid);
 	return status;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b8946db3ebaa..1ef015cbc055 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1002,7 +1002,19 @@ struct nfs4_cpntf_state *nfs4_alloc_init_cpntf_state(struct nfsd_net *nn,
 	 */
 	INIT_LIST_HEAD(&cps->cp_list);
 	cps->cpntf_time = ktime_get_boottime_seconds();
-	refcount_set(&cps->cp_stateid.cs_count, 1);
+	/*
+	 * Record the parent stateid and the owning clientid before
+	 * nfs4_init_cp_state() publishes the entry in s2s_cp_stateids.
+	 * Once published, a concurrent OFFLOAD_CANCEL can find and free
+	 * the entry, so it must be fully initialized first. Take an extra
+	 * reference for the caller (released with nfs4_put_cpntf_state())
+	 * so the returned object stays alive while the caller reads back
+	 * the stateid.
+	 */
+	memcpy(&cps->cp_p_stateid, &p_stid->sc_stateid, sizeof(stateid_t));
+	memcpy(&cps->cp_p_clid, &p_stid->sc_client->cl_clientid,
+	       sizeof(clientid_t));
+	refcount_set(&cps->cp_stateid.cs_count, 2);
 	if (!nfs4_init_cp_state(nn, &cps->cp_stateid, NFS4_COPYNOTIFY_STID,
 				p_stid))
 		goto out_free;

-- 
2.55.0

