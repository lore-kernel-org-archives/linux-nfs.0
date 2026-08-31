Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4543828315D
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 00:38:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788136732; cv=none; b=CiqzSVco+DkP3JCEJurMOtqH0kEGBPX9qSIts3+DgBjvZAOy2OPetjI5KFQrRXeX86oGHEHvRJqZGsQ/+dLZdD01y3uddciSob/MrmLpi5TeKezazkD9dHYlnoh0MOSlMWYnrxfkyjHv2cdcKMCo53wNEOAe4d7fo3FdA3qykgg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788136732; c=relaxed/simple;
	bh=c+4gIxaOViFrI4zO+9p2MfPD6nsaOpYSPrlT3+j1d6w=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=FUsSBDtDG9cl3gBSga6aGDaFW46jHvktwNMC2hFROjjDYk7RxtoJQeas7LxJW00KQfMkN+QafvZzdnrQpQN5ELwa3q9lZ7eRkBomqURqstSpZ7qo9VJh5XzgVds/UAfvTlfXSxBcJzgNokAUQtuxgt1JZD15egx2JTgOddjDV0Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=T81MTE25; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="T81MTE25"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 237CE1F000E9;
	Mon, 31 Aug 2026 00:38:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788136731;
	bh=kRPOc1XsaDAzn+AbKcHqJtZmsSMFBzvhswBrhlvUzUk=;
	h=From:Subject:Date:To:Cc;
	b=T81MTE25B5O9P+uFL/mGjPmHSZoKmteetV7J1E5rLgPaCdu+DCbO5c3d/oa9MSVtt
	 BPEmc20S4+J51IgXwCDWKFRgfFj+IfiTbT64W4vchVyx6OLAniFZRMbzbSgcKsYBQr
	 S87ioOZW1IDd0rljyupQlBJM2Y0XCPEl13QQMINTNKsSmC3nhZp9KmGx8cDVCBYtGY
	 t2siD1FzLZ6eTxeo67HfXHYjfkUElUgoD0XtpX9A4e03PTlrkLifwUWIykGEFhxSf1
	 zYp9s8lHj+sAk8q6bcJM/OROp4t4qx889g65avrdAIenlB6Oql8y/ASv2oeR4UiJ4f
	 66/zhwg1etnFw==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/5] Fix premature completion of rpc_pipefs upcalls
Date: Sun, 30 Aug 2026 20:38:37 -0400
Message-Id: <20260830-alemi-v1-0-463f80b9e9a8@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMSw7CMAwFr1J5jaUQoGq5CuoiH6c1AoPigJCq3
 p0ElvM081ZQykwK526FTG9WfkiF/a6DsDiZCTlWBmtsb4aDQXejO2Mc09Ga8dTTEKG6z0yJP7+
 fy/RnffkrhdLiZninhD47CUubJGnEQlpYZti2LwfQVrGIAAAA
X-Change-ID: 20260830-alemi-d9f420956e8d
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "J. Bruce Fields" <bfields@fieldses.org>, 
 Scott Mayhew <smayhew@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Farhad Alemi <farhad.alemi@berkeley.edu>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2310; i=cel@kernel.org;
 h=from:subject:message-id; bh=c+4gIxaOViFrI4zO+9p2MfPD6nsaOpYSPrlT3+j1d6w=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlM0PW02gy/TWaS6DfUwUdQoaZ6hTQj+XQ7of6
 UCUwq4Suz+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapTNDwAKCRAzarMzb2Z/
 l9TCD/490opFhDyw0Eq7r6sSn5+exC7yeuEhog7VatmVhcDEstX6qofXNwLE3kfYIVfKiRmQCkJ
 m/sAjcb9Hu1cAMMw0cRdPuEna+5JxuurMLBjSQPsV5jaokulm5U9tr4aYOB8w4DAgdzdVKni8zG
 zvfHq2SOvMlrgXkzjNhj2h6R3O5+NeCerVK0CzIVB2yZQR6Kst8IkzYYOhd6Zp/H9750TkP10Gb
 RFfMwSUuDdqwIM37I4xc4Ojo4RxMhgW4XrODoPCqSPYj73q5dBcHprUrTbxCNwvaTejbWDjV/Al
 CPlsHMje1eYRzwYvf78X9/+8BkZDYgycTiDAxYen/lJ6cgLE+MlV2e+GTODDt5K6c0Zx2wAREns
 SWjI9c5ErePzVHIzY6toce96ssjf2Jv0Z60LZiv7HFVUpv/N9C0NPM5F8LSWrvrHr8HWFweedsf
 A+ZGEOeRdGHJ5yDXr26XyhO71lLctq0XKlNEAfXHvlnGJ2voJCAzGT5hfHxjN3ShnZkPfUVTnYz
 A5oh4kz/bu0XNOQw+tkmNViHvPIxse4yzk3aIj+MbJCm9eYRIkYLqXOF84o/BTf6lElQUhNYh27
 SL/YBRpdkXADomuGzSBR1m6ZC2/GDC3Nhb1TZ1/dPfP4BSLDnaokKMWotPGMq0PhVcCjLEKCobF
 Kgxp0Vzs2J1HyuA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Farhad Alemi's syzkaller run against 7.1-rc5 hit a KASAN
vmalloc-out-of-bounds in rpc_queue_upcall() while NFSD was starting
client tracking:

  https://lore.kernel.org/linux-nfs/CA+0ovCjVF58WLeen2ctdzHyWUASAAW3Y=Yjihyq0pFApYawtDg@mail.gmail.com/

The cld downcall matches a reply to its upcall by xid alone. If a
write arrives before nfsdcld has read the upcall, the waiter returns
while its struct rpc_pipe_msg is still queued, and the pipe is left
holding a list_head into a dead stack frame. The blocklayout device
upcall has the same bug, plus two of its own: the waiter can go to
sleep after the reply has arrived, and a reply left over from a
purged upcall is taken as a fresh one.

rpc_pipefs pipes are mode 0600, so the writer is a daemon running as
root. These patches guard against a broken or hostile daemon, which
is unlikely. So consider the series as hardening rather than urgent.

The gss and idmap consumers keep their message in an object that
lives as long as the upcall and do not have this problem. The cld
and blocklayout fixes also complete only once the daemon has
consumed the whole message, and keep the message somewhere that
outlives the waiter.

Reading cld_pipe_downcall() for the fix turned up two unrelated
problems. A faulting reply copy strands the waiter and hangs NFSD
shutdown behind it, and an unchecked principal hash length reads past
a stack array in nfsd4_cld_check_v2().

Farhad, a run of your reproducer against this series would help.

---
Chuck Lever (5):
      NFSD: Don't complete a cld upcall the daemon has not read
      NFSD: Move the cld upcall message out of the caller's stack frame
      NFSD: Complete a cld upcall when copying its reply fails
      NFSD: Reject an oversized principal hash from nfsdcld
      pnfs/blocklayout: Complete a device upcall only on its own reply

 fs/nfs/blocklayout/blocklayout.h |  5 ----
 fs/nfs/blocklayout/rpc_pipefs.c  | 56 +++++++++++++++++++++++++---------------
 fs/nfs/netns.h                   |  5 +++-
 fs/nfsd/nfs4recover.c            | 53 +++++++++++++++++++++++++++----------
 4 files changed, 78 insertions(+), 41 deletions(-)
---
base-commit: e3c3b1a8188b192b125ae1fc9861d9a5d8d43d85
change-id: 20260830-alemi-d9f420956e8d

Best regards,
--  
Chuck Lever

