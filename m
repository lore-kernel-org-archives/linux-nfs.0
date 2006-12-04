From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: large files on nfs share
Date: Sun, 03 Dec 2006 21:36:37 -0500
Message-ID: <1165199797.711.114.camel@lade.trondhjem.org>
References: <941ca8f70612031233i1ccc8fddq3e27a9610f5b481a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gr3hT-000183-1Q
	for nfs@lists.sourceforge.net; Sun, 03 Dec 2006 18:36:59 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/hPld0dIpfUE0zbB53cz23a4Myro3BCKc=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gr3hT-0008CW-4D
	for nfs@lists.sourceforge.net; Sun, 03 Dec 2006 18:37:00 -0800
To: Allan Wilson <allanwilson@gmail.com>
In-Reply-To: <941ca8f70612031233i1ccc8fddq3e27a9610f5b481a@mail.gmail.com>
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

On Sun, 2006-12-03 at 14:33 -0600, Allan Wilson wrote:
> I am running a nfs server on Ubuntu Edgy and have some large movies
> stored on that box. One is 4.9GB and the other is 5.9GB. I can play
> the movies on another linux box by mounting the share or on a windows
> computer using "Windows Services for Unix" but no matter what I choose
> I can only see about 14minutes of each video before it tells me end of
> file. I have tried different players xine and mplayer both do the same
> thing. It has to be a nfs server setting but I don't know what it is.
> Any ideas? 

Are you using NFSv2 perhaps? That will only support a maximum of 2Gb
files. NFSv3 extends the protocol to support 64-bit filesizes.

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
