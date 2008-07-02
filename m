From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: inux-next: Tree for July 1
Date: Wed, 2 Jul 2008 12:51:22 +0200
Message-ID: <200807021251.23696.rjw@sisk.pl>
References: <20080702011434.6fb403d5.sfr@canb.auug.org.au> <1214959743.10317.3.camel@localhost> <20080701203211.95244ebd.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	kernel-testers@vger.kernel.org, linux-nfs@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20080701203211.95244ebd.rdunlap@xenotime.net>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday, 2 of July 2008, Randy Dunlap wrote:
> On Tue, 01 Jul 2008 20:49:03 -0400 Trond Myklebust wrote:
> 
> > On Tue, 2008-07-01 at 22:36 +0200, Rafael J. Wysocki wrote:
> > > I can't mount NFS shares with this kernel.  I get something of this sort in
> > > dmesg and it seems to be 100% reproducible:
> > > 
> > > [  314.058858] RPC: Registered udp transport module.
> > > [  314.058863] RPC: Registered tcp transport module.
> > > [  314.490970] RPC: transport (0) not supported
> > > [  319.246987] __ratelimit: 23 messages suppressed
> > 
> > Does this patch fix the problem for you?
> 
> Yes.  Thanks.

It also fixes the issue for me.

Thanks,
Rafael
