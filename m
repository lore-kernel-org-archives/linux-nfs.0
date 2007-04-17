From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: linux nfs client tcp timeout
Date: Tue, 17 Apr 2007 19:54:06 -0400
Message-ID: <1176854046.6796.2.camel@heimdal.trondhjem.org>
References: <4cf2912c0704060910n33a269f3xcce6967a3abafc92@mail.gmail.com>
	<1175980671.20878.7.camel@heimdal.trondhjem.org>
	<20070417153043.GA9616@pcnocjb.dlan.cinetic.de>
	<4cf2912c0704171019t46a53362h284f8088b4113c48@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Venkatesh KS <venkatesh.ks@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdxV6-0005v9-5G
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 16:54:20 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/jh4MMe3eQZgEWsNtOMWVghKpA8J+ElZs=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HdxV7-0004Yq-EK
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 16:54:22 -0700
In-Reply-To: <4cf2912c0704171019t46a53362h284f8088b4113c48@mail.gmail.com>
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

On Tue, 2007-04-17 at 22:49 +0530, Venkatesh KS wrote:
> My tests have shown no correlation between what the manpage says
> and nfs client behaviour.  Worse still after timeout, write system
> calls
> returns with 1024 as the number of bytes written while it should be 0.

You're supposed to check the return value of 'close()' or 'fsync()' if
you care about data integrity. The same is true of local filesystems:
write() only tells you how many bytes were written into the pagecache.
It tells you zilch about how many bytes actually hit permanent storage.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
