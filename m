From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Wed, 03 Mar 2004 19:18:20 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078359500.7818.12.camel@nidelv.trondhjem.org>
References: <20040303235442.31317.qmail@web12826.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Shantanu Goel <Shantanu.Goel@lehman.com>, Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>, Charles Lever <Charles.Lever@netapp.com>, Olaf Kirch <okir@suse.de>, Greg Banks <gnb@melbourne.sgi.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aygew-0005im-15
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 16:24:18 -0800
Received: from dh197.citi.umich.edu
	([141.211.133.197] helo=nidelv.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1AygZM-0005AY-5z
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 16:18:32 -0800
To: Shantanu Goel <sgoel01@yahoo.com>
In-Reply-To: <20040303235442.31317.qmail@web12826.mail.yahoo.com>
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

P=E5 on , 03/03/2004 klokka 18:54, skreiv Shantanu Goel:
> >=20
> > I haven't tested it yet, though...
>=20
> Trust me, it works... ;-)

ah... Famous last words 8-)
=20
> >         - nfs_writepage_async() really doesn't need
> > a "how" parameter.
> >         It only allocates an nfs_page().
> >        =20
>=20
> I added it here because of nfs_wb_page.  If the caller
> is kswapd, wouldn't we want the resultant
> nfs_sync_file to run at higher priority?

...but that call to nfs_wb_page() is in nfs_writepage(), not in
nfs_writepage_async().

> >         - Several of those #defines really ought to
> > be inline functions.
> >        =20
>=20
> Which ones?

Most of them. See Documentation/CodingStyle. The preference is for
inlined functions, with macros being acceptable only if you can really
prove that gcc makes a pigs ear of things.
The reason for this preference is that we want proper type checking of
arguments. Headers like sched.h are included in all sorts of places, so
you really do want that...

Again, a lot of the existing header files are pretty grimy, and do need
cleaning up w.r.t. this, but that's no reason to be introducing more
badness if we can avoid it.

> You mentioned you are already in the process of
> cleaning up some of the above.  Do you need me to
> submit anything else?

Nah... ...but I'll be posting a cleaned up version as soon as I'm done
integrating it with the rest. It would be nice if you could look over
it, and see if I haven't screwed up then...

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
