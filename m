From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: NFS regression?  Odd delays and lockups accessing an NFS
	export.
Date: Tue, 12 May 2009 13:27:58 -0700
Message-ID: <1242160078.2404.6.camel@dyn9047022153>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
	 <20080818185048.GO20684@miggy.org>  <48A9CF89.9090304@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>, neilb@suse.de,
	bfields@fieldses.org, linux-nfs@vger.kernel.org
To: jacliburn@bellsouth.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755653AbZELUW0@vger.kernel.org>
In-Reply-To: <48A9CF89.9090304@bellsouth.net>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-08-18 at 14:37 -0500, J. K. Cliburn wrote:
> Athanasius wrote:
> > On Mon, Aug 18, 2008 at 12:02:20PM +1000, Grant Coady wrote:
> >> I've been using NFS here for years, lately there's something odd going on 
> >> since about a month or so.  Previously reported last month:
> >> http://www.gossamer-threads.com/lists/linux/kernel/951419?page=last
> >>
> >> Now with 2.6.27-rc3 on one of the client boxes I get a complete stall 
> >> at odd times when accessing the server's exported directory, cannot 
> >> see a pattern to it.  Eventually recovers after a Ctrl-C.  Nothing in 
> >> the server or client log files.  Not easy to reproduce either.
> > 
> >   I wonder if this is what I've been seeing.  I've been otherwise too
> > busy to properly report it, thinking that *someone* else must also be
> > seeing it and it's being worked on, else it's a subtle configuration
> > problem my end.
> > 
> >   I first started seeing this with 2.6.26 on the client end, 
> 
> I see you're running the atl1 driver on your client.  I'm chasing an 
> intermittent bug in that driver that seems to be affected by certain 
> offload parameters.  Try disabling TSO and see if things improve.

Was this ever resolved? We're seeing a similar hangup in a 2.6.27
kernel.

Thanks

Frank Filz
