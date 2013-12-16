Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58675 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755001Ab3LPSyU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Dec 2013 13:54:20 -0500
Date: Mon, 16 Dec 2013 13:54:19 -0500
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: nfs-utils-1.2.9 does not play well with linux 3.10.x
Message-ID: <20131216185419.GB31816@fieldses.org>
References: <OFDD407A92.688D29A1-ONC1257C43.00634FC8-C1257C43.00645775@transmode.se>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OFDD407A92.688D29A1-ONC1257C43.00634FC8-C1257C43.00645775@transmode.se>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 16, 2013 at 07:16:00PM +0100, Joakim Tjernlund wrote:
> rpc.nfsd insists on adding "-4.2" when writing /proc/fs/nfsd/versions :
>   rpc.nfsd: Writing version string to kernel: +4.1 -4.2 -2 +3 +4
> Which causes Linux to return an EIVAL error as 3.10 has no support for 4.2 
> and
> does not accept any reference to 4.2
> 
> It seems reasonable to me that Linux should accpect -4.2 as a noop and 
> continue
> processing the rest of the options but I am just guessing.
> Anyhow, just to test I applied this commit to my 3.10.24 kernel:
>    
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=4bdc33ed5bd9fbaa243bda6fdccb22674aed6305
> and now it accepts the "-4.2" but I have no idea if this messes up 
> something else.

That should be perfectly safe.

I agree that we should teach the kernel to treat "-4.x" at least as a
no-op for unknown .x.  But nfs-utils also has to keep working with older
kernels which don't do that.

The problem was introduced by 12a590f8d556c00a9502eeebaa763d906222d521
"rpc.nfsd: Allow v4.2 server support with the -V option".  That should
be using an array of ints not a bit array, so it can make the
distinction between "off", "on", and "don't care".

--b.
