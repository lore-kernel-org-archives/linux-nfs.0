Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37430 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184Ab2HGTmx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 15:42:53 -0400
Date: Tue, 7 Aug 2012 15:42:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: nfs4 mounts failing with 3.6.0-rc1
Message-ID: <20120807194250.GB22532@fieldses.org>
References: <20120804000819.GB25558@fieldses.org>
 <20120803220039.743fe1f0@corrin.poochiereds.net>
 <20120804190104.GA2135@fieldses.org>
 <20120807130932.79625d7e@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120807130932.79625d7e@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 07, 2012 at 01:09:32PM -0400, Jeff Layton wrote:
> On Sat, 4 Aug 2012 15:01:04 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Fri, Aug 03, 2012 at 10:00:39PM -0400, Jeff Layton wrote:
> > > On Fri, 3 Aug 2012 20:08:19 -0400
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > 
> > > > I'm getting
> > > > 
> > > > 	# mount -tnfs -onfsvers=4 pip1:/exports /mnt/
> > > > 
> > > > (OK, admittedly that's with 3.6.0-rc1 + a few experimental patches, but
> > > > I doubt they're related.)
> > > > 
> > > > Also:
> > > > 
> > > > 	[root@pip2 ~]# modprobe nfs4
> > > > 	[root@pip2 ~]# lsmod|grep nfs4
> > > > 	[root@pip2 ~]# 
> > > > 
> > > > --b.
> > > 
> > > I hit the same problem...
> > > 
> > > Try removing /usr/lib/modprobe.d/nfs.conf (assuming you're running
> > > Fedora).
> > 
> > Oog, right.
> > 
> > But, without testing--won't that make v4 mounts fail on older kernels?
> 
> Actually, now that I look, this does not seem to break on older kernels
> as long as you use a syntax like:
> 
>     # mount -t nfs server:/export /mnt/point -o vers=4
> 
> ...if, however you use a syntax like:
> 
>     # mount -t nfs4 server:/export /mnt/point
> 
> ...then it fails without the above file in place. I guess the question
> we have to answer is: Do we want to continue to support the "-t nfs4"
> mount syntax?

I think you're right that we want to deprecate it.

Though this is a bit of a harsh way to do it--would have been nice to
have some transition period with a warning or something.

--b.
