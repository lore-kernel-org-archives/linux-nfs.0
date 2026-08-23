Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B1422EB10;
	Sun, 23 Aug 2026 01:28:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787448486; cv=none; b=ZqHhNhBRcxvprioX7a8+Qd+aAPljCsZNDhgy9Bvm0IA13fXyDhbyhy62uewRFieffjk8vDWEn49IAR65PzcDBBMEB88RUgfs1gepiwuGM4qdKxrptSjuldx9GPqSIMpDb9296z5fQoTMwrqfcmcpq+7/uAxEYbIPTm8n9FYQNdE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787448486; c=relaxed/simple;
	bh=TY8KFkxutSgZztfYxjA5awyY6wbeo8CLkfRDJJlACqU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=lCzYVrC1WSkyBjHRAFnSs7PS3FqvXl093VujBd0JnyFkrYu1N4YqYx02d3DNadN8Q8/HkCE2cXzCcvf1qxR7Qz9NOcrP7RoWZtMWl1xY9WHbH6GZw29fQidMTsVwBzFdu/czXjMq6BFKB0Je+3/kWn3M5xaKnkv8bKgAXkoTGy0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hzQHHYzg; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hzQHHYzg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0CE141F000E9;
	Sun, 23 Aug 2026 01:28:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787448484;
	bh=KXqSJZKuCl5DPpCiFWtVMOssMWgagpEVqGrakBU9TNU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hzQHHYzgm0+hylD5PL9aQT6cY25rZT8z5792C0xbek0Wp0DHmCnUToWXIzF6bobly
	 wD6zdw3RqEqQvYwQ975kGFFjCi5PitbuUi+IbdySBCcCgSLzx2nKRM+vi+oQyTaFPK
	 Lsg/rtIm3NiWwYdLjBhGhxD9tCQoPvVUgF5dYO2Km6PeUxV1VqNsU2xwd6iFG6hM0F
	 kJVtroTtaWwQfN1jPQeoucgHYxI3XNB8sQzSYKRyZO6mzr2slRR3QrVtIbmIYSo0kn
	 Mh52MI6MbeW3XUG2dqTw2MCoZEc0BB63PzZMUp6FHEiYG0OJGjOfuoWVRtLQIRH+mJ
	 P56unY3l4pwbQ==
From: Chuck Lever <cel@kernel.org>
To: Karl Mehltretter <kmehltretter@gmail.com>
Cc: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	linux-nfs@vger.kernel.org,
	Jonathan Corbet <corbet@lwn.net>,
	linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFSD: docs: Fix pNFS SCSI Kconfig symbol
Date: Sat, 22 Aug 2026 21:27:59 -0400
Message-ID: <178744847029.68316.12561358765745525594.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260822081033.82098-1-kmehltretter@gmail.com>
References: <20260822081033.82098-1-kmehltretter@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Sat, 22 Aug 2026 10:10:33 +0200, Karl Mehltretter wrote:
> The pNFS SCSI layout server is controlled by NFSD_SCSILAYOUT.
> NFSD_SCSI has never existed.

Applied to nfsd-testing, thanks!

[1/1] NFSD: docs: Fix pNFS SCSI Kconfig symbol
      commit: 55a29a459f1a6f9f70fddb8c5a6c94ce02e8d566

--
Chuck Lever

