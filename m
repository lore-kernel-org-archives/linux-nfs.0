Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.12])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B7B1A2C026F;
	Wed,  4 Feb 2026 15:51:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.12
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770220292; cv=none; b=mDc43vuLfrnw30uDc8bAvz5ULQUF/9YMZS231MCnEg+WXIsNGcaQTxSvBp4+Wu3mee0P9PB2M7BuKW8o/UO7o8mQY8eub66szbV+fus6S10jJ0/kugJ35vG4R2z2qp8rFXv0Jz9bbSySsG1lC9HSk/djbC3deDJFPaIvf85m9Vg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770220292; c=relaxed/simple;
	bh=uyBCUjP/mwjgx//FVeT4gz8yf648jspRHIOMRLzx6GQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Q0Di4BtY0stVHL0RFDjgjd8+BbKQO6dzL614W4yuUzv8JgEFVUDJLw0h4DWjWU76U01gHZ3dlH1g/gy3teHKNASdNDhj0srRvLZV7Pt/Z1Wk2tWtIs9gRYuZUN5VheOm/BFRZgBZEAKjvzSxhMweMP+6aZs7pWAsj6WQefgLsFE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=linux.intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=ALK/qwkl; arc=none smtp.client-ip=198.175.65.12
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="ALK/qwkl"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1770220292; x=1801756292;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=uyBCUjP/mwjgx//FVeT4gz8yf648jspRHIOMRLzx6GQ=;
  b=ALK/qwklIWkXON9r2dnOSmHhJ2oVknkmhHm/SdQzUr4hHbWN+TT8TMS2
   dDZ6zsSE3QhT2ec0nbpEcFcXPXIMIRv7b97ZsfT1sjDQUD8JDSTLt6+Lp
   MPZ7d31euFUL1MdTgFItOJtcogZX+G2p7hk5hu+6xVSXCt3ux7SyZOKpn
   3FXEdtQ61LYGk+2VhsdZ2qmirnxOkMzVPjaOc16dANV5YmUbCO/4ac2SS
   sgnsC0LT6XKoWiSPNKz4awKGhPa0NI6EBpi/63/xn1abswVGP2GE+MP3E
   Y0OioKg8s3ZtnpKSGfjeRanyGx07PvWKZsBG6t+DUib4cBaYTVZeu0KwC
   Q==;
X-CSE-ConnectionGUID: 5fjRa/6dTwC1eAQccT3JIg==
X-CSE-MsgGUID: ehnLUmwARFCMOvQJCnKOIw==
X-IronPort-AV: E=McAfee;i="6800,10657,11691"; a="82845518"
X-IronPort-AV: E=Sophos;i="6.21,272,1763452800"; 
   d="scan'208";a="82845518"
Received: from fmviesa005.fm.intel.com ([10.60.135.145])
  by orvoesa104.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 04 Feb 2026 07:51:32 -0800
X-CSE-ConnectionGUID: DdqKZCfuQg6+wVF0bCBX7w==
X-CSE-MsgGUID: PFTl2NZWTq+XwlXAndXRlg==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.21,272,1763452800"; 
   d="scan'208";a="214693284"
Received: from pgcooper-mobl3.ger.corp.intel.com (HELO localhost) ([10.245.245.188])
  by fmviesa005-auth.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 04 Feb 2026 07:51:26 -0800
Date: Wed, 4 Feb 2026 17:51:24 +0200
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>, Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, llvm@lists.linux.dev,
	Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Nathan Chancellor <nathan@kernel.org>,
	Nick Desaulniers <nick.desaulniers+lkml@gmail.com>,
	Bill Wendling <morbo@google.com>,
	Justin Stitt <justinstitt@google.com>
Subject: Re: [PATCH v2 0/3] sunrpc: Fix `make W=1` build issues
Message-ID: <aYNq_PdXPo-S-ItG@smile.fi.intel.com>
References: <20260204094500.2443455-1-andriy.shevchenko@linux.intel.com>
 <177021968762.97318.15008544066362314853.b4-ty@oracle.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <177021968762.97318.15008544066362314853.b4-ty@oracle.com>
Organization: Intel Finland Oy - BIC 0357606-4 - c/o Alberga Business Park, 6
 krs, Bertel Jungin Aukio 5, 02600 Espoo

On Wed, Feb 04, 2026 at 10:42:06AM -0500, Chuck Lever wrote:
> On Wed, 04 Feb 2026 10:41:20 +0100, Andy Shevchenko wrote:

[...]

> Applied to nfsd-testing, thanks!
> 
> Acks from the NFS client maintainers on 1/3 are welcome.

Thank you!

-- 
With Best Regards,
Andy Shevchenko


