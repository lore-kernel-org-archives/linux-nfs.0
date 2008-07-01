From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: inux-next: Tree for July 1
Date: Tue, 1 Jul 2008 13:41:00 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0807011340170.26330@shark.he.net>
References: <20080702011434.6fb403d5.sfr@canb.auug.org.au> <200807012236.19400.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	kernel-testers@vger.kernel.org, linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <kernel-testers-owner@vger.kernel.org>
In-Reply-To: <200807012236.19400.rjw@sisk.pl>
Sender: kernel-testers-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 1 Jul 2008, Rafael J. Wysocki wrote:

> On Tuesday, 1 of July 2008, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Changes since next-20080630:
> > 
> > New tree: ttydev - unfortunately it had to be reverted because of build
> > failures after lots of conflict resolution (which may have caused the
> > build failures).
> > 
> > Changed tree: the cris tree changed branch names.
> > 
> > The sched tree gained a couple of conflicts against the ftrace and
> > cpus4096 trees.
> > 
> > The pci tree gained a conflict against the x86 tree.
> > 
> > The usb tree reverted due to a build failure after merging with the pci
> > tree was changed for a fixup patch.
> > 
> > The v4l-dvb tree lost its three conflicts against Linus' tree.
> > 
> > The s390 tree gained a conflict against the diver-core tree.
> > 
> > The ide tree fixed its build problems.
> > 
> > The nfsd tree lost a conflict against the nfs tree.
> > 
> > The powerpc tree gained a conflict against the ide tree.
> > 
> > The net tree gained two conflicts against the powerpc tree.
> > 
> > The galak tree lost its conflict against the net tree.
> > 
> > the blk-removal tree gained a conflict against the s390 tree.
> > 
> > The firmware tree lost several conflicts against the net tree so didn't
> > need a commit reverted any more.
> > 
> > Merging the ttydev tree got several conflicts against the usb and
> > firmware trees.  Unfortunately, it also would not build and so was
> > reverted.
> > 
> > I have also applied the following patches for know problems:
> > 	module: fix NULL pointer dereference in find_symbol()
> 
> I can't mount NFS shares with this kernel.  I get something of this sort in
> dmesg and it seems to be 100% reproducible:
> 
> [  314.058858] RPC: Registered udp transport module.
> [  314.058863] RPC: Registered tcp transport module.
> [  314.490970] RPC: transport (0) not supported
> [  319.246987] __ratelimit: 23 messages suppressed
> 
> linux-next from yesterday was fine with the same .config .

Same problem for me.  Thanks for reporting it.
I wondered if it was something that I did wrong...

-- 
~Randy
