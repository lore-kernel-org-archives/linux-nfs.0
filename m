Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B78C630FC30;
	Fri,  6 Mar 2026 10:40:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772793613; cv=none; b=EF/f9R9jph2sek+u1KJRZh2o/b3v+/lXL48XoGeZfxRPNdjuQVEeMqh4gz/Yz1Lqla7fcBsN9TUeX7h30RjkaqRTRqInPxTciIEP8I3ccqs9Z7XSJQl1Qt0yHdY3Es93MdwKZQM/MYlvyGLJAo56v/5yNzlkKOEGVDYLsXgqc+U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772793613; c=relaxed/simple;
	bh=fLV+HWHyQ9rsS3Mae74R0FMH25Gpfx00+e4ZcI0fxCo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=R3xkHMvHB6bl33tDlCXo8smPrBNUDeJFuX6t3uNDT9o8grU9hBzn2P1aHa5HVw2Jd9KTlcPhK825uAw33GRwYd4Xj11Z4hGOhKFg65Fe1iyPpHzpWKxNXg3VXeb6JDlxQDWu2gejlEpRHg2tXUd54G457C+nzxQjyLnVVAxyITk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=rT0qPMf1; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="rT0qPMf1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F3ACBC4CEF7;
	Fri,  6 Mar 2026 10:40:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772793613;
	bh=fLV+HWHyQ9rsS3Mae74R0FMH25Gpfx00+e4ZcI0fxCo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=rT0qPMf1wpW8qjbSs8HQZS+lFQl6dKhRHiJrNgkxOcqU+4xy/Tm1ld4h3mfptVMjU
	 h1FVlTF5I8cQT0jJXRdrkZe61SsDv4eu9fKqIgKbKM9crbSwDtQumd0tMZ7e9v76V1
	 qrARmJzDlUCPSQD8RAMfafiAg3bYY0v86PFpuXsBikrRxksS9XCJIqQajXz6RD0P4z
	 h/V8kgf7dmsCkPsjyF2kuNjOH2pLIm2VPyPMuacI3VdLJOqY9+6Lfh8S8Yq0sf1l1h
	 SSt9L1dvU9VzNOfO6uBv4bhcUuNa6jwj4edKWk53rwkwpfPNuaO48cN9ZR61Pof71L
	 x3+Y5MMKG93CA==
Date: Fri, 6 Mar 2026 11:40:05 +0100
From: Christian Brauner <brauner@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, 
	David Howells <dhowells@redhat.com>, Jan Kara <jack@suse.cz>, Chuck Lever <chuck.lever@oracle.com>, 
	Jeff Layton <jlayton@kernel.org>, Miklos Szeredi <miklos@szeredi.hu>, 
	Amir Goldstein <amir73il@gmail.com>, John Johansen <john.johansen@canonical.com>, 
	Paul Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Stephen Smalley <stephen.smalley.work@gmail.com>, 
	"Darrick J. Wong" <djwong@kernel.org>, linux-kernel@vger.kernel.org, netfs@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-unionfs@vger.kernel.org, 
	apparmor@lists.ubuntu.com, linux-security-module@vger.kernel.org, selinux@vger.kernel.org
Subject: Re: [PATCH v3 00/15] Further centralising of directory locking for
 name ops.
Message-ID: <20260306-wildfremd-wildfremd-43848a9e91cd@brauner>
References: <20260224222542.3458677-1-neilb@ownmail.net>
 <177267387855.7472.13497219877141601891@noble.neil.brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <177267387855.7472.13497219877141601891@noble.neil.brown.name>

On Thu, Mar 05, 2026 at 12:24:38PM +1100, NeilBrown wrote:
> 
> Hi Christian,
>  do you have thoughts about this series?  Any idea when you might have
>  time to review and (hopefully) apply them?

Sorry, for the delay I picked it up but have two minor comments.
