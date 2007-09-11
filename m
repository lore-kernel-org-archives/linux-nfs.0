From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Re: [PATCH 2/3] Remove old logging implementation for idmapd and
	rework gssd and idmapd to use the new xlog logging infrastructure.
Date: Tue, 11 Sep 2007 13:01:18 -0400
Message-ID: <1189530078.12340.28.camel@moss-terrapins.epoch.ncsc.mil>
References: <1189459543.7914.16.camel@moss-terrapins.epoch.ncsc.mil>
	<1189515746.12340.4.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110800g558b1fect5f84ea20e25efc7b@mail.gmail.com>
	<1189523208.12340.10.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110824t60745764l3fc63a393d51b0b9@mail.gmail.com>
	<4d569c330709110828qfaf7726we21d80d8001c92f9@mail.gmail.com>
	<20070911153742.GG13948@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20070911153742.GG13948@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

Another question about the code in general. Why is it that idmapd is
using fcntl and user signals to indicate changes to the rpc pipe. Isn't
there something else we can use like Inotify or a Netlink socket?  I am
assuming that this is just a result of the code being written before
these things were in place. I was originally starting doimapd based on
the idmapd source however if it is acceptable to move to one of these
other techniques I can switched over to that instead.

Dave

On Tue, 2007-09-11 at 11:37 -0400, J. Bruce Fields wrote:
> On Tue, Sep 11, 2007 at 11:28:48AM -0400, Kevin Coffman wrote:
> > On 9/11/07, Kevin Coffman <kwc@citi.umich.edu> wrote:
> > > On 9/11/07, David P. Quigley <dpquigl@tycho.nsa.gov> wrote:
> > > > Could you point me to the second in gssd that is doing this? It might be
> > > > better to use the print statements in a saner way.
> > > >
> > > > Dave
> > >
> > > Agreed.  The cuprit is print_hexl() in svcgssd_proc.c, which currently
> > > calls printerr() multiple times.  I'll look to see if I can find other
> > > instances that might be depending on the line acculation of printerr.
> > 
> > The qword_* functions in cachio.c also currently use this.
> 
> Actually, we only have two print_hexl's, both dumping the data that was
> read from the kernel's null upcall pipe on the server side.
> 
> I think those could probably go.  Kevin, have you used them recently?
> There's also always the option of running the program under strace with
> -s9999 to see all the read and write data, though that may not be as
> convenient.
> 
> --b.
