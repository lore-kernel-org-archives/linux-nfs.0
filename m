From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Fri, 05 Mar 2004 22:42:48 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078544568.4847.52.camel@nidelv.trondhjem.org>
References: <20040306021648.85080.qmail@web12824.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Shantanu Goel <Shantanu.Goel@lehman.com>, Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>, Charles Lever <Charles.Lever@netapp.com>, Olaf Kirch <okir@suse.de>, Greg Banks <gnb@melbourne.sgi.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AzSp8-0003LZ-5E
	for nfs@lists.sourceforge.net; Fri, 05 Mar 2004 19:50:02 -0800
Received: from dh197.citi.umich.edu
	([141.211.133.197] helo=nidelv.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1AzSNH-0005Dv-Gh
	for nfs@lists.sourceforge.net; Fri, 05 Mar 2004 19:21:15 -0800
To: Shantanu Goel <sgoel01@yahoo.com>
In-Reply-To: <20040306021648.85080.qmail@web12824.mail.yahoo.com>
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

P=E5 fr , 05/03/2004 klokka 21:16, skreiv Shantanu Goel:
> I was looking through fs/nfs/write.c and noticed
> nfs_end_data_update() is only called when a write is
> successful.  Is that intentional?  I see the potential
> for the update count to never be decremented in case
> of errors.  I noticed, for comparision, operations in
> dir.c call it regardless of the RPC's outcome.  Am I
> missing something?

In nfs_writepage_async()? Yep, that's a bug... Thanks for spotting it!

Were there any other cases that I missed?

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
