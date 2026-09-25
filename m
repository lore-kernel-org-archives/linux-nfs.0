Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D3D843F8D9;
	Fri, 25 Sep 2026 18:48:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790362101; cv=none; b=JjO6q1tqI2+d2IBj3frSXA5ahA10R85hmWHlrflJEML+FVh44HuyiwtHKRd8KRg66wCCSRF9NXCYA0XQ5+n1EoxqoGHFvsW+J5bZhpwsw52WoBsx5djiz8zQuy/lkmvKNp5+sDxxB3DkjD/CWxgVDMc8dubJCG1hmN3yAZnHqwc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790362101; c=relaxed/simple;
	bh=tbm6qVcaRRU/He3iQd8ZKhWsncS+f9BZQ8RABrgQhe4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rA5Syceq/ah8EIOtxUlmOvqtqd9Qr17631ggG1ANXjl89XizI44pFpjW5xrS/NGKzB7CqvW2I2VESwlNk5nVcTJHdQPL+fJ2+xcxpK0LHQgASejwTL/0yMstktiLqsm3ddBi/JHi757llaQwiyyQfg0/UJ9WpmWiFv1YZio5ntc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=C5n1YUKV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="C5n1YUKV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 00C811F00893;
	Fri, 25 Sep 2026 18:48:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790362100;
	bh=rhJMb8thF9si9O2RrtvtTljDJcb/QqgrmML400cmdis=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=C5n1YUKV5mQUbYRfHAYvTEKRnXz4xY5jhy4nB39iSdAO90IqBU3Xj+HvYNv7R1R6p
	 Dg7TGmD+ODUAXEhknBqwPJxCPWcaw/pFgUwuaQYnIPvjpyvrP1Z7La6NpR45MY80XE
	 9Jh3gTpS/gh5OC3PFpHrUikr6MlO6lG/yWlvFPLqfWnxPJETDKpj7DDxpPgWBggkvP
	 AlM6MIIJ3vdKc0Tkmgc884eAD1brs9vBoswngZ0yUxMecKwYH8IxFpX+zpr9Q+8cT/
	 S4JHnkeBJntR/ZlNSs5vnYWtrQn7ab0Bbs/YjvuZoy99Wjj16NxW0Tsl/07IgQjIjb
	 vPmmJMK7pSpAA==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jakub Kicinski <kuba@kernel.org>,
	Olga Kornievskaia <kolga@netapp.com>
Cc: Sasha Levin <sashal@kernel.org>,
	Benjamin Robin <benjamin.robin@bootlin.com>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@bootlin.com>,
	NeilBrown <neilb@suse.de>,
	Robert Garcia <rob_garcia@163.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Miguel Gazquez (Schneider Electric)" <miguel.gazquez@bootlin.com>
Subject: Re: [PATCH 5.10.y] SUNRPC: lock against ->sock changing during sysfs read
Date: Fri, 25 Sep 2026 14:47:57 -0400
Message-ID: <2026-09-25-daily-reply-0005-re-sunrpc-sock-sysfs-read-5-10@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260924-cve-2022-48816-v1-1-b44c7e4dd493@bootlin.com>
References: <20260924-cve-2022-48816-v1-1-b44c7e4dd493@bootlin.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> [ Removed the changes about net/sunrpc/sysfs.c, as this file doesn't
> exist in 5.10 ]

Queued for 5.10, thanks.

-- 
Thanks,
Sasha
