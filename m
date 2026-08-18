Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 16FCF27FD43
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 00:57:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787014645; cv=none; b=bW0wkutedyvstorcaVLA2u7HAJZkRld1eusw39PYjEcq2cUKlI+OStdrvHheTaCeZ/hweUC73ePJNVhM919xbwB+4dfeyW+579fouq1XbC+jHlOPfz7C+rPw15ywDTL7l89MoFOf23LgJrKdfux3ADjObaAHYCsfn0LywwIT0/c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787014645; c=relaxed/simple;
	bh=+9mEvN2bO0y7gV8rJSRN9Oxzliz4cpSKr85XUUsdi5Q=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=Imspcmap4bMbUtOp2O+34fB/4X2rU+1KSGDCdSzyj5//SWnBxMD9tWMdFXeuTk76bVpiGHkYvIL9uIm3S3+9C/4WTl5og/iJfqaaQ05FIh9/Agrp8lfNnsXRnijdPHiCq+qdbUcF+T5Urz6B7OrUvXjZeGY4LLQNNi+w7CWxlP4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fi1IsZ1t; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fi1IsZ1t"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E8C51F000E9;
	Tue, 18 Aug 2026 00:57:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787014643;
	bh=vXwK2uvD11+OW3w4D2VeEK2mHMs0217TZLYgXW7/3fI=;
	h=From:Subject:Date:To:Cc;
	b=fi1IsZ1ttrzCrBtLoEfISge1Pio2GUT7V8TnTgGmC4TX0kb4QYs0cTkNxCFHvNW+A
	 qUAlB9+xxGct/PyYsNOWtgl6+tB9kZ44w/QSr2GiGoHw0T1eAKk3Uly006VvVXnrr5
	 nGeeH78PrzYc9SAViUUclKVm7Yme0Ff5+zT/8MH9WrUEg4+oJ1KfDW0yPxrZVkuQVV
	 +Tt2dOTADjw4qRQ9SloOLDoQdXTrMMPpPv/HqktBNg2KD90slLl/OVW1fXAHOEhymL
	 fgGNp3+RWnXuEJTXWrgXjFtpVNCf12z0A//U4/Gv4dnJ6kNFh94VRBVCQyiociNnRP
	 l3qz84WgSPcQA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/2] nfsd: fix a slab overwrite in the NFSv4.1 session
 reply cache
Date: Mon, 17 Aug 2026 20:57:13 -0400
Message-Id: <20260817-jean-v1-0-9e356596ab85@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMQQ6CMBBFr0JmbZOWpFa9inExLQMMi9F0ijEh3
 N0Wlu/nvb+BUmZSeHQbZPqy8lsquEsHaUaZyPBQGXrbX+3NebMQigkWKdyDJ48OqvrJNPLvuHm
 +TtY1LpRKa5sRUcnEjJLmNsmogymkhWWCff8DOzJRG4cAAAA=
X-Change-ID: 20260815-jean-70ae7975e5a1
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, 
 =?utf-8?q?J=C3=A9r=C3=A9my_Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1890; i=cel@kernel.org;
 h=from:subject:message-id; bh=+9mEvN2bO0y7gV8rJSRN9Oxzliz4cpSKr85XUUsdi5Q=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqg63sqqDep7snAO6mmaZ3Re2+pjidBp+pouq1i
 HEYkS5MaemJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoOt7AAKCRAzarMzb2Z/
 l7fHD/9cUnvhHbryKpx8PhhBkBmFkOJ24dKcUJRUso5RObfFk6UnzrBFLzKEnrVT3P+pYBU6QN9
 9wFRomtjUrjfHJSc/hASYM7SLa/W59BtxPyZGUdRDaUnhDWTNnyp3WLVSRkdzZLPr6+iPpR9del
 kizfLwlRrqS3KVAkSlyuVX6o/hMnNMBVSjSkiJe/XmSfh4C6tLc6Y9BcNLrIetiCcnPf8AUD2N7
 B23f3Eac0pGLlz/OM9GiNSw2uaoQEW3pnn3zAiN6blkSSAe1QXvF69owbWEcQPTAXXIA7N9ZsQR
 YUlZtVNd4dnmNHiPPlO5vXVZyVvCGUIBJniX8esI/6OJ5maYVAdCYkjYmIJZCHnG2ykoQv56oT7
 ocLktNG3cgO56oAzmOik5GHYEQko3xDpFKbHULTd4LCVHacVLeMMcXtc/UTHLrZB8mxrRvkttq4
 aPLdvvEgdlw3l5RAAUh5Y/UjZc48rPSFAMebFuLlLjRog+EVcjESHe5wNrnoudWAgSTpK9arBW8
 2/x0z6YB9mgnsgrsYPKpmuKqbUtaxRX2uawDlI7TKuF9KlQIDsy3cGTcknOEaUUmZYmywkZtZqy
 meJSehWseraXX8OY/Oe1Gc3nPXhHHTqT3++oJT6ZtRxd0MXAsXFlWpA5tQY5nmuC2GmbSdd1nOw
 Y4UzJLMIpzNNs0w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A client that can establish a session can negotiate
ca_maxresponsesize_cached down to NFSD_MIN_HDR_SEQ_SZ, which leaves
every slot's sl_data[] zero bytes long, and then send a cachethis
SEQUENCE whose COMPOUND tag fills the narrowed reply buffer. The
SEQUENCE result is never encoded, cstate.data_offset stays zero, and
the whole reply is copied past the end of the slot. Jérémy Jean found
this and reported it privately, with a KUnit fixture that reproduces
the write under KASAN. The fixture is not part of this series.

nfsd4_store_cache_entry() derives the length to copy from
cstate.data_offset and never compares it against what the slot was
allocated. Clamping the copy there would stop the write, but the slot
would then hold a truncated reply that a retry replays as a complete
one, and the slot seqid has already been consumed by that point.
RFC 8881 Section 2.10.6.1.2 requires an error returned from SEQUENCE
to leave the slot untouched, so the size has to be settled before the
slot is accepted. The copy in nfsd4_store_cache_entry() is left as it
stands.

The new check runs ahead of xdr_restrict_buflen(), which fails only
once the headers and tag alone overrun the negotiated limit. Adding
the fixed-size SEQUENCE result on top of them also rejects a request
that leaves no room for the reply the client asked to have cached.
Such a request cannot produce a complete reply today either.

---
Chuck Lever (1):
      nfsd: set op->status when an operation's header cannot be encoded

Jérémy Jean (1):
      nfsd: preflight SEQUENCE replies before accepting a slot

 fs/nfsd/nfs4state.c | 19 ++++++++++++++++++-
 fs/nfsd/nfs4xdr.c   | 13 +++++++++++--
 2 files changed, 29 insertions(+), 3 deletions(-)
---
base-commit: 76427d869120552a1a82e1f1488d9f8311827d84
change-id: 20260815-jean-70ae7975e5a1

Best regards,
--  
Chuck Lever

