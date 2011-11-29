Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48454 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756866Ab1K2Wgw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 17:36:52 -0500
Message-ID: <1322606193.11286.28.camel@lade.trondhjem.org>
Subject: Re: ore: FIX breakage when MISC_FILESYSTEMS is not set
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@tonian.com>, Randy Dunlap <rdunlap@xenotime.net>,
        Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>, Michal Marek <mmarek@suse.cz>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Date: Tue, 29 Nov 2011 17:36:33 -0500
In-Reply-To: <4ED55B3B.9050207@panasas.com>
References: <20111124174358.d88f11c0ff700e5e6b3bf73b@canb.auug.org.au>
	  <4ECE91F3.9010007@xenotime.net> <4ED422CC.60706@panasas.com>
	  <4ED4238F.4090407@panasas.com> <4ED4CE58.8090107@tonian.com>
	 <1322588023.4174.28.camel@lade.trondhjem.org>
	 <4ED55B3B.9050207@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-11-29 at 14:22 -0800, Boaz Harrosh wrote: 
> On 11/29/2011 09:33 AM, Trond Myklebust wrote:
> > On Tue, 2011-11-29 at 14:21 +0200, Benny Halevy wrote: 
> >> On 2011-11-29 02:13, Boaz Harrosh wrote:
> 
> >>>
> >>> The solution is to force all users of ORE (exofs, nfs) to manually
> >>> select everything auto-magically selected before.
> >>
> >> How about using "depend ORE" rather than "select ORE"?
> > 
> > Right. Make PNFS_OBJLAYOUT and EXOFS_FS depend on ASYNC_XOR (or select
> > it) and then make ORE depend on EXOFS_FS || PNFS_OBJLAYOUT.
> > 
> > There should be no need to add the 'select ORE'...
> > 
> 
> No! guys!
> 
> One it will not solve my problem because any
> solution that needs to inspect exofs/Kconfig file will
> not work if MISC_FILESYSTEMS is not selected and your
> solutions involve that.

Then move ORE _out_ of MISC_FILESYSTEMS. There is no reason why it needs
to be there as long as the things it depends on are there.

> And two:
> All the user needs to do is Select NFS4.1 everything
> else should be done automatically. He should not need
> to go to misc-filesystems and select ORE so he can have
> pnfs-objects. That's a nightmare.

The solution I proposed didn't involve having the user select anything
other than NFSv4.1 and possibly ASYNC_XOR.

> And anyway the current Kernel rule is that a user of a library
> needs to select it and all it's dependencies, because select
> is not recursive. Now I devised a little skim that can avoid

...and this is _my_ nightmare. I dont' _want_ these selects anywhere in
the NFS subsystem.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

