Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.9])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E89FA13A258;
	Wed,  4 Feb 2026 01:07:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.9
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770167227; cv=none; b=TW5PNZSXTyAXP459TwGs+qbrBVmVI19Utq+o0ENjt8DoV61hVLqhBymc9h456i94KLgCl9qzy0gPayxjNauYNEwjqnoUOBvfPVQGO5pyLQulxiukBmwpZX3XR8uorvZ9ttO63qLkn31DoArUQfXbu9EMAM6f4iJ9XHePa42svgc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770167227; c=relaxed/simple;
	bh=IrNaO4zpFSQ4AJbeej2ZokgTwc3zc0ZN8+vkfsy52Is=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Z4NcAUG2q5PU+vkSuIHD1NCZ2WlZsSviZ17o95drTbPcirK45huSZ0Ow5iLrWqwbzl8oPJXO7N9+Q4NmFYhtNeFPoJuhOW0dUSiK0xpV8dk3kxYrmb4+9k5evovKbS4u3H3GQFdpv4nhfZ47mWsPCrQDswpfcTu3ygIVEttmz1A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=linux.intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=GTqGpsVQ; arc=none smtp.client-ip=192.198.163.9
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="GTqGpsVQ"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1770167226; x=1801703226;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=IrNaO4zpFSQ4AJbeej2ZokgTwc3zc0ZN8+vkfsy52Is=;
  b=GTqGpsVQYdUsHxIS/f/DAQjoYvcJ6tuI03Upm1U2kI8rdOu53P2N3VHH
   FQxbWlCci1IqSl4LnFxWPGrpifkn8VscPD+W9HlxkT+FgUrZrWcZwr6w6
   9eA+YzLdjxCdvq7CQd96OCe1kbols8QIo4U6VaaWELCeA+Xgsf+g+JGBP
   B03akIZUgKBgIdt5AaAVmaDRrC5dA7p9QthTscHDCqPylCYRXREKXwb0B
   UKiTR7hCBqmTGKVO2aL+5nHMzyWJqLvooxqZaCg3RCUPuPF/OotpXaFZm
   9jlNiCxFwh+axqRLj/LLXNy/3DAoYDPxfOB7I3p7zmhbLJoom42LzT3Gd
   A==;
X-CSE-ConnectionGUID: 2NwHQYvQT0WOkMO0yzVDjg==
X-CSE-MsgGUID: p7rbZXdYRUqOVdQahWov4Q==
X-IronPort-AV: E=McAfee;i="6800,10657,11691"; a="82089631"
X-IronPort-AV: E=Sophos;i="6.21,271,1763452800"; 
   d="scan'208";a="82089631"
Received: from fmviesa010.fm.intel.com ([10.60.135.150])
  by fmvoesa103.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Feb 2026 17:07:06 -0800
X-CSE-ConnectionGUID: ULa8Ex5rR6Cow6G0nipYww==
X-CSE-MsgGUID: TFhnJb7yS8aRs4yTw3qUSA==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.21,271,1763452800"; 
   d="scan'208";a="210110850"
Received: from pgcooper-mobl3.ger.corp.intel.com (HELO localhost) ([10.245.245.99])
  by fmviesa010-auth.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Feb 2026 17:07:03 -0800
Date: Wed, 4 Feb 2026 03:07:01 +0200
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
Message-ID: <aYKbteXxCp4ksGTI@smile.fi.intel.com>
References: <20260204010402.2149563-1-andriy.shevchenko@linux.intel.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260204010402.2149563-1-andriy.shevchenko@linux.intel.com>
Organization: Intel Finland Oy - BIC 0357606-4 - c/o Alberga Business Park, 6
 krs, Bertel Jungin Aukio 5, 02600 Espoo

On Wed, Feb 04, 2026 at 02:04:02AM +0100, Andy Shevchenko wrote:
> Clang compiler is not happy about set but unused variable
> (when dprintk() is no-op):
> 
> .../blocklayout/blocklayout.c:384:9: error: variable 'count' set but not used [-Werror,-Wunused-but-set-variable]
> 
> Remove a leftover from the previous cleanup.

Note, if https://lore.kernel.org/r/20260204010415.2149607-1-andriy.shevchenko@linux.intel.com
is applied first, it will shadow the error here, this patch is needed anyway.

-- 
With Best Regards,
Andy Shevchenko


