From: Andi Kleen <ak@suse.de>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.36
Date: 20 Sep 2002 03:00:40 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <p73lm5xtqyv.fsf@oldwotan.suse.de>
References: <3D89176B.40FFD09B@digeo.com.suse.lists.linux.kernel> <20020919.221513.28808421.taka@valinux.co.jp.suse.lists.linux.kernel> <3D8A36A5.846D806@digeo.com.suse.lists.linux.kernel>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>,
	alan@lxorguk.ukuu.org.uk, davem@redhat.com, neilb@cse.unsw.edu.au,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns.suse.de ([213.95.15.193] helo=Cantor.suse.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sCA1-0002IF-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 18:00:45 -0700
To: Andrew Morton <akpm@digeo.com>
In-Reply-To: Andrew Morton's message of "19 Sep 2002 22:46:12 +0200"
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Andrew Morton <akpm@digeo.com> writes:

> Hirokazu Takahashi wrote:
> > 
> > ...
> > > It needs redoing.  These differences are really big, and this
> > > is the kernel's most expensive function.
> > >
> > > A little project for someone.
> > 
> > OK, if there is nobody who wants to do it I'll do it by myself.
> 
> That would be fantastic - thanks.  This is more a measurement
> and testing exercise than a coding one.  And if those measurements
> are sufficiently nice (eg: >5%) then a 2.4 backport should be done.

Very interesting IMHO would be to find a heuristic to switch between
a write combining copy and a cache hot copy. Write combining is good 
for blasting huge amounts of data quickly without killing your caches.
Cache hot is good for everything else.

But it'll need hints from the higher level code. e.g. read and write
could turn on write combining for bigger writes (let's say >8K) 
I discovered that just unconditionally turning it on for all copies 
is not good because it forces data out of cache. But I still have hope
that it helps for selected copies.


-Andi


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
