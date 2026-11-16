Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794872658;
	b=WLdQHTeGml4k2ZZUm7xvCh6YYkjv8PJANVLGcG5VdNAAvSo+mdBF1f77xsV9guj14Tm2
	 W68gFvs4eT9dt6rN2Spbs2cg6B6SuIbtAeEyYonqNRthcbd46kqZIK9u0UrMqULC1bwtB
	 skklQ5w8Mk4q4JxS9QPl4vjbMS9EqDZbez8ZvWK3OjLb/1RZMoX8Ojx/D8DhN+VmzkhHY
	 /R5C1my5qXLmI1hvyCOQFVQHOBZoP43q/BCAgZEoQ+CyQ6MH9vvPKS04cnbiGAgl85EiO
	 JorbuqiHzqOZQbT1qh15WYIQX0renLvReQeyAlIuBidt+49M76tGvEpRKcAA22qMAeQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794872658;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=yTEhY8tz5VAdG9LY2i99lpeczT+D0D1zRXvFeLmw0H4=;
	b=u60KkLioqnzbOdudBYPja4z02vwbAD/pD0ruq3jcx+RGEtmJDukrwEe1UWVWWJOjdFjs
	 /46xxEF7qIwxGgvtJpppWOa/NuXE2Qkr8DdQwQb9YXQWbhcZuktAvVY/Njz9bHsiAOIlr
	 A8ciuVZgm8/jfDaprpMsnLO4/0Erd7eOltsCwkJSGxikKZsuH2eRlgDdB/6kW1fvUOhap
	 Fmuw6MH/yqHSYGP0hIGnrg/Kolt3RPw6Ii2hsB2Gi8McEOAcj0Mbn8OqwSb3sWS3IImus
	 tAMvcX0SXgvxy5tIbuOEUovg7thJzPs79NDUKDuoko6IfZHqkJrmMcw2+nWNpMZLDpA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lplmGyj0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EEF8C606A31C
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 23:44:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lplmGyj0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A6BBF1F000C4;
	Mon, 16 Nov 2026 23:44:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794872657;
	bh=yTEhY8tz5VAdG9LY2i99lpeczT+D0D1zRXvFeLmw0H4=;
	h=From:Subject:Date:To:Cc;
	b=lplmGyj0vRhCzHoQhu8N/Mgc0WlLA5GQD6KVJ6chYPXJnAWl5M4/OmkV68lu5yBgV
	 M9nMOx8h19O+I9TZp2xVduOI5SJ1cmOpqm+y0rRxgcw+aWJlaakEPomNPkqjmUD7mB
	 XUyRcLQfNZA2iGvPyzAoPwavYi3FxmAyMuoy3Xr/0/yZGStUl/dq+Ac+gHw5xv5Dmy
	 NO9kmxJH2XvsGYbet9xH+lmCFnS2xNlCcqr18AmytUp9Ld1/SCAoDvvfb1OgxoBd3X
	 LuTzPJCfZPjlL96WtqFUCyLjJAeOUoHotkv9K+ghKgHRzxFLX5AlYwk5gktBo4HUqS
	 SkOnCSYYsC7tA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/7] NFS client backchannel reply bounds and callback
 status codes
Date: Mon, 16 Nov 2026 18:44:08 -0500
Message-Id: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMywrCQAxFf6Vk7YDpQKv+iriYR2ojGDVpRSj99
 87U5bmccxcwUiaDS7OA0peNX1IADw2kMcidHOfC0B7bDhE795lZxHmfz32Ppxz9AMV9Kw3823+
 utz/bHB+UphpXIwYjFzVIGuv0DDaRwrpuEdaibIIAAAA=
X-Change-ID: 20261116-quinn-33d97718db3f
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>, 
 Quinn Grant <leograntquinn@gmail.com>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1725; i=cel@kernel.org;
 h=from:subject:message-id; bh=Zg4E3c1+L9XnmAdUXZPIY9yzndX6QBhWQdYvX0FZbI8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq+5VKi0rzU7OScBPJNSk5ol0mHT1omyuquezn/
 sTOeijwJWOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavuVSgAKCRAzarMzb2Z/
 l/v5D/9kVCFX+oaeDoQb1/UIK1wnYQy1QJGSQEIwt/+QR9zIhG6ZkOHVn3SHg85UUavy2Guzw58
 UkaJ76WoB+lHKO3RPI98nu7DerSdXdJY7XVCPKceR25O1+11V/WGfBccdNVl/gUPAkUCHQjnpE2
 0oPxGt2gOk2e+XVaLa37cOv2XidN+mB6Ru7A0hV8q3BDw5J8bbp/svcCASB2VUsofUq1/dkCLM6
 HQ3VbhtD3zKJWsihfVeNIRrXz2rqVGGiLu/TUIuOtduql0blWoOHYAYxFiQ0DV0INwfvuvHeFXT
 TGLecqDTMh+IF+7TKWlvN89byXLIjXjDZd5UyllMMkm/yO+pDlcdhcvJhVHtBl3l2Ye9SlMVSaB
 BeUJbvwoFZqYLJ3XRX7njmoT+xNJrR0CieIbHXW38AbMK5Rn3l9zhzjXwPWdllUdv7LoRhBsFht
 iobPAWMSzVAQq3zoPi8c/eAULtB/Un4959oFen0D6aOjemZ9fptAtwqSXerCCI/4QLiofs+jT19
 C5WKZgd8hEn8ZxVM7ij622q3FBAyXaMX5Bw8ryzNNs4bqNOxjZjebEZ4HWn8A59ajDSeb/5SWpx
 ANlEM7CRcyETKSaSle8ixZUhIP8tvCsDE9dfSNOjLB0chicG0A9/RgVhg40UN7+600XxMiaS3Bx
 uo1absXpLMK2yvA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Currently svcxdr_init_encode() ignores the buffer length that
svc_process_bc() sets for a backchannel reply. A CB_COMPOUND reply
larger than the transport's buffer runs past the end of that buffer.
An NFS server can crash the NFS client over either TCP or RDMA with
a run of CB_GETATTR operations on a write-delegated file.

The SUNRPC fix has to end the series. Out-of-buffer-space failures
in the callback encoders cannot happen today because the reply
stream does not stop at the end of the transport's buffer. Once the
SUNRPC fix bounds the reply stream, those failures become possible,
and two of the failure paths produce a wrong reply: a partial result
that reports NFS4_OK (patch 5), and a CB_RECALL that takes effect
while its result is dropped from the reply (patch 6).

The series is meant to go in as a unit through the NFS client tree.

---
Chuck Lever (7):
      NFS: Return NFS4ERR_BADXDR for a callback with a short op header
      NFS: Return NFS4ERR_DELAY when CB_SEQUENCE decoding runs out of memory
      NFS: Return NFS4ERR_BADXDR for a callback with truncated arguments
      NFS: Return NFS4ERR_REP_TOO_BIG for an oversized NFSv4.1 callback reply
      NFS: Discard a partial callback result when encoding fails
      NFS: Require room for a result header before executing a callback
      SUNRPC: Bound a backchannel reply by its buffer length

 fs/nfs/callback_xdr.c      | 73 +++++++++++++++++++++++++++++-----------------
 include/linux/sunrpc/svc.h | 12 ++++++--
 2 files changed, 57 insertions(+), 28 deletions(-)
---
base-commit: aebb7274476403040d582c61478df8f4a7bf9cd3
change-id: 20261116-quinn-33d97718db3f

Best regards,
--  
Chuck Lever <cel@kernel.org>

