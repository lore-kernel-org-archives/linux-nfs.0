Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793735576;
	b=B68X5u5YlOREnSyY10SVpWJChYoKvmygodIE8TH7rIEmN450MK2SxLMD2S1gubBFjN9o
	 u3FeBt8L7VZYnuWEBSBLB036AxskwAR1VSKeyEInuIF3iEQGqz6ZSk3kYA0NELWVH0Xt2
	 uVtjcnEzIe4nzknmiW+gJNvJV5C4+yrAdxreS4dbzAXqn1fLoy4vfE05u8b5Urt5NR2bP
	 1VFdhexHdxOpJVIpAyrv0oYTZOwViC2vjmVN8573S6MxQnGlI+LCRlf8/cgy2jJUXx4EJ
	 fLIPregW8KgwzzB+uqlewVL083A1qytO7dpM94poinyHj5d0BS9IEEjGUHHSKXvsEFw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793735576;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=/rwigdIUNzwp71CbGdNZ2Ix3gIWfjYURbq0aMA+gBpY=;
	b=EggTmtUaSz1H5J0H0lhHvXaTxvDj3/9VNpBo2jaicnAAtzTf0YwL5BKKNp04JxthKqnY
	 LjSOEFytaFiJ8W7vV153hl5D0iKT42PdoKBdC7CDRA1ZgRFkBIA350+3VMgQF5B9DFUE8
	 lTs6MxwQ3cpW+i0iJxdirPHQ/QIVni2+bDq+Q8lPdtPJVtXg7dldj4yx7KWKtKHZj3Lyv
	 68TljwoBYpxPXzhtNtW28PyZfTN4TouiaLyda/XW8Sj/ptBh/xz9VWi1IrKX8KKaNrKZ+
	 Z4UZvi/x/ZTodQEU5QojzYaEbRmKknxTy9oqP1kfzPQf7twPOGK2MlS4D8XM3IRA1nQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="SJF50/8Q";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A037606A32C
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 19:52:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SJF50/8Q
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 583381F000C1;
	Tue,  3 Nov 2026 19:52:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793735576;
	bh=/rwigdIUNzwp71CbGdNZ2Ix3gIWfjYURbq0aMA+gBpY=;
	h=From:Subject:Date:To:Cc;
	b=SJF50/8QHAGSHWIDh+wkoppkHFbcbYQn3U/t5T4falFlyntDXlC1LzKzX9aN+KFuK
	 6UNhkbLFcLlsedxpaoh0u4fEKXNE6vNdotOjGdhO+SSssyWOS9GGZ1BvcSXXCF5/R/
	 O2SM67xlLNYBUQ4o3jYpjvh4X8SmqdTpbvXh65yjfbV2q9qgYfMVh5AtzvahjOUIxA
	 vPPadER/3iQ0/UO2LvS3CH5U03ny56B1MlhSyL934D3Man9qr16hsUvEzqy+GQ/s6c
	 tF7/uXNQh+ehVVoIEHZGMsGDcQNLM7Dl06LNbs3Ww2mEwlHF2+cjWO8KpvqkmuUgiE
	 TVQ3szpeqpsmg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/5] NFSD: Apply export security when a compound crosses
 exports
Date: Tue, 03 Nov 2026 14:52:35 -0500
Message-Id: <20261103-verofess-2-v1-0-9e6568221beb@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMQQrCMBBFr1Jm7WDSoIhXERfJZNKOSCqZWITSu
 5vo8n3+exsoF2GF67BB4VVUltzAHgag2eeJUWJjGM14ttY4XLksiVVxRGeNjSdHiewFmvAqnOT
 zi93uf9Z3eDDVXuiP4JUxFJ9p7hPx85iTRqysVfIE+/4F0pejF5EAAAA=
