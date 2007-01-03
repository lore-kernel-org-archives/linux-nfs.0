From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS has caching?
Date: Wed, 03 Jan 2007 01:48:43 +0100
Message-ID: <1167785323.6090.128.camel@lade.trondhjem.org>
References: <b66ddc900612281822n3df54e44se296b937b58d158@mail.gmail.com>
	<1167389481.6106.54.camel@lade.trondhjem.org>
	<b66ddc900612290712r6944954cy2739b657efaae14c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H1uJZ-0003pN-Gz
	for nfs@lists.sourceforge.net; Tue, 02 Jan 2007 16:49:09 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19mfBgfP28wO8JF03aAbIJUoKCrAGYuYi8=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H1uJZ-0001aW-Q8
	for nfs@lists.sourceforge.net; Tue, 02 Jan 2007 16:49:11 -0800
To: howard chen <howachen@gmail.com>
In-Reply-To: <b66ddc900612290712r6944954cy2739b657efaae14c@mail.gmail.com>
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

On Fri, 2006-12-29 at 23:12 +0800, howard chen wrote:

> short questions:
> 
> 1. are they enabled by default in Linux?

It is impossible to turn off caching.

> 2. is it possible to config. the cache size? for example, i have 100GB
> files in NFS, sometimes i want the client to cache as much as
> possible, while sometimes i want to limit the disk space usage, say to
> 1GB cache.

No you don't. Memory is managed by the kernel, not by userspace.

If the memory is not needed for other tasks, then it will cache whatever
filesystem data it held previously. If the memory is needed for other
tasks, then the kernel will reclaim it from the page cache.
You do have a few knobs for tweaking that reclaim algorithm
in /proc/sys/vm (see /usr/src/linux/Documentation/filesystems/proc.txt)
but you cannot use that to limit the cache size.

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
