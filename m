Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795113241;
	b=5fwU+YkzryYyA9dQu2MT21wjb3r8T+uhLpxdjyWf16vdyXroys3i4Pe/PRnldMHZq0CM
	 9OXvDNmZbzeIZYwDnca91DzXIOqHMb+JsbKaW1ORhmTgZoSPrFLTquGzwUv7PlV5C63OG
	 +/kpcNtacEm3mhouCrH6z/z/T00eUNKxc2h/c7aLpNo3Ft1+jaY1KiBTkRAZLSSFhZsgu
	 nUeJR2ZKbsQhsL1Ho6ijkXdy7dNvofe7AdrCXWeAKtoRYkdGFyjCLbd50xHyL+Vq99SZP
	 tzToTqMFC5nrrHEV/0OcQDeTV3opNcTxhoOpE4HrX19HGjiOf8z2c7rKzqrvfXlEg3w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795113241;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=+hFEpdZqzup7+W07GQKsfWv3rE/RCMhmGsqoxnEoAOg=;
	b=MpzmwxTwWs5Q6/t9HugRpvqIGy1U48fe6EZJZlmpJecG8xuUQ0FQKHDZCn131Vth/BkD
	 ng/IxpJUKp3EAyiGmrGcVjHMo48jfa1m2AmmWj3b70cLd8glO7K9sxIJB+chpEwKJEuEx
	 WuBLsyDVj7cJUB4XPWVI4mEq3mwDAU30WtmUhOCmh8sn58LSYrxSHQr2GlGptNfo7edi9
	 1GItqhqiIg7dboB6XjOHFTl+1RzNsEkWcHsdOc/xHL2+A+43jsDgS8Md47vSdAOPxGiuR
	 hwhbwz2Pa0CsJuiiEsg+MJJ9EK/pnAWsG8TUKhYO1B3SRvLHRrsCo+tWEt/pv77FdHQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=S6qTmt9a;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03EA1606A324
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 18:34:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=S6qTmt9a
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 49EB21F000C6;
	Thu, 19 Nov 2026 18:34:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795113240;
	bh=+hFEpdZqzup7+W07GQKsfWv3rE/RCMhmGsqoxnEoAOg=;
	h=From:Subject:Date:To:Cc;
	b=S6qTmt9aYkyk4sIZkiRtFG7kl3U2EgWJokNmRnHwvBAmv+/Jea6McmchIFHNcBLOY
	 LNyMdAUnWgyJL3UFqH+3DoTHNTZjLAtfuXfCPcMG6XBoEjmaUWI0Jy1+DfiyNJIgsJ
	 gkJ6/sGY/0DfXSQzt1QjHnwR2eJMSeVmk36hy5ve0hC8ZE+rcux/9jXdsnnn0pGzke
	 hqi4jRRqo4t1GIB4XBDl8vJYo1sxbK9cO3g43JqJ8phc+QZJ7tqyDNqJRkEPavhSt+
	 7k90m3gPAODOr45M7lEg8BDwkOjP7O+RMhso9U4EkTwUULjHH+8NhB79AyBZOwhpKE
	 xYKUMHJDlLovg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/4] NFSD: More minor XDR restructuring
Date: Thu, 19 Nov 2026 13:33:50 -0500
Message-Id: <20261119-blocklayout-decode-stream-v1-0-d71322f42c28@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMSw7CMBBDr4JmzYimfARcBbHIx2kDJUGZFIGq3
 p0UvHuW/SYS5ACh82qijFeQkGIFtV6R7XXswMFVprZpD0qpE5sh2fugP2ks7GCTA0vJ0A/226P
 foVH7Gqr/Z4YP75/7cv2zjOYGWxbhsjBawCbraPulshg20YvjAikhdjTPX72KW86gAAAA
X-Change-ID: 20261119-blocklayout-decode-stream-f38f4e015555
To: Chuck Lever <cel@kernel.org>, Christoph Hellwig <hch@lst.de>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Sergey Bashirov <sergeybashirov@gmail.com>, 
 Konstantin Evtushenko <koevtushenko@yandex.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1006; i=cel@kernel.org;
 h=from:subject:message-id; bh=wfOgA3jpGzEkmgXjRvIHqTgh8i8LfSGaEggaV70fSf0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq/0ESvWOLZJ4delpRFRjnsV/TjCNWEhu3tOM+o
 Aqik5V3/LaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCav9BEgAKCRAzarMzb2Z/
 lw+WEACBAZvaIvPd2S4At3QRM0Vn/96DuZ1aUOmJYsJCcfZbg32CCgIDd7I+TCzS/IlzROwI+20
 NI6QGe/B7TZAhtkxZNlxf1zgz+GwTWST30yYOn+YnFQgyLy1tb8BN5pGRNqUzZjeEPseHUrDRmG
 z7ROu7cdHOwOd3kHVMnpriFLQusRQbpXY5ixCVF4rmvO6J4DS609MkEOq4102rIi9aP6h9im4oz
 P4N2uRSzW0JrbEi5oCYRLhPYEwG31YDlIOLfpSQJJM+v6dIf+D3O1ywH9mCtVhAm1/L+RHm7rAC
 NVm///OXjOb96tsRKOjr/aC78Qd98hUDOB4ezf7clLxjdAGcFjBWEjvPbtJg7g/OzeF7Nm10t+m
 tILnNzA5LS67Ei96y5RoN3HkwNW6CbVX5JF3NWi2/1GrJLwEM1RliDr0Mx8ABsRsC2xiSZ6+Kdl
 BoWkZNRJ45G3b7RxRS6m9cuYE8077PEHbwhImu2JKO+9LkdWeqwe6vneba7Pe6zxrQCl+EMIPHL
 uHfPZtSqb9l8jl6x7tVZk2XP2o6dCPagKp5aC2wa1SDEdy+o7NLvW4wdnRiYjE71fNDDls1uxQh
 tmEUwj4QhjrbAuJj9BNrVP5KQjqsGzpyx2mCzw6/MPLM9IqM866klo0vm63Ply5HwJNijHUek/n
 DLYG2A6NU8mOsLw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The main change in this series replaces the use of the svc_rqst's
rq_arg and rq_arg_stream fields with local stack variables, but
as usual, agentic review discovered a number of pre-existing issues
in this area that needed attention.

---
Chuck Lever (4):
      NFSD: Reject layoutupdate extent counts that wrap the length check
      NFSD: Allocate the layoutupdate extent array with kvzalloc_objs()
      NFSD: Decode block and SCSI layoutupdates from a local xdr_stream
      NFSD: Remove the svc_rqst argument from proc_layoutcommit

 fs/nfsd/blocklayout.c    | 32 +++++++++++++++++++-------------
 fs/nfsd/blocklayoutxdr.c | 24 ++++++++++++------------
 fs/nfsd/flexfilelayout.c |  4 ++--
 fs/nfsd/nfs4proc.c       |  2 +-
 fs/nfsd/pnfs.h           |  3 +--
 5 files changed, 35 insertions(+), 30 deletions(-)
---
base-commit: 8489270d1cb9568fc88f3cda4626a19807300d77
change-id: 20261119-blocklayout-decode-stream-f38f4e015555

Best regards,
--  
Chuck Lever <cel@kernel.org>

