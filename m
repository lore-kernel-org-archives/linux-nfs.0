Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C78F532142B;
	Sun,  1 Mar 2026 15:29:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772378973; cv=none; b=sikyAYw9Vn0gkyXeX1WBBGio2Kq0hkYpes1XdT8/kKkOrqIEdvkqTEg5JMlo+44P4nC0PUEDoFsKLXmc1w8qgEn43MIbqlKwBipknaR8zzW/49yZfBDQ98L2ve9IJsF36YfGfYO4gsaLCHLYxPNQ/62kppGBDbCJ9S8DMEkqDeU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772378973; c=relaxed/simple;
	bh=Bx3z32IhN9CFHRKIlteQ50LHrLdrPaNXkV2fQy7Qtpw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=a0aSmST6zP6IqlXNNdlxLsiI8/vlNbCmBns3+81L1QhlRbLgdyI2s0UF2oLz3yTAyyUo1itIIGSmG1la9Z1vrUe5RR2N2sH8YPnBA2Pu9v1cYuLvOoqsKqVex4yFc+V1ipeYBtECyENYx+SaJjAES3W247d9GaejYw/DJaOXkAY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EuO7JlqZ; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EuO7JlqZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A8950C116C6;
	Sun,  1 Mar 2026 15:29:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772378973;
	bh=Bx3z32IhN9CFHRKIlteQ50LHrLdrPaNXkV2fQy7Qtpw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=EuO7JlqZ2B1BHXfqGOgLCasmEIucNVh6vm+zsFtSBjj2+v1OOsJdkf7FcrFC9FmKC
	 zsOt8OrbNe6zi0YqONMzmwQJA9d7ANP2DcYj7FjWW7HK/cIGoC/So1ubKmVwZfHONb
	 j7L70foAsU0mn00c1lQoY1tq7vSRPIugldzEZv+Aliho70PrXHiQ9Q1VvWld2v/XgP
	 riGLolOh39NYuXQnOGKClv0EQjUH4qAnLlgwiBmgmDjuzN87ON84/s+6bL0FcUOlBL
	 iLwJUg/jD6sX1bqFiedPIm+znxBXa5TabP3ZrIp01V/fi7Xle+3mNacJZkXk8bxONx
	 SzzY8ILg9yizA==
Date: Sun, 1 Mar 2026 15:29:28 +0000
From: Simon Horman <horms@kernel.org>
To: Eric-Terminal <ericterminal@gmail.com>
Cc: Dominique Martinet <asmadeus@codewreck.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S . Miller" <davem@davemloft.net>,
	Jakub Kicinski <kuba@kernel.org>, v9fs@lists.linux.dev,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nikolay Aleksandrov <razor@blackwall.org>, bridge@lists.linux.dev,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/4] net: replace deprecated simple_strto* parsers
 with kstrto*
Message-ID: <aaRbWCeu-wNdWGzB@horms.kernel.org>
References: <20260225010853.15916-1-ericterminal@gmail.com>
 <20260225033840.33000-1-ericterminal@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260225033840.33000-1-ericterminal@gmail.com>

On Wed, Feb 25, 2026 at 11:38:36AM +0800, Eric-Terminal wrote:
> From: Yufan Chen <ericterminal@gmail.com>
> 
> This series replaces deprecated simple_strto* parsers in net paths with
> kstrto* helpers and keeps parser behavior strict.
> 
> v2:
> Split the original large patch into a 4-patch series for easier review.
> Added a prerequisite fix for xen_9pfs dataring cleanup idempotency
> (Patch 1) to ensure safe error handling during the parser transition.
> Refined the xen_9pfs version parsing logic to use strsep() for better
> token handling.
> 
> Patch 1/4 fixes xen_9pfs dataring cleanup idempotency to avoid repeated
> resource teardown on init error paths.
> Patch 2/4 switches xen_9pfs backend version parsing to kstrtouint().
> Patch 3/4 updates bridge brport_store() to use kstrtoul().
> Patch 4/4 updates sunrpc proc_dodebug() to use kstrtouint().

Hi,

Thanks for your patches.

I would like to understand what testing has been performed on these patches.

With the possible exception of patch 3/4, I feel that unless they
are motivated as bug fixes, these changes are too complex to accept
without testing. Although the opinions of the relevant maintainers
may differ.

And as for 3/4, I lean towards falling into the policy regarding
clean-ups not being generally accepted unless it is part of other work.
