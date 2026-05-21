Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED6973D7D86;
	Thu, 21 May 2026 13:30:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779370223; cv=none; b=r5qJz9EAizZGNTeCWiRkNCUb9HqVzntYi9LtVzi/+Uir8+ci415nRsBRK665FuNVnFTD3fIxrJuMmkH02u/+8BNrFATohFQVaT3KEYpRV6a3LWn3/hzWIlTegBaW1jLBd451VKPfbXY7U2eZG64/w+F+Qg5VbHndIUSn21h4Pas=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779370223; c=relaxed/simple;
	bh=VMRwHK4fSGndRZqipAu2jAwXoxuQ0/Z+eM/8QyQRfXw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=jvVujQL9FO98wSKnSWmyOTul0xMDmhftTpwsU0u3voqaOeqafZcfMea0emBZvYEXCT/kxT7snH2qVFGvIMkSIwqDp4ZMr19pUDZjNde899AGl5jiwA9JqVMNK2ui85/fm1B93gUuSeMKEEUUcV8FPfxj4pByrwr5OVqVRGvILJE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=la/1VfcB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="la/1VfcB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6FE511F00A3C;
	Thu, 21 May 2026 13:30:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779370221;
	bh=C/4wmfr2F7U2i+22udgOcU9kURp4t5WVUMLVUplE3d4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=la/1VfcBn69iGXpBNUnMyWLPDpBP32mbpZ2EK+6URczSzMq61D5Sw1Hg1RzsX6Zdv
	 ko72RWh7CeHWanti2VColsuOSKocXTV0O6QC1VheeVeCu2CvAIkcOTaizMqCq2Etk3
	 Nl+ypjp4M8QdqU45f9YJT9+Vb3XLCxnfdRIWFdUr5dIWjW2CCA/jZDiuIUQBFxH0kJ
	 +0mXgsxrm+z1dlaxHTu2RFZE1rL45bI1+wgk6jhk3kMT104xBIeSsLxrPBbGWxZTIZ
	 46O/xYBVAi62G8XFpghW/CqrpYkB6OknjXxZqPrVlSxmVwTy+UmmjoFcIXu5jjC5QU
	 4FEKIYfVaXrRQ==
From: Chuck Lever <cel@kernel.org>
To: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	Ren Wei <n05ec@lzu.edu.cn>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	trondmy@kernel.org,
	anna@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	yuantan098@gmail.com,
	yifanwucs@gmail.com,
	tomapufckgml@gmail.com,
	bird@lzu.edu.cn,
	rakukuip@gmail.com
Subject: Re: [PATCH v2 1/1] sunrpc: harden rq_procinfo lifecycle to prevent double-free
Date: Thu, 21 May 2026 09:30:17 -0400
Message-ID: <177937018686.113875.15243798649112680633.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260521070636.900264-1-n05ec@lzu.edu.cn>
References: <20260521070636.900264-1-n05ec@lzu.edu.cn>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Thu, 21 May 2026 15:06:32 +0800, Ren Wei wrote:
> The svc_release_rqst() function executes the callback inside
> rqstp->rq_procinfo->pc_release. However, if a worker thread begins
> processing a new request and encounters an early error path (e.g.,
> unsupported protocol, short frame, or bad auth) before a valid
> rq_procinfo is installed, a stale release hook can be re-triggered
> against reused state from the previous RPC, resulting in a double-free
> or use-after-free vulnerability.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] sunrpc: harden rq_procinfo lifecycle to prevent double-free
      commit: 2739a03352101a0f6b3b185bc6c9e983129cbd49

--
Chuck Lever <chuck.lever@oracle.com>
