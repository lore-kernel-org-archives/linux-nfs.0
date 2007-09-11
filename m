From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Re: [PATCH 2/3] Remove old logging implementation for idmapd and
	rework gssd and idmapd to use the new xlog logging infrastructure.
Date: Tue, 11 Sep 2007 11:23:50 -0400
Message-ID: <1189524230.12340.15.camel@moss-terrapins.epoch.ncsc.mil>
References: <1189459543.7914.16.camel@moss-terrapins.epoch.ncsc.mil>
	<1189515746.12340.4.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110800g558b1fect5f84ea20e25efc7b@mail.gmail.com>
	<1189523208.12340.10.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110824t60745764l3fc63a393d51b0b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4d569c330709110824t60745764l3fc63a393d51b0b9@mail.gmail.com>
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

I am trying to figure out exactly what this function is doing. I think
it might be best to precalculate the length of the string needed to
convert this char * to hex and then use snprintf to build it here rather
than in the logging subsystem. What exactly is the data that we are
getting in via cp? Are we just getting a string of bytes that we want
printed in hex?

Dave

On Tue, 2007-09-11 at 11:24 -0400, Kevin Coffman wrote:
> On 9/11/07, David P. Quigley <dpquigl@tycho.nsa.gov> wrote:
> > Could you point me to the second in gssd that is doing this? It might be
> > better to use the print statements in a saner way.
> >
> > Dave
> 
> Agreed.  The cuprit is print_hexl() in svcgssd_proc.c, which currently
> calls printerr() multiple times.  I'll look to see if I can find other
> instances that might be depending on the line acculation of printerr.
