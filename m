From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [-mm patch] fs/nfsd/nfs4state.c: make a struct static
Date: Tue, 4 Apr 2006 12:50:45 -0400
Message-ID: <20060404165045.GD17709@fieldses.org>
References: <20060404014504.564bf45a.akpm@osdl.org> <20060404163010.GQ6529@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, NeilBrown <neilb@suse.de>,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750755AbWDDQu4@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060404163010.GQ6529@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Apr 04, 2006 at 06:30:10PM +0200, Adrian Bunk wrote:
> On Tue, Apr 04, 2006 at 01:45:04AM -0700, Andrew Morton wrote:
> >...
> > Changes since 2.6.16-mm2:
> >...
> > +knfsd-locks-flag-nfsv4-owned-locks.patch
> >...
> >  knfsd updates.
> >...
> 
> This patch makes the needlessly global struct nfsd_posix_mng_ops static.

Whoops, thanks, looks good.

Do you have a script to look for patches that add non-statics?

--b.
