From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: (no subject)
Date: Wed, 26 Jul 2006 07:43:24 -0400
Message-ID: <1153914204.5656.13.camel@localhost>
References: <200607261247.35653.bernd.schubert@pci.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6QU3-0002e7-Ve
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 04:26:24 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G66uq-0000S1-3X
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 07:32:45 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41) id 1G5hnq-0007Eu-VO
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 04:43:51 -0700
To: bernd-schubert@gmx.de
In-Reply-To: <200607261247.35653.bernd.schubert@pci.uni-heidelberg.de>
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

On Wed, 2006-07-26 at 12:47 +0200, Bernd Schubert wrote:
> Hi,
> 
> I'm just looking into a nfs i/o error problem. The server for /etc is unfs3 
> and the client is 2.6.16. I need some help regarding the nfs protocol.
> 
> Probably after updating mozilla /etc/mozilla/mozillarc was rewritten, I also 
> guess the inode was recycled.
> 
> A 'ls /etc/mozilla/mozillarc' worked fine and showed the correct results.
> A 'cat /etc/mozilla/mozillarc' gave i/o errors.
> 
> Ethereal shows that the getattr gives the correct results, but the read call 
> gives an NFS3ERR_STALE. 
> Should the client in this case drop its filehandle cache and entirely 
> re-request the file from the server, or is the given i/o error ok?

The ESTALE error is usually correct. The client should not be reopening
the file unless it can guarantee that the file is the same as the one
that was originally open()ed.

> From the point of the server, I guess, it already should return the 
> NFS3ERR_STALE for the getattr call, shouldn't it? I will look into the 
> sources to see why it didn't. (unfs3 was compiled with inode generation 
> number support).

Yes. Under the close-to-open caching model, the expectation is that the
filehandle will remain valid from the moment the successful GETATTR call
is sent in the first open() request until the last call to close(). If
unfs3 is caching filehandles, then it needs to use something like
inotify in order to figure out when to invalidate its cache.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
