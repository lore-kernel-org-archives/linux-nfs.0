Received: from mgamail.intel.com (mgamail.intel.com [192.198.163.14])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9FDBC23D7F0
	for <linux-nfs@vger.kernel.org>; Wed,  3 Jun 2026 08:19:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.198.163.14
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780474769; cv=none; b=mRAlFSjXIsaQBOGtrAiItO4z3bsSwwk9RXS/kJT07GeCRkDCipJWXYhH/7J2VDp0ztkli1e77QwTpydMOYhmJ1yEXFkPRLmlcfMd6awUN0eVi2lGEDLdukmkmVxqdUva6kVJIpz2Nqtf+EMVHwaxsjzqjWzqBZfF8EhkX6faE5A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780474769; c=relaxed/simple;
	bh=eR1KK9z9Afjg8V/D/SIP3xh+zLxBKi2Mag78w0KCiV4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=WbvXnDSwEnYLeeNHpTeluM4lIcfVzsiloaOLDrys4SGY+63YYTot6RW4wDNFLR+MF8E0im9eU9mQISz5u8xFe75+/y5mSGvYTnxRbvy6BZfDIrn3BfzQQcxBmcWh5XamByxpRzbT8V0bKnZK9Jxfyr8IaHMWza1yUhv9nmJ6XK0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=mcGXbX8m; arc=none smtp.client-ip=192.198.163.14
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="mcGXbX8m"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1780474767; x=1812010767;
  h=date:from:to:cc:subject:message-id:references:
   mime-version:in-reply-to;
  bh=eR1KK9z9Afjg8V/D/SIP3xh+zLxBKi2Mag78w0KCiV4=;
  b=mcGXbX8m2ukPQLllzlTTlyrITOmAMHaMivRIgq88vobtuFnb7zYRidtE
   9VLJl5LCMLJiVw4J5nkox1hY5xEH4eKEahdvHWO6u4T9A8r35Ftk7b1oh
   pmSql10dHr2i/mI4RDNz/zxtqxZbQ3svm8mIsZoXTuqhlElGogVurg9BK
   Q6BmUJZMSjQbErK0uKjFdypzqHVQCQxdYNjA/beczbZLISWohwt+F4qEJ
   zWxtaPXbg0euIAxjYdPAJ4xM0NUEIuMfl7PnKn/kZ8TsuRrYM1c/4W7xf
   ex5HCH/9fvnLh156pfrEK+28IfKqvvd15R92o8HOrNVMuoaTUq1XNH/Gq
   A==;
X-CSE-ConnectionGUID: 7qaVIjiYRo2AXjJre0Qhhw==
X-CSE-MsgGUID: 1mQrDzXUSSqzXHk6XnHxeQ==
X-IronPort-AV: E=McAfee;i="6800,10657,11805"; a="81305385"
X-IronPort-AV: E=Sophos;i="6.24,184,1774335600"; 
   d="scan'208";a="81305385"
Received: from orviesa006.jf.intel.com ([10.64.159.146])
  by fmvoesa108.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Jun 2026 01:19:26 -0700
X-CSE-ConnectionGUID: 9e1mPLtLTTq2e0nWMbYv6A==
X-CSE-MsgGUID: EPSYGF7EQTW9tybiJMCFrw==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.24,184,1774335600"; 
   d="scan'208";a="243104952"
Received: from black.igk.intel.com ([10.91.253.5])
  by orviesa006.jf.intel.com with ESMTP; 03 Jun 2026 01:19:24 -0700
Received: by black.igk.intel.com (Postfix, from userid 1003)
	id C1C5395; Wed, 03 Jun 2026 10:19:23 +0200 (CEST)
Date: Wed, 3 Jun 2026 10:19:23 +0200
From: Andy Shevchenko <andriy.shevchenko@intel.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Subject: Re: [PATCH v2 1/2] nfsd: Replace open-coded conversion of bytes to
 hex
Message-ID: <ah_jizDKdRuVrniB@black.igk.intel.com>
References: <20250804224701.2278773-1-ebiggers@kernel.org>
 <20250804224701.2278773-2-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20250804224701.2278773-2-ebiggers@kernel.org>
Organization: Intel Finland Oy - BIC 0357606-4 - Westendinkatu 7, 02160 Espoo

On Mon, Aug 04, 2025 at 10:46:59PM +0000, Eric Biggers wrote:
> Since the Linux kernel's sprintf() has conversion to hex built-in via
> "%*phN", delete md5_to_hex() and just use that.  Also add an explicit
> array bound to the dname parameter of nfs4_make_rec_clidname() to make
> its size clear.  No functional change.

...

> +	sprintf(dname, "%*phN", 16, cksum.data);

FWIW, since the length is static no need to use stack for that:

	sprintf(dname, "%16phN", cksum.data);

will be better.

-- 
With Best Regards,
Andy Shevchenko


