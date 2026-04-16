Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8ACC837C11C;
	Thu, 16 Apr 2026 09:27:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776331655; cv=none; b=CQXF2m7E8sVwALzutNqkdj21pZQEjruMnbO6/jTiVqfucTmuUu80PnuGSsJApDOcqZxLPpfXwdjP6xXKH5NeuwEfN0XSiFU8AEt/Znd/nsE16HXidztC1vtZPewnJQC2WF06E6qneone9oxC4UyxXJ1YmzibHGVVXiJPvFlfBls=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776331655; c=relaxed/simple;
	bh=Qid/cT/17BcNmWi1Xk3ku0DKb66l//g2unNZ3ZE7CVo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=J/bJ0FIUVRlvEy6hyRPH0CPF3BUY4JmS7hl2iWBq5AmalTWCMIpGeqFjfdewcdzaiATF5wVqL5rsAd0J7g65yswDE+9ZFLR/Is7dbH5rE9A5uMxZoiE7m18U98ONvlrhZj9f0wwoWHHwsbQJzcKXqNwRZLtpFUY6yyixSMWquZc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=o96JAUra; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="o96JAUra"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 86052C2BCAF;
	Thu, 16 Apr 2026 09:27:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776331655;
	bh=Qid/cT/17BcNmWi1Xk3ku0DKb66l//g2unNZ3ZE7CVo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=o96JAUraVR3iNEJskCiQjvDO5ZY0OUbln4vGh/8J5j4J+/20kO1TDsflRPUhWhAef
	 gXZ6iFlmT2U0k9btfDGGYIJnZ4TECTwOzJu2r8YVVnFDSaMvSFwcVeMMUefNxU8Wr5
	 jOZi9sNonFH4cR8jKrOU7t78ehqu/WfidloLw+j9AGGCAUXr6qcQAvEzNE7DsgaXwD
	 NzGKM3Q+7D3tR/N7JqygANUlJrHXuqDBe/lWdQ1pi8ckCj2pm3Gqx1l2u3K1T/m7BU
	 xyR7iLEEFeAR+nG4OdWXJswOCGatmPxrF9MCXYyqpBS0jFRr9O+zbTYxwL//4ZaXwD
	 IPvcfahU0uc2Q==
Date: Thu, 16 Apr 2026 11:27:29 +0200
From: Christian Brauner <brauner@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>, 
	Amir Goldstein <amir73il@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: cleanup block-style layouts exports v2
Message-ID: <20260416-absuchen-ofenfrisch-6bdf094c6d7e@brauner>
References: <20260401144059.160746-1-hch@lst.de>
 <8bef4d4e-1c0d-451d-8854-ed0cba27ee1f@app.fastmail.com>
 <20260409-schwalben-neutralisieren-fb5a184e5049@brauner>
 <20260410111007.GA10292@lst.de>
 <20260414-ausbrechen-gemixt-ff09f46bdad2@brauner>
 <20260415052925.GC26559@lst.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20260415052925.GC26559@lst.de>

On Wed, Apr 15, 2026 at 07:29:25AM +0200, Christoph Hellwig wrote:
> On Tue, Apr 14, 2026 at 12:01:39PM +0200, Christian Brauner wrote:
> > On Fri, Apr 10, 2026 at 01:10:07PM +0200, Christoph Hellwig wrote:
> > > On Thu, Apr 09, 2026 at 03:26:09PM +0200, Christian Brauner wrote:
> > > > > Christian, are you OK if I take this series through the NFSD tree?
> > > > 
> > > > Hm, I generally prefer infrastructure to go through the VFS tree.
> > > > You can get a stable branch ofc.
> > > 
> > > Communicating this earlier would be helpful.  If we switch to a new
> > > tree base we're going to miss this merge window.
> > 
> > The series was sent on April 1 so with about 2 weeks before the merge
> > window... If your series isn't ready by -rc5 what is it doing being
> > merged for the coming merge window is the other side of the question. So
> > afaict, there's no hurry.
> 
> That's a very weird generic standard.  I know a lot of subsystem don't
> take complex core changes until a bit before the cutoff, but killing
> 3 weeks of the merge window for everything is odd.

I didn't NAK anything. You pushed urgency here by complaining I didn't
communicate antyhing earlier. And I'm merely clarifying that 2 weeks
before the merge window when stuff should've been stabilized there's
other things to do then rush to reply to something that looks like it
can't go in this merge window anymore.

> Even more I'm not even why we're having that discussion - exportfs
> has it's own maintainers, one of whom ACKed this including the whole
> tree discussion.

If it's generic infra I generally want it centralized in one of the VFS
tree. I have clarified this over and over. It's fine to make exceptions.
It's not fine to pick and choose what currently best suits your needs.
