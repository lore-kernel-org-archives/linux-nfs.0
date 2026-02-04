Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 364E0295DA6;
	Wed,  4 Feb 2026 09:41:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770198112; cv=none; b=OYLrIMzW6SkY3hi1RSQzAmrtJ4zwH0fJ0NXCYwKfvtGJaaRFkvKOr9cJsCOfmfUW3uF0xDO5Z9AeqORCPOmFyLDaSx4SQEBIe+oHvHV+9SqwiLTl4gnfcq9LNkJHUNszRP4uPSbvLQN/nPJjvsDGQhFmXLywZjZgx/q2LhnipgI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770198112; c=relaxed/simple;
	bh=G1sgpYrSgBlPHBRA1BVR65u2Da+Y0RYmuB1xl9FhI/c=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=BizfWmu6/r4egq/xG7cZjLyK/jUbLWEHYxWF6gOrIDc6Is+BDhYGzR7bbej0dNs6Z4iEf6JPAc/SIIB7cJbxr4/Tzkboc4PIdnKEHsUtfTtMNLP/7Rw1PJzqdKuUbMXunVrscyEaY+2IL03tPx3vfAjl7Gq9WCIZSKJczT79vUs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=linux.intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=nm0vpttK; arc=none smtp.client-ip=198.175.65.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="nm0vpttK"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1770198112; x=1801734112;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=G1sgpYrSgBlPHBRA1BVR65u2Da+Y0RYmuB1xl9FhI/c=;
  b=nm0vpttKi82iI8f5LAO39RMdSUl9ADMLAdm0hzGb4yGATeJ4fcq1dfse
   Xw8gBsf78Axk3iCQ+/+C8GJh1oOhSwton/AiqyvCGux/1phylfCHcyUB/
   OupTCppBudcy4iYTxn2geaXr6oYQx4bCZotaabZT3rAOCAMX+sj1yUn0L
   /xiGAXJwFU3XDdT2DXatccZptQD2yYrjtTqwxBFqy2hMuQNbP/CE+wzc4
   XM+BpeFdGm1e2LFHryA5dgntdCz63d4hLE1oQjKG/MW5DkEJAnlp91XFy
   RGuo7NFqtkfcirlaKtkn7aL+ise652kf7i7vDBZ4lMi+fta+atUNRwZoA
   w==;
X-CSE-ConnectionGUID: zWT0en0DRHiXRy3QNGkwEA==
X-CSE-MsgGUID: KaK6Sv8uT8euLUAg8jXDlg==
X-IronPort-AV: E=McAfee;i="6800,10657,11691"; a="71109788"
X-IronPort-AV: E=Sophos;i="6.21,272,1763452800"; 
   d="scan'208";a="71109788"
Received: from fmviesa005.fm.intel.com ([10.60.135.145])
  by orvoesa112.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 04 Feb 2026 01:41:52 -0800
X-CSE-ConnectionGUID: u8kb2s1oS3mGJVU5bUNYFA==
X-CSE-MsgGUID: qUeLMOUbTxeAePNsFoJNvQ==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.21,272,1763452800"; 
   d="scan'208";a="214596568"
Received: from pgcooper-mobl3.ger.corp.intel.com (HELO localhost) ([10.245.245.188])
  by fmviesa005-auth.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 04 Feb 2026 01:41:49 -0800
Date: Wed, 4 Feb 2026 11:41:47 +0200
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	llvm@lists.linux.dev
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Nathan Chancellor <nathan@kernel.org>,
	Nick Desaulniers <nick.desaulniers+lkml@gmail.com>,
	Bill Wendling <morbo@google.com>,
	Justin Stitt <justinstitt@google.com>
Subject: Re: [PATCH v1 1/1] nfs/blocklayout: Fix compilation error (`make
 W=1`) in bl_write_pagelist()
Message-ID: <aYMUW07J-u9lpVBf@smile.fi.intel.com>
References: <20260204010402.2149563-1-andriy.shevchenko@linux.intel.com>
 <aYKbteXxCp4ksGTI@smile.fi.intel.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aYKbteXxCp4ksGTI@smile.fi.intel.com>
Organization: Intel Finland Oy - BIC 0357606-4 - c/o Alberga Business Park, 6
 krs, Bertel Jungin Aukio 5, 02600 Espoo

On Wed, Feb 04, 2026 at 03:07:05AM +0200, Andy Shevchenko wrote:
> On Wed, Feb 04, 2026 at 02:04:02AM +0100, Andy Shevchenko wrote:
> > Clang compiler is not happy about set but unused variable
> > (when dprintk() is no-op):
> > 
> > .../blocklayout/blocklayout.c:384:9: error: variable 'count' set but not used [-Werror,-Wunused-but-set-variable]
> > 
> > Remove a leftover from the previous cleanup.
> 
> Note, if https://lore.kernel.org/r/20260204010415.2149607-1-andriy.shevchenko@linux.intel.com
> is applied first, it will shadow the error here, this patch is needed anyway.

Nevermind, I will send a v2 where it will be part of the series.

-- 
With Best Regards,
Andy Shevchenko


