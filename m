Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.7])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 72F8A3A5E92;
	Thu, 19 Mar 2026 14:41:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.7
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773931294; cv=none; b=nQ91ihQLua84+7OZF9j5jvyyTH1KFcHJL31o8EQhvPhr3DCE9LrG+8vTsOlQWqyI3okrq/77t2Dfr5N5C+kz8/VC8Odwn1GL5bI3OTHlZIcVr35Ej0kedsADJ7/+PNTZLFKqLFLKpjHrW4t1A7vBz2kBplB3oQg9e8rPQsGKAwM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773931294; c=relaxed/simple;
	bh=PmOkxoRXCD8OlRMEJ8MSm5qTImPX/q3XBzALcAio7yY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=qQrofhkc4zTp5kFmecdwUlRtMe99JEzCZogiYwHaexTlLPZZ05NNEuLWA33hu1ks3smyT50Lsgvd99R7gsGuOwFjxgXo5NcHvlQK8ig5LJRJciEIyePQDLrPKXeM2yrBJjIiX8IaC3MHyj9yACLcluqVjjypWtNWhUETeRczTq8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=I1ajkPNZ; arc=none smtp.client-ip=192.198.163.7
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="I1ajkPNZ"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1773931292; x=1805467292;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=PmOkxoRXCD8OlRMEJ8MSm5qTImPX/q3XBzALcAio7yY=;
  b=I1ajkPNZV8A7azBkfGE/IsdHw9g2KbWnnHL4iVAbXVeDA4lGjEuMZFEa
   Bo9NCam8h5oNJeurCScPWkKEYWJ+0cKNMpRyMOHSdLtAip0qvQTQpRGtX
   MseVycXp26m2Yrovjt1v0ZRiiAhDO5E0duwCKe2wvo9oWpe3Mwvp5weX3
   SdeZXF7ubeVbsEJgRfaJ0HGKPpodYCeGCpfZ5sO8fgIxtDS8SMoJ4Fnhc
   iu6Cm0VkOkWUcqVYaGs4aE1ydh124ecNkxHq5hD0aBAIGkcAiojjqFW4i
   fSL9donY0sBAE/Wb5mR7BIU3RXt/Pn2B62Xdjlk6SZQOdQwVpO0LgdmVd
   A==;
X-CSE-ConnectionGUID: v4urBkQrTm+K3OOX+epvyQ==
X-CSE-MsgGUID: kDO5wYKsR1KA9iAZJEOhvQ==
X-IronPort-AV: E=McAfee;i="6800,10657,11734"; a="100464651"
X-IronPort-AV: E=Sophos;i="6.23,129,1770624000"; 
   d="scan'208";a="100464651"
Received: from orviesa006.jf.intel.com ([10.64.159.146])
  by fmvoesa101.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 19 Mar 2026 07:41:31 -0700
X-CSE-ConnectionGUID: hKKQslcBTvy3f3098oNEtQ==
X-CSE-MsgGUID: UIuO1HIeTV2nuTbKtOLE6w==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.23,129,1770624000"; 
   d="scan'208";a="222083988"
Received: from klitkey1-mobl1.ger.corp.intel.com (HELO localhost) ([10.245.244.120])
  by orviesa006-auth.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 19 Mar 2026 07:41:29 -0700
Date: Thu, 19 Mar 2026 16:41:26 +0200
From: Andy Shevchenko <andriy.shevchenko@intel.com>
To: Sean Chang <seanwascoding@gmail.com>
Cc: Andrew Lunn <andrew@lunn.ch>, Chuck Lever <chuck.lever@oracle.com>,
	David Laight <david.laight.linux@gmail.com>,
	Anna Schumaker <anna@kernel.org>, netdev@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel test robot <lkp@intel.com>
Subject: Re: [PATCH v3 3/3] nfs: refactor nfs_errorf macros and remove unused
 ones
Message-ID: <abwLFk0L_kCZqIiK@ashevche-desk.local>
References: <20260319141846.78222-1-seanwascoding@gmail.com>
 <20260319141846.78222-4-seanwascoding@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260319141846.78222-4-seanwascoding@gmail.com>
Organization: Intel Finland Oy - BIC 0357606-4 - c/o Alberga Business Park, 6
 krs, Bertel Jungin Aukio 5, 02600 Espoo

On Thu, Mar 19, 2026 at 10:18:46PM +0800, Sean Chang wrote:
> refactor nfs_errorf() and nfs_ferrorf() to the standard do-while(0)
> pattern for safer macro expansion and kernel style compliance.
> 
> additionally, remove nfs_warnf() and nfs_fwarnf() as git grep
> confirms they have no callers in the current tree.

...

>  #define nfs_invalf(fc, fmt, ...) ((fc)->log.log ?		\
>  	invalf(fc, fmt, ## __VA_ARGS__) :			\

>  	invalf(fc, fmt, ## __VA_ARGS__) :			\
>  	({ dfprintk(fac, fmt "\n", ## __VA_ARGS__);  -EINVAL; }))

Why not all of them?

-- 
With Best Regards,
Andy Shevchenko


