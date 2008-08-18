From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS regression?  Odd delays and lockups accessing an NFS
	export.
Date: Mon, 18 Aug 2008 15:19:33 -0400
Message-ID: <1219087173.7192.17.camel@localhost>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
	 <20080818185048.GO20684@miggy.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>, neilb@suse.de,
	bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Athanasius <link@miggy.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752797AbYHRTT4@vger.kernel.org>
In-Reply-To: <20080818185048.GO20684@miggy.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-08-18 at 19:50 +0100, Athanasius wrote:
> On Mon, Aug 18, 2008 at 12:02:20PM +1000, Grant Coady wrote:
> > I've been using NFS here for years, lately there's something odd going on 
> > since about a month or so.  Previously reported last month:
> > http://www.gossamer-threads.com/lists/linux/kernel/951419?page=last
> > 
> > Now with 2.6.27-rc3 on one of the client boxes I get a complete stall 
> > at odd times when accessing the server's exported directory, cannot 
> > see a pattern to it.  Eventually recovers after a Ctrl-C.  Nothing in 
> > the server or client log files.  Not easy to reproduce either.
> 
>   I wonder if this is what I've been seeing.  I've been otherwise too
> busy to properly report it, thinking that *someone* else must also be
> seeing it and it's being worked on, else it's a subtle configuration
> problem my end.

Your lockdep trace basically shows that the rpc layer is blocking for
some reason. Could you please try to reproduce the problem, and then do

	echo 0 >/proc/sys/sunrpc/rpc_debug

...and see what the output from 'dmesg' shows?

Cheers
  Trond
