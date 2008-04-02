From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd restart failures without /proc/fs/nfsd filesystem mounted
Date: Wed, 2 Apr 2008 18:26:11 -0400
Message-ID: <20080402222611.GC16302@fieldses.org>
References: <DDFD17CC94A9BD49A82147DDF7D545C59D349C@exchange.ZeugmaSystems.local> <20080401210627.GD21343@fieldses.org> <DDFD17CC94A9BD49A82147DDF7D545C59D3777@exchange.ZeugmaSystems.local> <20080401221327.GH21343@fieldses.org> <DDFD17CC94A9BD49A82147DDF7D545C59D3A6C@exchange.ZeugmaSystems.local> <DDFD17CC94A9BD49A82147DDF7D545C59D3B32@exchange.ZeugmaSystems.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Anirban Sinha <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48089 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755058AbYDBW0P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Apr 2008 18:26:15 -0400
In-Reply-To: <DDFD17CC94A9BD49A82147DDF7D545C59D3B32-Lp/cVzEoVyb8BYCnuv3k+coc7lC+zEt2hPhL2mjWHbk@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 02, 2008 at 02:25:10PM -0700, Anirban Sinha wrote:
> >As you can see, we have an extra u_ptr member in the union (which is
> the
> >same as in the kernel: include/linux/nfsd/syscall.h).
> >
> >For experiment, I removed this member, recompiled nfs-utils and wala!
> >The kernel now gets the correct value of the server thread #.
> >
> >I am a bit puzzled by this since u_umap member already has a char* and
> I
> >think adding a void* does not change the alignment of the union. 
> 
> 
> Indeed. Actually, by mistake, I was using the new 1.1.2 nfs-utils
> binaries and making changes in the old 1.1.0 nfs-utils source. The
> removal of the member does not change anything. What is happening is
> that an upgrade to the new 1.1.2 nfs-utils binaries solves the problem.
> I think you can reproduce the problem at your end simply by unmounting
> nfsd filesystem and using 1.1.0 nfs-utils binary.

OK!  Hm, do you know which patch actually fixed this?  (Is it actually
just the same problem you reported before?)  On a quick skim through the
git history I'm not seeing it.

--b.
