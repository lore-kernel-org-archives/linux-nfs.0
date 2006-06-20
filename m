From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: On NFS mounted file system access time not updated
Date: Tue, 20 Jun 2006 08:47:13 -0400
Message-ID: <1150807633.14850.1.camel@lade.trondhjem.org>
References: <b01966ec0606170504p1575f325y560aa3b764dc47a2@mail.gmail.com>
	<1150660000.6771.189.camel@lade.trondhjem.org>
	<b01966ec0606190050r48757400x98945f58f1032283@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neil@brown.name, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fsfdj-0001SI-B4
	for nfs@lists.sourceforge.net; Tue, 20 Jun 2006 05:47:31 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fsfdj-0000tf-9h
	for nfs@lists.sourceforge.net; Tue, 20 Jun 2006 05:47:31 -0700
To: Nida M <nidajm@gmail.com>
In-Reply-To: <b01966ec0606190050r48757400x98945f58f1032283@mail.gmail.com>
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

On Mon, 2006-06-19 at 13:20 +0530, Nida M wrote:

>  
> How to make sure that the atime is updated for every read.

You would have to either use O_DIRECT reads (i.e. uncached reads) or you
would have to call utimes() after every read. Either way that will
seriously slow down your application.

Cheers,
  Trond



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
