From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: protocol question
Date: Wed, 26 Jul 2006 08:24:10 -0400
Message-ID: <1153916650.5656.27.camel@localhost>
References: <200607261247.35653.bernd.schubert@pci.uni-heidelberg.de>
	<1153914204.5656.13.camel@localhost>
	<200607261356.38520.bernd.schubert@pci.uni-heidelberg.de>
	<1153916394.5656.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7]
	helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6Z8o-0005YN-8m
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 13:41:02 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1G6Vsn-0000z7-Az
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 10:12:17 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G66WC-0005V9-3s
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 07:07:17 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41) id 1G5iRE-0006ht-AJ
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 05:24:33 -0700
To: bernd-schubert@gmx.de
In-Reply-To: <1153916394.5656.23.camel@localhost>
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

On Wed, 2006-07-26 at 08:20 -0400, Trond Myklebust wrote:
> Right. The inode generation number changes when the inode number is
> reused. After that, any NFS rpc request containing the filehandle with
> the old generation number should receive an immediate NFSERR3_STALE.

Oops. Actually, it would be more correct to say that the filehandle is
invalidated immediately once the file has been deleted on the server.

The generation number is there in order to ensure that the old
filehandle is not 'resurrected' when the inode number is reused.

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
