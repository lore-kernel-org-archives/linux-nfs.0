From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [BUG] nfs version 2 broken
Date: Wed, 01 Feb 2006 11:41:05 -0500
Message-ID: <1138812065.7858.6.camel@lade.trondhjem.org>
References: <43E05031.2000107@t-online.de>
	 <1138774519.7861.4.camel@lade.trondhjem.org>  <43E0567F.20004@t-online.de>
	 <1138775744.7875.0.camel@lade.trondhjem.org> <43E05FA1.6070407@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, neilb@cse.unsw.edu.au,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161041AbWBAQlS@vger.kernel.org>
To: Knut Petersen <Knut_Petersen@t-online.de>
In-Reply-To: <43E05FA1.6070407@t-online.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2006-02-01 at 08:13 +0100, Knut Petersen wrote:
> >>AOpen i915GMm-HFS with Pentium M, linux kernel 2.6.15-git7
> >>running a system that startet as SuSE 9.2. Nfs-utils are still
> >>the original 1.0.6, grep -i nfs linuxbuild/.config gives
> >>    
> >>
> >
> >...and what kind of filesystem are you exporting?
> >
> >  
> >
> 
> I think it is _not_ related to reiserfs. Moving my
> exported /tftpboot directory to a fresh ext2 partition
> gave the same results - failing with nfs 2, succeeding with
> nfs 3.

Does it do the same if you mount the same partition normally (i.e. not
through nfsroot) in some other directory?

Cheers,
  Trond
