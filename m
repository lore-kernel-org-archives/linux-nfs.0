From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: sco 5(server) linux(client,
	FC4) cp stalls after a few	ten KBs
Date: Tue, 12 Dec 2006 20:58:35 -0500
Message-ID: <1165975115.5695.21.camel@lade.trondhjem.org>
References: <457F5AE6.90900@gamebox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuJOX-00068H-MQ
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 17:58:53 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+r1k2kHgdv8FrN8rqtyozjTCvxPekZN5A=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GuJOX-0005Vn-9o
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 17:58:54 -0800
To: Georg Ritter <newsgr.2007@gamebox.net>
In-Reply-To: <457F5AE6.90900@gamebox.net>
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

On Wed, 2006-12-13 at 02:44 +0100, Georg Ritter wrote:
> Dear NFS gurus :-),
> 
> Problem:
> FC4 box as client to a SCO 5 server stops copying after a few 10 KBs, worked on 
> same hardware with RH9 as client, and currently still works for a mdk10 client.
> 
> I would be grateful for a hint or better a way to fix it, as I have no idea of 
> what else could be wrong and where/how to investigate it further.

How about starting with a tcpdump of the client and server behaviour?
Also, when forcing tcp mounts, you can use 'netstat -t' to monitor the
TCP link.

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
