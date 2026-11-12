Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794516193;
	b=Tk+ndCwhcbzOQgu00/GWGNIN1cGpncXDxPdh35253rKkEM69qivEJijHuYTYTwNbC373
	 c6qo3pyvTyG8TLcv3L5cn6JBdoy36bRYKpjHi1pT1M9SLlyQF1uXj9SqDalAnzZjY5Q/r
	 3pFQ/T3jbLkTMIqaOkrPMOvrTxfkQcWvUQaJrZLhNww9B7rNRThrJ/vnG5PEv+H/jSlsy
	 RgWyNP4r+FlVF2EKv4OMhiyMgT8g7PyPWcby6A08ACr72Uxi/ueEV2vQJCXd+814q1kSg
	 LVq3uV4lHfBXaTaFnMcJ4HQ14T3IDBfnEUK8zlVfEjqdLhMwdtBnT/cLfFHu7GGo27w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794516193;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=VzLU5Gw1OjV2//jdRIp/6h/wcdCcqXPkHSaA5kSvWyg=;
	b=ePDKM/A3Lte4e/N+e7m8w5SQgkDnsvKyVaXZTrQYP5n/o3O4zCMdBvITfId4hi9fJmRW
	 +LxK65PkuuBE0zkqJspIJ63s1x3MIp1g2mJ/1ibljAb62R9EPIJgdzdP6zImXPM2VDaqV
	 PG/JvwbAopCceh/Wq8Fe4SMJhH8+xC6B9l8rX2re5uT96qh/UBzAUrZSW3882n3A5i3er
	 qh998lgOwNGKOO5vic7uHNxL/SGVt30c45rFlK2984T/b2kibTcr4UWdfPQKqc0jjtnlP
	 EJfQnDqREEPSFIUaQP9obbuVMVxHDYu3Cli81B0jC2A9ICdmEXnJGX2kpVTxH2PAfwA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QKiQGpZY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 31BD0606A321
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 20:43:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QKiQGpZY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DBDAF1F000C4;
	Thu, 12 Nov 2026 20:43:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794516193;
	bh=VzLU5Gw1OjV2//jdRIp/6h/wcdCcqXPkHSaA5kSvWyg=;
	h=From:Subject:Date:To:Cc;
	b=QKiQGpZYw7YDNmeBzxIwZp/Ms5QgTSgu5miv+rOp5lr+zyv1LGWN+m6P4RdXA4cQ+
	 m7ftJkFSzG9qS7Uoamv0WsCnljhotV6ymT1e07QIggM3aEOG/K96G/uLx42FBTYNgZ
	 Y/OAN6f0qJtyP4lQoD2vBhIYLbKSGem1evfRxaso/vomhsRFqEnKpjrEKYMQecQ43r
	 rvZNkwB5BOrq3JuyqVPqFm87qfaz6LZcn/Wpb/ZI5x/E9waxL7hBXiyDNhBh57vahW
	 ljz7AganoSM4HBpeU2lAtp45qy2dp9UmFoXZxq+xzgWY/CkQ8ojYEedQ1sIDkHylyf
	 w+9W8PNrjz5wQ==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v3 0/7] NFSD: Apply export security when a compound crosses
 exports
Date: Thu, 12 Nov 2026 15:43:00 -0500
Message-Id: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22OQQ6CMBBFr0K6ttopQsCV9zAu2jKFKimmg42Gc
 HcpbiRx+Sb//T8TIwwOiZ2yiQWMjtzgF8h3GTOd8i1y1yzMpJAlgMh5xDBYJOKS5yCgKXJjDVR
 sER4BrXutZZfrl+mpb2jG1JASWhFyHZQ3XToZ7A/eUsNHpNH5NkU6R+MQ3utDEVLV3+0IXPAay
 6KspASN+nzH4LHfD6FlaTzKHxdg48rFFVDUpVHHptKwced5/gANPthzFgEAAA==
