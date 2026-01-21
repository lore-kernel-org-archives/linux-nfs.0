Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86062481238;
	Wed, 21 Jan 2026 10:12:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1768990361; cv=none; b=bRj2bCxsZ+CcpaoALoqNC7jgPg/PtuInFNIhyUkrShH8uRM9aXcY7pzKkdK4dE3sRE0PJN8ccRSPktcB4qj/kuTXu7uKFL1AsTMKZqT4tHKBKYfIN2d65m/Jv/HtLmV2vMju2+xw3uws9M4BvwzP1bxAnhJTjGpwE+I8buAsiBs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1768990361; c=relaxed/simple;
	bh=DJWlDvhlyav+iIwRKqw40ldF+YMmp4lcVZqyheS1InQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=OU+CfxCNtiq7yKxED0qKi84GZHLHroDJqodpoOemi8SFR9w7hFJ5sil/6kbcbTqiywnCvvhFhTca3vr36s7B1PIv06r/fVoYi/kHHfLaMImn1VsXpK7rXcKOsbOzkj6BZeEmsO+6kaZuqJpcUPMT80BZfC6Ipvxl6ZZdsn9zgnU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id A69E1227AAA; Wed, 21 Jan 2026 11:12:34 +0100 (CET)
Date: Wed, 21 Jan 2026 11:12:34 +0100
From: Christoph Hellwig <hch@lst.de>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Christian Brauner <brauner@kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>, Christoph Hellwig <hch@lst.de>,
	Neil Brown <neilb@suse.de>, Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: do not allow exporting of special kernel
 filesystems
Message-ID: <20260121101234.GA22918@lst.de>
References: <20260121085028.558164-1-amir73il@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260121085028.558164-1-amir73il@gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Wed, Jan 21, 2026 at 09:50:27AM +0100, Amir Goldstein wrote:
> pidfs and nsfs recently gained support for encode/decode of file handles
> via name_to_handle_at(2)/opan_by_handle_at(2).
> 
> These special kernel filesystems have custom ->open() and ->permission()
> export methods, which nfsd does not respect and it was never meant to be
> used for exporting those filesystems by nfsd.
> 
> Therefore, do not allow nfsd to export filesystems with custom ->open()
> or ->permission() methods.

Yeah, this was added in and not used in the existing export_ops users.

> +	/*
> +	 * The requirements for a filesystem to be exportable:
> +	 * 1. The filehandle must identify a filesystem by number
> +	 * 2. The filehandle must uniquely identify an inode
> +	 * 3. The filesystem must not have custom filehandle open/perm methods
> +	 * 4. The requested file must not reside on an idmapped mount
>  	 */

Please spell out here why ->open and ->permission are not allowed.
Listing what the code does is generally not that useful, while why
it does that provides value.

While looking this I have to say the API documentation for these
methods in exportfs.h is unfortunately completely useless as well.
It doesn't mention the limitation that it's only used by the
non-exportfs code, and also doesn't mention why a file system
would implement or have to implement them :(  The commit messages
adding them are just as bad as well.
