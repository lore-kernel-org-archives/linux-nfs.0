From: Jakob Oestergaard <jakob@unthought.net>
Subject: Re: NFS/Kernel Problem: getfh failed: Operation not permitted
Date: Thu, 30 Mar 2006 18:41:40 +0200
Message-ID: <20060330164140.GD9811@unthought.net>
References: <1143728720.8074.41.camel@lade.trondhjem.org> <Pine.LNX.4.64.0603300929340.18696@p34> <1143729766.8074.49.camel@lade.trondhjem.org> <Pine.LNX.4.64.0603300949000.18696@p34> <1143731364.8074.53.camel@lade.trondhjem.org> <Pine.LNX.4.64.0603301011160.18696@p34> <20060330153128.GB9811@unthought.net> <Pine.LNX.4.61.0603301053030.738@chaos.analogic.com> <20060330160521.GC9811@unthought.net> <Pine.LNX.4.61.0603301111421.738@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Piszcz <jpiszcz@lucidpixels.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932243AbWC3Qlm@vger.kernel.org>
To: "linux-os (Dick Johnson)" <linux-os@analogic.com>
In-Reply-To: <Pine.LNX.4.61.0603301111421.738@chaos.analogic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, Mar 30, 2006 at 11:14:11AM -0500, linux-os (Dick Johnson) wrote:
> 
...
> Well NFS is supposed to work like this.

I know that (which is why I once spent a *long* time troubleshooting
this until someone told me that is was well known to cause flaky
behaviour on Linux - quite unlike Solaris in the same setup).

Anyway, it's a long time ago, and as I state initially, I don't know if
this is still a problem.

> If it doesn't, you may
> have some far more serious problems, perhaps duplicate IP addresses,
> etc., that prevent proper resolution and subsequent connections.
> It has nothing to do with luck.

Whatever you say.

-- 

 / jakob
