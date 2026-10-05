Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3BBC949E5E1
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 15:00:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791212440; cv=none; b=lvnzQJp418Fu3qxdCo9AnGeXelGNR21QdooZKpNQFZc8XIOBd5BdlEzdqXk4jK868ZqhTZO8lTykAKdroPTEB6y61dFRu6RdFEz/bAVus5s1F0hUWWqkc9PBCattW5XuR2tlK6AU6uRexYds1lxMMAr+32otgjgM2ECNrGRQcB8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791212440; c=relaxed/simple;
	bh=/pW2TlbG1adDBs8NgAs6BajGKQEOT+0fqnnSpW4SGkk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=ewDc/NzgGEI254celL911IuDRKG0a2jJIV+zxO/0VOh905qu2aeHzXravu/WP/xkfKN8RfIT1m0LEwEiqHBh0RqrPF/qe6Ka9WSuJC92umVx+Uffh5aiH0SfvaJuxFqpQY+2R0m3nud8RRTXvuCQUNWJvZHittSRh/EVW9DsecE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=A+ebWgg/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="A+ebWgg/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2BD1E1F00893;
	Mon,  5 Oct 2026 15:00:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791212438;
	bh=QSRPylZ00nJLAVXCMiDltq+5z/8vARYBCpk3J5394yw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=A+ebWgg/y1CloomHo1Nnb3ZKYdp+eTb1qWDzz11a0aavdb9W2YhTFcQvc8k4KCu36
	 t1HS4gt3ZbOaQVSPnMVFdau+HW+0wPjGtL8IlwGEGPZACXJZpmenK+3ZYEwpzkA0DB
	 L4VN6YQinhN9X+RQ2vega+x0IcPWtEt23xDy7/ibVWL8kkARJKKzeOWqMLHjtx7gP6
	 AalK56x1yAyXYYkAwlv6kqbzhnAT+62UVpfrgbV5/lwTC9hFTou05O9iLUEg6s6XPw
	 hMM1TOWlv4qg8hFYhIiOVVAiv9EysQ4gn/qwcX4tF+SJpF8n43nrpTXRruQktK+s0Q
	 n4Bisoyl8mKyg==
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
Subject: Re: [PATCH v2] nfsd: hold client reference while reaping async copies
Date: Mon,  5 Oct 2026 11:00:34 -0400
Message-ID: <179121242263.30709.1424909534100183084.b4-ty@b4>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260928083050.642664-1-bint4b13@gmail.com>
References: <20260928083050.642664-1-bint4b13@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


On Mon, 28 Sep 2026 17:30:50 +0900, Jinpyo Lee wrote:
> nfsd4_async_copy_reaper() moves expired COPY state from the client list
> to a private reap list while holding nn->client_lock, then releases the
> lock before destroying the stateid. The detached COPY state retains a
> raw sc_client pointer, but does not hold a reference on the associated
> nfs4_client.
> 
> Client teardown can therefore release the final client reference after
> the COPY state is detached and before cleanup_async_copy() releases its
> stateid. nfs4_put_stid() then follows sc_client and accesses state in the
> freed client. Generic KASAN reported a four-byte use-after-free write in
> _raw_spin_lock() through nfs4_put_stid() and
> nfsd4_async_copy_reaper().
> 
> [...]

Applied, thanks!

[1/1] nfsd: hold client reference while reaping async copies
      commit: 719ce5204fcfb98daf1656fd85c76ba2f5369f8d

Best regards,
-- 
Chuck Lever <cel@kernel.org>
