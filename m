From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: [PATCH 2.6.3] Add write throttling to NFS client
Date: Wed, 03 Mar 2004 21:13:57 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078366437.7818.16.camel@nidelv.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435DCCF@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Shantanu Goel <sgoel01@yahoo.com>, Shantanu Goel <Shantanu.Goel@lehman.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyiSr-0008Fv-E9
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 18:19:57 -0800
Received: from dh197.citi.umich.edu
	([141.211.133.197] helo=nidelv.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1Ayi3w-0005Pf-PF
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 17:54:12 -0800
To: Charles Lever <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DCCF@lavender-fe.eng.netapp.com>
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

P=E5 on , 03/03/2004 klokka 21:08, skreiv Lever, Charles:
> > BTW, there was a one line nfs_rename fix I sent a
> > while back.  At the time 2.6.0 was in freeze so it
> > couldn't be integrated.  The issue was the NFS client
> > does not refresh attributes after a rename causing
> > some programs to spew out bogus errors.  One such
> > culprit is GNU tar.
>=20
> that fix is appropriate for 2.4, but trond tells me
> that his attribute cache fixes will address this issue
> in 2.6.

...and if it doesn't I definitely want to know...

Note that attribute caching patch is already queued up in Andrew's
2.6.4-rc1-mm2 patch...

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
