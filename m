From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Fri, 05 Mar 2004 23:15:46 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078546545.4847.70.camel@nidelv.trondhjem.org>
References: <20040306035627.79190.qmail@web12822.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Shantanu Goel <Shantanu.Goel@lehman.com>, Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>, Charles Lever <Charles.Lever@netapp.com>, Olaf Kirch <okir@suse.de>, Greg Banks <gnb@melbourne.sgi.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AzTL0-00033j-PW
	for nfs@lists.sourceforge.net; Fri, 05 Mar 2004 20:22:58 -0800
Received: from dh197.citi.umich.edu
	([141.211.133.197] helo=nidelv.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1AzTEA-0007pD-U0
	for nfs@lists.sourceforge.net; Fri, 05 Mar 2004 20:15:55 -0800
To: Shantanu Goel <sgoel01@yahoo.com>
In-Reply-To: <20040306035627.79190.qmail@web12822.mail.yahoo.com>
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

P=E5 fr , 05/03/2004 klokka 22:56, skreiv Shantanu Goel:
> > Were there any other cases that I missed?
>=20
> The only other one I can see is nfs_writepage_sync().=20

Doh... Right you are. I shouldn't be checking code on a full stomach...

> One more thing I just noticed in nfs_writepages(), the
> return status of nfs_wait_on_write_congestion() is not
> checked.  Do we want to ignore signals here?

The return value will always be zero, since nfs_write_congestion() is
called with "intr" set to 0. My gut feeling here is that pdflush et al.
should ignore signals. If they don't then we will end up with a memory
leak.

I'm open to being persuaded that this might be wrong, though...

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
