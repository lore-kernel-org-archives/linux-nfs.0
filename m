From: Andrew Morton <akpm@digeo.com>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Thu, 19 Sep 2002 18:09:34 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D8A754E.5BA2E28D@digeo.com>
References: <3D89176B.40FFD09B@digeo.com.suse.lists.linux.kernel> <20020919.221513.28808421.taka@valinux.co.jp.suse.lists.linux.kernel> <3D8A36A5.846D806@digeo.com.suse.lists.linux.kernel> <p73lm5xtqyv.fsf@oldwotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, alan@lxorguk.ukuu.org.uk,
        davem@redhat.com, neilb@cse.unsw.edu.au, linux-kernel@vger.kernel.org,
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from packet.digeo.com ([12.110.80.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sCIl-0004Lw-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 18:09:47 -0700
Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id SAA19749
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 18:09:40 -0700 (PDT)
To: Andi Kleen <ak@suse.de>
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

Andi Kleen wrote:
> 
> Andrew Morton <akpm@digeo.com> writes:
> 
> > Hirokazu Takahashi wrote:
> > >
> > > ...
> > > > It needs redoing.  These differences are really big, and this
> > > > is the kernel's most expensive function.
> > > >
> > > > A little project for someone.
> > >
> > > OK, if there is nobody who wants to do it I'll do it by myself.
> >
> > That would be fantastic - thanks.  This is more a measurement
> > and testing exercise than a coding one.  And if those measurements
> > are sufficiently nice (eg: >5%) then a 2.4 backport should be done.
> 
> Very interesting IMHO would be to find a heuristic to switch between
> a write combining copy and a cache hot copy. Write combining is good
> for blasting huge amounts of data quickly without killing your caches.
> Cache hot is good for everything else.

I expect that caching userspace and not pagecache would be
a reasonable choice.

> But it'll need hints from the higher level code. e.g. read and write
> could turn on write combining for bigger writes (let's say >8K)
> I discovered that just unconditionally turning it on for all copies
> is not good because it forces data out of cache. But I still have hope
> that it helps for selected copies.

Well if it's a really big read then bypassing the CPU cache on
the userspace-side buffer would make sense.

Can you control the cachability of the memory reads as well?

What restrictions are there on these instructions?  Would
they force us to bear the cost of the aligment problem?


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
