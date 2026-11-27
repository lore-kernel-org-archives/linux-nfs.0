Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795801292;
	b=sDW4RZCY2K7DjwMXjcSpchuqMfqIvL9cEV8TUrxkxRwbvhTLqReR6I663M6tDSrJlCev
	 YwK5i1tSl37PSiNrnzQqY7pv7to9aMXFmpfjA49GOlSwk1rs6zUK7wxaTQdjckVTmwOLR
	 VzWlq48po/zqtCKnPJ/O5ezKHAL0cbK6N0LX0Ck0MS2voOEAUrhpSMJAFzIPoyudVnimt
	 HPMx2P7ZF7sjelBe9VP+OgVZ2pgVq49sgnBUs5rC0OxL1nxmPXr2lbAZU6/he6w7ltzbC
	 lINfcuvnAIpO/LEpl4KgAd9pAdVAetnIqHdIHzKBrFhmwe05QToCtDQowHj6QgfiEyw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795801292;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=6+gGf55wW0NDqieHYVrN1p1lsG0XVC+VIIKKfXoHp3g=;
	b=R/pLhV7IjgO15xcCQ+MbZZ7PXuO2gS1xOhOfAtjqT3e7oDcTB3vuHC9npmHq4wT45dja
	 MGrCbFl5kucFJ2ugvg/+HEwEf3NEFyNZvn7huRkTavsrqjjcZI4PLOUXV2y544Wg6DJjb
	 R1rYJ/Yj+hxxYvh02jpkay/WdMc6CIvB9qtbj2LxjmUxywB62RSAckK8RPa68LTGqxxbZ
	 wMetUDRdfsXzJ+I0p+g/l41MfCOERE23TLQ3bH5qemSRXB3KjCIfXXHORz/YsxzO5KGa3
	 oFf7a7pj/O+PkeZvDQw4z2cxbG6pXPx9rxTj2ax+WtSZSUWKbVLaS+dg/W8fhw3Efxg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Jo9HcRLc;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35747606A31C
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 17:41:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Jo9HcRLc
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2A4601F00893;
	Fri, 27 Nov 2026 17:41:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795801291;
	bh=6+gGf55wW0NDqieHYVrN1p1lsG0XVC+VIIKKfXoHp3g=;
	h=From:Subject:Date:To:Cc;
	b=Jo9HcRLcQ897V1kbE6Hqke4Nx08DRZtgHx3nBrixbY3ABM4K8njsGzn8RKooTjvPu
	 VwpS990Pp+HZfpJRHKfY7Mlx8DgP36OcSOck7NbTFYH7JvjSIN6oAj5kDme8ci5DUt
	 QT8KL5gpqBw91Dr0DyB8nsvyPd6p5zd3u9KJb1PrknKv9QMWtjI2tPNjaaFhG44/4T
	 0kkQBC8Q2V9xuNRcI0AKCKP8RYVOJewVZNA962Pi4B8r35pRCEGQ10JKzNTEXZIeEa
	 u8k5/mjhglN+4rf03AMNXg4ExmAkepa8/XeaIoA5o0aJ9zUGepeF+vCxI292nqwS6S
	 HH6bb2XXVc1MA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH RFC 0/5] NFSD: Stop shrinking NFSv4 session slot tables
Date: Fri, 27 Nov 2026 12:41:22 -0500
Message-Id: <20261127-nfsd-slot-retire-v1-0-d9f6636cc713@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMQQrCMBBFr1JmbTANmLZuBQ/gVlwk6bQdKanMR
 BFK725Sl+/x/1tBkAkFztUKjB8SWmKG+lBBmFwcUVGfGYw2tq7NScVBeiXzkhRjIkalG9201ti
 uNR3k24txoO+evMPteoHHX8rbPzGkEisz7wSVZxfDVFTA+binE0qiOMK2/QATE9k3nAAAAA==
