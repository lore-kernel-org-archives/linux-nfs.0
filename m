From: Andi Kleen <ak@suse.de>
Subject: Re: modular nfsd requires kernel changes on sh, sparc64, x86_64
Date: Sat, 13 Mar 2004 19:05:06 +0100
Sender: sparclinux-owner@vger.kernel.org
Message-ID: <20040313180505.GA2338@wotan.suse.de>
References: <20040313173444.GX14833@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, davem@redhat.com,
	sparclinux@vger.kernel.org, ak@suse.de, discuss@x86-64.org,
	gniibe@m17n.org, kkojima@rr.iij4u.or.jp, linux-sh@m17n.org
Return-path: <sparclinux-owner@vger.kernel.org>
To: Adrian Bunk <bunk@fs.tum.de>
In-Reply-To: <20040313173444.GX14833@fs.tum.de>
List-ID: <nfs.lists.sourceforge.net>

On Sat, Mar 13, 2004 at 06:34:44PM +0100, Adrian Bunk wrote:
> Compiling and inserting a module into the currently running kernel 
> should work without needing a reboot.
> 
> For nfsd this seems to work everywhere except on the sh, sparc64 
> and x86_64 architectures where adding the nfsd module changes 
> non-modular kernel code (checked in 2.6.4-mm1):

Ideally if you want to do that I would suggest you move the nfsd
emulation layer into nfsd itself (compat_nfsservctl) and let
it be called using a stub like the normal modular sys_nfsservctl

-Andi
