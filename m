From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Errors ...
Date: Tue, 08 Nov 2005 08:12:45 -0800
Message-ID: <1131466365.32482.40.camel@lade.trondhjem.org>
References: <4370AB14.9020203@renatre.org.ar>
	 <1131460555.32482.4.camel@lade.trondhjem.org>
	 <4370C459.5050600@renatre.org.ar>
	 <1131465035.32482.37.camel@lade.trondhjem.org>
	 <4370CB53.2000006@renatre.org.ar>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZW5p-0003Xb-Qh
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 08:13:05 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EZW5n-0007kl-6K
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 08:13:05 -0800
To: Alan Glait <aglait@renatre.org.ar>
In-Reply-To: <4370CB53.2000006@renatre.org.ar>
Sender: nfs-admin@lists.sourceforge.net
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

On Tue, 2005-11-08 at 12:59 -0300, Alan Glait wrote:
> Ok ... when it happend i will test the comunication between the servers 
> ....

Thanks.

> I will add to the kernel :
> Provide client support for the NFSv3 ACL protocol extension
> Provide server support for the NFSv3 ACL protocol extension

This isn't really necessary unless you want to use ACLs. The server
should be able to return the appropriate error to the client, and the
client will stop probing.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
