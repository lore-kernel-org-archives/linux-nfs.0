Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5311A19D891
	for <linux-nfs@vger.kernel.org>; Wed,  8 Apr 2026 12:51:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775652719; cv=none; b=YopFl+o0xYWGNOTVBbVuZhtWip5q1tLL7xSYRoKmra3YZ7yzy+ueReuXd2mzWbDB7xm3rNZACBCFIVLvSS9W/H57NJnBuxbLz+lIR3aiNB9BnExdsv1gQcnt2lwdSM8FoTlUEHIhemsJiCeKqABPPLCVEhqVHlBqzjK3CvfCLZw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775652719; c=relaxed/simple;
	bh=QmwkuW9ydFTorcUWv6jHTAPRhI9u9ldbxt4RTCx8TAI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=ACGr7+j6aoVWC4OzLrPfvgfnk8lN1PEyHKMthss4ntFnDMibxkM7jLCFd/hvh0WSxE/4hEQk5GfsGKRNBKVLiz3k4kUoNqHq1uzqXYuNRqx6mJvLQpr5CsRzW/q3k9wvT+PgRd3mezTGuSmj4fli56JMSPJ0ZX9/zR++05qLgIk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JQmsEEzE; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JQmsEEzE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4906DC19424;
	Wed,  8 Apr 2026 12:51:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1775652719;
	bh=QmwkuW9ydFTorcUWv6jHTAPRhI9u9ldbxt4RTCx8TAI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=JQmsEEzEh1hIzEx9Oiq77hChzsHvnBV7vckIpqpIfo0AXir3Jrerk5ydkN/LAJvf7
	 ZhiMOf4q+SgfcUJbE+bEXvkul9qWeGS/G5A7V0OlCR7gZJ3dDUWzzEzpHdvxyaK4zj
	 7Kse+yMbLtX9kVJwKtYOB8NVmLPNbxpX5FHrD4xYbOnSgsJpy4nSM2VI3deW6hR/s4
	 +wjgv/HBG3LKQ0OTUnR++u4DbxVjbSjeiZEpZr8HNEqZke/SSU9YrQdXF3zaYf43b3
	 RHa5oAR/HXJcg/n6TjvolgFvvt+YagBBIdAw4baezRFFQbRkoAAKZj0sAaJoZdU2Gh
	 C/+dUIIDyy+XQ==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Scott Mayhew <smayhew@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4] nfsd: fix file change detection in CB_GETATTR
Date: Wed,  8 Apr 2026 08:51:53 -0400
Message-ID: <177565264307.804387.4529450531664012401.b4-ty@b4>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260407220857.1826441-1-smayhew@redhat.com>
References: <20260407220857.1826441-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Tue, 07 Apr 2026 18:08:57 -0400, Scott Mayhew wrote:
> RFC 8881, section 10.4.3 doesn't say anything about caching the file
> size in the delegation record, nor does it say anything about comparing
> a cached file size with the size reported by the client in the
> CB_GETATTR reply for the purpose of determining if the client holds
> modified data for the file.
> 
> What section 10.4.3 of RFC 8881 does say is that the server should
> compare the *current* file size with the size reported by the client
> holding the delegation in the CB_GETATTR reply, and if they differ to
> treat it as a modification regardless of the change attribute retrieved
> via the CB_GETATTR.
> 
> [...]

Applied to nfsd-testing, thanks! And, thanks for confirming
applicability to LTS kernels. Cc: stable@ added.

[1/1] nfsd: fix file change detection in CB_GETATTR
      commit: 17a5b972dbf13cb2a7ef38317f971d9ccfe8471b

--
Chuck Lever

