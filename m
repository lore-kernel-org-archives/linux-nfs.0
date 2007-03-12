From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS mount problem (2000 NFS filesystems) of linux	clients
	to a solaris server
Date: Mon, 12 Mar 2007 12:57:38 -0400
Message-ID: <1173718658.6436.27.camel@heimdal.trondhjem.org>
References: <45F004BD.1070500@biochem.mpg.de> <45F15018.1060804@biochem.mpg.de>
	<EXNANE01VuMhvqgStMV00000097@exnane01.hq.netapp.com>
	<200703091546.19536.olaf.kirch@oracle.com>
	<EXNANE01okLQ8aZRhQd00000099@exnane01.hq.netapp.com>
	<EXNANE0169aZbLAX3cf000000af@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQnqB-0006gJ-MX
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 09:57:44 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18Hiqgxh/PYLtSk+2l0OwPDOasTdqpNPMU=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQnqC-0002TG-K7
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 09:57:46 -0700
In-Reply-To: <EXNANE0169aZbLAX3cf000000af@exnane01.hq.netapp.com>
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

On Mon, 2007-03-12 at 08:35 -0400, Talpey, Thomas wrote:
> For its ten-year anniversary, is the better approach to delete this
> support from nfs-utils altogether? It means that nfs-utils >1.0.12
> won't work on early-to-mid 2.1 kernels. Which does not strike me
> as a likely issue.

The mount command _knows_ which kernel it is working on (and uses that
information to determine what revision of the mount structure to fill
in).
Why not just leave the fd argument blank for all kernels >= 2.2.0?

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
