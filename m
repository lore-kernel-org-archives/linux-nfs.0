From: Nathan Straz <nstraz@sgi.com>
Subject: Re: Irix NFS servers, again :-)
Date: Thu, 17 Jun 2004 08:38:28 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040617133828.GA20029@sgi.com>
References: <1087411925.30092.35.camel@ceiriog1.demon.co.uk> <40D163C8.30507@greenhydrant.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Wainwright <prw@ceiriog1.demon.co.uk>,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266491AbUFQNj1@vger.kernel.org>
To: David Rees <drees@greenhydrant.com>
In-Reply-To: <40D163C8.30507@greenhydrant.com>
List-ID: <nfs.lists.sourceforge.net>

On Thu, Jun 17, 2004 at 02:26:32AM -0700, David Rees wrote:
> Peter Wainwright wrote, On 6/16/2004 11:52 AM:
> >I just upgraded one of my machines to Fedora Core 2, including
> >kernel 2.6.5. I found myself bitten on the bum by a bug I thought
> >had expired long ago, namely the Irix server readdir bug, or
> >32/64-bit cookie problem.
>
> glibc.  I can't seem to reproduce it using `ls` which I remember being 
> able to last time I had the problem so that would explain it.  What 
> software showed the problem for you?

You can see the different if you do `ls dir` and `ls dir/*`.  Typically
the shell will use readdir and ls will use getdents, IIRC.  I was using
the test case readdir01 from LTP.

-- 
Nate Straz                                              nstraz@sgi.com
sgi, inc                                           http://www.sgi.com/
Linux Test Project                                  http://ltp.sf.net/
