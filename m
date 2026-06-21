Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35275284693;
	Sun, 21 Jun 2026 13:48:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782049681; cv=none; b=kYs5Q+KLz9R7GZp8k6c0RKKP+b+J9xH8Q9ONHSlTuG7kUOZkr7af6C1F8RN7nvkQT+hwr0/Dulm9Y4BhzthOdwBu9uAjrWAx3abSBPZRHD4TUB/iXIuJ/yvzs+TLKqYyksWt0eXdzKFBi1IRZ2bFXH87vAettc5jN5Hq9bdDB/E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782049681; c=relaxed/simple;
	bh=uEbRfZOwBOc96pWTx6nxNqTXYlOtrL4xz6eymHRUbwA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=VrZMRb61dleGfCcBtbY+aMM/rJKxHD+S/TIy1MIcyHWyV8uk0nGALombWk2MfHamk1MMh/XA8KFQBmk7XG6/wqC6P4NEzd56yKUMrhedtq7MBOeqqcprYZ4JfcSh+1afgrmja45KwXE3bB5qEk9RpxDfCWePmWoYN6Xi0thhpsg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NEIE+TIB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NEIE+TIB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 306B11F000E9;
	Sun, 21 Jun 2026 13:47:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782049679;
	bh=TiuitKeGB0onh6bbUQZCgZxyAd8ckls4Kn7l7oo2FgQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NEIE+TIBvym0U/DJXH5zQxGa0TvdNOcJw7Y7yyQ7Ul2swE89M8XJm5Tkja3CgoHl8
	 vW4XrkvyAcdcO+MWso8HjqsuzImd2gm8iD7eok+0aAO0Mdi6zPH0mVqgODWqhSrBfF
	 13OR5u8MTD6xfr0DkcUbYwM9LRK0igpeLtfPW7Y/4BsHFVy0cUdIec69AmMMi4/E+R
	 DNg+4rt30WCVjaTDvjsKLB/2APRVgpnaVhTCopB0Zy8zDiscmdIq2avm4dL6lw71AC
	 I3AHNQk6GUc5ZCKTMk30hDSEHJD+QrypvI00NHcpRtmvBJ+Z3DzKDpNcgglNkZr/9A
	 X7u1VShPEX8ag==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Tj <tj.iam.tj@proton.me>,
	Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>
Subject: Re: [PATCH v7.0.2] lockd: fix TEST handling when not all permissions are available.
Date: Sun, 21 Jun 2026 09:47:45 -0400
Message-ID: <20260621133722.0007.sashal@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260619204750.1803357-1-cel@kernel.org>
References: <20260619204750.1803357-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> The F_GETLK fcntl can work with either read access or write access or
> both.  It can query F_RDLCK and F_WRLCK locks in either case.
>
> However lockd currently treats F_GETLK similar to F_SETLK in that read
> access is required to query an F_RDLCK lock and write access is required
> to query a F_WRLCK lock.

Queued for 7.0, thanks.

-- 
Thanks,
Sasha
