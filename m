From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NAS server avalanche overload
Date: Wed, 03 Mar 2004 21:17:31 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078366650.7818.20.camel@nidelv.trondhjem.org>
References: <1078302718.825.67.camel@localhost>
	 <1078351343.821.28.camel@localhost>  <20040304000438.GA25910@sgi.com>
	 <1078359638.813.71.camel@localhost>  <404688FE.69592A2A@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Erik Walthinsen <omega@pdxcolo.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyiWD-0000RB-Iu
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 18:23:25 -0800
Received: from dh197.citi.umich.edu
	([141.211.133.197] helo=nidelv.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1AyiQa-00055D-Mv
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 18:17:36 -0800
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <404688FE.69592A2A@melbourne.sgi.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

P=E5 on , 03/03/2004 klokka 20:40, skreiv Greg Banks:

> > > The problem I've seen is that the data is written out from the page
> > > cache with the BKL held, which prevents any nfsd thread from waking u=
p
> > > and responding to incoming requests, and NFS traffic drops to zero.
> > > In addition, if any of the nfsd's owned some other lock when this
> > > happened, some local processes can be blocked too.  This is an
> > > inevitable result of the "async" export option.
> > That sounds like the kind of scenario I've been imagining.  Are there
> > any (stable) patches to get rid of the BKL in this case,=20
>=20
> Not AFAIK.  Trond?  It would in any case be a fairly adventurous patch.

I'm not aware of anything, but this is more of a question for Neil.

I *really* doubt anyone has bothered to do it for 2.4.x...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
