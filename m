Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B8D0484230;
	Tue, 13 Oct 2026 18:05:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791914733; cv=none; b=Le3AE5nK1vXnqM29elPv2ZbfrZXJilxuFZgc221d6zZgH7wqVJ//6RhA4RzRhuIdlchudYLmiD4q/8Reqy5fsIb8NmUyFIbKNd51v6y7RIaULTJwsGPK9/jPgC6MAHfTbzZShU+dRriW75QmTwA90m0oKkfH38OjcPJ6M+gEoco=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791914733; c=relaxed/simple;
	bh=T80pmibn7aSi6N9hDzJvCBDoLXDCN4HDH9fhrQVJ60g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=V4v2UH2KNsg2AHFpCJ8LyxSMlRpBdwGSn4JJ+U3oUH2wFKQBfdLkpikDjbH9iD7Q7TEfREEukLnWy2fgV+wfsJ1XeTB9+FPUIXQ7Ul5DRu6fcspkMG67GqrZTM7POhjitLlJtaNcS3C6mqTmWMERtuXQT6Q+C/R+jDgrahkiw14=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aWMm9bLA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aWMm9bLA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EDC241F000FF;
	Tue, 13 Oct 2026 18:05:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791914732;
	bh=ZCAoLYZlSrLohEk+mBrzJi43HvKosm2TxiN/tMhp9/s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=aWMm9bLAInsLYZgw0CLg3bTYbbM5NQCTOGg/PJYbyMKZLePA7BorrKEbtrS3AuuzG
	 bnYF0+IXimmufMeHJzOhN29hH0mayXKokTXCc2YCse2781Qw0k3mORWFOPR6Q1IH0F
	 9gw/r/toExmmN7ndsbjVnrdVFB1FkTY3TMLrUPq9Nt7ec9iZUf+CxbvLJ+qWyO4S0V
	 Q/bXeW2lVYNLSSmVEao6Zi2vEYLKkjPwkm3tMqvoEjCtCuq7h6vWLG8SGqKoGkezNK
	 mD6He5Dk6LRk242PzAbroKy8HaAsb8ROtoVDOyWI/dREldWGvFZxff6fmr9ydGPdbC
	 9sPLGU1gIFGfQ==
From: netdev-bot+sinfo@kernel.org
To: Josef Bacik <josef@toxicpanda.com>
Cc: Andrew Lunn <andrew+netdev@lunn.ch>,
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>,
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
 Simon Horman <horms@kernel.org>, David Ahern <dsahern@kernel.org>,
 Ido Schimmel <idosch@nvidia.com>, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>,
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
 Tom Talpey <tom@talpey.com>, Mina Almasry <almasrymina@google.com>,
 Kaiyuan Zhang <kaiyuanz@google.com>, Willem de Bruijn <willemb@google.com>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH net v2] net: skbuff: make skb_copy_and_csum_bits() report
 unreadable frags
Date: Tue, 13 Oct 2026 18:05:30 +0000
Message-ID: <179191473048.99822.411131589969126386@kernel.org>
In-Reply-To: 
 <20261013-b4-skb-segment-nosg-unreadable-v2-1-6c28d8ffa51e@toxicpanda.com>
References: 
 <20261013-b4-skb-segment-nosg-unreadable-v2-1-6c28d8ffa51e@toxicpanda.com>
Auto-Submitted: auto-generated
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Hi!

This is an automated message. This series looks like a fix, but its
commit messages seem to be missing some information:

 - Whether the issue was actually triggered, or is only theoretical
   (e.g. found by code inspection). If it was triggered please include
   the symptoms, like the stack trace or error messages.

Please do not repost the series just to address the above. Instead,
reply to this email with the missing information, so that reviewers
can take it into account. If the series needs another revision for
other reasons, please include the information in the commit messages
then.

The evaluation is done by an LLM so it may be wrong, if you think
that is the case please reply and explain.
