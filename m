Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.8])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 405623FCC;
	Wed,  4 Feb 2026 01:09:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.8
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770167356; cv=none; b=LvYfVk0LbFNCYKmi0nDdCYDm86UnMrhG0Tc9eaFbWPp8FozxSdPoSPC/t8Tu/prMjmYKv/jpfqsnXM5ZwAJvIPb1Y7KMYZAY9kb6/qEFz7a8CM7M53ej9xZB0KfrySAga7CI28uZz2E8VTmq41YeDbVu9OOd/9OP5J6HXzpEdfg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770167356; c=relaxed/simple;
	bh=/9HVvPdr8HQCtfTWppNf6n84GxbfsGIRo3YUXCxq7pk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=A85hV0nw1vgMOFDcov+OKETiNmgyoe19+97zPX0UsW+FvBSIYnOCHuSkfkiRcehMlm0XdK8tHIoLMthKDF/GCTiCze34R9T18EBSryDMG5csISgUmZ2c+5wSPabK9BqynXncU5wfTiljZ7yClCWkMyVpeRnh+agM8fZUUAxxfBs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com; spf=pass smtp.mailfrom=linux.intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=gUSLRKO9; arc=none smtp.client-ip=192.198.163.8
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="gUSLRKO9"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1770167355; x=1801703355;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=/9HVvPdr8HQCtfTWppNf6n84GxbfsGIRo3YUXCxq7pk=;
  b=gUSLRKO96cgJSL1OTs1qVfRgg/gKjZYxEcjN2tfFmSZIxRjpVdGIh9Pg
   xcTFKIpKoz1AQW/W7rEjMWQrvaMIj9+kwUacLa2MXQgsAPKlLiTYuwS20
   4RVT06NLPIVO3CHt09+Id2Q70Q7RA0JxTEnZKvu7VMOktCKAa8Ss1brZ4
   Y7sQ4WLNfjd60KVyAR4DIt2yrpKvlM6duU7OSze/c7OoKH7EljSHHLoZm
   lDccmmGJsjMLtGDGyPOZlhioBjb8lK8y8u0tImx08UwlJ6N5BlYnMnp3u
   lXKEd7udEJCqsByi/61kqoqvPAxh9HwOzN9F8fKzegl3DCMIThfNNd5+b
   Q==;
X-CSE-ConnectionGUID: uQqcaNDASBqvAWLQBNdoEg==
X-CSE-MsgGUID: nN3juj82QZynlxdvcvEMRg==
X-IronPort-AV: E=McAfee;i="6800,10657,11691"; a="88926472"
X-IronPort-AV: E=Sophos;i="6.21,271,1763452800"; 
   d="scan'208";a="88926472"
Received: from fmviesa006.fm.intel.com ([10.60.135.146])
  by fmvoesa102.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Feb 2026 17:09:15 -0800
X-CSE-ConnectionGUID: oKdSBW3ETHqmD0iExfH6cQ==
X-CSE-MsgGUID: tI4URy7TRB65xA6sz/1xbg==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.21,271,1763452800"; 
   d="scan'208";a="209662651"
Received: from pgcooper-mobl3.ger.corp.intel.com (HELO localhost) ([10.245.245.99])
  by fmviesa006-auth.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Feb 2026 17:09:11 -0800
Date: Wed, 4 Feb 2026 03:09:09 +0200
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, llvm@lists.linux.dev
Cc: Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Nathan Chancellor <nathan@kernel.org>,
	Nick Desaulniers <nick.desaulniers+lkml@gmail.com>,
	Bill Wendling <morbo@google.com>,
	Justin Stitt <justinstitt@google.com>
Subject: Re: [PATCH v1 1/1] sunrpc: Fix compilation error (`make W=1`) when
 dprintk() is no-op
Message-ID: <aYKcNds-XsVLRjcC@smile.fi.intel.com>
References: <20260204010415.2149607-1-andriy.shevchenko@linux.intel.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260204010415.2149607-1-andriy.shevchenko@linux.intel.com>
Organization: Intel Finland Oy - BIC 0357606-4 - c/o Alberga Business Park, 6
 krs, Bertel Jungin Aukio 5, 02600 Espoo

On Wed, Feb 04, 2026 at 02:04:15AM +0100, Andy Shevchenko wrote:
> Clang compiler is not happy about set but unused variables:
> 
> .../flexfilelayout/flexfilelayoutdev.c:56:9: error: variable 'ret' set but not used [-Werror,-Wunused-but-set-variable]
> .../flexfilelayout/flexfilelayout.c:1505:6: error: variable 'err' set but not used [-Werror,-Wunused-but-set-variable]
> .../nfs4proc.c:9244:12: error: variable 'ptr' set but not used [-Werror,-Wunused-but-set-variable]
> 
> Fix these by forwarding parameters of dprintk() to no_printk().
> The positive side-effect is a format-string checker enabled even for the cases
> when dprintk() is no-op.

Note, the alternative fix is to add __maybe_unused all over the place.
With pros and cons I consider my approach better.

-- 
With Best Regards,
Andy Shevchenko


