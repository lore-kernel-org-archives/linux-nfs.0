Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A62703A6B6D;
	Fri,  4 Sep 2026 10:50:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788519053; cv=none; b=rj891+Zovn/FE6R8Pz2S0s9sjsTlp78gz4fLPeU0uex3+tYfsA7h0PWcM5lUFVi/a1oV2jIc83pe9XKqV6BN4KDwmmJXw8nTXQ3ayZsN/IExPyE7GMSqMtrZogYLpV93ghYbELNJyBiLYqu+9cmBoDkR/EsM+/1bfcNDb9PgsyQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788519053; c=relaxed/simple;
	bh=xEOW/4H3p7yBMSpoUyhfY+10AJxbXHQvs/nMGT4sB2Y=;
	h=MIME-Version:Content-Type:Subject:From:To:Cc:In-Reply-To:
	 References:Date:Message-Id; b=YYeHTMzKm7z5SVW+pflSR9F9pjlBVh9X3rsLeW7vxe+wSfHOJ0iQpPWqCf2AhbO7R8XLyMTETkPOrrSEo9nqMH7CT9hyLhIhoxapj0pvmx9rrnSQ5ZHSjj+Gakyb5pZnIjP0TSStPOqeFhJrO7KbnmYrhIi9pGTtRXaDJFyZBak=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XXkHrpqE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XXkHrpqE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 95F301F00A3D;
	Fri,  4 Sep 2026 10:50:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788519052;
	bh=BkcMFybV50PQZ5nR2pp7nwMKr/9EAjjeNaTtRTlQy6M=;
	h=Subject:From:To:Cc:In-Reply-To:References:Date;
	b=XXkHrpqEoAi3BJdml7qXpcYHZx+LFuPKuYwEZBoESehuEjIER/okiGPOQawZ77jaq
	 n7rhBmTjibKqxRaW9T3wUL3+5bP4Kaq67cW8c2qRdfaVExbb0B1sVTAO46qFz/0Xwo
	 +mx1xL9VnigOjDQ/ApS+siEJkQfhoM1HK5F5T0s9VRM+PcFRbV6pegPVJ0oq1Fhiyj
	 A9rBXyPqSQgrq4lqYqWcWXmYYLSPVyS1u6uGylwtgZyJp63zn0bDa1FjoolyQ8Iaa9
	 UizsTB58ez8H1Re/u+dbRz5p6C1wnhYYM2YHg70So0jw67B9sW0CjMKmB/GmRWPSQT
	 J+l6wWRYlgLEA==
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH v2 0/3] fs/nfsd: accept a backdated timestamp from a
 delegation holder
From: Christian Brauner <brauner@kernel.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
 Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
In-Reply-To: <20260902-delegts-v2-0-383cb289ce88@kernel.org>
References: <20260902-delegts-v2-0-383cb289ce88@kernel.org>
Date: Fri, 04 Sep 2026 12:50:46 +0200
Message-Id: <20260904-abreibung-schnupfen-texten-3120c46b6d23@brauner>
X-Mailer: b4 0.17-dev-db0b7
X-Developer-Signature: v=1; a=openpgp-sha256; l=720; i=brauner@kernel.org;
 h=from:subject:message-id; bh=xEOW/4H3p7yBMSpoUyhfY+10AJxbXHQvs/nMGT4sB2Y=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWTNWtS+fnUt/4zUFf6tm7fruj79e3XtbGYOQ8HXJnvFF
 31ZsuH4n45SFgYxLgZZMUUWh3aTcLnlPBWbjTI1YOawMoEMYeDiFICJqJYy/K+ffKM8+sXJK6fM
 dK+7PF8yMS3FIbJwybLZkosKHiT/545n+KdSuVPqrnqyhVWQXazzrBW6P7uS8mc3xLxm4wi0yWh
 5wAMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

> The main problem is that an attribute delegation has strict rules about
> updates can be done, and that prevents applications that backdate
> timestamps on files after writing them, (e.g. tar -x, cp -p, etc.) from
> setting them properly.
> 
> We could fix this on the client by making it always issue an RPC for the
> SETATTR, but that would harm performance in these common use-cases.
> This set allows the server to accept some of these backdated mtime
> updates, by changing how the ctime is handled.
> 
> It'd be nice to see this in v7.4.
> 
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---

There's a bunch of Sashiko comments outstanding, Jeff. Let me know, if I
can ignore them.

-- 

