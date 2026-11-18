Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794962539;
	b=BpChno63tGN6wVLlPgB5AfnGOqmha0zSybTENXSkFKQz6bgysyZQlq36lvyZcQoWN7O8
	 bFXZMuE2vZgHJpwj4sW9z4O4jWGVauXfw1ari5ecl1JD4hqsAgaZKCUE3sBkTkAmFAaVJ
	 e2iQZqgIxjO5iarrPL0UjltNaxKGttEEo5I0JASHPwG14hZxOiXZMcL0uPTZUhTQ1cpQ5
	 F580lDxW7xzb2/I+BEU0c+PjwPD5R4vLFtDdRbgwSOwthUhcFXPlip51lQvp1P3rYzrRd
	 yBXxPnZ6cTMk1CJMxrCFX1N1h+ek/hRQI2sIk5WIFZWAMeWDN8CxjA0K0huQBT/odqA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794962539;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=XqlCfJ0XcXFD6+kdpM51Uxge1IRxyddZJW9M7ChbI34=;
	b=Pydyq/qYqjp+auR9IGnRhTFeh/nzmVqAwJ2IiIPZRmNKPOIGpk0s/dITN0YRkidGqHLL
	 5khKPlg4LaekIecE/CE0JpTtuLup8j4iYBe2rASJxkXFVuc/6ZhhSTEa/Q+/revN+HYIW
	 sIHownzuXSoFv/oQM/0pnxa6Z2vwn0IVOxEvS26Dr04dzmz0K0jpeqcvuV2NTkAD+73uz
	 p+d4RzM6mRjF36i7IdrkzjkK74qF6cLYRz+uep+xu0KHn9VibGp8QZhzW63ZoecKTYdeW
	 iQSpjUWoozTvmUKraiOkZ4Q5YDA7zKaYSw08qFl6VZ756D4IImJtl2VTGTaBYFVa8JA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PRxyZjwa;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 653B4606A883
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 00:42:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PRxyZjwa
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9BF1C1F000C4;
	Wed, 18 Nov 2026 00:42:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794962538;
	bh=XqlCfJ0XcXFD6+kdpM51Uxge1IRxyddZJW9M7ChbI34=;
	h=From:Subject:Date:To:Cc;
	b=PRxyZjwaLH55jjBNJjx5gXrp/7xY2FarNN21jfrSLQzP/J7qsEUc/qlSBoZzRTvZD
	 HznfN0ZntYQCF/eZAooc/0XIatJQrOz7mPYf9tcvoxIj1ZVsZSuBTPsPYKtU4ZHkID
	 eHpCg5C2QgNcl0queK8CO/9DYaI6KPQFC5clALp5Fq5QKCFY6VGzknaWc6xmxYPWmH
	 5YAtOhOu234O+63SHH7HO0/ED6RAKUn6S5iQdqXcfa2cX3Re1tnLJ66SVS/4DFDtd4
	 3SImXPlWl0u9chVcIpnvtDn+1w/YlA8/Jy0a+A4v9a9wyu/qabQyy3cJ696NPxznIn
	 qjwjJkgvcU+KA==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/2] NFSD: Restrict the spo_must_allow security flavor
 exception
Date: Tue, 17 Nov 2026 19:42:08 -0500
Message-Id: <20261117-nfsd-spo-must-allow-v1-0-ac351b60d1a3@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMQQ6CMBBFr0Jm7URao6hXIS7aMsCYWkinqAnh7
 ra4fD//vRWEIpPAvVoh0puFp5BBHSpwowkDIXeZQdf6opRqMPTSocwTvhZJaLyfPkik6xM1+my
 uN8jmHKnn715tH3+WxT7JpZIqD2uE0EYT3FgmR/64hxNJ4jDAtv0A8nErIZoAAAA=
X-Change-ID: 20261117-nfsd-spo-must-allow-ee203e725a89
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1469; i=cel@kernel.org;
 h=from:subject:message-id; bh=/KdNu6INI4WrclkiSHxAyMe+9Mu/oyy4eFADmLAnC4I=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq/PRjg93gYgvodUkxwSkFOwihvQQIuVjQi7w/9
 JcgRvi6iH+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavz0YwAKCRAzarMzb2Z/
 lxplD/9x8g4Qbd84EWABG2wT8gSnRJ+NK2opJ8a37hNRN96bZ5WxRSY8Vtsg2cYXqFq+y+EnLEU
 XhPF2PFkalIPVW1oyiqEhoLHix/9m4vZCDhWAvkIMLRF1mXYUyevWnuJnNvA3DjwOxNzNBJlYVn
 dPlSeWrNK0iBiCrEHia6x1IGIfXVOEbNYk3BeGh6SQ6LAibFqVC5KTCiShnapjBmup7E+9f7gX2
 yjfR6jBVBOg5ABeu0cKZYzyabP5qSbKcUA8c0WA3PojM3icmrW1vG3hsjS4ohkAdQWvrbWnX3f2
 z2D92KrBGrq5woWbHLMHSYlfrpWcbn2z+M0u5yaU2hCmaJEQdCLzklAfn58m+5qM4hWeSIF9kQy
 skaSUSgCa83s1TRUg5CSNJ40JbLmng0b6UC5i0FJnMKBvXN7i2+lxPUf5Y4e7pNznA4yu+ZxCKt
 9TkDpm2pYydPvMICBs9WTEyV0B7lCpH/R+1mtr5PSNN3ciIrfw8aMV0j9B6ztlpGNT91UPkywXB
 53n0aCkMfUIWbhVxHvNrw+Q/qBtNs257ZSTpCwGswlwaNMdDTbcyxc9uRzaPVilVrJcw/plXWlR
 8eS11nWUiTM0mDOw9aXd6oa1CJ6l8FNWVA/L2OtUGydJxH+c4jlat+atwyB0EeEqUTpQdTWIB4+
 RgkGFPJ0k0YNlEw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFSD allows operations in a client's spo_must_allow set to use its
machine credential even when the credential's security flavor is not
listed in an export's sec= options. The current check is shared by all
NFS and NLM requests and applies the exception to an entire NFSv4
COMPOUND.

An NLM request that fails the export's flavor check can trigger an
out-of-bounds read when the exception check accesses the request's
response as an NFSv4 COMPOUND response. Fix that read first, then move
the exception check into NFSv4 COMPOUND processing and limit its scope
to the current filehandle subseries and export.

The second change narrows the exception but does not yet restrict it to
individual spo_must_allow operations. For example, in a COMPOUND of
PUTFH, WRITE, CLOSE, the WRITE can still use the exception granted for
CLOSE.

---
Chuck Lever (2):
      NFSD: Check for a COMPOUND before reading nfsd4_compound_state
      NFSD: Move the spo_must_allow check out of check_security_flavor()

 fs/nfsd/export.c   | 13 ++------
 fs/nfsd/nfs4ctl.h  |  5 ---
 fs/nfsd/nfs4proc.c | 91 ++++++++++++++++++++++++++++++++++++++++--------------
 fs/nfsd/nfsfh.c    |  9 +++++-
 fs/nfsd/nfsfh.h    |  1 +
 fs/nfsd/xdr4.h     |  1 -
 6 files changed, 78 insertions(+), 42 deletions(-)
---
base-commit: bc82014d199f834d07839934b8fe89b89dbb6302
change-id: 20261117-nfsd-spo-must-allow-ee203e725a89

Best regards,
--  
Chuck Lever <cel@kernel.org>