X-Change-ID: 20261103-verofess-2-3101d53cfc18
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>, 
 sashiko-bot <sashiko-bot@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3390; i=cel@kernel.org;
 h=from:subject:message-id; bh=nwTdBBFngce5OPMCQvFEye7RX8RwKFULriBQsc82IJk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9iTXqZ68+n8Nlhzex2tuqFZDOYlSXoTle+bnM
 pMjxEqfCKaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavYk1wAKCRAzarMzb2Z/
 l9aPD/9lUPVwm7X1eXTegQT7J9S4DrGc8tvfDZo7905fPojlKul/tIOx/K/2ngpMwdg2Z777+5S
 e0HvYdk5Y9pBQLSK6xhOnxG2ZinddjzrNn7Y3yRrSWTwlHrxCMIpGzjGxz7h3r11e2OkVa9+ChE
 dD5ovKe60MFJs83JKcBOOuf+jOaMCqH4WHICJD1DuYhZDfb1S7Lefm7n9RJxx02aRFtlRMjikSi
 TH4bkp7TUlqzntBEensLedeq8bfDf4WZ9DHgGGeuXuLSuRexHgS0pQWt22bKweZlUD8QSdBddUi
 PEuSgG3E/+BOLVu5rljm6n9PSbErAANqR3genIUdo9zyJuVqGgGUeBwCAXcGFbkMmg9EvXtuD1r
 BBSvj6d8xhGBBE/Jhd6GjnZQ+PwR22SoemETFtzMh5fy3Fu1NYc+/FsTRE5CSphlTehbf8doEQq
 HVixo+U+tF0CriIduAdUGRB+jKeMo4YC1StsP16eMf5godtRdkEiUh37TDDiCyj0T4S7I22qXFa
 CUUm4PgA+mgJolKcEloXh7ue4g2aRN9GZLcpbq2Kg+WXvXCml+pzrpf6SGpBn01CT/7r9JdfQrD
 WN7a5G3fiSwH3FMmWGFFh5HISplvuWjC1ul6qQsCfuCcN5oAIQT17znS3f0chEyPtF6XGI4x3nD
 ZhpCdRVEXysudng==
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
Changes in v3:
- Mark the transport valid when a deferred check passes (sashiko)
- Verify the LINK target directory last in nfsd_link() (sashiko)
- Drop the nfsd_setuser() call that v2 added to nfsd4_link()
- Clear OP_HANDLES_WRONGSEC on OPEN, which nothing reads any longer
- Explain why a sys-only secure export still gets NFS4ERR_WRONGSEC
- Describe READDIR's result for a port denial at a mount crossing
- State that an NFSv4.0 PUTFH before SECINFO still reports the denial
- Link to v2: https://patch.msgid.link/20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org

Changes in v2:
- Install credentials after PUTROOTFH and PUTPUBFH (sashiko)
- Name COPY in the comment that PUTROOTFH carries
- Apply the current export's credentials after LINK (new patch, sashiko)
- Skip svc_xprt_set_valid() on a deferred check (new patch, sashiko)
- Name NFSD_MAY_BYPASS_PORT in the __nfsd_lookup() kernel-doc (sashiko)
- Correct the failed-decode comment in open_handles_wrongsec() (sashiko)
- Link to v1: https://patch.msgid.link/20261103-verofess-2-v1-0-9e6568221beb@kernel.org

---
Chuck Lever (7):
      NFSD: Check the secure-port policy when entering an export
      NFSD: Do not validate the transport before a deferred flavor check
      NFSD: Defer the PUTFH secure-port check
      NFSD: Report WRONGSEC from PUTFH when OPEN uses the current filehandle
      NFSD: Apply the entered export's credentials after LOOKUP and RESTOREFH
      NFSD: Use each export's credentials for the COPY and CLONE stateids
      NFSD: Verify the target directory last in nfsd_link()

 fs/nfsd/export.c   | 24 +++++++++++-----
 fs/nfsd/export.h   |  3 +-
 fs/nfsd/nfs4proc.c | 82 ++++++++++++++++++++++++++++++++++++++++++++++--------
 fs/nfsd/nfsfh.c    | 49 +++++++++++++++++++++++++-------
 fs/nfsd/nfsfh.h    |  2 ++
 fs/nfsd/trace.h    |  3 +-
 fs/nfsd/vfs.c      | 28 +++++++++++++------
 fs/nfsd/vfs.h      |  1 +
 8 files changed, 153 insertions(+), 39 deletions(-)
---
base-commit: 1ba84639d05b57a0cdd182966e64b4942fbe82ac
change-id: 20261103-verofess-2-3101d53cfc18

Best regards,
--  
Chuck Lever <cel@kernel.org>

