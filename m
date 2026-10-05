Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7285C4A3F1C
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 15:04:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791212682; cv=none; b=oxpJkPkPPMVxkWnZbuT6GYY/UiRaBb+J6QTjEa23Z0fXQ5CFiNqxH51nC1VyQFkqaICUE7ozvUmBAIXh8QDMr1Uxs3NNzeTUua/OFTOMthMwXhIk2AXV0xD7wc6frYr7Q4xf4jtQoJwT5ObdOvTKl9+oZoCZzZ8HN0U3uqb1jEw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791212682; c=relaxed/simple;
	bh=V4JWH40iWiJ4wmoqmg60YqSAbW6tJghBgIkdsERNXO4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=O+n5BxU5LjfGllEZXQyBTkWTEESHWBrLaf1WQrCoWypTDGYWZ3DxU/Kwq4KMKFkFAjPWLaLIwa7sVOBfDV5R3yxKHjwfjKzj1QvJQAAWejrqZVuE6ixOGbwMs79h8kQhRasr/TFC9YP3EKAzKmkkiwXM2dHh/Jg57jCmMpQ4Pa8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=j1hV5V5B; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="j1hV5V5B"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 80EC41F00893;
	Mon,  5 Oct 2026 15:04:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791212681;
	bh=Qavc/4x35DnuMX2p2May8xDLNPWrGfpzdly/eu54+h0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=j1hV5V5BWt0OyoFFUnWH2/EMkGDmrz/hNqBs6H6rwRwIWoSqcV/xDozTd6iovOZdy
	 mYoDU0RKn/hP6A0Ar1XEPVoUHaE8H7zgWughEGwRS08x/k8K0w6jlczlI/+Nq3+na4
	 zaNajMoYgHy8cwNfMS8Djl1lokYU6edztVNjqkYDyYIVRVCAzhno68N7ydcuE4EWzD
	 quzlN0haKuDlFbv0h7LgoKZHaR+LMTjg3eKz+ftF1fySIGa7q7ORWZIoIMhujeZC2/
	 NNCt03RfKaxBKJzyYC+IUblyJPQ+BFIMV2fmhYFchNpkagSDsRfp5GsZThOE3NrodG
	 ezwcWviDvTTfw==
From: Chuck Lever <cel@kernel.org>
To: linux-nfs@vger.kernel.org,
	Jinpyo Lee <bint4b13@gmail.com>
Cc: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	bobtobabz@gmail.com
Subject: Re: [PATCH v2] nfsd: bounds-check opnum before testing spo_must_allow
Date: Mon,  5 Oct 2026 11:04:38 -0400
Message-ID: <179121267127.31216.2401567496305307393.b4-ty@b4>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260930055414.136306-1-bint4b13@gmail.com>
References: <20260930055414.136306-1-bint4b13@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


On Wed, 30 Sep 2026 14:54:14 +0900, Jinpyo Lee wrote:
> The NFSv4 decoder represents an unknown wire operation as OP_ILLEGAL,
> whose value is outside struct nfs4_op_map. nfsd4_spo_must_allow() passes
> that value directly to test_bit(), causing an out-of-bounds bitmap read
> when an invalid operation follows a successfully processed operation.
> 
> For an SP4_MACH_CRED client, a set out-of-bounds bit also marks the
> compound as spo_must_allowed. Validation used the nfsd-testing base
> recorded below. On the unmodified KASAN kernel with an empty allow bitmap,
> the out-of-bounds bit changed the export security-flavor result from
> NFS4ERR_WRONGSEC to NFS4_OK for 64 of 72 client instances. A krb5i canary
> read then succeeded through a sec=krb5p export. The current allocation
> layout did not produce a KASAN report for this invalid bitmap access.
> 
> [...]

Applied, thanks!

[1/1] nfsd: bounds-check opnum before testing spo_must_allow
      commit: 759d4bfd7697400acba1f66fd2dbba414f78a80f

Best regards,
-- 
Chuck Lever <cel@kernel.org>
