From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Thu, 04 Mar 2004 21:22:01 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078453320.4865.3.camel@nidelv.trondhjem.org>
References: <20040303235442.31317.qmail@web12826.mail.yahoo.com>
	 <1078359500.7818.12.camel@nidelv.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Shantanu Goel <Shantanu.Goel@lehman.com>, Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>, Charles Lever <Charles.Lever@netapp.com>, Olaf Kirch <okir@suse.de>, Greg Banks <gnb@melbourne.sgi.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Az54q-0001B0-Ml
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 18:28:40 -0800
Received: from dh197.citi.umich.edu
	([141.211.133.197] helo=nidelv.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1Az4yd-00052Z-OA
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 18:22:15 -0800
To: Shantanu Goel <sgoel01@yahoo.com>
In-Reply-To: <1078359500.7818.12.camel@nidelv.trondhjem.org>
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

P=E5 on , 03/03/2004 klokka 19:18, skreiv Trond Myklebust:
> P=E5 on , 03/03/2004 klokka 18:54, skreiv Shantanu Goel:
> > You mentioned you are already in the process of
> > cleaning up some of the above.  Do you need me to
> > submit anything else?
>=20
> Nah... ...but I'll be posting a cleaned up version as soon as I'm done
> integrating it with the rest. It would be nice if you could look over
> it, and see if I haven't screwed up then...
>=20

OK. The patches have been cleaned up and should be ready for testing
now. The reason for the delay was that I had to track down a hang that
turned out to be caused by the congestion control patch that I posted.
It should be fixed now, I hope.

See http://www.fys.uio.no/~trondmy/src/Linux-2.6.x/2.6.4/

As usual, the NFS4_ALL patch contains the aggregate of all the
subpatches.

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
