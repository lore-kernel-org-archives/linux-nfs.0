From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3/4] Add /proc/sys/fs/nfs sysctls to nfsd module
Date: Fri, 04 Aug 2006 11:36:37 -0400
Message-ID: <1154705797.4727.18.camel@localhost>
References: <20060803110538.GA17173@suse.de>
	<76bd70e30608030952p15e1500cy191b5ef19241b58e@mail.gmail.com>
	<1154680981.21040.2415.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G91jM-0003oJ-6t
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 08:36:56 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G91jM-00088F-6S
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 08:36:56 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1154680981.21040.2415.camel@hole.melbourne.sgi.com>
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

On Fri, 2006-08-04 at 18:43 +1000, Greg Banks wrote:
> On Fri, 2006-08-04 at 02:52, Chuck Lever wrote:
> > On 8/3/06, Olaf Kirch <okir@suse.de> wrote:
> > > From: okir@suse.de
> > > Subject: Add /proc/sys/fs/nfs sysctls to nfsd module
> > >
> > >   This patch adds the plumbing for adding nfs-specific sysctls to fs/nfs,
> > >   and makes the max size of a readdirplus reply tunable.
> > >
> > >   The reason for this is that we found that some clients do not seem
> > >   to grok readdirplus replies larger than 4K. Rather than reducing the
> > >   overall number this sysctl allows admins to work around these clients.
> 
> Neat.

Not really. It would be better to identify and fix the buggy clients
that aren't setting the READDIRPLUS maxcount parameter correctly.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
