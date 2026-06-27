Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0AAC42BEC2E;
	Sat, 27 Jun 2026 16:35:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782578143; cv=none; b=VyBUVwLs8b9XF8tJHIbtfoGlwEOed1YhWpFNListw8ow4cLBIDh6cPWFn5sjEq1wj2vPGkBS2hPTAHiVMnqHDhFjlz8AFFI/reI3bKGecT2JRhcyuywo+a56/LkD2p7GGjoyZwLNAH+XihTAf0zRDJ1WM2mlQpXcwvrLbN1NvzY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782578143; c=relaxed/simple;
	bh=zTN0q2glhrsJYPew7PDgqVnYg1W1zHDewxL8xD1PklU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=i5ukkq70m2HLw763M4gLU70odP8lVGzpSDCjP6M82q3QZEvzRWe71xwIGtXylhxJgKIBNOQxsXqt52QZuUXCD6GLLFe1k7izf3Ja7bp0PkOVYVWa0KqmDIE3Pzse1Wiu7w+tPC6XK/CzHLSbhfsvtovJh0ig4e8vCPgsYKWMLWQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PyJa+V3p; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PyJa+V3p"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 479D51F00A3A;
	Sat, 27 Jun 2026 16:35:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782578142;
	bh=L86NcFVsGNYxp1VrAP0RC6+4a+4d3KBmXI+tfRjqWEc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=PyJa+V3ptU5C/7VUSnAhyx4Fg2J64zYgrsfz7MylGVxRLUUyMIzzZdhKwSjoCu2kM
	 mK5Iaa7s7+cWUdvAuLijJN8mpiDwbfmWzXjyIXR1lKCumCjlSKEs8T8HJVfWEXYFzq
	 i2Ddia9IkFnwJAQjHUJnUBoEe1kxZBEvdoyKw6xVwfYVYIEfB6Bjk7RClWDQcZ8Zwf
	 MM50ew5eIHkcVhqdUSh37u40ORI8sx+zmlG1pNyJzJaffwjq9Wne8heXdGHxleeGiM
	 h3CvumYCUx+MOL1Km9PfT/owakjELAzO+3cN+F7UH6osoGsp2IVbNPFFlBi0JCTAgB
	 3dOpPguaQD6VQ==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Tj <tj.iam.tj@proton.me>,
	Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>
Subject: Re: [PATCH 6.18.y] lockd: fix TEST handling when not all permissions are available.
Date: Sat, 27 Jun 2026 12:35:29 -0400
Message-ID: <stable-reply-item014-lockd-618-20260627162226@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260626143122.71386-1-cel@kernel.org>
References: <20260626143122.71386-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Fri, 26 Jun 2026 10:31 -0400, Chuck Lever <cel@kernel.org> wrote:
> [PATCH 6.18.y] lockd: fix TEST handling when not all permissions are available.

Queued for 6.18.

-- 
Thanks,
Sasha
