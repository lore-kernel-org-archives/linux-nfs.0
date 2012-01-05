Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21263 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754234Ab2AEUmm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jan 2012 15:42:42 -0500
Date: Thu, 5 Jan 2012 15:42:38 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] autoconf: clean up linking in nfs-utils
Message-ID: <20120105154238.1286fe22@dantu.rdu.redhat.com>
In-Reply-To: <20120105185707.GA4757@umich.edu>
References: <1324669625-2948-1-git-send-email-jlayton@redhat.com>
	<20111224145456.GA13830@umich.edu>
	<20111224165301.GA16658@umich.edu>
	<20120105133748.5cfa2506@dantu.rdu.redhat.com>
	<20120105185707.GA4757@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 5 Jan 2012 13:57:07 -0500
Jim Rees <rees@umich.edu> wrote:

> Jeff Layton wrote:
> 
>   On Sat, 24 Dec 2011 11:53:01 -0500
>   Jim Rees <rees@umich.edu> wrote:
>   
>   > Jim Rees wrote:
>   > 
>   >   Jeff Layton wrote:
>   >   
>   >     This patchset is a cleanup of the linking in nfs-utils. This should
>   >     reduce the number of unnecessary libraries that each of the binaries are
>   >     linked against.
>   >   
>   >   This is probably unrelated to your patches, but here's what I get:
>   >   
>   >   ...
>   >   /bin/bash ../../libtool --tag=CC   --mode=link gcc -Wall -Wextra -Wstrict-prototypes  -pipe -g -O2   -o nfsidmap nfsidmap.o -lnfsidmap -lkeyutils -lnfsidmap -ltirpc 
>   >   libtool: link: gcc -Wall -Wextra -Wstrict-prototypes -pipe -g -O2 -o nfsidmap nfsidmap.o  -lkeyutils -lnfsidmap -ltirpc
>   >   nfsidmap.o: In function `key_revoke':
>   >   /home/rees/p/nfs-utils/utils/nfsidmap/nfsidmap.c:153: undefined reference to `xlog_syslog'
>   >   ...
>   > 
>   > Never mind, cockpit error.  I ran autogen in the wrong directory.  Now I'm
>   > getting this:
>   > 
>   > % configure --prefix=/usr --sysconfdir=/etc --enable-nfsv41 --enable-ipv6 \
>   > ?   --disable-gss --disable-uuid --enable-tirpc --without-tcp-wrappers \
>   > ?   --disable-libmount-mount
>   > ...
>   > checking for bindresvport_sa... no
>   > configure: error: Missing library functions needed for IPv6.
>   
>   Sorry I didn't respond to this sooner...
>   
>   Did you ever figure out what's going on here? Is this a regression
>   caused by this patchset?
> 
> No, I didn't.  I can try reverting your patch to see what happens if you
> want.  Do you know where bindresvport_sa is supposed to come from?

Nevermind...the last patch in this series broke that test. I'll fix and
respin -- sorry for the noise!

-- 
Jeff Layton <jlayton@redhat.com>
