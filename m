From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Trouble accessing NFS mountpoint as user
Date: Thu, 04 Jan 2007 10:09:27 +0100
Message-ID: <1167901767.6046.17.camel@lade.trondhjem.org>
References: <459CB96A.1060806@amplex.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2Obc-0005WK-HM
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 01:09:48 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+HoO2eJPNXORXXZbkw6dlAfa8JkXpEfl8=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H2Obc-0001BR-QM
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 01:09:50 -0800
To: Stephan Henningsen <sth@amplex.dk>
In-Reply-To: <459CB96A.1060806@amplex.dk>
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

On Thu, 2007-01-04 at 09:23 +0100, Stephan Henningsen wrote:
> Hi,
> 
> I'm exporting a directory on my server.  Access to the export is restricted 
>   to local users by permissions.
> 
> When I mount it as user (or root) on my client, only root has access to the 
> mountpoint.  The client user's permissions match those of the export on the 
> server.

NFS will only support a maximum of 16 supplemental groups. That is a
protocol limitation, not a Linux implementation issue. See for instance

http://nfsworld.blogspot.com/2005/03/whats-deal-on-16-group-id-limitation.html

if you want a more complete explanation of why this is the case.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
