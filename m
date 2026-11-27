Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795801296;
	b=pQ3zZfCQGN7C+hRyFwZf6Zb51l0qF8oLwrOP/gv+IMN3yWnYMJN2bs3pE+ijwP/bqKSx
	 I3WP3Iggm7f8DueNx0lTVhKt4WbQ1cgfKF5R9OqD/H8bTCmKX0z84hcNKRE1RTbczQVzo
	 pCzyQf4Jgl4xABLG0KtIh092zac4oV7mzp4C2I2qIQ+0rTeFXWgJCq3xTJvo5iTYxrFiK
	 ZklZ6KuHSeVuBX61UTdnFF0VWa7jsY3lCSMel2ovPyof0yBGoJ9yNxpsxQ+WE6KWB5HkI
	 kFgpWnudI6zZZCAgOyST6HYuqpu1pCDC4B9jjS8lDUULTXe/Evijkx+NksI2HZkxi9Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795801296;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=dk5d2Dkvedcp0kIf+HG4hw3EVUlNYJa+/VqUUgw+Yis=;
	b=EiEbJJ3Z/h1wqYtQ2x3eETxp9OU4188/eQ2N1QuLhfy3QJ/YxhH0e+NLXWQ5zTSSuVG5
	 IaAHm8LeNemulnPnGKzbfxg9uRWe1NuWhJ4j+xS7+vAxVewkdy98X5gylOfnXEZW4DzlL
	 p2MYXOWrXT1JEliT3fujXJJgKzM+L7wdTo8oFaE/DnItjnJp4qArSQn8YTuTdAwFFal71
	 T7qAjVRJwwV9jpaLN/wYY3xqAv76IO/nmSP6P+BUgJmoYd+XRed+owK4hHxkola9ZdZEE
	 WjmShJnLzOyy+vfIgFxbKMFNcQaHTFUOh/k7Hp30v4l6p+Jl2Kh9mkkk3XkFKkfDWxg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aodSEfA+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5197D606A321
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 17:41:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aodSEfA+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D3A421F0089C;
	Fri, 27 Nov 2026 17:41:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795801295;
	bh=dk5d2Dkvedcp0kIf+HG4hw3EVUlNYJa+/VqUUgw+Yis=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=aodSEfA+aaEc8eC9dsPbyhBEjV36avtCl1DEGMeaP3gsJYfJwrakZBF7WxZsFVAvc
	 WVmRgVsPAGNrL7Q4XLjXAeUEcJkk+kt2j2XNnXSnufydQx95A2BHBdAoFP6OqPW+mN
	 PcRKQuk+oR4myUuq9MEt07J1bzZpcKvW7w/y8ursX0vH5XgylNrZGk+Vxan1suD9lO
	 OZelYcZHtOoiVqQpeXyXJs4rYDdI5Q1HLMgPZ+m5vd97B//HrxOgllqaIu7sNn0SO0
	 PKJ/WWubGi02teo/n0wTYDBX/RU9HdjrQ7exE61egiboXIp/DipJVC+OkNiSPOB+SB
	 cIpO3P1qOd1oQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 27 Nov 2026 12:41:26 -0500
Subject: [PATCH RFC 4/5] NFSD: Remove the global session list and slot
 counters
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261127-nfsd-slot-retire-v1-4-d9f6636cc713@kernel.org>
References: <20261127-nfsd-slot-retire-v1-0-d9f6636cc713@kernel.org>
In-Reply-To: <20261127-nfsd-slot-retire-v1-0-d9f6636cc713@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>
Cc: Chuck Lever <cel@kernel.org>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=4771; i=cel@kernel.org;
 h=from:subject:message-id; bh=AiA6xcUtlUYbiNCTQWCIO3XVkDJG8ogmjL0T4z++27M=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrCcDKy4qAOoGMMi43/6aMpGE01tDu2YTNlMpKM
 /45a7EdQh2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawnAygAKCRAzarMzb2Z/
 l32pD/wLfyTVhM+tWMm39uqz1M6UTnWEp922Md/qoHTrTFQbUtjmVFdkRMhWJou1DYkY0DM1dI4
 ANHLLYPR5JY6yzOU4wvW3cQTEWdsq+qHkiG3UqLM+SZN1Kf+aZOSweu9ckxt0J+WEzI7WRpxbDm
 RXD5uq94te3MThjPGytQfutob1x+XXIvJfdP3FBRye+rlnZ8yWeFO5j+j3NjQ/sBdojXUx3IXi/
 lmhz3uhnUu7qZGVfAFlEkNivYN98fWo8lWDwHgFWBD41PKWDVfZbC1qqsgb/w44aiORhr69LQsm
 3HuVgJXEr9pD1NAdk9d5Dh5qDdTtVEUTwnkrvW7qAEnMd3bLO9860/G6EO3Gm67B8jnHLqn3EKG
 3fhJeuve7towXDLW9bcxyow5J8nXsBm46ilzhsCyktwS+qQIljLVOaJr/qaVZ2TQ9FBKzGg1cJw
 3Ri/QAUivGxhs/PuSHvNwa4GtiNeM+tJl6gBY8NgPSN39ZR8Hnp0H6Oy+FR9ipDcBqddbvT4Zvo
 ogFzI5rBFt/+9cbbeI/0oKrIe/MXTd7ZsP+uASgLHm9U79c8GsauXRQtjm61I/VP+0RWiAZQOtl
 gUp92pKbNSSK8RkeR5ZGXotul12fLQG/tQT/d50CcI9JMtWycgSiCjfulF68ebHn/priZrwQFn4
 DpZmHIbU1zcpUhg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The session slot shrinker was the only reader of nfsd_session_list
