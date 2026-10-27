Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793119540;
	b=dUn1KzpCeWFkaojguuxdWC1TAJ6B94urB0jAgKlrf/XAUZaaVPkf826x8FX7ZvE7jojb
	 2EO4YHYFJvKGoks0qumpGLJZBWCVa0Aob71TXKgRgOVtiKGCjw8Vf0QFKvX5308UNnCBu
	 BVRcqj5Ge6mhGOYcJgHXk6JUC9hHFncN2sKYIB/qQAu5NCdSEIWq/C8D7rLAh2ltn6aBZ
	 SFmBCr/tYjUtJ2om17rDDcX2IzUkEwkInceodOYyt+w+Kj8VpL2e9o4aIWVlbreCh0An2
	 56Xq5pCgphWgcB4fe34PuLFcnpZBgrmsdYCjxX2KCLCbJNqPvbw3Yp9T89yo4+HRqSw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793119540;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=GB8C8xwzyc/IL+AqJ93PS/uMKHHeD77qm1hgNww9A+k=;
	b=0Js66aggM0uwcW+zk30OTdnmzX6lmX8kq6Ya0o9mKU09lqsrzr6dxvqanWnP2g1T4JiZ
	 bNfFof28v+Ohtl0OmAn/3SFWUlBMDMMpHHQx1Pc90ncHBZP6OZI67zZKcGTGBL9iL40f2
	 0BKFLgsZh1um33PC8npMLAXYjmuuOe6h/tClZEmXHRtX7gzGbl0N48sAMwmJ5a5zPYqPP
	 HSohluRb62IO2gYQKn8xgPOOnddvkuOALGgjN0+lY+Y5J/RSXSZukIT6YzrPwe6Wm2oma
	 llVlK1ucJLEvCXwKuK/mgVr/JOzdawG6C80NQr2QGXAYMgF9trZo4dJQevi3ZOpdyqw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mEukjEnx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 954D860A2603;
	Tue, 27 Oct 2026 16:45:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mEukjEnx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 858E81F031E1;
	Tue, 27 Oct 2026 16:45:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793119540;
	bh=GB8C8xwzyc/IL+AqJ93PS/uMKHHeD77qm1hgNww9A+k=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mEukjEnxYMltTz1wAC8RoSbvvJie3CcwmSWnfZnPavnqROGsmE2q0cCiB6Ll/4XSm
	 7yCyJqmm2hWSriYFGkXIXK0QrssyEbYrurzcOXa9ioMs468MJL8cNxwzT785XPuO/U
	 a0iEzb11/sdnxUkYTLXPStjLFCT3XeiBU6gDgTvaCVgx8gQLKO/6FfrCVOhHcqX5KS
	 cTtzfFlTqVjxECcefA8XQf42YiuwjHASAxFoSlJeRpyhcSTyjwx37ggJDUSRpShW+n
	 jYQREKeKaDFY+A6hmVM5/SxXVEsYENLVXyfAeodNbzCHaX3R6Wgxln5pI6/vfIYQMH
	 qrTkmhEMc55vg==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 27 Oct 2026 12:45:26 -0400
Subject: [PATCH 3/6] NFSD: Document per-export riomode= and wiomode=
 options
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
Message-Id: <20261027-export-iomode-v1-3-262ed932a036@kernel.org>
References: <20261027-export-iomode-v1-0-262ed932a036@kernel.org>
In-Reply-To: <20261027-export-iomode-v1-0-262ed932a036@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>, Mike Snitzer <snitzer@kernel.org>, 
 Donald Hunter <donald.hunter@gmail.com>, Jakub Kicinski <kuba@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>
Cc: Steve Dickson <steved@redhat.com>, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-doc@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1817; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=tID4IlMuFhv5yZcgOANZ4uc88Bl+HXEK9e9IOMUPHv4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4NUr5gZE1rmlenWxSejnj76cZJIYlfvQgIIUU
 uamQ+rnZfiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauDVKwAKCRAADmhBGVaC
 FXHCD/sHz2MdswliBO2lFn2K+F8f6SxCuRrCMpsmCLSwMPx+8B998ElmkKyBUMDZq424ga4b0Wm
 VwKnGp5WnXa4mudKwQZE43NniGX+DgpGTVIhjeruha0L21rnqz82ffy7JrGd7bsj4zBfdD4yEZl
 NmWbD7EfYoSvYwZZ7lyHyQxGDLC3vWo45uQK14r/Y/lVFtrDhlA9SXJv5+iP0pBMZ+mgtgq8lyp
 diK/CMLAiKYjLFohF7ql9YSMSZ3K/+HEkSLMusSqy1T+KHZlD5My2cAuD+4BFqR3fNvbHipLTMk
 /ZwRW0nT552accSs0CbvEv4EJLREBlLwqGGGTUDYQNF5mCQr+Ez5LsqTNijn4YQvjrRd7T3ff2p
 sxqT1yeUB9g63QM2Z+ZV4FvY0sPv0YisA/K0Pm5N/zJRM5v5K8dEnXBkKPj2p8s/jfQ2IVXMace
 D/MDajG6CI8Re4SjgaQIol5DblNRxrHPJGFJZUBljixOyLr/gwZfwCOEj5l6eiVR2xBkl8unpac
 6TNLnqI9wstOH8yJ9ehDHS/doHBpQUaAU69Yo0AKC8y35c97x1CirUahXADLpZTtF4ICVgxc0YR
 5Jo1II0WaCj62RA3MNNavNZ8JG4/SddckuPek4Issjnz9ozBtpRLCGMQGrmR1IWk/Diworj2ABW
 mhQbOPrvkBND8Jw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Describe the new export options and their precedence over the global
debugfs knobs.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst | 26 +++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index f06fa1b9d406..6b29275e9128 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -41,6 +41,32 @@ corresponding IO operation's debugfs interface, e.g.::
 If you experiment with NFSD's IO modes on a recent kernel and have
 interesting results, please report them to linux-nfs@vger.kernel.org
 
+NFSD PER-EXPORT IO MODES
+========================
+
+In addition to the global debugfs knobs above, the IO mode may be set
+independently for each export via the ``riomode=`` and ``wiomode=``
+export options, e.g.::
+
+  /srv/data  client(ro,riomode=direct,wiomode=dontcache)
+
+Each option accepts one of ``buffered``, ``dontcache``, or ``direct``,
+with the same meanings as the corresponding debugfs values.
+
+An export without an explicit ``riomode=`` (or ``wiomode=``) setting
+follows the global ``io_cache_read`` (or ``io_cache_write``) knob, so
+the effective default for both reads and writes remains buffered IO.
+An explicit per-export setting pins that export's IO mode regardless
+of the global knob.
+
+As with the global setting, a read IO mode of ``dontcache`` or
+``direct`` disables the use of splice for reads via that export.
+
+The per-export settings are reported in
+/proc/net/rpc/nfsd.export/content, e.g.::
+
+  /srv/data  client(...,riomode=direct,wiomode=dontcache)
+
 NFSD DONTCACHE
 ==============
 

-- 
2.56.0

