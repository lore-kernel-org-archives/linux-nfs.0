Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7C72E3D3009
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 20:44:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791319475; cv=none; b=lMTNKxmaPM0s/0VCRzI/IdxkJR8+PFcMkXLEb1WJc9p+u6CZWCx1j6I0Ouy3K4UBAxaxDchagYcBZiCUILgYxE2KYuRYurUAAKb6B8KTK8TYaGVugnjl3/WnIZUJwWY5yuXON3wn+WMo1TD7H8W6MemI/pZ9duup1rUeBKw5VSc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791319475; c=relaxed/simple;
	bh=O2764/9bZJ5OUyqaoWs5tL9UfwRHq6AaKCp5xlfGReo=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=LkY/EzkPuQH2L4RNO1Qtw+ACiYXEX+xfpbhe2C6gdtzbKTaF6L+J7CYDQ6EUHPaYTfU3IwGcbWg/8e2Pm3mA0SkNmTBc6kKKDWLAdf6TeT8FqVFx9nt9/3+Ov60p3e5Ez2EIsDYZdZIgGh0IQpSgVr91yPK3AhCFgBOcPd/w1xA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HvXgPHYJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HvXgPHYJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9CF651F0089D;
	Tue,  6 Oct 2026 20:44:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791319474;
	bh=x3AlM0h/9gT92K/ViZhpOOKIyzQM5HmC0lIcIADgvVI=;
	h=From:Subject:Date:To:Cc;
	b=HvXgPHYJ0EE2HEUqpLQybEsWDDibQs2BRSk7G4d715GKk2jw4/JuI40yl/Nl3gfOy
	 XGfXTn7lySAhAwqWC03YzIxSrg08HAOMeZDp6L7aaGCzU/ffokyk/I+Hs1zihSYrD0
	 81jOKQ5Yq8nLmXLwhMqpPvwiVETsmBD3Pn7hBhjRLc5Mh0q74/CvN1RAnwQNmKPoTz
	 YoiLbNDeuR9EvW4Qax+UTrDlk3qRQ0Z1OPnye+CyfpstCf9kQGP0SnnUO15nGAIDRs
	 USwBjaUGtTbgzOFdEPgSiI0iACQ/zaepyM7p/VadfKxdwlajlMsSM2P6k+c+CVgpPQ
	 clJFj31Qry+mA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/2] NFSD: NFSv4.0 stateowner replay cache fixes
Date: Tue, 06 Oct 2026 16:44:13 -0400
Message-Id: <20261006-open-replay-fixes-v1-0-0c668a3e7216@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMSw7CMBBDr1LNmhFJ+YhyFcQiH7cNqtIqExCo6
 t1JYPlsP68kSAFC12alhFeQMMcCeteQG00cwMEXpla1Z63UiecFkROWyXy4D28IXzp9wFH5zne
 airck/Iqi3e5/lqd9wOV6VBfWCNgmE91YI4dpH3vxnCE5xIG27QscoQqpmAAAAA==
X-Change-ID: 20261005-open-replay-fixes-8913e40d9d91
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2289; i=cel@kernel.org;
 h=from:subject:message-id; bh=O2764/9bZJ5OUyqaoWs5tL9UfwRHq6AaKCp5xlfGReo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqxV2kDA/gXhCn0qOCFSyy58uV6aprbYzBf7z5b
 VlnC03fK7qJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasVdpAAKCRAzarMzb2Z/
 l+3cD/oCbvZJpE0jrtBDo4FnpTKVALpSzTI/5by3fBbF/na0PFnN5o45xQsxKtQGlCS44j0tfBb
 iB07UV5a9a8KqsWddPXn6PUlk5/eQ2kcGHJ40uZSzc1Qpz1DYklO06z//fzk0Vi1rWn68QmTixS
 EXIxA+UQzF11KzdqDVQCmHHorzk2Q3HCV+SL3j6ebc1hjkqDbudmtgbXn9LRxSOgeeF2e7YnOiL
 AxppVNymTyWH9CEm/ZQn7lN3qdqM8wEwMH1Za7Imh0b0SrbQiQIjOsk5ZrC3ub9kRUDL3B35LIG
 PAL8ecD/nYzaJnrlMNii6NlBmXhhXJ117TvsXGcTuApQn/emdvDMAP/e3hTmPEjaST2Y9a8xBUr
 03V+AeZcBIccbaSjr7Nr1Qdnpn3M0PaIBU73I7WTOZaTn6yULxIT7joIdTjRuS7S3VHuKl095cS
 Blwepgc+tE3juBPNudSqwjBGAze2zWV5Ww0ulK7+OQypeux6J55vzHYhSOvoGbc7Wg8JUdO0Sjh
 j1EXY88cG+bxatjzZN0DBAh3FA96PSrOyT6VFkOD2tHikLTRrOz7TlieW+oZGERs18cykrYT7Dk
 lgr8q+yZcZmOUV7/ZyAmzA2CWbJwjSE0Tz9Eyz8b8gRxskYNZmtRQATxTGTEQVOnoqxXCPhu5xy
 7FC2nVCtccpipxw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFSD caches an NFSv4.0 open-owner's or lock-owner's most recent
reply in the so_replay field. When OPEN, OPEN_CONFIRM,
OPEN_DOWNGRADE, CLOSE, LOCK, or LOCKU fails with a status that advances
the seqid, NFSD currently advances so_seqid but leaves the previous
reply in so_replay, and sends the cached reply in response to a
request that reuses the failed operation's seqid.

pynfs found the defect by resending an OPEN unchanged after
NFS4ERR_DELAY, a resend RFC 7530 Section 9.1.7 forbids. A client
that follows Section 9.1.7 reaches the same code when it retransmits
after a reconnect. The duplicate reply cache does not catch these
requests: nfsd4_decode_compound() marks a COMPOUND RC_NOCACHE unless
one of its operations has OP_CACHEME, and no seqid-mutating
operation has it. NFSv4.1 and later are not affected, since a
COMPOUND in a session has no replay owner.

The OPEN replay path has a second defect: when fh_verify() of
rp_openfh fails, NFSD advances so_seqid as for a new OPEN.
Once failed operations are saved, that path would also overwrite the
cached OPEN reply with the fh_verify() error, so its fix comes first
(patch 1).

After this series, a seqid-mutating operation that succeeds and is
then truncated to NFS4ERR_RESOURCE still advances so_seqid without a
save, so a request that reuses its seqid receives the previous
operation's reply. NFSD also still compares only the seqid, though
RFC 7530 Section 9.1.9 requires NFS4ERR_BAD_SEQID when the operation
differs too.

I've tested this series with pynfs NFSv4.0, augmenting it with new
st_replay.py tests that resend a failed OPEN, OPEN_CONFIRM,
OPEN_DOWNGRADE, CLOSE, and LOCKU with the same seqid and a new xid,
expecting the cached error and then success at seqid N+1.

The new tests will be posted to pynfs separately.

---
Chuck Lever (2):
      NFSD: Release the replay owner when an OPEN replay fails
      NFSD: Save the stateowner reply when a seqid-mutating operation fails

 fs/nfsd/nfs4proc.c |  7 +++++--
 fs/nfsd/nfs4xdr.c  | 15 +++++++++------
 2 files changed, 14 insertions(+), 8 deletions(-)
---
base-commit: ee791ecdff6410f241e180338694033889b37607
change-id: 20261005-open-replay-fixes-8913e40d9d91

Best regards,
--  
Chuck Lever <cel@kernel.org>

