Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42639 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932371AbeF0LXk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Jun 2018 07:23:40 -0400
Date: Wed, 27 Jun 2018 13:23:39 +0200
From: Thorsten Kukuk <kukuk@suse.de>
To: Naruto Nguyen <narutonguyen2018@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Subject: Re: [Libtirpc-devel] [PATCH RFC] Make bindresvport(3) avoid
 IANA-assigned ports
Message-ID: <20180627112339.GA9161@suse.de>
References: <20180519203436.9560.83609.stgit@klimt.1015granger.net>
 <CANpxKHGTMfhy1HKWVxqV9XyyWW5ieL-NR7VjTZs26B5Rc6nayw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CANpxKHGTMfhy1HKWVxqV9XyyWW5ieL-NR7VjTZs26B5Rc6nayw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,

On Wed, Jun 27, Naruto Nguyen wrote:

> In this thread, as I understand this patch still does not resolve a
> problem regarding to deadlock when getservbyport can use NIS as you
> and Thorsten discussed, right? I am not quite clear about the use case
> of this deadlock so please correct me if I am wrong.

What will happen is: 
NIS asks RPC to connect to the NIS server for some informations.
RPC asks NIS for the port numbers to fullfill this request.
NIS asks RPC to connect to the NIS server to get the port numbers.
RPC asks NIS for the port numbers to fullfill this request.
NIS asks ...

Depending on which function the application called first,
and if your application is linked against libpthread,
this will end either in a deadlock or an endless recursion.

The latest libnsl has some heuristic to detect this recursion and
possible deadlocks and bails out with an error. So the application
will not crash, but the initial function call will return with an
error and not the requested informations.

> Could you please let me know which is the final solution for this
> issue, your patch or Thorsten's blacklist hack solution (SUSE 15 years
> solution), or you are investigating another solution?

Chuck is currently waiting for me that I write a manual page for this,
but I didn't found the time yet to write one ...

  Thorsten

> Thanks,
> Brs,
> Bao
> 
> 
> On 20 May 2018 at 03:39, Chuck Lever <chuck.lever@oracle.com> wrote:
> > There have been complaints over many years that bindresvport(3) can
> > bind to a reserved port that is also assigned to a well-known
> > service, preventing that service from starting as long as bindresv-
> > port's caller is still squatting on that port.  For instance:
> >
> > https://sourceware.org/bugzilla/show_bug.cgi?id=1014
> > https://bugzilla.redhat.com/show_bug.cgi?id=103401
> > https://bugzilla.novell.com/show_bug.cgi?id=262341
> > https://bugs.debian.org/638322
> > http://cyberelk.net/tim/software/portreserve/
> > https://sources.debian.org/src/glibc/2.26-3/debian/patches/any/local-bindresvport_blacklist.diff/
> >
> > statd, for example, has a long-running downcall client that can
> > squat on a reserved port for as long as the system is up. statd is
> > courteous enough to try hard to avoid choosing a well-known port
> > for its downcall client.
> >
> > bindresvport(3) is a generic API, and therefore can't simply skip
> > all ports assigned in /etc/services, as that leaves a pretty skimpy
> > set of remaining ports that can be used.
> >
> > An explicit blacklist might be used to prevent the use of just a
> > few common services. Although /etc/bindresvport.blacklist is
> > historically supported on several distributions, there have been
> > some objections to that approach in the long term:
> >
> > - It should be improved by making the blacklist a directory (say,
> >   /etc/bindresvport.blacklist.d/) so that other packages can
> >   easily insert new blacklisted ports when they are installed.
> >
> > - But it would be even nicer if there wasn't an additional adminis-
> >   trative interface, particularly one that largely duplicates what
> >   is already in /etc/services .
> >
> > Thus I'm proposing a slightly different approach: Change bindresv-
> > port(3) so it tries to skip IANA-assigned ports; if no unused port
> > is found, search again, but allow the use of IANA-assigned ports
> > this time.
> >
> > This gives reasonable avoidance behavior but still allows operation
> > when the set of unassigned ports runs out, and does not introduce
> > another administrative interface.
> >
> > See also commit c254b435007e.
> >
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > ---
> >  src/bindresvport.c |    9 ++++++++-
> >  1 file changed, 8 insertions(+), 1 deletion(-)
> >
> > Hi Naruto-
> >
> > Please apply this patch to the latest libtirpc source tree. Rebuild
> > it, then "sudo make install". Then rebuild rpcinfo to pull in the
> > rebuilt version of libtirpc.
> >
> > diff --git a/src/bindresvport.c b/src/bindresvport.c
> > index 2d8f2bc..6423afb 100644
> > --- a/src/bindresvport.c
> > +++ b/src/bindresvport.c
> > @@ -85,6 +85,7 @@ bindresvport_sa(sd, sa)
> >         socklen_t salen;
> >         int nports;
> >         int endport = ENDPORT;
> > +       int pass;
> >         int i;
> >
> >         mutex_lock(&port_lock);
> > @@ -130,11 +131,15 @@ bindresvport_sa(sd, sa)
> >          }
> >          res = -1;
> >          errno = EADDRINUSE;
> > -               again:
> > +        pass = 1;
> > +       setservent(1);
> > +again:
> >          for (i = 0; i < nports; ++i) {
> >                  *portp = htons(port++);
> >                   if (port > endport)
> >                          port = startport;
> > +               if (pass == 1 && getservbyport(*portp, NULL))
> > +                       continue;
> >                  res = bind(sd, sa, salen);
> >                 if (res >= 0 || errno != EADDRINUSE)
> >                         break;
> > @@ -144,8 +149,10 @@ bindresvport_sa(sd, sa)
> >             endport = STARTPORT - 1;
> >             nports = STARTPORT - LOWPORT;
> >             port = LOWPORT + port % (STARTPORT - LOWPORT);
> > +           pass++;
> >             goto again;
> >         }
> > +       endservent();
> >         mutex_unlock(&port_lock);
> >
> >          return (res);
> >
> 
> ------------------------------------------------------------------------------
> Check out the vibrant tech community on one of the world's most
> engaging tech sites, Slashdot.org! http://sdm.link/slashdot
> _______________________________________________
> Libtirpc-devel mailing list
> Libtirpc-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel

-- 
Thorsten Kukuk, Distinguished Engineer, Senior Architect SLES & CaaSP
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nuernberg, Germany
GF: Felix Imendoerffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nuernberg)
