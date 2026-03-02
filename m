Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.10])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 43D44309F09;
	Mon,  2 Mar 2026 16:51:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.175.65.10
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772470292; cv=none; b=Nf56icYRnVEsU3g3IhLfAhQX8L3oPqLX3NPu8lNOdnq0z/TbjEmB7z8Umw7Sc54RUW8zFBBIqJiqgU8ztHVH3UuGF7/1VfhAtoKSipZx+3xarwX/5OwA3KDKobPuziQga8ieGizWwKr1rQx9xOGEeM1gRUAx8AiLfVMCSNoDm9k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772470292; c=relaxed/simple;
	bh=G7s5Ca3WvbG9IlRb+qozWNbbm1yC6JvqcItIR66+piA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=qlto9inkQD7SvNR40xB5GZkwXhXmllMJ0Xh4ETfIkoa8TzbupVi2BUmYrbnhVJ6b9Pv/bHRGIdtrMGhdknkmf08NLeDSwJwEARqmnMHzslGC/N0VP7LN6UqfwfzL4bnLLQfcHveSBPzrajm9BYzSsMp1ZAlsrSh9756UZK9TCj4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=Qo+ono/8; arc=none smtp.client-ip=198.175.65.10
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="Qo+ono/8"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1772470291; x=1804006291;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=G7s5Ca3WvbG9IlRb+qozWNbbm1yC6JvqcItIR66+piA=;
  b=Qo+ono/8ULuduDGNRBLD37oiFb/vee1M/HqxlqQGSOvZsq/WVEuozLdH
   P/9CxHSiXpLPdWV/9Hy+3dXxeo3TJZkJJehtpEaTpDrSIxjoQtgXC5H/X
   43HlYnHXJuoO59qGgoan7arY54R3SvVL6VXyG46zYqAKkg4M1RsC1HBoW
   D+w2m0sT/V2bWj59T7mZWyx9vkTkfaPk/KOCZXLpJ0LSG8qF6+0hWX+6G
   G7kHeaMnII3yLg/+c7adxXscLPMSuSSfu/uGw9Ekwp7450EWVCcLKw3US
   rSoo/ScmEK66WBXimKetfQlt6gJSxZpHgrbsl8jFylzvmvAfyCn53+3Xd
   A==;
X-CSE-ConnectionGUID: AyT1rmKTTeKfHhrYbcBz0Q==
X-CSE-MsgGUID: OYTyEbzRTomqxYPhpgtmgw==
X-IronPort-AV: E=McAfee;i="6800,10657,11717"; a="90876708"
X-IronPort-AV: E=Sophos;i="6.21,320,1763452800"; 
   d="scan'208";a="90876708"
Received: from fmviesa009.fm.intel.com ([10.60.135.149])
  by orvoesa102.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 02 Mar 2026 08:51:29 -0800
X-CSE-ConnectionGUID: M4VzmEXHSI2/9+WRpZtgkg==
X-CSE-MsgGUID: PquzHs0xQfm031qLBqSD0w==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.21,320,1763452800"; 
   d="scan'208";a="214149930"
Received: from dalessan-mobl3.ger.corp.intel.com (HELO localhost) ([10.245.244.52])
  by fmviesa009-auth.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 02 Mar 2026 08:51:26 -0800
Date: Mon, 2 Mar 2026 18:51:24 +0200
From: Andy Shevchenko <andriy.shevchenko@intel.com>
To: Sean Chang <seanwascoding@gmail.com>
Cc: Andrew Lunn <andrew@lunn.ch>, Chuck Lever <chuck.lever@oracle.com>,
	David Laight <david.laight.linux@gmail.com>,
	Anna Schumaker <anna@kernel.org>, netdev@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sunrpc: simplify dprintk macros and cleanup redundant
 debug guards
Message-ID: <aaXADI1NWecG190C@ashevche-desk.local>
References: <20260302161818.63651-1-seanwascoding@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260302161818.63651-1-seanwascoding@gmail.com>
Organization: Intel Finland Oy - BIC 0357606-4 - c/o Alberga Business Park, 6
 krs, Bertel Jungin Aukio 5, 02600 Espoo

On Tue, Mar 03, 2026 at 12:18:18AM +0800, Sean Chang wrote:

In the Subject: dprintk --> dprintk()

> Following David Laight's suggestion, simplify the macro definitions by
> removing the unnecessary 'fmt' argument and using no_printk(__VA_ARGS__)
> directly.

> This ensures the compiler performs type checking

This is already the case with the current code.

> and "sees" the variables, silencing the warnings without emitting any code.

Also, isn't it the current state of affairs?

> Verification with .lst files under -O2 confirms that the compiler
> successfully performs "dead code elimination". Even when variables
> (like char buf[] in nfsfh.c) or static helper functions (like
> nlmdbg_cookie2a in svclock.c) are declared without #ifdef, they are
> completely optimized out (no stack allocation, no symbol references in
> the final executable) as they are only referenced within no_printk().
> 
> This allows for significant cleanup:
> - Remove redundant #if IS_ENABLED(CONFIG_SUNRPC_DEBUG) from
>   fs/nfsd/nfsfh.c and net/sunrpc/xprtrdma/svc_rdma_transport.c
> - Remove the #if IS_ENABLED(CONFIG_SUNRPC_DEBUG) guard around
>   nlmdbg_cookie2a and stub function in fs/lockd/svclock.c

nlmdbg_cookie2a()

> - Consolidate the dprintk definition to be more idiomatic.

dprintk()


Isn't this list redundant in the commit message? We can see this from the code
without much brain used.

...

>  	struct ib_qp_init_attr qp_attr;
>  	struct ib_device *dev;
>  	int ret = 0;
> +	struct sockaddr *sap;

Keep it in reversed xmas tree order.

...

Ideally it would be nice to have this patch squashed to the mine, but I think
since it's part of nfsd-next, the rebasing is not an option. Since I am not
the maintainer, just my 2c.

-- 
With Best Regards,
Andy Shevchenko


