From: Robert Love <rml@tech9.net>
Subject: Re: 2.5: NFS troubles
Date: 07 Apr 2003 11:17:19 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1049728638.717.16.camel@localhost>
References: <1049630768.592.24.camel@teapot.felipe-alfaro.com>
	 <shsbrzjn5of.fsf@charged.uio.no> <20030406171855.6bd3552d.akpm@digeo.com>
	 <1049675270.753.166.camel@localhost>
	 <16017.31727.798961.19493@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Siim Vahtre <siim@pld.ttu.ee>, linux-kernel@vger.kernel.org,
	NFS maillist <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: trond.myklebust@fys.uio.no
In-Reply-To: <16017.31727.798961.19493@charged.uio.no>
List-ID: <nfs.lists.sourceforge.net>

On Mon, 2003-04-07 at 09:23, Trond Myklebust wrote:

> OK. I've managed to squash the NFS read corruption problems that I had
> on my 2.5.x client setup with the following patch.
> Since the two of you reported what appears to be the same problem,
> would you mind trying it out?

This fixes it for me.  No errors, no corruption.

I did a verify of the md5sums of all of the Red Hat 9 RPM packages over
NFS.  I had random failures (in different packages each time) before.

I just did it twice to be sure -- it works.

Thank you, Trond.

	Robert Love
