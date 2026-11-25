Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795614870;
	b=HXwFisFGQAv3B9/s//QBBLm+4/9tQDwTktb+JUHvDJ0bxuHzsQPUyK3jvFg7KIi4/9Yp
	 9Nk0eAA5oA09ZmbG72SsiIi6scLbuZM4b65moeyURT7nCcOMNMNYCOXCa+fyYuJJyLLOO
	 ikXsLTrkJxndGZhOi5zJA2Vy6KYti/z0kvAAw6Gi5ezhnsNphTX1FMu9+uWAn3zz5wq6T
	 7pherVpVIilGaokzGhA6rFUBsou8w4qOnEmZ19dQks4JaVDAxXM5mwvbP+eO2YUQntMct
	 3f3nMStLwvNY26Nq3+y6aoNGXvQ2RmFsbrSV1wDLyFBBC8a2Ac9dtZ9yyv91rvuuOTw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795614870;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=NncwYsxK2lOQWMqt6piCPBurgJ5d5v4CQ4w9FaJLNmE=;
	b=bQ7Ti1qRx/cY1JrjKlnP8M1zvXDkvmwN8D6PkerDxDbWNo77GLyTYCVI/AxFY2HIyGms
	 8OMrlo6sklcwHxPRR3gb63ag8FLyWxVyc3YCaM1bGbnUKsY76bJ7kxJhxzR49oWyiitl9
	 6+/nChpdZ25OChyQpm5bR75Tzw5LH6RE7EaBHLBcaZBNdsfbgZ5eUpVATy+mFwe8rmSJi
	 w5tGINkEAjHVxNIiyu06vf30jHdVsnUGoyLpz20kzDvdYN2KgLdtklpT8s3vO6EZjJXmH
	 UK70t2MJan/QIBUEsJSTPniIcN04yqVi++v9MBybHkFPkGNrIVbPDaTdyOOexkPv46Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Bsq9bzdA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 75551606A31E
	for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 13:54:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Bsq9bzdA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EA39A1F000C6
	for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 13:54:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795614870;
	bh=NncwYsxK2lOQWMqt6piCPBurgJ5d5v4CQ4w9FaJLNmE=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Bsq9bzdAcEUe9ToulXOiPcbEWrBKNgQDObidlQNF22zv5rrmrj5/tQFgNzBHtGgdN
	 TAlELdoZZUfrYx8fipOYQ9qmjBC2FsVj3xduILUqNqI3rrCTruY7ipIwNmQnl8K3/5
	 Fn0g0YoluV2ulyGWX1AwS78Cvz3cQLsi1YXkZWLDZKuWvDs0247fq8Swec0UvW1XyG
	 cOowsVVAySoVWh/xDCaskDRx8MzTuDlcO0Jx9i4tDaCUF0/SFLvNN5Ykt+8srSYTL9
	 Lddc50Or3+DX+VqOApxG6qfTX84AtUMrsdQfLyMiajVC0U8RVctgcccylpSH1wYn4a
	 +aR4s0b1nTvzA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 2AFDEF4006E;
	Wed, 25 Nov 2026 08:54:29 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 25 Nov 2026 08:54:29 -0500
X-ME-Sender: <xms:legGaxcwXkGlX1aPq68t8dDGs7jCvP2O7ZDYnlL0nXmEEdi6zudK0Q>
    <xme:legGa6D3EZecz2MoeBhcggAIevFMqhPPbWzZc1PZKLVeFbf1L8cxi70gcDns7mdpC
    ZGywyt8hy80hsYs0Kd2hGsuhA0_W7h6BJaiGZFEtz1CvgKjppyPtfgd>
X-ME-Proxy-Cause: dmFkZTFeOd+3TMqC72BsJ70ITSvtZqrDa+NEWzM39TZlYUp9QdUrPNglcgYqJZbfXIGQOm
    MmU1ID0qQ7Jdrckh0dO7vFefDB/AjTKrs7NG7b+6tNlAc7fN0G89+yRRTTVmVMDUkjU15b
    COCOU9bSjPslIGo+IS4ObWQgxA2pedCEE1xabTHulCsx9SHg9P5WK1zi8F8onGCfimp7DH
    G3fdGkWmOMeLDsDUK60UFxquOAnwm7eesVUCSntk6HXlk/axCFNGVju1FBXOOJzeO1yNLC
    fLdiMUFcES48CNdeodLMngUryyqxqgANSjdjB7Fy8msWR1CfT+Qlt9C0NWFXK6BfiVxUnm
    ptgTM6NxvYYH+VxpGo5t6KmuMF5v17ntV1rq1nSDOMMNudSbln/q4qQpJACGBoV7CqNZ1c
    AHTeaznz8Hf19HJrSMB2aE9l/wcOCWIXfgd3rPjpvGwjmGcd7T9hmaaC4kP6fJ3iVd48+K
    pYqxohfObn/Ro1y41NzlpxNGxcxsMu22fjPcXJBjvmmwQ6qUQz191bkFYOhedNpbaTlU4c
    ml0I0WICRs11u+l9snmpMNVreOXMud378iWc8kRCjFwSGrEHzr70iMj7O7gwurT899kM4S
    BbOcKwSAa5lQ5Wy59iMKYYfdUYgyyxZFRCXCxnJR9wrIW5Z/Z1iQt2HfEt9A
X-ME-Proxy: <xmx:legGa9GhE7e47aO-Icx8Wkpy21baGa_7e8EwmJ73GI5gNL2SRGjhIQ>
    <xmx:legGawK6idrehj-QbgZhqmwXcM3yl32SeOJvlpp0Mm8Ft5HtsEvGrg>
    <xmx:legGa5k026xWIedjY4boHIJN3CK5xu1JPkLyA3h_ZY0ue5D-PjWRXA>
    <xmx:legGawQpOQRXadvm9BrYPuxi-6ZnT8mPdPSX2q50IlJvj1UnAo2kfg>
    <xmx:legGazIiy_b-smNg1bLoSMKKsxMTCiXAtrWeKFNGP3wxDZtl4hPPUA5h>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 1301A780075; Wed, 25 Nov 2026 08:54:29 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AkK9xiJcrb7R
Date: Wed, 25 Nov 2026 08:54:08 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Rida Shamasneh" <ridahani@gmail.com>
Cc: "Calum Mackay" <calum.mackay@cdmnet.org>,
 "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Message-Id: <8999aef5-c521-4a78-9137-fd82ef2dab6d@app.fastmail.com>
In-Reply-To: 
 <CANkg2rM7XsiVriVzDr52WcxD-xFb4qu3qxiPJNyJUYYOTLUmNg@mail.gmail.com>
References: 
 <CANkg2rNRVyYLYLaVnCz75nYvC0DAKrphNazX1Asacf8MuBnxAg@mail.gmail.com>
 <525d6d4a-f015-415a-a4b9-9ffdbb8966be@app.fastmail.com>
 <CANkg2rM7XsiVriVzDr52WcxD-xFb4qu3qxiPJNyJUYYOTLUmNg@mail.gmail.com>
Subject: Re: RFC: RPC-over-RDMA client transport for pynfs (testserver.py --rdma)
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Nov 24, 2026, at 4:44 PM, Rida Shamasneh wrote:
> I sent the patch via email "[PATCH] rpc: do not format a whole reply
> for the debug log";
> Do I need to open a PR as well?

CONTRIBUTING explains pynfs is a project that takes patches only by
email. No PR is needed.


-- 
Chuck Lever
