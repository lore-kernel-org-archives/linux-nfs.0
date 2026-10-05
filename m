Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7C604BB26B
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 15:01:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791212495; cv=none; b=KCV/lSQxUnm1Ic79EwbGLLyu6s9EHATKE2Qg8ygBdthoYc8Z+9ut49jKj4NB/QSsOUDyTdi5vIxbOBc1lBEBwdAkAtQWoVIlfJUB/kIW3kQfmONMfPtE275TyjhNtQ/sLGVAoNLdyNe/sR34n8AQqCC9V4aVzIdXo4K3KOuAq2A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791212495; c=relaxed/simple;
	bh=S7qIGPsHyig0GjW74JMNgQa0HEMwytokjtzXMCHG50s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=asdjOuDVSpMqzjGPgMpSgEYFdWOvaF83jaUdWt9L5rb2az+OkUlibyTC74ycNSOtE0t/7H3pVJec+w5V08aH3nRzP9K7TtiE5fheYdl8zRvCQ+wKIrG8hRc63Bz+KFXptqL96t8nS0fkPH7m2zwJPHLRLb2RfCgQtjEU/sKa6Yk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gqrg73F4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gqrg73F4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D1D301F00898;
	Mon,  5 Oct 2026 15:01:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791212494;
	bh=roNmcZpW0Ew0iE4TBqf3IO4KRwwtJJOAWWw35vXbbhI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gqrg73F4Pzgq8vN1to3jT675bKZqU4xKmkOZsZ4zf5TzNiw2cfmg3YKmZwPU5Rmcj
	 IaluIwkGvuslBVnoeG5zAlUqLDOLy+4KNzTfURwPia//RiM74Jtk08v7dxtXtow4hS
	 Zoqa2RzTtfUpEDQVmb0wTvyjCbhbh5VjIrIKFVt3uD0/1y1EayB0j6X6sckXERxb+J
	 fH03vIy3C3XW2T6Zu/aJTWVFad5pSW+SHdfkYJXIoCEYuukaAxqsIxaHT0UkUeqEIj
	 puIOwGuzz35doYM9rZY9SG0EACYp/aIRRfStaKgtRf6/av5DiKO7DH9GOdNwJgGgvx
	 bOgyxvuyfa6IA==
From: Chuck Lever <cel@kernel.org>
To: linux-nfs@vger.kernel.org,
	Jinpyo Lee <bint4b13@gmail.com>
Cc: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	bobtobabz@gmail.com
Subject: Re: [PATCH v2] nfsd: avoid dereferencing callback connection after unlocking
Date: Mon,  5 Oct 2026 11:01:31 -0400
Message-ID: <179121248185.30837.10054154203647606127.b4-ty@b4>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260928083424.642863-1-bint4b13@gmail.com>
References: <20260928083424.642863-1-bint4b13@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


On Mon, 28 Sep 2026 17:34:24 +0900, Jinpyo Lee wrote:
> nfsd4_process_cb_update() takes a reference on c->cn_xprt while
> holding clp->cl_lock, but retains the raw nfsd4_conn pointer after
> dropping the lock. The svc_xprt reference keeps the transport alive;
> it does not retain the enclosing nfsd4_conn.
> 
> Concurrent transport-loss handling can unlink and free the connection
> through nfsd4_conn_lost(). If setup_callback_client() subsequently
> fails, the original error path evaluates c->cn_xprt through the freed
> connection in order to release the transport reference, resulting in
> a use-after-free read.
> 
> [...]

Applied, thanks!

[1/1] nfsd: avoid dereferencing callback connection after unlocking
      commit: c186c6483c45f5c0867faad9c63f95a53dad46e7

Best regards,
-- 
Chuck Lever <cel@kernel.org>
