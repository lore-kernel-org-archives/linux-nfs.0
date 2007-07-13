From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH/RFC] Return ENOSPC and EDQUOT for
	nfs	writes	earlier.
Date: Fri, 13 Jul 2007 17:12:49 -0400
Message-ID: <1184361169.30876.180.camel@heimdal.trondhjem.org>
References: <18069.29184.792156.782358@notabene.brown>
	<1184272296.30876.159.camel@heimdal.trondhjem.org>
	<4697B372.4080003@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9SRf-0005W3-SL
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 14:13:00 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19rkOoe9ylwjnR0LkozGg+TSl05D4w3OEk=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9SRi-0007Yi-UO
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 14:13:03 -0700
In-Reply-To: <4697B372.4080003@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-07-13 at 13:16 -0400, Chuck Lever wrote:
> OK, but...
> 
> After it is triggered by a write error, how would the synchronous 
> behavior be turned off?  Both EDQUOT and ENOSPC, for example, are really 
> a temporary error; if applications are smart enough, they can retry an 
> EDQUOT and might get a successful write.  In that case, performance 
> would be hosed until.... the client decides it's OK to use unstable 
> writes again.

Just as Neil said: you disable the forced synchronous behaviour upon the
first successful write. Obviously, it would be quite simple for the
application to hose this heuristic. You could do so trivially by writing
one byte at a time in order to get the error cleared, and then try to
build up a large asynchronous write backlog.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
