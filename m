From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 3/4] Add /proc/sys/fs/nfs sysctls to nfsd module
Date: Fri, 04 Aug 2006 18:43:01 +1000
Message-ID: <1154680981.21040.2415.camel@hole.melbourne.sgi.com>
References: <20060803110538.GA17173@suse.de>
	<76bd70e30608030952p15e1500cy191b5ef19241b58e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8vGw-0000ec-JQ
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 01:43:10 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G8vGv-0004by-UT
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 01:43:11 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30608030952p15e1500cy191b5ef19241b58e@mail.gmail.com>
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

On Fri, 2006-08-04 at 02:52, Chuck Lever wrote:
> On 8/3/06, Olaf Kirch <okir@suse.de> wrote:
> > From: okir@suse.de
> > Subject: Add /proc/sys/fs/nfs sysctls to nfsd module
> >
> >   This patch adds the plumbing for adding nfs-specific sysctls to fs/nfs,
> >   and makes the max size of a readdirplus reply tunable.
> >
> >   The reason for this is that we found that some clients do not seem
> >   to grok readdirplus replies larger than 4K. Rather than reducing the
> >   overall number this sysctl allows admins to work around these clients.

Neat.

> > --- linux-2.6.18.orig/fs/nfsd/nfs3xdr.c
> > +++ linux-2.6.18/fs/nfsd/nfs3xdr.c
> > @@ -573,7 +576,7 @@ nfs3svc_decode_readdirplusargs(struct sv
> >         args->dircount = ntohl(*p++);
> >         args->count    = ntohl(*p++);
> >
> > -       len = (args->count > NFSSVC_MAXBLKSIZE) ? NFSSVC_MAXBLKSIZE :
> > +       len = (args->count > nfsd_readdirplus_max) ? nfsd_readdirplus_max :
> >                                                   args->count;
> >         args->count = len;
> >

Neil, a headsup: this hunk clashes with one in the server large
wsize patch, and will require minor and obvious manual adjustment.

> I don't recall the history of /proc/sys/fs -- is there also a
> /proc/sys/fs/nfsd directory, 

No.

> and wouldn't it be better to add this
> particular sysctl in there?

I'd be happy to see such a thing.  One of my pending patches adds
serverside sysctls; it feels wrong putting them in /proc/sys/fs/nfs/.
OTOH that directory already has four serverside NLM entries that
people do use.

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
