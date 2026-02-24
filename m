Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CABE033121E;
	Tue, 24 Feb 2026 08:35:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771922130; cv=none; b=EQZGDCyhJlWTrMQLo4mOnffzWhBvrj27haxnl1mzISvT3BeeqFdGSonvZPLnwDnpxLIzcmxtaOXF2DcHHsyZnGBNKervAww1Nxp7UHGvhqvkaAzUKxLeYkZT8t8U6ISHkHHhsbO82cATPSuU0JPrMu8sShlHJjvYwK+cT5P+cXA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771922130; c=relaxed/simple;
	bh=9PLsfnR5iHMOyJCMofHcZdCMkEvGsqpqrr6DHikEOSY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=VkSQszxJ3i1RGCFRShSPtWFTEvK92aIGiMCCfBW15Z6dBIGZvZaurtSm5U6jIKvd0CFTItt+rY5od9xqnPT6ZbU5ks82tlL0zl7ZniqQKzUphuRsaLFKvxPHCNwkWs8RKmiMAwjjqHlpjiPKeor6KoyOzwzKclOVH73C031wGbg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XDeHg3Yd; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XDeHg3Yd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1FECBC116D0;
	Tue, 24 Feb 2026 08:35:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771922130;
	bh=9PLsfnR5iHMOyJCMofHcZdCMkEvGsqpqrr6DHikEOSY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=XDeHg3YdzfdE1v2m6VJYhzwn6l+fsxpvhM8pB5Vqb5Ft8H+R4QWWYqORm7EXouxkG
	 ZHo1xyAjFCdl9GLpK0+LE9qR5RKvtNGlSd7sNd2A1UIlmjdXVd+KhIrJu3sa3SyhxU
	 XbIe8arpl4sTUrDrbBmrY5ldZAN7x1wmNjUOp6jN/EHTu4AgkpGhrgAx0cBduiqmrk
	 W8nNtpvg0S2YNq+VtRg9wiWKNZpjmd3qLLe40qovpJKew0vPukB3HxPQsKu0t9KAho
	 lfVVy3Uodk8a8lzrqAJEd2+gHJkKU5RYziggsmE8MGpt+J+LD3s7SVA9xCLcFRsn5d
	 06lUVNP4LKVAA==
Date: Tue, 24 Feb 2026 09:35:25 +0100
From: Christian Brauner <brauner@kernel.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Shyam Prasad N <nspmangalore@gmail.com>, 
	lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	keyrings@vger.kernel.org, CIFS <linux-cifs@vger.kernel.org>, linux-nfs@vger.kernel.org, 
	David Howells <dhowells@redhat.com>
Subject: Re: [LSF/MM/BPF TOPIC] Namespace-aware upcalls from kernel
 filesystems
Message-ID: <20260224-luftzug-wildfremd-c15f558741e8@brauner>
References: <CANT5p=rDxeYKXoCJoWRwGGXv4tPCM2OuX+US_G3hm_tL3UyqtA@mail.gmail.com>
 <7570f43c-8f6c-4419-a8b8-141efdb1363a@app.fastmail.com>
 <CANT5p=rpJDx0xXfeS3G01VEWGS4SzTeFqm2vO6tEnq9kS=+iOw@mail.gmail.com>
 <510c1f0a-4f42-4ce5-ab85-20d491019c53@app.fastmail.com>
 <785793ea21fb65c3e721b51f24897b3000e4aec3.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <785793ea21fb65c3e721b51f24897b3000e4aec3.camel@kernel.org>

On Tue, Feb 17, 2026 at 10:18:39AM -0500, Jeff Layton wrote:
> On Tue, 2026-02-17 at 09:21 -0500, Chuck Lever wrote:
> > 
> > On Mon, Feb 16, 2026, at 11:14 PM, Shyam Prasad N wrote:
> > > On Sat, Feb 14, 2026 at 9:10 PM Chuck Lever <cel@kernel.org> wrote:
> > > > 
> > > > 
> > > > On Sat, Feb 14, 2026, at 5:06 AM, Shyam Prasad N wrote:
> > > > > Kernel filesystems sometimes need to upcall to userspace to get some
> > > > > work done, which cannot be achieved in kernel code (or rather it is
> > > > > better to be done in userspace). Some examples are DNS resolutions,
> > > > > user authentication, ID mapping etc.
> > > > > 
> > > > > Filesystems like SMB and NFS clients use the kernel keys subsystem for
> > > > > some of these, which has an upcall facility that can exec a binary in
> > > > > userspace. However, this upcall mechanism is not namespace aware and
> > > > > upcalls to the host namespaces (namespaces of the init process).
> > > > 
> > > > Hello Shyam, we've been introducing netlink control interfaces, which
> > > > are namespace-aware. The kernel TLS handshake mechanism now uses
> > > > this approach, as does the new NFSD netlink protocol.
> > > > 
> > > > 
> > > > --
> > > > Chuck Lever
> > > 
> > > Hi Chuck,
> > > 
> > > Interesting. Let me explore this a bit more.
> > > I'm assuming that this is the file that I should be looking into:
> > > fs/nfsd/nfsctl.c
> > 
> > Yes, clustered towards the end of the file. NFSD's use of netlink
> > is as a downcall-style administrative control plane.
> > 
> > net/handshake/netlink.c uses netlink as an upcall for driving
> > kernel-initiated TLS handshake requests up to a user daemon. This
> > mechanism has been adopted by NFSD, the NFS client, and the NVMe
> > over TCP drivers. An in-kernel QUIC implementation is planned and
> > will also be using this.
> > 
> > 
> > > And that there would be a corresponding handler in nfs-utils?
> > 
> > For NFSD, nfs-utils has a new tool called nfsdctl.
> > 
> > The TLS handshake user space components are in ktls-utils. See:
> > https://github.com/oracle/ktls-utils
> 
> 
> I think the consensus at this point is to move away from usermodehelper
> as an upcall mechanism. The Linux kernel lacks a container object that
> allows you to associate namespaces with one another, so you need an
> already-running userspace process to do that association in userland.
> 
> netlink upcalls are bound to a network namespace. That works in the
> above examples because they are also bound to a network namespace.
> netlink upcalls require a running daemon in that namespace, which is
> what ties that network namespace to other sorts of namespaces.
> 
> So, a related discussion we should have is whether and how we should
> deprecate the old usermodehelper upcalls, given that they are
> problematic in this way. 

Yes, I want usermodehelpers to eventually go away with the very few
legitimate cases being ideally replaced by user workers I added a few
years ago. User workers are spawned by the kernel but are actual
children of the caller and inherit its settings just like a fork()
would.

They're not just problematic because they're namespace unaware. That's
even something we could fix, I'm sure. It's that they run with full
kernel privileges. As evidenced by the old coredump usermodehelper this
is just an invitation for security issues. It's also completely opaque
to userspace when a process suddenly pops into the process table that is
not a child and more or less out of its control that then executes
binaries placed in some location in userspace. The mechanism just
doesn't cut it anymore imho.

There's a couple of avenues we have here to redo this so having that
discussion might be useful.
