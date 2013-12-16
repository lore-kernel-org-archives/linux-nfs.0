Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw1.transmode.se ([195.58.98.146]:60253 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019Ab3LPWYG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Dec 2013 17:24:06 -0500
In-Reply-To: <20131216202345.GF31816@fieldses.org>
References: <OFDD407A92.688D29A1-ONC1257C43.00634FC8-C1257C43.00645775@transmode.se> <20131216185419.GB31816@fieldses.org> <20131216200301.GD31816@fieldses.org> <OF149AE409.624B2B0A-ONC1257C43.006F77D7-C1257C43.006FCED2@transmode.se> <20131216202345.GF31816@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
MIME-Version: 1.0
Subject: Re: nfs-utils-1.2.9 does not play well with linux 3.10.x
From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Message-ID: <OF942071D7.5EC379B1-ONC1257C43.007AB858-C1257C43.007B0CFB@transmode.se>
Date: Mon, 16 Dec 2013 23:24:03 +0100
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> wrote on 2013/12/16 21:23:45:

> From: "J. Bruce Fields" <bfields@fieldses.org>
> To: Joakim Tjernlund <joakim.tjernlund@transmode.se>, 
> Cc: linux-nfs@vger.kernel.org, steved@redhat.com
> Date: 2013/12/16 21:23
> Subject: Re: nfs-utils-1.2.9 does not play well with linux 3.10.x
> 
> On Mon, Dec 16, 2013 at 09:21:15PM +0100, Joakim Tjernlund wrote:
> > "J. Bruce Fields" <bfields@fieldses.org> wrote on 2013/12/16 21:03:01:
> > 
> > > From: "J. Bruce Fields" <bfields@fieldses.org>
> > > To: Joakim Tjernlund <joakim.tjernlund@transmode.se>, 
> > > Cc: linux-nfs@vger.kernel.org, steved@redhat.com
> > > Date: 2013/12/16 21:03
> > > Subject: Re: nfs-utils-1.2.9 does not play well with linux 3.10.x
> > > 
> > > On Mon, Dec 16, 2013 at 01:54:19PM -0500, bfields wrote:
> > > > On Mon, Dec 16, 2013 at 07:16:00PM +0100, Joakim Tjernlund wrote:
> > > > > rpc.nfsd insists on adding "-4.2" when writing 
> > /proc/fs/nfsd/versions :
> > > > >   rpc.nfsd: Writing version string to kernel: +4.1 -4.2 -2 +3 +4
> > > > > Which causes Linux to return an EIVAL error as 3.10 has no 
support 
> > for 4.2 
> > > > > and
> > > > > does not accept any reference to 4.2
> > > > > 
> > > > > It seems reasonable to me that Linux should accpect -4.2 as a 
noop 
> > and 
> > > > > continue
> > > > > processing the rest of the options but I am just guessing.
> > > > > Anyhow, just to test I applied this commit to my 3.10.24 kernel:
> > > > > 
> > > > > 
> > 
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=4bdc33ed5bd9fbaa243bda6fdccb22674aed6305

> > 
> > > > > and now it accepts the "-4.2" but I have no idea if this messes 
up 
> > > > > something else.
> > > > 
> > > > That should be perfectly safe.
> > 
> > Thanks, I will keep this then until nfs-utils is working.
> > 
> > > > 
> > > > I agree that we should teach the kernel to treat "-4.x" at least 
as a
> > > > no-op for unknown .x.  But nfs-utils also has to keep working with 

> > older
> > > > kernels which don't do that.
> > > > 
> > > > The problem was introduced by 
12a590f8d556c00a9502eeebaa763d906222d521
> > > > "rpc.nfsd: Allow v4.2 server support with the -V option".  That 
should
> > > > be using an array of ints not a bit array, so it can make the
> > > > distinction between "off", "on", and "don't care".
> > > 
> > > So, something like this (untested).--b.
> > 
> > I tested this on my system(which has the above kernel patch) and I 
noticed
> > a difference:
> 
> Thanks!
> 
> >   rpc.nfsd: Writing version string to kernel: -2 +3 +4 
> > which is different than previous
> >  rpc.nfsd: Writing version string to kernel: +4.1 -4.2 -2 +3 +4
> > 
> > The "+4.1" is missing.
> 
> Yes, that's intentional.  Is it causing you any problem?

I don't know yet, but I don't think it would be a problem for me.
However, are you not changing the defaults here? In that
case someone else relying on 4.1 might have a problem I guess.

 Jocke

