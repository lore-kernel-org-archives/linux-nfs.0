Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793275542;
	b=l9WT6qvOeRAoqHDjTZTJvYxQ1pKa1FPtZIOgK7b3pINl+t7SnFzwD6IqS2GStgHDcLJq
	 iY0558iicXl5vNyK6v15MFnl0mxdZEkRj8o0XtWFvRbtJPTRtwFVO55Njmts4gHzIfh+z
	 WRHHwCWod5jBpjsQbpaMPIdgkTxxu1kg7WCsBrF+41Wa09ke+d5mpYjJOLm7kiuBAISxU
	 ayX9dBI6Kxp+dDnorUJGk0/gSeX4jcENSj3qhdPZv4/q2f5mUwOuuQBjg/ci/ps6opPiN
	 8SWyV4N7onYDi2cmuXRLM+C+YuN5Q/vntzQKvIxDBmOrAOpP1z/aEAyWlVcrM+4Dxow==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793275542;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=VKf17k28DUXX5KJP/n7F4jiYDpTVBBx+hs/tipvoCTk=;
	b=ZBuruxaRtlcO1j24EczN6MsiwPa/hEeBZXx48MSVitKMtTJJLXIiM2QhWH5XahgTeQEp
	 /ql3bRh/yWcgin9YXeaZQZgj27o699HCIaCLatwVGMUge09xUuNHwkYUONtkH+uFEoze7
	 OlgQb9THk6nAcfE1DGvcNDTccHA5BLgmv8kL0XxlhNAkxugyPaeSG4cj5/kaLYEVOSMWS
	 wmPJiPiJrdGy967pEyr8/ttW2kARfzQRgK8WrmlGGcKu8W+n9uLnffAqDw5ONSd5nlCVT
	 YzFfaHBur+hu9r268DFJvfV3sEJgWmUTVBFa438fxRUscn7LatFRv3Yr/IfRu9T+R3g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="nX/Or1RM";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60BC7606A339;
	Thu, 29 Oct 2026 12:05:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nX/Or1RM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8415D1F031E4;
	Thu, 29 Oct 2026 12:05:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793275542;
	bh=VKf17k28DUXX5KJP/n7F4jiYDpTVBBx+hs/tipvoCTk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=nX/Or1RMnEOBqdjsRWYfHoB5Zfn2Dk7hQs0K29Ogq2QxOeywb1+tY+UvtDkKqwtpv
	 z0mC/YEMTK+WXt/1Mq4IcplUPcLzLkR5DXNwaN7rSLWSmY0TCr2nfkRAP7KqS77DMs
	 nWlEMYQS/gMuFbW7z1/Lb/3BgAX1xedJQrkpCLaqAmErSmAok0tHcfseMOPfGp7d07
	 +QfFU+VjjDv29jQEuqJeBEH21cry1N2jXS2QeDZUEuPHu+dEgCdZe1jc4oO85WTpi6
	 IpBRGI0KTYKcdhZnPnDotghW+gpmejClUltGV4XEIU4BWhnsSbPLQrSrEwhA+vp5bd
	 hULyQ0Mx+MkOQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 29 Oct 2026 08:05:16 -0400
Subject: [PATCH v2 3/6] NFSD: Document per-export read_io= and write_io=
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
Message-Id: <20261029-export-iomode-v2-3-fe8ec6251a36@kernel.org>
References: <20261029-export-iomode-v2-0-fe8ec6251a36@kernel.org>
In-Reply-To: <20261029-export-iomode-v2-0-fe8ec6251a36@kernel.org>
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>
Cc: Steve Dickson <steved@redhat.com>, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-doc@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1904; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=uVxjSKXh7rDt6GD/1c2zJVhX3GX9a3jg3IMlYe2NeaI=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4zaOO7z8Ny0QSCNO1/be/4mZWWlCJvMKxCkge
 GvHvoGMP3+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauM2jgAKCRAADmhBGVaC
 FWtyD/4s2YrNRkkcyHR5nmuCu5XiVuz9fUyRN3pe2dQvqQ9W8H8brlfKkMRr+yo+hEsPq53RHwl
 DuG7lKPzGK3gW6vhgQTcw3htNfSijoxrDkuwIp8TkhUigJxCGZozoJycv7UAh5ONPer3LUUXJNK
 GVKRJSO4gbVbBOF1hWi11VNNSP2pf91grhT3BiDuuMcnHiE41OING5x2OE4AythsD2hX7v6Uk9D
 28r/V7WOAwNIwBWIKAi5jV+x0AkGWRCTpoq/Ch3aapGGh3r7XMXNffxkUnUewI13DglJyva40NC
 gkeurjBOxWaBb3uqfrhRl3S+FN4eC434ivPuvJqTMqhZswPGFXV611VNqgNij2KE0cJvRb9W+eB
 lV3OFRqy8ugpIIn7sPVNn1/hy3rIiK1evxmd0d/juPeRQWR0GTB+kMet4NLbkvlygq5UKUBwJ/x
 KHGTaNmpQkRgoC5NhF2CyR+0hsFm+YPymKkl003ox5sR+M4rIcpDH5BlhjDfHr9CStfyoizNEk3
 QsYYIrkd0rX58WGjnRFdbDO29YaTK9d86gjmnZwaH/DE0mGyj50rEJVcP9pdLeqfXFgFwf19IGK
 wxYznDp6gk4goS4ZYV4oDRuBl4AjBQ5gllDO/ilWD2YxVUG+P1BTR3cnBY2xVNkBIx7MAgM32Aq
 y0mHU2MEN40mM+A==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Describe the new export options and their precedence over the global
debugfs knobs.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst | 28 +++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 7b186201c6b6..1ad30518c234 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -41,6 +41,34 @@ corresponding IO operation's debugfs interface, e.g.::
 If you experiment with NFSD's IO modes on a recent kernel and have
 interesting results, please report them to linux-nfs@vger.kernel.org
 
+NFSD PER-EXPORT IO MODES
+========================
+
+In addition to the global debugfs knobs above, the IO mode may be set
+independently for each export via the ``read_io=`` and ``write_io=``
+export options, e.g.::
+
+  /srv/data  client(ro,read_io=direct,write_io=dontcache)
+
+Each option accepts one of ``buffered``, ``dontcache``, or ``direct``,
+with the same meanings as the corresponding debugfs values.
+
+An export without an explicit ``read_io=`` (or ``write_io=``) setting
+follows the global ``io_cache_read`` (or ``io_cache_write``) knob, so
+the effective default for both reads and writes remains buffered IO.
+An explicit per-export setting pins that export's IO mode regardless
+of the global knob.
+
+NFSD uses splice only for READs whose effective IO mode is
+``buffered``. The ``disable-splice-read`` debugfs knob turns splice off
+for all exports, but changes neither the global nor any per-export IO
+mode.
+
+The per-export settings are reported in
+/proc/net/rpc/nfsd.export/content, e.g.::
+
+  /srv/data  client(...,read_io=direct,write_io=dontcache)
+
 NFSD DONTCACHE
 ==============
 

-- 
2.56.0

