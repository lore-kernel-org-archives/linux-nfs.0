Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D63DB42885F;
	Sat, 12 Sep 2026 15:53:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789228415; cv=none; b=T4z9KU6zBo4bWjPM53os84DaIqyPeOKnfJGgD1+J5a8YZMMItSQgCb7RFtKAZl6iPMHvJIYsylRUNvgc62kb6UADYdknoHFKBbVXX7pW+KfarKjQ9HdorPp0P/UCnKAI7T+ft7ozdcCT3SLQfBcsd/pLHsINMt1Y6S5Fcyl8VWg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789228415; c=relaxed/simple;
	bh=N8HapuqbUfj56wL0LPpu2izcPfR8iZAWLOVEpo5FCuc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=apbYrg/P9HNbMrFgpTlosUmImX8RsqIo0gIsbJkS9qYFlc6NR1YNrWniy208KxC2J4j5Dd1MJtmNUdAym0PnPUEIQ9TiRqjhcF3x4ZSTF2ZgpZeEGlTP4R5sePoARsfsZoQrK+9tQ1M4dnhbJTKy6wCAbGfWEPxbocdxWb7AZnc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bIS4C6Tn; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bIS4C6Tn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7F83B1F00893;
	Sat, 12 Sep 2026 15:53:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789228414;
	bh=ttKQbOzVjb6AlBFxuNQpx741zEfCYj+Y/WuAcre2rpQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bIS4C6Tn6NOZOueeVx1VyzZFb/xzivhTGQ4pJdKLIXlpLOLRXIV4oaNYTaVp6/0B3
	 c8oCAylZPXSMK8s0YCumfhZKB64IrOhA6/+g9frf0udJyaaTTUgLl0lsH5V6g2V7j3
	 6VSxTN+42VwDJ5Ag4lYIlsnuJPkl0ns12w7Cwd6NASiCBrW9kXgbh4ZjSuCrEQyaO6
	 zMRJVlzrbntG9M/nzoNnp5lfgJhsJQ3whUMGhSoazPXhQ7VvBNvaLlia4ZcTQMPNK9
	 FYQ86hKL/iZRzgMIeDXLQf2VSNkyVfP/9OnntnQxBZUgLzhpZl+0MICDgJH0oAAp1i
	 RlKBKHhFZMepA==
From: Chuck Lever <cel@kernel.org>
To: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	Zhiling Zou <zhilinz@nebusec.ai>
Cc: trondmy@kernel.org,
	anna@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	davem@davemloft.net,
	edumazet@google.com,
	pabeni@redhat.com,
	horms@kernel.org,
	vega@nebusec.ai
Subject: Re: [PATCH net 0/1] SUNRPC: hold a reference while tracing accepted transports
Date: Sat, 12 Sep 2026 11:53:29 -0400
Message-ID: <178922840185.184815.12388585730489010833.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <cover.1789220778.git.zhilinz@nebusec.ai>
References: <cover.1789220778.git.zhilinz@nebusec.ai>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Sat, 12 Sep 2026 21:56:08 +0800, Zhiling Zou wrote:
> We found and validated an issue in net/sunrpc/svc_xprt.c. The bug is
> reachable by a root user through the NFSD listener and TCP connect path.
> We've tested it, and it should not affect any other functionality.
> 
> We will provide detailed information about the bug
> in this email, along with a PoC to trigger it.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] SUNRPC: hold a reference while tracing accepted transports
      commit: 5fe97e4d0a041521dc4aef417ff250c902fad928

--
Chuck Lever

