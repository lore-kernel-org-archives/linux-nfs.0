Received: from mailout4.samsung.com (mailout4.samsung.com [203.254.224.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6426C414406
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 07:03:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=203.254.224.34
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790924632; cv=none; b=e7g69Vq+K3c3u15i6a8mB3KlXlaYXNJ1yjVWk88+uixHCDkY+f3xwJ5UZXkARCtvwR1Mf/kkpov4wPMe2Y30S5WY8LHdVFJomqYTNgK11UUJBVjniBJVJMm1HsS9e+D9IlQzZ9Q/FXwWoiR+msAmxc7DpMJlBMD7EZ8YWr0z8Fs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790924632; c=relaxed/simple;
	bh=ZRLK9Xfq/852TvpiNnY6YBdiIbx92Vnng+DlryrUxlw=;
	h=Mime-Version:Subject:From:To:CC:In-Reply-To:Message-ID:Date:
	 Content-Type:References; b=gkU7TwSPG3hHcD5X+kk4C5YI4iALdg8kGXtVqJLjJvEuEEijEQGv20slvv3ytCeafXO8dLjaeMh+Fq7YkopQIG32LtvB1B44l4GtbuQkhB3b6LM8VGFAoxNe4eJYQMTIv8R0ejofA7aXPn+oH/wm5/rAlj4tRIGNqzWXPLpdHH8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com; spf=pass smtp.mailfrom=samsung.com; dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b=VUaVlqmV; arc=none smtp.client-ip=203.254.224.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=samsung.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samsung.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="VUaVlqmV"
Received: from epcas2p1.samsung.com (unknown [182.195.41.53])
	by mailout4.samsung.com (KnoxPortal) with ESMTP id 20261002070348epoutp042971ad54ef5a2eab85975a9a6d510af9~apHXpU9qq0721907219epoutp04e
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 07:03:48 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout4.samsung.com 20261002070348epoutp042971ad54ef5a2eab85975a9a6d510af9~apHXpU9qq0721907219epoutp04e
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1790924628;
	bh=7HqN1Vx6yBbpaHNRy8ORyBDiazEMrazm50bZ8i01OPA=;
	h=Subject:Reply-To:From:To:CC:In-Reply-To:Date:References:From;
	b=VUaVlqmVLaqkDhKh2QE2KVuTX3qUHjCk3KDPe6jNldCPAWHilLrW2DFNDmlGTIQKd
	 DcWmF5614RBodhI7gIK2b+vnTSOhzhfTis1Q4Gl5TVVrGKLfVWGQJPyVrjNFlUfTGw
	 jcOeeaSuZk1+LiPjNnhZ4o1E6kJxOZG6FsCfWupM=
Received: from epsnrtp02.localdomain (unknown [182.195.42.154]) by
	epcas2p3.samsung.com (KnoxPortal) with ESMTPS id
	20261002070342epcas2p35b772ffe3226af31a7314d1e5090bd73~apHSk24cm2248022480epcas2p30;
	Fri,  2 Oct 2026 07:03:42 +0000 (GMT)
Received: from epcas2p3.samsung.com (unknown [182.195.38.208]) by
	epsnrtp02.localdomain (Postfix) with ESMTP id 4hx0B62kk2z2SSKj; Fri,  2 Oct
	2026 07:03:42 +0000 (GMT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
Subject: [PATCH 2/2] nvmet: fix preempt of another registrant by the
 reservation holder
Reply-To: daejun7.park@samsung.com
Sender: Daejun Park <daejun7.park@samsung.com>
From: Daejun Park <daejun7.park@samsung.com>
To: "hch@lst.de" <hch@lst.de>, "sagi@grimberg.me" <sagi@grimberg.me>,
	"kch@nvidia.com" <kch@nvidia.com>
CC: "kbusch@kernel.org" <kbusch@kernel.org>, "kanie@linux.alibaba.com"
	<kanie@linux.alibaba.com>, "linux-nvme@lists.infradead.org"
	<linux-nvme@lists.infradead.org>, "linux-nfs@vger.kernel.org"
	<linux-nfs@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Daejun Park <daejun7.park@samsung.com>
X-Priority: 3
X-Content-Kind-Code: NORMAL
In-Reply-To: <20261002070200epcms2p593a0aa8ac482e776e8f1de89d9f212ae@epcms2p5>
X-CPGS-Detection: blocking_info_exchange
X-Drm-Type: N,general
X-Msg-Generator: Mail
X-Msg-Type: PERSONAL
X-Reply-Demand: N
Message-ID: <20261002070341epcms2p4e1409e8fcea145562a2996ad1d1d24ea@epcms2p4>
Date: Fri, 02 Oct 2026 16:03:41 +0900
X-CMS-MailID: 20261002070341epcms2p4e1409e8fcea145562a2996ad1d1d24ea
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
X-Sendblock-Type: AUTO_CONFIDENTIAL
CMS-TYPE: 102P
X-CPGSPASS: Y
X-CPGSPASS: Y
cpgsPolicy: CPGSC10-223,Y
X-CFilter-Loop: Reflected
X-CMS-RootMailID: 20261002065931epcms2p1cb2c16f98cf3b05f8c859ad92b0ad465
References: <20261002070200epcms2p593a0aa8ac482e776e8f1de89d9f212ae@epcms2p5>
	<20261002065931epcms2p1cb2c16f98cf3b05f8c859ad92b0ad465@epcms2p1>
	<CGME20261002065931epcms2p1cb2c16f98cf3b05f8c859ad92b0ad465@epcms2p4>

Unless the reservation is of an All Registrants type, nvmet_pr_preempt()
treats every Reservation Acquire command with the Preempt or Preempt and
Abort action that is sent by the reservation holder as the holder
preempting itself.  It updates the reservation type to RTYPE and
completes the command successfully without looking at PRKEY.

NVMe Base Specification 2.1, section 8.1.22.7 makes the action depend
on PRKEY for these reservation types, no matter which registrant sends
the command:

 - PRKEY matches the key of the reservation holder: the reservation is
   preempted.  This is how a holder preempts itself.
 - PRKEY does not match the key of the holder and is not 0h: the
   registrants whose key matches PRKEY are unregistered.
 - PRKEY does not match the key of the holder and is 0h: the command is
   aborted with Invalid Field in Command.

With the current code, a holder that preempts with the key of another
registrant leaves that registrant registered, changes the reservation
type to RTYPE and still gets a successful completion.  With hosts A, B
and C registered with the keys 0xa, 0xb and 0xc, and A holding an
Exclusive Access - Registrants Only reservation, A sends:

  # nvme resv-acquire /dev/nvme1 -n 1 --crkey=0xa --prkey=0xb \
        --rtype=4 --racqa=1
  NVME Reservation Acquire success
  # nvme resv-report /dev/nvme1 -n 1 --eds | grep '^regctl '
  regctl    : 3

and B can still write to the namespace.  Preempt and Abort (--racqa=2)
gives the same result.  When C sends the preempt instead (--crkey=0xc),
B is unregistered and its writes fail with Reservation Conflict.

This defeats fencing in the pNFS SCSI layout server.  nfsd holds the
reservation and fences a client that does not return its layout by
calling pr_preempt() with the key of that client and the abort flag,
which is the command RFC 9561 section 2.2.3 asks for.  On an nvmet
namespace the preempt succeeds, nfsd logs the client as fenced, and the
client keeps writing to the device.  In a test with an nfsd server and
two clients on an nvmet-tcp namespace, the namespace still had three
registrants after the fence and the fenced client went on writing to
it.  With this patch two registrants are left and the writes of the
fenced client fail with a reservation conflict.

Take the self preempt path only when PRKEY is the key of the holder.
Any other PRKEY sent by the holder is then handled by the code that
already serves a non-holder registrant, for Preempt and for Preempt and
Abort.  For a host that holds the reservation this changes the
following:

 - A preempt with the key of another registrant unregisters the
   registrants with that key, sends them the registration preempted
   notification and leaves the reservation type alone.
 - A preempt with PRKEY 0h fails with Invalid Field in Command.  A
   holder that changed its reservation type this way has to pass its
   own key in PRKEY, which works with and without this patch.
 - A preempt with a PRKEY that matches no registrant fails with
   Reservation Conflict.  The specification defines that status only
   for the All Registrants types.  It is what nvmet already returns to
   a non-holder registrant in this case and what the SCSI target
   returns for an unregistered key.  nfsd treats it as a successful
   fence.

Not changed: when the holder preempts itself, registrants that share
its key stay registered.

Fixes: 5a47c2080a73 ("nvmet: support reservation feature")
Cc: stable@vger.kernel.org
Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
 drivers/nvme/target/pr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/nvme/target/pr.c b/drivers/nvme/target/pr.c
index bfd5447f6..665cee8fc 100644
--- a/drivers/nvme/target/pr.c
+++ b/drivers/nvme/target/pr.c
@@ -585,7 +585,7 @@ static u16 nvmet_pr_preempt(struct nvmet_req *req,
 				&ctrl->hostid, abort);
 	}
 
-	if (holder == reg) {
+	if (holder == reg && prkey == holder->rkey) {
 		status = nvmet_pr_update_reg_attr(pr, holder,
 				nvmet_pr_update_holder_rtype, &rtype);
 		if (!status && original_rtype != rtype)
-- 
2.43.0

