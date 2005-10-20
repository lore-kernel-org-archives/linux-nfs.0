From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS port use.
Date: Thu, 20 Oct 2005 10:08:56 -0700
Message-ID: <1129828136.9882.11.camel@lade.trondhjem.org>
References: <4357C75C.8050805@sanger.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESduu-0007ZG-W7
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 10:09:24 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ESdut-0000SG-A7
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 10:09:24 -0700
To: Simon Kelley <srk@sanger.ac.uk>
In-Reply-To: <4357C75C.8050805@sanger.ac.uk>
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

to den 20.10.2005 klokka 17:35 (+0100) skreiv Simon Kelley:

> logger: tcp        0      0 bc-4-3-09.internal.:988 ecs2:sunrpc 
>     TIME_WAIT  -

This is probably the "mount" program probing the portmapper for the
supported NFS versions.

> At this point I need help: my reasoning is wrong somewhere and I can't 
> get any furher. Can anybody clarify things and tell me how to keep the 
> NFS client subsystem away from port 988?

Why can't you just ensure that start your daemon before you start NFS?

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
