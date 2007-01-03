From: "howard chen" <howachen@gmail.com>
Subject: Re: NFS has caching?
Date: Wed, 3 Jan 2007 10:28:55 +0800
Message-ID: <b66ddc900701021828x49f9d5a2ya83fd946260dcb27@mail.gmail.com>
References: <b66ddc900612281822n3df54e44se296b937b58d158@mail.gmail.com>
	<1167389481.6106.54.camel@lade.trondhjem.org>
	<b66ddc900612290712r6944954cy2739b657efaae14c@mail.gmail.com>
	<1167785323.6090.128.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H1vs8-0004Uc-3d
	for nfs@lists.sourceforge.net; Tue, 02 Jan 2007 18:28:56 -0800
Received: from ug-out-1314.google.com ([66.249.92.170])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H1vs8-0001GV-G4
	for nfs@lists.sourceforge.net; Tue, 02 Jan 2007 18:28:57 -0800
Received: by ug-out-1314.google.com with SMTP id z38so5019248ugc
	for <nfs@lists.sourceforge.net>; Tue, 02 Jan 2007 18:28:55 -0800 (PST)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1167785323.6090.128.camel@lade.trondhjem.org>
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

On 1/3/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Fri, 2006-12-29 at 23:12 +0800, howard chen wrote:
>
> > short questions:
> >
> > 1. are they enabled by default in Linux?
>
> It is impossible to turn off caching.
>
> > 2. is it possible to config. the cache size? for example, i have 100GB
> > files in NFS, sometimes i want the client to cache as much as
> > possible, while sometimes i want to limit the disk space usage, say to
> > 1GB cache.
>
> No you don't. Memory is managed by the kernel, not by userspace.
>
> If the memory is not needed for other tasks, then it will cache whatever
> filesystem data it held previously. If the memory is needed for other
> tasks, then the kernel will reclaim it from the page cache.
> You do have a few knobs for tweaking that reclaim algorithm
> in /proc/sys/vm (see /usr/src/linux/Documentation/filesystems/proc.txt)
> but you cannot use that to limit the cache size.
>
> Trond
>
>

so it that mean cacheing is done by the FS, nothing can be done on NFS
to improve the performance?

thanks...

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
