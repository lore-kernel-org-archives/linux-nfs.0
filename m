From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: oops in rpc_pipe_release
Date: Tue, 08 Nov 2005 11:58:13 -0800
Message-ID: <1131479893.32482.45.camel@lade.trondhjem.org>
References: <436FEB9B.3010007@google.com> <4370B4E0.6090306@RedHat.com>
	 <4370F072.3090104@google.com>  <4370F56D.6090606@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vince Busam <vbusam@google.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZZbs-0004t1-UU
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 11:58:25 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EZZbp-0005MD-Mq
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 11:58:25 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4370F56D.6090606@RedHat.com>
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

On Tue, 2005-11-08 at 13:58 -0500, Steve Dickson wrote:
> 
> Vince Busam wrote:
> > I tried that with and without the linux-2.6.13-CITI_NFS4_ALL-1.dif 
> > patch, and either way it ends up causing another NULL pointer 
> > dereference in __rpc_purge_upcall after an hour or two.
> See if the attached patch helps... It makes gss_pipe_release()
> handles the fact that given pointer that are passed in
> could be NULL. This seem to fix the problem I was seeing...
> 
> Trond, Is this something that's a bit more palatable? :)

I'd rather like to find out how this is happening, and fix the root
cause. Your patch seems like a bit too much of a band-aid.

My point is that we should never want to find ourselves in the situation
that the directory is being cleared without the auth code having first
cleaned up and deleted its pipes.

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
