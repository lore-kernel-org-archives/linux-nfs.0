Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.16])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B92B337BAC;
	Mon,  2 Mar 2026 13:21:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.16
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772457687; cv=none; b=sfjI557NFIt+2l56E5mJWK4+06Az+em1E7f1g+kVKJ/2J8ZzyL2i7a7X+MocH4VUDmfqSctbwS8UKrH0IMNW7YvTWb+TaiB+IyE/JAROPp0HtQ7YnWfXWUc0zrM+oXnNwaH767UnHcOfXMJm6L/ZmCUK5ZjvqOlCEzkGYu3ATwA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772457687; c=relaxed/simple;
	bh=16mnAXn4hs18SJXfAMjkEgy7Te9I5qcSgAy5WJ2dHLI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=fonorUztu2LAi8AtDY1HeYLmPQbEYi1AGKwhOIDfcKHl4eNhtSZrGWFixc7OQ7dd2kQd1v1DJl5J7b8JBI9JXYIK5TlJTzhVPatYCnYq+wFAaF7WQXpKIHA2HB22o+Ne5fqO01tDt9+4ZLZSciBRDf9JMgBVh+DTvkMxwcq3Oro=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=linux.intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=jn+4ObSR; arc=none smtp.client-ip=198.175.65.16
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="jn+4ObSR"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1772457687; x=1803993687;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=16mnAXn4hs18SJXfAMjkEgy7Te9I5qcSgAy5WJ2dHLI=;
  b=jn+4ObSRRFOyvDI+/JyMBex2lmMswIi3+fCu/3VBwyBIFNIH3Iw01Svx
   noGyjC1qEXtlpkAani6Ra+Jy/MW+H6vtUX3AYRV9f47wyjfi08GmGsJHP
   jSZqzYuNhyFkXVGGJOkqVjyLuTcjuibfFyW1Bv6Z91V+n3p7UC5gr9ipp
   UfqulxkwMq0kyOxZ90yVLbRZsg7znfQos6A1hsPAN/3Oomb0FiwLttvrq
   McSCpG5UUXXb+vQtL0naV3rs4N2J7UGgbe9XjKCxA/T6p8+lBOR1+3nbP
   znIt9Nxj2vVeM9emBPoUR/S8GsmUJqvxxZkvOy+I3RU/ObBiv12IR4JXy
   A==;
X-CSE-ConnectionGUID: poVs3BQLTNm8wq8buZ9iew==
X-CSE-MsgGUID: Owc3tq6ZR9O5uAlY3aqlkg==
X-IronPort-AV: E=McAfee;i="6800,10657,11717"; a="73649549"
X-IronPort-AV: E=Sophos;i="6.21,320,1763452800"; 
   d="scan'208";a="73649549"
Received: from orviesa003.jf.intel.com ([10.64.159.143])
  by orvoesa108.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 02 Mar 2026 05:21:27 -0800
X-CSE-ConnectionGUID: T8XbxPOET1+PmZXXkV4ewA==
X-CSE-MsgGUID: fZIU5bLaRZCdPoJPklsOIQ==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.21,320,1763452800"; 
   d="scan'208";a="221805062"
Received: from dalessan-mobl3.ger.corp.intel.com (HELO localhost) ([10.245.244.52])
  by ORVIESA003-auth.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 02 Mar 2026 05:21:23 -0800
Date: Mon, 2 Mar 2026 15:21:20 +0200
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Sean Chang <seanwascoding@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
	Chuck Lever <chuck.lever@oracle.com>,
	David Laight <david.laight.linux@gmail.com>,
	nicolas.ferre@microchip.com, claudiu.beznea@tuxon.dev,
	trond.myklebust@hammerspace.com, anna@kernel.org,
	netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v5 1/2] sunrpc: simplify dfprintk macros and fix nfsd
 build error
Message-ID: <aaWO0N621E5iqFXy@ashevche-desk.local>
References: <20260228180821.811683-1-seanwascoding@gmail.com>
 <20260228180821.811683-2-seanwascoding@gmail.com>
 <CAMuHMdUvynCH_eqNWr6EWusCWc7z6s-0b6gwQ1B_=mDkkxMd4w@mail.gmail.com>
 <CAAb=EJVvkyGHE7RfPaQOLLYuFdXGJMUaAzyVrREcKYSBQ3iKMg@mail.gmail.com>
 <CAMuHMdVVG=QR2iV=fUmdCvyguyYqQ98qXo3sKdL2gHzmLABMDA@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdVVG=QR2iV=fUmdCvyguyYqQ98qXo3sKdL2gHzmLABMDA@mail.gmail.com>
Organization: Intel Finland Oy - BIC 0357606-4 - c/o Alberga Business Park, 6
 krs, Bertel Jungin Aukio 5, 02600 Espoo

On Mon, Mar 02, 2026 at 02:15:16PM +0100, Geert Uytterhoeven wrote:
> CC Andy

Thanks!

Recently Chuck updated his nfsd-next, so please rebase and resend, Cc'ing me.

-- 
With Best Regards,
Andy Shevchenko