X-Change-ID: 20261125-nfsd-slot-retire-070786269829
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>
Cc: Chuck Lever <cel@kernel.org>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 linux-nfs@vger.kernel.org, Kari Pulli <kari@smasint.com>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=3552; i=cel@kernel.org;
 h=from:subject:message-id; bh=VGAL9gmpJ2pw6rBaM3vZwRuKGEaXjFT1BAWS8Rx6ai8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrCcDErKxufx+U/eBauT7UrniYmschQqzNgxBIx
 Cpgk6pxO3eJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawnAxAAKCRAzarMzb2Z/
 l0fSEACuDmruWc/FsmXJuMxdxHkAy+HiyGvDsoiMzZdV3t6pglvn+FcVC2m78oFOuHd6wN0gUgb
 1nE9x8oPe2Ur4iIGb4JR/Eu8f8ZhOGuzOMucGBrG/wkGmm1tYrqvKNoGn4naTtHLN+chxAnm677
 cUjKL74wm9iPD96ziO1u1KwmpC6rBp1dkQNbk5IZvPl4WXlqiW4yaQw8pEqCcDi4B1xXL+y3k+r
 Xr+BLINOpk+dPYlv3v+sVNbh7zG7BhAQRGYmJOKnrL/jm7yJpf43rHZ2OS4bcLb+uqHyvWf1FQV
 hztl2CFdsChCaSwajxWQqaLyO9UWHygOEbt7fjDxkkAV3QsIA/5KSTb5A5dfbH1NohrGn/s7EVP
 ZsIcnL1ELDbxlOSpXOwOGEiNhzxtSHpuuFMX+JJkZ4/KXxGneb/E4rlgx1m0fqw3jgwbWODYkY8
 QHbZNZQYR9KUV1zfwQZAa4S6W3MZbJbFfO06oak8FHvcZHxD59tmCxzkrvgWAP4gH4qsCL/RX2l
 TJQxhCtHWPYXFnwePH1+Z6jrk9WaJOWii1+FayPHf8lwIeF8cX1I3om0vOI4oUbrVOoUrE4Wvnk
 f4eKHQi3a3LoTvlN2Zt7GPJcEnRcepr+pMRxmrRj9bXrZkpBQ6X8fAbjYb0A8nOOQhNWnScY6Gh
 Mq1dkfdQHrlqh+g==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Problem statement:

1. We've had a few recent reports of persistent hangs due to
   NFS4ERR_SEQ_MISORDERED loops after the NFSD slot table shrinker
   runs.

   After a session slot is freed and regrown, a retransmit on that
   slot gets NFS4ERR_SEQ_MISORDERED on every retry. Session state on
   NFSD and the client has drifted apart such that the client resets
   slots to sequence ID 1 while NFSD still holds the old sequence ID
   values for those slots.

2. After a table shrink, NFSD accepts either a sequence ID of 1 or
   the remembered sequence ID of the old slot that was there before
   a table shrink, the latter case permits the server to re-execute
   the RPC the client thinks is still executing but the server
   thinks has been shrunk and regrown. This breaks exactly-once
   semantics.

Analysis:

Since v6.14, a memory shrinker lowers an NFSv4 session's slot target
so that NFSD can release the slots above the target (once it infers
that the client's slot table has shrunk). However after close study
of RFC 8881, I've found no reliable protocol mechanism for an NFSv4
server to make this inference. A server can observe that the client
has currently idle slots above the target, but it cannot determine
with certainty that these are "no longer used" slots.

Slides on dynamic slot allocation presented at IETF 86 in 2013
describe the missing mechanism [1]. A reordered SEQUENCE can make a
slot look retired while the client still has a request to replay on
it, and RFC 5661 does not specify the sequence ID of a slot that is
retired and then reinstated. The slides propose a per-slot record of
the last target sent. NFSD's sl_generation is that record, and the
hangs occur with it in place.

Proposed fix:

Since the NFSv4 session protocol cannot signal the difference between
an idle slot and a freed slot, the only way forward is to remove the
slot table shrinker from NFSD. nfs4j, NFS-Ganesha, FreeBSD, illumos,
and Buildbarn each return a constant sr_target_highest_slotid for
the life of a session, and none of them implements CB_RECALL_SLOT.

Without the shrinker, NFSD no longer frees any slot before its
session is destroyed. An NFS client whose workload grows its session
slot table can pin up to 2048 slots, or about 8MB. For comparison,
the Linux client asks initially for 64 slots, but never more than
1024.

Testing:

On 7.2.15, a pynfs reproducer shows the double execution and the
SEQ_MISORDERED loop. With this series applied, NFSD correctly
replies from the slot's cached reply. pynfs NFSv4.1 "all" results
match with and without the series. Session and client teardown,
CB_RECALL handling, and fio from a remote Linux client with
nconnect=8 against a server under memory pressure ran clean under
KASAN, kmemleak, and lockdep.

[1] https://www.ietf.org/proceedings/86/slides/slides-86-nfsv4-6.pdf

---
Chuck Lever (5):
      NFSD: Cap the CREATE_SESSION slot count at the thread ceiling
      NFSD: Remove the session slot shrinker
      NFSD: Simplify the recall-grant slot check
      NFSD: Remove the global session list and slot counters
      NFSD: Remove the dead session slot retirement code

 fs/nfsd/nfs4state.c | 262 +++++-----------------------------------------------
 fs/nfsd/state.h     |   5 -
 fs/nfsd/trace.h     |   3 +-
 3 files changed, 26 insertions(+), 244 deletions(-)
---
base-commit: 6f174a0eca19e69a14c34b0ed56b60d484f22fd6
change-id: 20261125-nfsd-slot-retire-070786269829

Best regards,
--  
Chuck Lever

