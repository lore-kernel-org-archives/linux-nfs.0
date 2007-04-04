From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd and statd
Date: Wed, 04 Apr 2007 08:40:26 -0400
Message-ID: <1175690426.6118.6.camel@heimdal.trondhjem.org>
References: <57bc13580704040011u3058e6d9wd0d4fc0de63d4d93@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Greg Bradner <greg.bradner@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HZ4my-0001HB-Cm
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 05:40:39 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19zth4DsYbXZH8Thbns96pUe1agEDHLHdE=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HZ4mz-0005e6-B5
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 05:40:38 -0700
In-Reply-To: <57bc13580704040011u3058e6d9wd0d4fc0de63d4d93@mail.gmail.com>
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

On Wed, 2007-04-04 at 00:11 -0700, Greg Bradner wrote:
> I'm getting these errors in the syslog:
> Apr  4 00:08:53 fbs2 kernel: statd: server localhost not responding, timed out
> Apr  4 00:08:53 fbs2 kernel: lockd: cannot monitor fnas2
> Apr  4 00:08:53 fbs2 kernel: lockd: failed to monitor fnas2
> 
> 
> I'm using the 2.6.20.4 kernel.
> 
> I don't see any statd.c in the src tree.
> 
> Did I miss something Ideas?

statd lives in userland, and is part of the nfs-utils package. It should
be pretty standard in all distributions that claim to support nfs.

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