and of the nfsd_total_target_slots and nfsd_total_sessions counters.
With the shrinker gone, NFSD still takes nfsd_session_list_lock, a
global spinlock, to maintain all three each time it creates, destroys,
or unhashes a session.

Remove the list, its lock, the se_all_sessions field, and both
counters.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 43 +++----------------------------------------
 fs/nfsd/state.h     |  1 -
 2 files changed, 3 insertions(+), 41 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 12d06ffc7a4e..9662b3f1fca4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2372,13 +2372,6 @@ gen_sessionid(struct nfsd4_session *ses, u64 rand)
  */
 #define NFSD_MIN_HDR_SEQ_SZ  (24 + 12 + 44)
 
-static DEFINE_SPINLOCK(nfsd_session_list_lock);
-static LIST_HEAD(nfsd_session_list);
-/* The sum of "target_slots" on every session, slot 0 included. */
-static atomic_t nfsd_total_target_slots = ATOMIC_INIT(0);
-/* Session count, subtracted from the sum to exclude slot 0. */
-static atomic_t nfsd_total_sessions = ATOMIC_INIT(0);
-
 static void
 free_session_slots(struct nfsd4_session *ses, int from)
 {
@@ -2400,13 +2393,9 @@ free_session_slots(struct nfsd4_session *ses, int from)
 		kfree(slot);
 	}
 	ses->se_fchannel.maxreqs = from;
-	if (ses->se_target_maxslots > from) {
-		int delta = ses->se_target_maxslots - from;
-
-		atomic_sub(delta, &nfsd_total_target_slots);
-		/* Retain one slot so the session can make forward progress. */
+	/* Retain one slot so the session can make forward progress. */
+	if (ses->se_target_maxslots > from)
 		ses->se_target_maxslots = from ?: 1;
-	}
 }
 
 static struct nfsd4_slot *nfsd4_alloc_slot(struct nfsd4_channel_attrs *fattrs,
@@ -2459,7 +2448,6 @@ static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fattrs,
 	fattrs->maxreqs = i;
 	memcpy(&new->se_fchannel, fattrs, sizeof(struct nfsd4_channel_attrs));
 	new->se_target_maxslots = i;
-	atomic_add(i, &nfsd_total_target_slots);
 	new->se_cb_slot_avail = ~0U;
 	new->se_cb_highest_slot = min(battrs->maxreqs - 1,
 				      NFSD_BC_SLOT_TABLE_SIZE - 1);
@@ -2610,11 +2598,6 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new,
 	list_add(&new->se_perclnt, &clp->cl_sessions);
 	spin_unlock(&clp->cl_lock);
 
-	spin_lock(&nfsd_session_list_lock);
-	list_add_tail(&new->se_all_sessions, &nfsd_session_list);
-	atomic_inc(&nfsd_total_sessions);
-	spin_unlock(&nfsd_session_list_lock);
-
 	{
 		struct sockaddr *sa = svc_addr(rqstp);
 		/*
@@ -2709,10 +2692,6 @@ unhash_session(struct nfsd4_session *ses)
 	spin_lock(&ses->se_client->cl_lock);
 	list_del(&ses->se_perclnt);
 	spin_unlock(&ses->se_client->cl_lock);
-	spin_lock(&nfsd_session_list_lock);
-	list_del(&ses->se_all_sessions);
-	atomic_dec(&nfsd_total_sessions);
-	spin_unlock(&nfsd_session_list_lock);
 }
 
 /* SETCLIENTID and SETCLIENTID_CONFIRM Helper functions */
@@ -2904,22 +2883,8 @@ unhash_client_locked(struct nfs4_client *clp)
 	}
 	list_del_init(&clp->cl_lru);
 	spin_lock(&clp->cl_lock);
-	spin_lock(&nfsd_session_list_lock);
-	list_for_each_entry(ses, &clp->cl_sessions, se_perclnt) {
+	list_for_each_entry(ses, &clp->cl_sessions, se_perclnt)
 		list_del_init(&ses->se_hash);
-		/*
-		 * unhash_client_locked() can run more than once for a
-		 * client; the session stays on cl_sessions across calls.
-		 * The first pass empties se_all_sessions via
-		 * list_del_init(), so skip the decrement on later passes
-		 * to keep nfsd_total_sessions from being double-counted.
-		 */
-		if (!list_empty(&ses->se_all_sessions)) {
-			list_del_init(&ses->se_all_sessions);
-			atomic_dec(&nfsd_total_sessions);
-		}
-	}
-	spin_unlock(&nfsd_session_list_lock);
 	spin_unlock(&clp->cl_lock);
 }
 
@@ -5384,8 +5349,6 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 						GFP_NOWAIT))) {
 				s += 1;
 				session->se_fchannel.maxreqs = s;
-				atomic_add(s - session->se_target_maxslots,
-					   &nfsd_total_target_slots);
 				session->se_target_maxslots = s;
 			} else {
 				kfree(slot);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c5f607049aaf..b3c1a6486df9 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -480,7 +480,6 @@ struct nfsd4_session {
 	u32			se_cb_prog;
 	struct list_head	se_hash;	/* hash by sessionid */
 	struct list_head	se_perclnt;
-	struct list_head	se_all_sessions;/* global list of sessions */
 	struct nfs4_client	*se_client;
 	struct nfs4_sessionid	se_sessionid;
 	struct nfsd4_channel_attrs se_fchannel;

-- 
2.56.0

