From: Greg Banks <gnb@sgi.com>
Subject: Re: kernel exports table flushes out on running exportfs -a over mips
Date: Thu, 31 Jan 2008 13:36:54 +1100
Message-ID: <20080131023654.GA45273388@ocelot.melbourne.sgi.com>
References: <DDFD17CC94A9BD49A82147DDF7D545C5743B89@exchange.ZeugmaSystems.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Anirban Sinha <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:48479 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756318AbYAaChG (ORCPT
	<rfc822;@relay.sgi.com:linux-nfs@vger.kernel.org>);
	Wed, 30 Jan 2008 21:37:06 -0500
In-Reply-To: <DDFD17CC94A9BD49A82147DDF7D545C5743B89-Lp/cVzEoVyb8BYCnuv3k+coc7lC+zEt2hPhL2mjWHbk@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 30, 2008 at 05:34:13PM -0800, Anirban Sinha wrote:
> Hi:
> 
> I am seeing an unusual problem on running nfs server on mips. Over Intel
> this does not happen. When I run exportfs -a on the server when the
> clients have already mounted their nfs filesystem, the kernel exports
> table as can be seen from /proc/fs/nfs/exports gets completely flushed
> out. We (me and one another colleague) have done some digging (mostly
> looking into nfsutils codebase) and it looks like a kernel side issue.
> We had also asked folks in the linux-mips mailing list, but apparently
> no one has any clue. I am just hoping that those who are more familiar
> with the user level and kernel side of nfs might me something more to
> chew on. If you can give any suggestions that will be really useful. If
> you think the information I provided is not enough, I can give you any
> other information you need in this regard.

Does the MIPS box have the /proc/fs/nfsd/ filesystem mounted?
Perhaps you could try

1) running exportfs under strace.  I suggest
   strace -o /tmp/s.log -s 1024 exportfs ...

2) AND enabling kernel debug messages
   rpcdebug -m nfsd -s export
   rpcdebug -m rpc -s cache


-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.
