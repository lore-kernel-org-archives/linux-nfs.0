Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792615348;
	b=Qthmi9SrAEVIw2RnhwBzMWbni8P1jGTwgJHsNbQrE1djw8G7LV/y9lOm6+pwfHmSF13E
	 JdGhxRMb8MePLQy0XwpEHNxRXyePkZnzeThOrdr3bd8+CE512m1LVKNBj8Mv/L/cmexzO
	 IWVv0D7Yjwg1o2FLqlVWb+kWVLIZytG/wo6kcRhm4DNHVBSCzj2lWxhquW53PXsGJdY5p
	 jDJyLKeIlk43FxvbDe8+GDV7Nf8+O02kzlqPYSCkjVO1NZmyPslfwuGIHOc+NkAcqMiri
	 618Jka+jZ1sW12+4W9qzCrbfhcBrD/cnkBP9u894m+oC0wx5jIAz4AdmbhtLqnLr4yg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792615348;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:Auto-Submitted:Content-Type:
	 Content-Transfer-Encoding:MIME-Version;
	bh=PJRu7W6/Or1we5Gv3BgoLEtby0D0Y0UGgfjBHfRc5+k=;
	b=34J7LbnzvQ5Zic/ndmCEyRFN7arij33O0IT72Ear8mGITZ8R+4NayiHb9B9jfAIrCJJf
	 b6bCiMEn0nTLxrK+Ovvrg/FEtZX7Y6meq/HgVgFJBda7DRjiHR/g2dTTK56hbDoTF/Svh
	 V5YSBF4fOhm1bB8QfYlArVmF2eZzZuqdaCf4GAk4ixk6x+9wXqtk2ygUP/gV0i6qh78eD
	 2aj5ZVIenzEnX+HvXLcn8XwGDuqcEFIzhFx14dP0hhBIoXH0Hifjxo0rf7XgGTbXZhbcO
	 I5O7+6Ft/5CFyqbTwgS5yj5pf13lNai/4Q8spt8Wo67KYIeGXqw66WTOYf3iWGN4/pw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hliodYKD;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 089F9606A31D;
	Wed, 21 Oct 2026 20:42:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hliodYKD
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0D54C1F000C1;
	Wed, 21 Oct 2026 20:42:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792615347;
	bh=PJRu7W6/Or1we5Gv3BgoLEtby0D0Y0UGgfjBHfRc5+k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hliodYKDGdw3vIrDwEXiJRZLczydcEIg7WHMAfXTJhZBYe3erVdcMWClgLhc/XP/S
	 RUN5dkVRAUWHov6fvvgpwHmNgfuRqXh0cNq91rQPya5Btt1I37ggywHMA4xrApkLXP
	 7+rP1ecJ40W+cgVTyKNkpiutsszOOz9/VTwxbDtaX/+wzG9QIhTMQDPXfUbWtkQ9z3
	 plkoFzQpdM+p9+8HK9CNihwu8oLMJSDGkdT+kt2fl/7CU/FC/YfUyf1kpfD2Zj+A3+
	 lL+N0wHSSn/va5RG5QVXXM9GmNVdPaos6cFMuArrpsUp/+HMVK6yknR+OjxpBJ3vMI
	 ETawwS5UatGJg==
From: netdev-bot+sinfo@kernel.org
To: Giorgi Kobakhia <gkobakhi@asu.edu>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 Xiang Mei <xmei5@asu.edu>, linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, stable@vger.kernel.org
Subject: 
 Re: [PATCH] svcrdma: bound check rc_curpage in svc_rdma_build_read_segment
Date: Wed, 21 Oct 2026 20:42:26 +0000
Message-ID: <179261534659.3290.17346208401833249303@kernel.org>
In-Reply-To: <20261021203817.3898293-1-gkobakhi@asu.edu>
References: <20261021203817.3898293-1-gkobakhi@asu.edu>
Auto-Submitted: auto-generated
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

Hi!

This is an automated message. This series looks like a fix, but its
commit messages seem to be missing some information:

 - How the issue was discovered, e.g. hit in production, hit during
   development, syzbot report, manual code inspection, LLM or static
   analysis tool scan.

Please do not repost the series just to address the above. Instead,
reply to this email with the missing information, so that reviewers
can take it into account. If the series needs another revision for
other reasons, please include the information in the commit messages
then.

The evaluation is done by an LLM so it may be wrong, if you think
that is the case please reply and explain.
