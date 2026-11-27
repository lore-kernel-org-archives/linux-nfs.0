Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795801292;
	b=UTxiYmYAb2gSruNUVhBFsI7dbsON1JmeWu34RQXAifiPLMgYODppl2FplRPJBkfOd7xI
	 NixNTUdDdaDCBPJ99QB8rQ6wVvbN/Txlb+TokC4gsuFIArhNxI/zw16f91rlwQ29LNT+9
	 zBv8QrE293tSdaNZfFpjv5eytg4d4NX4jnlU31pZwnALS+iN79vvPM0DJssqUri0gMPF3
	 hP/qMftJxdcLPRaDjs2dPOypHU1D/PbT4vgazUajNNQ0sMFGSjFF6ZKnX5XYiZ0Xde68O
	 eklviXLpItxgVUEjea6lCediOcu5l6xsyNgcJVCm+dtsEKz3GvLTZLNZw1mRWlI7cUw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795801292;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=jwqM64RtEGdcvM5dPp4L9fYd7nbq9Fx36rftcIh10Xo=;
	b=hC1jq0kSXlyKWRcAeAElI4HsmfutEcUcHifKb+o/xJau3D0FM25o0s/lTXXQxcbxSCqk
	 m9fVM+TWBjMUhoYwM+AFCAbRywHcWlGUjTGaS2NOY1UFWsrBUnSiqvaQlZvn8BZ257YJ4
	 rxFFHq6lrjV04pXHp6G1+0bpM6jmWknAIiT5yfAUDaeh02wotlkUkEKLFWSy67UP8N6EI
	 wTjLYjGpLVQoAkJDIrkdSzSnp4sHSkXJKlbKtokd8LE80n1XQ3H9rKcUCqqPwLyuvBN7u
	 WcAC4/8mN5hZcsNV0SlE2EJleCPd9fPsfzUF+G7xY+aYI9mWyuSa97+dMdvl+06mx/Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RniRtZiI;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC725606A323
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 17:41:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RniRtZiI
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 083741F00898;
	Fri, 27 Nov 2026 17:41:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795801292;
	bh=jwqM64RtEGdcvM5dPp4L9fYd7nbq9Fx36rftcIh10Xo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RniRtZiIn4nlpUAZ9PxewgBybcKlOwYWGeKemlje4VaEPm4wuQNJpVMa4hLgLXLXM
	 uND2fesbN9XpnaaEsilH7l/x0ySt1Z/1zg/6YlB80vhUmWuSEUXyXsWVOIbi3OYgqz
	 0T7vfEl/ic+nlP/YwGESxV0ikmQGqKhoRcuRQMx2P9zkTAWi6wmmf5mqCeNDcLt25u
	 ZqV3KP2GCUL1MqHBNHavptPV/WHfs3OyvSjwNk1Q8ND7hE8Y/Fpt5ERmfc4Fk7eAWP
	 T8BoKBR3ctDSIxx+SLcJk3nxbdQPTlBaiZYFEw5tJ/GevQgM7rbCIMFkavLGYdal/z
	 9XQ2zce1oUbVw==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 27 Nov 2026 12:41:23 -0500
Subject: [PATCH RFC 1/5] NFSD: Cap the CREATE_SESSION slot count at the
 thread ceiling
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
Message-Id: <20261127-nfsd-slot-retire-v1-1-d9f6636cc713@kernel.org>
References: <20261127-nfsd-slot-retire-v1-0-d9f6636cc713@kernel.org>
In-Reply-To: <20261127-nfsd-slot-retire-v1-0-d9f6636cc713@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>
Cc: Chuck Lever <cel@kernel.org>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1447; i=cel@kernel.org;
 h=from:subject:message-id; bh=ZNRZ/TdjC+DFRmbI060jU7h426iKNJYT5doPy1F6HYc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrCcDJXQ/X82VZmBEil3Z+lciZvhNaV8cc/J4/t
 EW2zj6i+4mJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawnAyQAKCRAzarMzb2Z/
 l6AkD/9nDAcMMjMqqIv9jSrkCzy5ppcID1qP+fDIePqIKuI9nO2hJYKEnoSgNbCtA+GnxTiQjnP
 GUYD+Km/zqm6ZrCmwuACKjml33WH6I3vXybGA5lKba9mvsP46xikepMDWyuARPDZUhwQ7HVKB4C
 uT5VmXLCznnDNSkE74cW3XaBDNHrEG6F6Zg/+w3ZXKliy8zkrq/077l1Avr2G41s7L9UrJq7bw6
 lNXdussx5bBnzFZcLDO0gw2irWOPdFNXijQevo4jXN0cAqftUkh1p4Tj3YWN6GwszDA5slAb21N
 gi8xteBvjV93e41ARLugfWfhb9Bfz7UutnaNttcO9qMxzfMU6d9/SsKV0a9K02etwWYiMbELFNL
 rvi3HpRIO7+N3lnywU89z6qMhzKrOdSb3RD+as9MLYLaBwyrD98DtfzC9zJMidg70p3Swo3QOVW
 AF2NmEHlcO6keOt1r4ZT46B3FRe3L24xyZAOBgjwGgWVWRGLIgX6SOq+YYpWDxF+ybjf+PwfGdb
 acfzBdF4kbpqg2VGy+3JJrWjDeS6qyw6UxDkq+HfnDtZcH8Z5EzMW1aMp8bZfPqCSJxaa1JqNX9
 SHIHkr+PTN2EqTPYPzlIMpJf6tmoZqFSSdKkTbaiAVGhY3cUzBrYXQgfGNtpmeP0jnb2D+tbjAp
 qM0WsBitD83zErg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

check_forechannel_attrs() grants a new session up to
NFSD_MAX_SLOTS_PER_SESSION slots, and alloc_session() allocates all of
them up front. The growth path in nfsd4_sequence() stops at
svc_serv_maxthreads() instead, because slots beyond the nfsd thread
count cannot raise a client's throughput. A client that asks for 2048
slots in CREATE_SESSION gets a table it cannot use, and only the slot
shrinker reclaims the excess before the session is destroyed.

Apply the same ceiling in check_forechannel_attrs(), so a session's
slot table stays within it even without a shrinker to trim it.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9ebee4fca9d6..29f675b14670 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4803,7 +4803,9 @@ static __be32 check_forechannel_attrs(struct nfsd4_channel_attrs *ca, struct nfs
 	ca->maxops = min_t(u32, ca->maxops, NFSD_MAX_OPS_PER_COMPOUND);
 	ca->maxresp_cached = min_t(u32, ca->maxresp_cached,
 			NFSD_SLOT_CACHE_SIZE + NFSD_MIN_HDR_SEQ_SZ);
-	ca->maxreqs = min_t(u32, ca->maxreqs, NFSD_MAX_SLOTS_PER_SESSION);
+	/* The same ceiling bounds slot table growth in nfsd4_sequence(). */
+	ca->maxreqs = min3(ca->maxreqs, NFSD_MAX_SLOTS_PER_SESSION,
+			   svc_serv_maxthreads(nn->nfsd_serv));
 
 	return nfs_ok;
 }

-- 
2.56.0

