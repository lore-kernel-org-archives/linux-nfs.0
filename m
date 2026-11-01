Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=136.143.169.97
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793568124;
	b=kQ5XjYXXT+4SpeNBTm482tUjezjstQe+CeCoM7acJ5yjTfqZb5Snz/ytqJKjk403FTwg
	 4k5Shl1OQ7rcZUG9iITcLE3/Vtoyeed29hByFBaZfzQWdhwaRLzad0gNih5Ku4QFHtDFU
	 NC76+f1Nwux/kDMhNCDFBIHo/sBABt4O4CiNMi4J2RULArUBuaXl/Zfsvl8KkOCwiZTPz
	 rHBk0bvsryXeYpqFfakj7T05AKTgot50ibT1s9uIBjkuVhhD6E25j5D91NwRstVvPoIdr
	 8qfTBqie9NQW6hqhiW7KSWc7RpPE6gVEGCQdsK9L/RCcaZNfoFL6dIMcJcaNkilZn0g==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793568124;
	h=DMARC-Filter:DKIM-Signature:Received:From:To:Cc:Subject:Date:
	 Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding:
	 X-ZohoMailClient;
	bh=O2sixno5Wo4Kie4jH6khHQZLx2ZXMi60/WYTxGHP8Bc=;
	b=V4WurjfBrtcwooSVufDBg1MPK/S9iufNUWwa89oOaXZ7cw6DtOb7zGdcJXU8lnfWBFHF
	 RDndZdEUTfxX8u2r0MR5M0UWska2QQm/VbQ2NPOtSrWmXZdVNMiXSH9dLecI+JZIXE3Eb
	 xgB5S7fpeideZEi/7sqGn7g8q1V2I2VwFevy5Cp0KnAGuLocsJYUUcNwyj70hof7TRBEF
	 gtpaOJbDBuyrCawMjDC9kX6NPBT0faxzJUmp8vzNYtoD1CWc8jRwp1KZTbHaPGddu0ADq
	 8AkpqZK7IOcHbNX43/1EjchkFO1igZCq38rFue23CjHyi/w6IwTP/R305tRCBJiBoDg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=zohomail.eu;
	spf=pass smtp.mailfrom=zohomail.eu;
	dkim=pass header.d=zohomail.eu header.i=@zohomail.eu header.a=rsa-sha256 header.s=zoho header.b=rrU7Bg6n;
	arc=pass header.oldest-pass=0 smtp.remote-ip=136.143.169.97
Received: from sender-pp-o97.zoho.eu (sender-pp-o97.zoho.eu [136.143.169.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 07D3A606A324;
	Sun,  1 Nov 2026 21:22:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 07D3A606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=zohomail.eu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=zohomail.eu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=zohomail.eu header.i=@zohomail.eu header.a=rsa-sha256 header.s=zoho header.b=rrU7Bg6n
ARC-Seal: i=1; a=rsa-sha256; t=1793568098; cv=none; 
	d=zohomail.eu; s=zohoarc; 
	b=cxv0TJtwYqakzp5G5cbG2g+quUTcfT/BGjtlWiYrNRj/2qzwAAPvN972cnBSmw/DRRo5agNoSaQxA1FrYAXxYmK6zDFqU2s70tEueWJQaBaoCO5PbBwK0xKiT+xs5SyzHslyq8vv2bkLVp0i3xUdaq3VaGC+k6vkEDOgiXgJ7Ho=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.eu; s=zohoarc; 
	t=1793568098; h=Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:MIME-Version:Message-ID:Subject:Subject:To:To:Message-Id:Reply-To; 
	bh=O2sixno5Wo4Kie4jH6khHQZLx2ZXMi60/WYTxGHP8Bc=; 
	b=h6ttrkbeHRH2/edsBPz203KJIztHnQGdNqsLagcuPAk2+9dUA06qCL3SWBzYpRDTc4istqnL2OVRj0h93ikrqwQfclEfwVniNWwfy/bq9oDW7UZBUPwJtzQCwc1lUmm2ZPTgU1qpgrEoHqYizqSAS3OsyRWCSQi781pAyCFitm4=
ARC-Authentication-Results: i=1; mx.zohomail.eu;
	dkim=pass  header.i=zohomail.eu;
	spf=pass  smtp.mailfrom=harukak@zohomail.eu;
	dmarc=pass header.from=<harukak@zohomail.eu>
DKIM-Signature: a=rsa-sha256; b=rrU7Bg6nb1QNvNrfs+lRIl3so/6q1xu3PBgdULPovAKLtYriX6EKAqtMLEBBFN9as9hGxEdNNLZdd1O8LTmvhoj4jfxL6kZmLyJ21lC2l22T+kbo59pI4VpDHT2Ymtaao1CzHYhwWQilXjYLQYgtp1lW6VZVmXrfOWOdyd/2VFw=; c=relaxed/relaxed; s=zoho; d=zohomail.eu; v=1; bh=O2sixno5Wo4Kie4jH6khHQZLx2ZXMi60/WYTxGHP8Bc=; h=Content-Description:Content-ID:Content-Type:Content-Transfer-Encoding:Cc:Date:From:In-Reply-To:List-Subscribe:List-Post:List-Owner:List-Id:List-Archive:List-Help:List-Unsubscribe:MIME-Version:Message-ID:Resent-Sender:Resent-Cc:Resent-Date:Resent-To:Reply-To:Resent-Message-ID:Resent-From:Sender:Subject:To:Date:From:Message-Id:Reply-To:Subject:To:Cc;
Received: by smtp.zoho.eu with SMTPS id 1793568096866663.084048042429;
	Sun, 1 Nov 2026 22:21:36 +0100 (CET)
From: Haruka Kuze <harukak@zohomail.eu>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd: don't access freed memory when cannot grant a write delegation
Date: Mon,  2 Nov 2026 06:21:35 +0900
Message-ID: <20261101212135.1231222-1-harukak@zohomail.eu>
X-Mailer: git-send-email 2.55.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-ZohoMailClient: External

From: Haruka Kuze <harukak@zohomail.eu>

nfs4_open_delegation() hashes the delegation before the call to
nfsd4_add_rdaccess_to_wrdeleg() and nfs4_delegation_stat(), both of which
can sleep, and it calls destroy_delegation() from the error path after
dropping the caller's reference.

Moreover, a DELEGRETURN from same client can unhash the delegation and
drop the hash reference in this window, so nfs4_put_stid() frees it and
destroy_delegation() then reads freed memory.

Call destroy_delegation() before dropping the caller reference.

Fixes: c5967721e106 ("NFSD: handle GETATTR conflict with write delegation")
Cc: stable@vger.kernel.org
Signed-off-by: Haruka Kuze <harukak@zohomail.eu>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1de6c6d757c3..b13d05fe8993 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7300,8 +7300,8 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 		f = rcu_dereference_protected(dp->dl_stid.sc_file->fi_deleg_file, 1)->nf_file;
 		if (!nfsd4_add_rdaccess_to_wrdeleg(rqstp, open, fh, stp) ||
 				!nfs4_delegation_stat(dp, currentfh, &stat)) {
-			nfs4_put_stid(&dp->dl_stid);
 			destroy_delegation(dp);
+			nfs4_put_stid(&dp->dl_stid);
 			goto out_no_deleg;
 		}
 		open->op_delegate_type = deleg_ts ? OPEN_DELEGATE_WRITE_ATTRS_DELEG :
-- 
2.55.0

