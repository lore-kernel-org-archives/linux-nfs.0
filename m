From: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Subject: RE: nfsd restart failures without /proc/fs/nfsd filesystem mounted
Date: Wed, 2 Apr 2008 14:25:10 -0700
Message-ID: <DDFD17CC94A9BD49A82147DDF7D545C59D3B32@exchange.ZeugmaSystems.local>
References: <DDFD17CC94A9BD49A82147DDF7D545C59D349C@exchange.ZeugmaSystems.local> <20080401210627.GD21343@fieldses.org> <DDFD17CC94A9BD49A82147DDF7D545C59D3777@exchange.ZeugmaSystems.local> <20080401221327.GH21343@fieldses.org> <DDFD17CC94A9BD49A82147DDF7D545C59D3A6C@exchange.ZeugmaSystems.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	<linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.zeugmasystems.com ([192.139.122.66]:21961 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755947AbYDBVZo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Apr 2008 17:25:44 -0400
In-Reply-To: <DDFD17CC94A9BD49A82147DDF7D545C59D3A6C-Lp/cVzEoVyb8BYCnuv3k+coc7lC+zEt2hPhL2mjWHbk@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>As you can see, we have an extra u_ptr member in the union (which is
the
>same as in the kernel: include/linux/nfsd/syscall.h).
>
>For experiment, I removed this member, recompiled nfs-utils and wala!
>The kernel now gets the correct value of the server thread #.
>
>I am a bit puzzled by this since u_umap member already has a char* and
I
>think adding a void* does not change the alignment of the union. 


Indeed. Actually, by mistake, I was using the new 1.1.2 nfs-utils
binaries and making changes in the old 1.1.0 nfs-utils source. The
removal of the member does not change anything. What is happening is
that an upgrade to the new 1.1.2 nfs-utils binaries solves the problem.
I think you can reproduce the problem at your end simply by unmounting
nfsd filesystem and using 1.1.0 nfs-utils binary.

Cheers,

Ani




