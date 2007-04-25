From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS with Dynamic IP clients
Date: Tue, 24 Apr 2007 19:45:57 -0700
Message-ID: <1177469157.11257.28.camel@heimdal.trondhjem.org>
References: <002801c786ab$e934cdf0$0202a8c0@artemis>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Alexandre DELAY <alexandre.delay@free.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgXNY-0005Ht-Gh
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 19:37:12 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18d6mF94HsabDxKhM4um5LEEjLp+OusGno=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HgXNa-0007tH-Rq
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 19:37:15 -0700
In-Reply-To: <002801c786ab$e934cdf0$0202a8c0@artemis>
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

On Tue, 2007-04-24 at 22:05 +0200, Alexandre DELAY wrote:
> Hi
> 
> I am searching for a solution to my problem.
> 
> I have a fixed NFS server connected to Internet. Clients (There will
> be ~300 NFS connected clients) have dynamic public IP addresses.
> 
> How can I setup my server and clients?

If they are all on the same private subnet then just use the standard IP
subnet syntax as described in 'man 5 exports'.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
