Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 427E9358D3D;
	Tue, 14 Apr 2026 10:01:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776160905; cv=none; b=cUVLDtMpcAR9cIou5fiqDHpx+fFEIdVLcYx/PNptyXBF1mFQkm/JdRYZdiO80f6D/aPAiPAQ+4fzsoK9CjiIqTULM+lTOXjrPjUS/eDo/AWB3U3j1+9XtP684qQ0ROzEPWivAgegRXB0BVOjduVgtQn+EUnOssqeXqHqh8HGAf0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776160905; c=relaxed/simple;
	bh=BSuVS/OigjttJi3/c02qQ9rupCdrtyhHHook3jJVokE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=nGXZLVTZbIEgnjbcU9EFRgybw5u42q0ve7jqzoWjd38QcM6yMkt/jaj21vXgH5EKY1z3nhaPBvb2pUSyw7zhr6DW3V0cYsFMpYzTEDDT/fsdHAXkTzGJpaAjNFvpiv9yk2tRnGp13ZvAd1Vz90px31C0edZ3SFcxGN4IMYjhBzk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DHcCYvha; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DHcCYvha"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3A766C19425;
	Tue, 14 Apr 2026 10:01:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776160904;
	bh=BSuVS/OigjttJi3/c02qQ9rupCdrtyhHHook3jJVokE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=DHcCYvhahb0wlvUNb6mUgX5xexwnFxnAIsF1w+uinEKflRs6Fxw2g3mccUqQhvcl+
	 A8jzm0uIr0dIsgC6dkb2wsR0x3H2fxxAAIC0CIJg2grFOg2FhGZ+bkPE49FBqdbn0B
	 MoqInoxHWLq/fBLj4GNPAUFQkX6NkVHnHP/RZMRRKjqL26ZXKBpxoEE06sIP/btKEJ
	 S5Umgcjj9d+qkmPDgbytUbdZhjtTOuaSnfm0a8RFMcUrMrXXfKvjphWHImeR2nd6V5
	 aBQgbW1UqJHlKvgW7dWaqTjXQcVTq59cXLN+t6TWf5w36NUyZ3bqwyMEJ5A7551+bk
	 YRZ2YRPj0CsYg==
Date: Tue, 14 Apr 2026 12:01:39 +0200
From: Christian Brauner <brauner@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>, 
	Amir Goldstein <amir73il@gmail.com>
Subject: Re: cleanup block-style layouts exports v2
Message-ID: <20260414-ausbrechen-gemixt-ff09f46bdad2@brauner>
References: <20260401144059.160746-1-hch@lst.de>
 <8bef4d4e-1c0d-451d-8854-ed0cba27ee1f@app.fastmail.com>
 <20260409-schwalben-neutralisieren-fb5a184e5049@brauner>
 <20260410111007.GA10292@lst.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20260410111007.GA10292@lst.de>

On Fri, Apr 10, 2026 at 01:10:07PM +0200, Christoph Hellwig wrote:
> On Thu, Apr 09, 2026 at 03:26:09PM +0200, Christian Brauner wrote:
> > > Christian, are you OK if I take this series through the NFSD tree?
> > 
> > Hm, I generally prefer infrastructure to go through the VFS tree.
> > You can get a stable branch ofc.
> 
> Communicating this earlier would be helpful.  If we switch to a new
> tree base we're going to miss this merge window.

The series was sent on April 1 so with about 2 weeks before the merge
window... If your series isn't ready by -rc5 what is it doing being
merged for the coming merge window is the other side of the question. So
afaict, there's no hurry.
