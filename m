Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795029411;
	b=cql5ybDIUZbm0RsR1bNLtaUSCxOGkqv+YaaRlQbOrhdvs8gx3WWcJedpwOeqiKfSafWz
	 0AmbI8+/d6uLdLbcDtWMTX8MzQCIrGTfXaGtlZcdPC0BEmjMBGndP+GgKQeJsbdD/M646
	 eUCyTAJYt08cvnpawKrjGSOQP/juuAFXuJ4MQqp3eG14sNRZfOrygVXgQ/tFbjXoj7SWy
	 uBudFbYLqL1iw+384RCDXx9IQyTai92rAl6uo74Nf7Yd7i/uHMD9vD51+yTBQ54bRx0a0
	 6ubXezcGEjQqKL3bp8f5IWQCAetXKgvJSdPRWxibL/aA/d+lvIrS8+35py4uBpoRkAA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795029411;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=H38ENmodqN1FuK0Y7w5EQFi1MRpe2PB43J+7yK5gV+E=;
	b=WR36M2iCfKV1FhH2jNuKJNDvYh4YVTL14URkzFVMmr04TyugoVa+rrVvGYX6azK6ClUa
	 EpcvXRryyItIVAadx1W6FNfWTgFfAKrh0XF7ZbIpZ0Gis3MG30CdN8OvBA/LIX5lJ9fhn
	 pzOfRY41wRAuzFTRw2+OLyqG39OUaEaRVZCWoqxsIstUrduspRY4lbysJDaTwVNAXk+cV
	 Wi0F0BmUrmjBOd5VsJxzvBPMpeLygphgJ2veXkcZGVGNa4ffc8/BgXci1RPNmdDbQV4yj
	 xmdwynYzYgqHMAACpd5QEfCUr+oP9vKbkydJKj7/w+1RjfnwK0DLCng2PvljOwBJ6ag==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FgCHf8zd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 88579606A332
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 19:16:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FgCHf8zd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 336F41F000CA;
	Wed, 18 Nov 2026 19:16:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795029411;
	bh=H38ENmodqN1FuK0Y7w5EQFi1MRpe2PB43J+7yK5gV+E=;
	h=From:Subject:Date:To:Cc;
	b=FgCHf8zdRYlrKn3m1syiy7fKgBlJgTHCItLl3KmjBtdFJnB1MM1Yb2X3gMFflyzoh
	 RWeHsD9RQwe3uayzIbE1vSyYEvSH+7aYIj18iRPBiUv3bZ42ODSJYt248rqAvD+UNO
	 bPGWRgGr0Q2dWO5tg0tgbRmCqviK0Y+hPnq5P1/wN2ZQlC/1H08MSYhpXeJ9R4rGgO
	 ivve6mpblgoAaYLPuwOsg3bwfYtBCePGjkDZivDM+ssC6/jYSVvCElLbvSbTYILvIk
	 JvejWfvkNRswQN3CfgliT3X0dCCD4KDmicKXEG9f9WzJBXmUbRnNjalr/4WBr0fj0d
	 mROAVUqU4fKaQ==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH pynfs 0/6] pynfs: add a set of tests for delegated
 timestamps
Date: Wed, 18 Nov 2026 11:16:39 -0800
Message-Id: <20261118-delegts-v1-0-9bd252eea637@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3MQQqAIBBA0avIrBPURURXiRaiMzUQJk5EId49a
 fng8ysIFkaBWVUoeLPwmTrsoCDsPm2oOXaDM2601k464oHbJZqiDy56opEM9DoXJH7+0wL5TSS
 wtvYBLns9DWAAAAA=
X-Change-ID: 20261118-delegts-fdac2daff6f0
To: Calum Mackay <calum.mackay@cdmnet.org>, 
 Jeff Layton <jlayton@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1204; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=D9vdvP3tfNVyQ2HOtIDv1TIq/d3PfFkLgRNioHqUk2s=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq/fmhzxkoTIvUPtO5E1Z6SiiGaFfdk/S4qyUHw
 X+fZed40MuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCav35oQAKCRAADmhBGVaC
 Fa2HD/91Ili7tR+DZ4OIypAPl5pMX5wxJ/7oNQToSnPCUWfbr5ZDmU80VaXbT245N19Kr1hWBYS
 +AaqomKeaRMotBlCeSe/iWf+61qc06IiQIU5AxQ3jEvIwCN/dh+2zYdnGrLZoHXDW4inhw1NWnz
 D/upQ2LBrOzqfx8XKbv0EEqt8sW/m7C5XkSlKD2X2CJDcV/aCYfMHJE6IfzeqLvAh9HB56iOdfu
 UOqgKQDwocDGXwWLt6fIu227qr+Gle44+++7M2aPtkIh4FsVaxWijz2WXpxnXIRGvV5GMSodIH6
 uwXUu6ZZxbxDlLUvHFIQ5xdCSJ4GYoSmAXl+NWnynPBdebZ8KN8Dbvafltrr/ntTBwvFJSj//qF
 2zBWwDAoStOT2+likhmhF6DUqb2mmRPyUHtSbzT2DuYYpr44DwwkEDsYBJx24LE5fiAdmIDIN6Q
 QlIfllPVWtD61/M3xphWICWqwU08wQwhU/OfvEaIxl9BoaBuRRife8t9kwcVmhHFXtv+F517aEX
 UUkyLA+XT4vfnivA2PrEod9mclYFkKbGWsjFbNPuXhwcep2wirgMSwyb24u2N3NnYWRkHe+q02g
 RBG5sfpv8SsySXyYceGn9ZZxZANUWP3RUekPgA9+LDWdV44yff/D0FRzQiNfIAv14jY3YOfb3T8
 txOjRQbgIs/K/rg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

We've had a running set of issues with the delegated timestamp support
in knfsd that is usually surfaced by a gitr test run. That's not always
deterministic though since it involves the client. This adds a set of
new tests that test various corner-cases of the delegated timestamp
handling in the server.

If the server doesn't support delegated timestamps, then these tests
return UNSUPPORTED.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (6):
      server41tests: factor out sampling the server's clock
      server41tests: check that delegated times survive DELEGRETURN
      server41tests: check delegated times that predate the server's WRITE
      server41tests: check that times seen via CB_GETATTR survive return
      server41tests: check CB_GETATTR times that predate the server's WRITE
      server41tests: check delegated times after a truncate survive return

 nfs4.1/server41tests/st_delegation.py | 229 +++++++++++++++++++++++++++++++---
 1 file changed, 215 insertions(+), 14 deletions(-)
---
base-commit: f03d0914f4fdae7735b207f1c8424274e12afa9a
change-id: 20261118-delegts-fdac2daff6f0

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

