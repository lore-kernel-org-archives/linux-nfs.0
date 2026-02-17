Received: from vps0.lunn.ch (vps0.lunn.ch [156.67.10.101])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1EE0D259CBD;
	Tue, 17 Feb 2026 17:46:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=156.67.10.101
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771350418; cv=none; b=md53slAJLa1MJ18iAvunyUWH99t60beAp91UDaKgNm7fqKSglog5JnShwKBxBDKtINX4aQaiisT+7nnZCefeNufR6HQfQ4QKn2M3G/oKZTmEBEfbjSrpwSuDy6VPcSX4q9bDNgd1msJl1CGLdP5mroYJw9bkKlu1QMgMPckAhV8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771350418; c=relaxed/simple;
	bh=/YOvvGm5oBmVJ+yh9mfJfOeXrCW7z2EefpQ61ojKo4M=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=D1WKL/gB7aI8yWktF9VE4QkW2kwOJPLxr2LXvvFmHm7+PxRp6szuC9t1f5UQyS/QtzVC1mDKXCUoEfISbtoJw5uE4wdXitAlC4Cxw8Y7WRAp6oKyd0sxgaWN1USV39mId36cya76Rw+IhgfddEySiTbltYHvjRVBr78NPov9iik=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lunn.ch; spf=pass smtp.mailfrom=lunn.ch; dkim=pass (1024-bit key) header.d=lunn.ch header.i=@lunn.ch header.b=iJO4nic4; arc=none smtp.client-ip=156.67.10.101
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lunn.ch
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lunn.ch
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=lunn.ch header.i=@lunn.ch header.b="iJO4nic4"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=lunn.ch;
	s=20171124; h=In-Reply-To:Content-Disposition:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:From:Sender:Reply-To:Subject:
	Date:Message-ID:To:Cc:MIME-Version:Content-Type:Content-Transfer-Encoding:
	Content-ID:Content-Description:Content-Disposition:In-Reply-To:References;
	bh=x+IMn6ekNyuPUJq7ANKTeXzNCQrAnc/yvZ6lcfaucaE=; b=iJO4nic4vu9Ma78zZn3OSVlf8+
	evgOVNOyWxAV2rQr1GMnR4ch47xfoeHNnfrqxi76PoGpBdzgNLnYMEzNn5cHMQttRBtUqcpWtbjmk
	uBukBZizwQWptKTyrNsjYzU3utsFOF5xKi1A8yLJjP4lYm3ssBEzlZdYDRz62ieMBBNA=;
Received: from andrew by vps0.lunn.ch with local (Exim 4.94.2)
	(envelope-from <andrew@lunn.ch>)
	id 1vsP9r-007fho-KE; Tue, 17 Feb 2026 18:46:47 +0100
Date: Tue, 17 Feb 2026 18:46:47 +0100
From: Andrew Lunn <andrew@lunn.ch>
To: Sean Chang <seanwascoding@gmail.com>
Cc: nicolas.ferre@microchip.com, claudiu.beznea@tuxon.dev,
	trond.myklebust@hammerspace.com, anna@kernel.org,
	netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 2/2] net: macb: fix format-truncation warning
Message-ID: <00ebdd77-d6ef-48f2-a25d-8d8b3c7dc7a8@lunn.ch>
References: <20260216174950.455244-1-seanwascoding@gmail.com>
 <20260216174950.455244-3-seanwascoding@gmail.com>
 <f71cdfa7-25f8-487d-b727-39ae962401a4@lunn.ch>
 <CAAb=EJWNSvTHuUX862vLmA2s1uKO0vy_x9OSZ6VXqY9X-+JNsg@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAb=EJWNSvTHuUX862vLmA2s1uKO0vy_x9OSZ6VXqY9X-+JNsg@mail.gmail.com>

> Regarding the architecture-specific nature of the warning: I have verified that
> this warning is not triggered on x86_64, even with W=1. It appears to
> be specific
> to the RISC-V toolchain's diagnostic analysis.

Given the other patches in there series, i have to wounder, is the
diagnostic analysis correct? Or is the RISC-V toolchain buggy?

> Regardless, converting to ethtool_sprintf() is the correct approach
> which does not throw any warning on the both platforms.

I do agree ethtool_sprintf() is better. But we want the commit message
to reflect why we are making this change. Is it because
ethtool_sprintf() is better, or are we working around toolchain bugs?

	Andrew
