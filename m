From: Ian Kent <raven@themaw.net>
Subject: Re: VFS: Busy inodes after unmount. Self-destruct in 5
 seconds. Have a nice day...
Date: Thu, 28 Dec 2006 19:32:26 +0900 (WST)
Message-ID: <Pine.LNX.4.64.0612281930120.5917@raven.themaw.net>
References: <200612281027.09783.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GzsYT-0005UB-0w
	for nfs@lists.sourceforge.net; Thu, 28 Dec 2006 02:32:09 -0800
Received: from out4.smtp.messagingengine.com ([66.111.4.28])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GzsYT-0004qx-FI
	for nfs@lists.sourceforge.net; Thu, 28 Dec 2006 02:32:10 -0800
To: Jesper Juhl <jesper.juhl@gmail.com>
In-Reply-To: <200612281027.09783.jesper.juhl@gmail.com>
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

On Thu, 28 Dec 2006, Jesper Juhl wrote:

> 
> I get this message in my webservers (with NFS mounted homedirs) logs once 
> in a while : 
> 
>   kernel: VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day...
> 
> It doesn't seem to have any bad effect on anything, but it would be nice 
> to know if there is any cause for concern.

It's at least a memory leak.

> 
> The NFS server is running 2.6.18.1 and the webservers are running 2.6.17.8

Strange, I've not heard of this message appearing for a long time now.

Ian


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