X-Change-ID: 20261103-verofess-2-3101d53cfc18
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2168; i=cel@kernel.org;
 h=from:subject:message-id; bh=gGgMTPKFvvN1pcT6Oj3y+LRF0RKSMpBv/AZxKZy1Kuw=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6juOBOKePWmuQCMpIpwdp5bv/M8S+QvPhgucG
 AMEF5qczNGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauo7jgAKCRAzarMzb2Z/
 l5y/D/0T382AmrQr8MbRD2ul5eY+PZNh570ODr5r4ZQbd5L+ISA/GC7cBf1IEsM7xt69FFy7J/2
 0qO2+3B6l7E94yfueh650fDbdqLmRP/0ayvS9/hxJQy8MuN2q5USbw9dYwh7M+RTr3mz+v8KsO1
 M121iRH1RSMemi24WQVIbezql9/U+oiUr0SCfmEp3ptxL91h+cvSvEu2wKz789SE+36KLBDWf21
 hK6FMamxd6L4QNC70daAwNdF2ibUSNzu4Q7+I6FSPa9axgRkwuaoLvrDV0oaDTP1Bns/bN3zbAa
 aCHraAhQfVdTMoQ1QMi5bFcuCeb832hEeUJPkStaNXfyMkS9Y3LIVnbnupW3Y6TZsoHhYgJPAG8
 fRFOBNHCyej21S1vcqugIfP53FQ1xjNuTv7PNFoaM+N+0JNUITlPu90I1sMhs4Z8Qp159Jf+OPT
 YnMwn3CkZXCCXEVOd2T0r8YEDxbYrusZESdC+sjJgmHMBYFskxtJARn4K5rI38IwsqEYrQfZL0H
 5KVEDmo95yQKdiyd1C36KhA0oLzDHBxHe07dXS1DrY72V0Nvnf5TA/HPX5vfM9n9tAg68ouBv2v
 Pz+oUgKqY9RwlEts6jXLqDRBYcQ0Jl2Hc9MKtubzNJO2TBjBWfM3sXxPVtIxRpUwfaNsuf6hXzd
 JNx46lio5+fbrmQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

VeroFess reported that a compound can move the current filehandle
into another export without NFSD applying all of that export's
policy:

  https://patch.msgid.link/20261103013237.1174538-1-coderzeng@gmail.com

fh_verify() is where NFSD checks an export's secure-port setting and
installs the credentials its squash options map a request to. A
LOOKUP that crosses a mountpoint, RESTOREFH, and the saved filehandle
that COPY and CLONE consume do not go through fh_verify(). An
operation that then uses an OPEN stateid, such as READ, CLONE, or
COPY, resolves the stateid without calling fh_verify() either. The
request runs under the previous export's port policy and credential
mapping. The requester must already hold an OPEN stateid that NFSD
granted after a full check, so the exposure is a client that keeps a
stateid across a change of port or of export options.

Rather than repeat fh_verify() at every crossing, this series makes
the crossing path itself complete. check_nfsd_access() gains the port
check, so a check added there covers LOOKUP, LOOKUPP, and the COPY
source alongside PUTFH. nfsd_setuser() runs after a crossing and
after RESTOREFH, and once for each side of a cross-export COPY or
CLONE.

---
Chuck Lever (5):
      NFSD: Check the secure-port policy when entering an export
      NFSD: Defer the PUTFH secure-port check
      NFSD: Report WRONGSEC from PUTFH when OPEN uses the current filehandle
      NFSD: Apply the entered export's credentials after LOOKUP and RESTOREFH
      NFSD: Use each export's credentials for the COPY and CLONE stateids

 fs/nfsd/export.c   | 24 ++++++++++++++------
 fs/nfsd/export.h   |  3 ++-
 fs/nfsd/nfs4proc.c | 65 +++++++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfsfh.c    | 45 +++++++++++++++++++++++++++++--------
 fs/nfsd/nfsfh.h    |  2 ++
 fs/nfsd/trace.h    |  3 ++-
 fs/nfsd/vfs.c      | 17 +++++++++-----
 fs/nfsd/vfs.h      |  1 +
 8 files changed, 128 insertions(+), 32 deletions(-)
---
base-commit: 693afd3ce9ae5cddb7225ec87975e6ef1443e502
change-id: 20261103-verofess-2-3101d53cfc18

Best regards,
--  
Chuck Lever <cel@kernel.org>

