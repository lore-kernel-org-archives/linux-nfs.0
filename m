From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Wed, 03 Mar 2004 13:35:02 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078338902.3259.13.camel@nidelv.trondhjem.org>
References: <20040303032213.58494.qmail@web12823.mail.yahoo.com>
	 <40461CCC.5040609@lehman.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Shantanu Goel <sgoel01@yahoo.com>, Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>, Charles Lever <Charles.Lever@netapp.com>, Olaf Kirch <okir@suse.de>, Greg Banks <gnb@melbourne.sgi.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AybIi-0007lt-Ng
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 10:41:00 -0800
Received: from dh197.citi.umich.edu
	([141.211.133.197] helo=nidelv.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1AyauF-0007tU-Uw
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 10:15:44 -0800
To: Shantanu Goel <Shantanu.Goel@lehman.com>
In-Reply-To: <40461CCC.5040609@lehman.com>
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

P=E5 on , 03/03/2004 klokka 12:58, skreiv Shantanu Goel:
> Attached is a patch that eliminates nfs_strategy() and just relies on=20
> pdflush to regulate dirty pages.  It applies on top of the rpc throttle=20
> patch I emailed earlier.

See
http://www.fys.uio.no/~trondmy/src/Linux-2.6.x/2.6.3/linux-2.6.3-02-strateg=
y.dif

which already does this...

Cheers,
  Trond


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
