From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: libtirpc and nis
Date: Thu, 04 Jun 2009 11:17:19 -0400
Message-ID: <1244128639.5203.44.camel@heimdal.trondhjem.org>
References: <200906031002.38551.vapier@gentoo.org>
	 <200906031844.34398.vapier@gentoo.org>
	 <047CD688-878B-4504-BD59-3C0B65C1B631@oracle.com>
	 <200906032012.21876.vapier@gentoo.org> <4A279C05.9030108@RedHat.com>
	 <CB7FE21D-FDC3-4D55-9D44-B78A065F057C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steve Dickson <SteveD@redhat.com>,
	Mike Frysinger <vapier@gentoo.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	libtirpc <libtirpc-devel@lists.sourceforge.net>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:41342 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753580AbZFDPRa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2009 11:17:30 -0400
In-Reply-To: <CB7FE21D-FDC3-4D55-9D44-B78A065F057C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-06-04 at 10:28 -0400, Chuck Lever wrote:
> On Jun 4, 2009, at 6:03 AM, Steve Dickson wrote:
> 
> >
> >
> > Mike Frysinger wrote:
> >> On Wednesday 03 June 2009 19:59:09 Chuck Lever wrote:
> >>> On Jun 3, 2009, at 6:44 PM, Mike Frysinger wrote:
> >>>> On Wednesday 03 June 2009 11:14:44 Steve Dickson wrote:
> >>>>> Mike Frysinger wrote:
> >>>>>> the libtirpc package is self described as a "standalone  
> >>>>>> package".  i
> >>>>>> wonder how far that actually goes.  wrt NIS, it requires the
> >>>>>> system C
> >>>>>> library to provide NIS functionality or you get a build failure  
> >>>>>> in
> >>>>>> a few
> >>>>>> files.  would be nice if libtirpc were usable without any NIS
> >>>>>> baggage at
> >>>>>> all.
> >>>>> NIS used RPC procedures to communicate. As it stands today
> >>>>> NIS is currently using the RPC procedures glibc. In the
> >>>>> future there is a very good chance that NIS will start
> >>>>> using the RPC procedures in libtirpc especially if
> >>>>> IPV6 support is needed...
> >>>>>
> >>>>> So I'm a bit confused on what you mean by "NIS baggage"
> >>>>> in the libtirpc package.
> >>>> you cannot build libtirpc on a system that doesnt provide NIS
> >>>> functionality.
> >>>> realistic RPC usage today is NFS related services only (i.e. a NFS
> >>>> client
> >>>> mounting a share on a NFS server).
> >>> Mike, it would help if you could provide the build output so we can
> >>> see exactly what's failing.
> >>
> >> libtirpc does not provide rpcsvc/nis.h
> >
> > Hmm... I wonder what it would take to incorporate that file into
> > libitrpc...
> 
> Alternately, you could disable auth_des on systems that don't already  
> have NIS.

Why? It isn't using any NIS functionality here. All that is being done
is to store information in a structure. The following definition is
literally all that should be needed in order to make auth_des work:

typedef char *nis_name;
struct nis_server {
        nis_name name;
        struct {
                u_int ep_len;
                endpoint *ep_val;
        } ep;
        uint32_t key_type;
        netobj pkey;
};
typedef struct nis_server nis_server;

If you want, I can write you a spec, and you can sit down and reverse
engineer it...

Trond.

