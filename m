Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.15])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5CA4A360732;
	Fri,  6 Feb 2026 10:34:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.15
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770374062; cv=none; b=iWNGhMSYZkSsC09em67f+NwDxc+Q54E/BQXTBiyDRCrdZ+PBwffqXOQQNDijU7kwD57AJqPL3yDBz9MPRlE9w4eLNM3OTPIRrFI5PZRlXICQ8tUrmt8Z+lDsvnWoWj3+zH1NgZfy3w/3QKr2IlGxzsh+KMLT5nuna0lME9JOkpM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770374062; c=relaxed/simple;
	bh=pYahGYQ1UW6tbFtVQv/Wppkl22KOOt0QfChqJtgA1BU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=AGUBjgLbrCbZGlq4d4xuYNIcmKkMRA/DsZO8T9Mq/Ob4NuD8KdnMbH5dtAD65vWnw1sowEXWTQcOLAzAaBLMLCN+f3r2M0Jgs9P62LYE0Vu27FsyZGc8D71VOuHAIr/HedKspG8Yka+A4iIorjJ/k3FDzpa+DC6fnv1Ul3Jq/Ss=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=linux.intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=WAxyxgd+; arc=none smtp.client-ip=198.175.65.15
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="WAxyxgd+"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1770374063; x=1801910063;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=pYahGYQ1UW6tbFtVQv/Wppkl22KOOt0QfChqJtgA1BU=;
  b=WAxyxgd+JLDdbSX4SgH4gDzsSn+cYFrYinB7iR0UioXEppHudeAw+72L
   E16ow7LrXSLgdXdM7owMYQR6N8tl88qFvbuZ27OHkNZNLvEc5fHi+Lj11
   eFBBqyIoiJtY6V85ssn1epwlIdwqreepnNtVsTeI4svzwiQikxlzIMuyz
   lTd8pIfHSa8nMh6eBS54J37JWtNCoiDzZh7e7wkBwU9YiEk+342pT7bs2
   kXn+jd6LEfKAJiYFtpvPxRG2ZS4KOvjkM118EnwDbPkQ8kl/6MANix/Ee
   eUHyppMTPkTpYlOXPnEmX/tMf7oRz1XynHi3LBoHDrAiOwMQOpfX72e+6
   g==;
X-CSE-ConnectionGUID: +nkf+KYRQnyT0roTO8WAzA==
X-CSE-MsgGUID: wHqBrRCiQJSZhd2sHeIhNg==
X-IronPort-AV: E=McAfee;i="6800,10657,11692"; a="75199279"
X-IronPort-AV: E=Sophos;i="6.21,276,1763452800"; 
   d="scan'208";a="75199279"
Received: from fmviesa002.fm.intel.com ([10.60.135.142])
  by orvoesa107.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 06 Feb 2026 02:34:22 -0800
X-CSE-ConnectionGUID: OkQ02fUiRNuIqWq3reALhg==
X-CSE-MsgGUID: o6kkH2+TT5KzQjY57oOsPg==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.21,276,1763452800"; 
   d="scan'208";a="233779723"
Received: from ijarvine-mobl1.ger.corp.intel.com (HELO localhost) ([10.245.244.202])
  by fmviesa002-auth.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 06 Feb 2026 02:34:16 -0800
Date: Fri, 6 Feb 2026 12:34:14 +0200
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
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
Subject: Re: [PATCH v3 0/3] sunrpc: Fix `make W=1` build issues
Message-ID: <aYXDpqqM0qrEVzvy@smile.fi.intel.com>
References: <20260204202437.2762161-1-andriy.shevchenko@linux.intel.com>
 <177024270291.126397.9981743455921781902.b4-ty@oracle.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <177024270291.126397.9981743455921781902.b4-ty@oracle.com>
Organization: Intel Finland Oy - BIC 0357606-4 - c/o Alberga Business Park, 6
 krs, Bertel Jungin Aukio 5, 02600 Espoo

On Wed, Feb 04, 2026 at 05:05:35PM -0500, Chuck Lever wrote:

> On Wed, 04 Feb 2026 21:21:48 +0100, Andy Shevchenko wrote:

[...]

> Applied to nfsd-testing, thanks!

Thanks!

FWIW, I have got a success report from LKP.

-- 
With Best Regards,
Andy Shevchenko


