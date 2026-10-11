Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E74122BD022;
	Sun, 11 Oct 2026 07:19:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791703197; cv=none; b=STJri/DhpzW26bWGoRyHsdvjRoxUeEBHbW5/la3NqUb5Ewh6E56aTy4J24PTy3dBp3izqWXgMAT0bOj2OGVUGlpaFaIxB860QJQf6S4I0wWXbq2NE2r1OSpsH/CR+L6IWUhrCZ6DuBnyqsAcqPUMfVadlwjn0a34V8wpS1DizXA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791703197; c=relaxed/simple;
	bh=OB5z/SLnlJLkG3NA8CFS2bikRgEPoV+AfnWbf/1/F/Q=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=tY44P5bx4nGlwurGY0gxjwi4BreiCmAz8mRXRaYWPG9F7SySBNc3rubByM44ztbWfsd3gJJuP3yS1V9T4GMAIPGx6K2MqdqrQOt/ggGChD04O0AvXFG55+lhgBIr/dQFQs7vmBECIF90AuAovr961ibGCeS2reBH8gKf6u5OoXc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b=k/P3ONC2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b="k/P3ONC2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C34EE1F0089B;
	Sun, 11 Oct 2026 07:19:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linuxfoundation.org;
	s=korg; t=1791703196;
	bh=OB5z/SLnlJLkG3NA8CFS2bikRgEPoV+AfnWbf/1/F/Q=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=k/P3ONC23zQoB5Mekhk4DYqnjW2jpgRrJICmSOlUnQbpMmKVl/BH8L0lfWOg/Wx8o
	 sxz/UVC5RLRYVTvIlMbaGbPLHYC7XRaR6eV+PuHS9YXYUcO1Z3bkEHj6Y+9ZRd3kO7
	 wXhfSH7mjU5urxba/4dXzgnrIqnb8FEorW1+w7kY=
Date: Sun, 11 Oct 2026 09:19:53 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Lubos Rendek <l.rendek@proxmox.com>
Cc: stable@vger.kernel.org, regressions@lists.linux.dev,
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [REGRESSION] 7.2.4: nfsd sends CB_OFFLOAD with all-zero stateid,
 async NFSv4.2 COPY never completes
Message-ID: <2026101121-staining-scheme-358a@gregkh>
References: <7cc824c4-632d-49df-ae5e-cfcbb5bf76ad@proxmox.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7cc824c4-632d-49df-ae5e-cfcbb5bf76ad@proxmox.com>

On Sun, Oct 11, 2026 at 06:30:40AM +1100, Lubos Rendek wrote:
> Since 7.2.4, an NFSv4.2 server-side COPY between two exports of a Linux
> NFS server never completes, because nfsd sends CB_OFFLOAD with an
> all-zero stateid.

Can you just use git bisect to determine the offending commit?

And is this also the same for 7.3-rc?

thanks,

greg k-h
