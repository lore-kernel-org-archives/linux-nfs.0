From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Replication for NFSv4
Date: Thu, 07 Dec 2006 14:21:19 -0500
Message-ID: <1165519279.2903.8.camel@lade.trondhjem.org>
References: <20061207162620.9618182f.dn.tlp@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsOoU-0000cA-8L
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 11:21:46 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+87kpi/opESnR7DRWjt3ICZcn1qubVw2I=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsOoU-00011l-0h
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 11:21:47 -0800
To: Simon Peter <dn.tlp@gmx.net>
In-Reply-To: <20061207162620.9618182f.dn.tlp@gmx.net>
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

On Thu, 2006-12-07 at 16:26 +0100, Simon Peter wrote:
> (I crosspost this to both NFS lists, as I think it is interesting to
> readers of either one)
> 
> Hi,
> 
> I developed a replication solution for NFSv4, allowing for a wide
> variety of replication strategies to be employed with NFSv4. It is
> entirely protocol based and thus works with all NFSv4 implementations.
> 
> It is still in beta stage, but already useable. If anyone is
> interested, a preliminary website with more information can be found
> here: http://www.cs.ucr.edu/~simon/replication/

Note that we already have some of the functionality required for
replication support in the 2.6.18 client. We do not have support for
advanced features such as client failover to other replicas, though.
Does your solution implement something like that?

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
