From: "howard chen" <howachen@gmail.com>
Subject: Re: NFS has caching?
Date: Fri, 29 Dec 2006 23:12:53 +0800
Message-ID: <b66ddc900612290712r6944954cy2739b657efaae14c@mail.gmail.com>
References: <b66ddc900612281822n3df54e44se296b937b58d158@mail.gmail.com>
	<1167389481.6106.54.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H0JPj-0006ig-0Q
	for nfs@lists.sourceforge.net; Fri, 29 Dec 2006 07:12:55 -0800
Received: from ug-out-1314.google.com ([66.249.92.174])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H0JPj-0005u7-9o
	for nfs@lists.sourceforge.net; Fri, 29 Dec 2006 07:12:56 -0800
Received: by ug-out-1314.google.com with SMTP id z38so4369378ugc
	for <nfs@lists.sourceforge.net>; Fri, 29 Dec 2006 07:12:53 -0800 (PST)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1167389481.6106.54.camel@lade.trondhjem.org>
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

On 12/29/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Fri, 2006-12-29 at 10:22 +0800, howard chen wrote:
> > I have around 100 files, currently NFS shared among 5 servers, all
> > servers access the file quite frequently, e.g. 10 hits per second per
> > server.
> >
> > I cannot afford to rync since i want the delay of write as small as
> > possible, e.g. less than 1 second.
> >
> >
> > I want to know, since the file will be accessed quite frequent, does
> > NFS has build-in caching functions that if files are not modified, it
> > will not try to fetch from the network?
>
> Short answer: yes.
>
> Long answer: http://nfs.sourceforge.net/#faq_a8
>
> Trond
>
>

short questions:

1. are they enabled by default in Linux?

2. is it possible to config. the cache size? for example, i have 100GB
files in NFS, sometimes i want the client to cache as much as
possible, while sometimes i want to limit the disk space usage, say to
1GB cache.

Thanks.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
