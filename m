From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 000 of 11] knfsd: NUMAisation
Date: Thu, 27 Jul 2006 10:47:00 +1000
Message-ID: <1153961220.21040.1648.camel@hole.melbourne.sgi.com>
References: <1153805274.21040.38.camel@hole.melbourne.sgi.com>
	<17605.50325.842862.8823@cse.unsw.edu.au>
	<76bd70e30607250705h3e8c9eefjc794397e0c45a21b@mail.gmail.com>
	<D29213A6-C328-4C88-8D6D-428F3FDF4F56@rgmadvisors.com>
	<76bd70e30607250836v35110d6eo20043dccc4d284b7@mail.gmail.com>
	<1153895119.21040.494.camel@hole.melbourne.sgi.com>
	<76bd70e30607261126s28003af9neae6366f001fefe3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Paul Jimenez <pj@rgmadvisors.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G64q7-00029v-Vz
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 05:19:44 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G64q1-0004iJ-NQ
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 05:19:39 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1G5u1x-0005W0-EW
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 17:47:13 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30607261126s28003af9neae6366f001fefe3@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2006-07-27 at 04:26, Chuck Lever wrote:
> On 7/26/06, Greg Banks <gnb@melbourne.sgi.com> wrote:
> > On Wed, 2006-07-26 at 01:36, Chuck Lever wrote:
> > > On 7/25/06, Paul Jimenez <pj@rgmadvisors.com> wrote:
> > > >
> > > My vote is to zap the least recently used connection.  That is overall
> > > the safest compromise.
> >
> > Agreed.  The following patch (on top of my earlier patch 001) does
> > that.  I've verified that it enforces the connection limit and
> > doesn't kill the oldest socket.
> 
> Looks like you're only dropping sockets that aren't registered with
> the local portmapper.

Yes, I've preserved that logic.

>   Should you do something similar for the
> permanent sockets,

No.

>  or am I missing something?

At this time there are two permanent sockets: the UDP socket and
the TCP rendezvous socket (i.e. the one in LISTEN state).  Neither
of these is ever connected; neither should they ever be dropped
(because they're holding their respective ports, and dropping
them might allow a userspace program to bind to those ports,
which would be a security issue).

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
