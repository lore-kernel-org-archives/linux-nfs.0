From: Andi Kleen <ak@suse.de>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Fri, 20 Sep 2002 03:23:46 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020920032346.A22949@wotan.suse.de>
References: <3D89176B.40FFD09B@digeo.com.suse.lists.linux.kernel> <20020919.221513.28808421.taka@valinux.co.jp.suse.lists.linux.kernel> <3D8A36A5.846D806@digeo.com.suse.lists.linux.kernel> <p73lm5xtqyv.fsf@oldwotan.suse.de> <3D8A754E.5BA2E28D@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Hirokazu Takahashi <taka@valinux.co.jp>,
	alan@lxorguk.ukuu.org.uk, davem@redhat.com, neilb@cse.unsw.edu.au,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns.suse.de ([213.95.15.193] helo=Cantor.suse.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sCWP-000126-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 18:23:53 -0700
To: Andrew Morton <akpm@digeo.com>
In-Reply-To: <3D8A754E.5BA2E28D@digeo.com>
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

On Thu, Sep 19, 2002 at 06:09:34PM -0700, Andrew Morton wrote:
> > Very interesting IMHO would be to find a heuristic to switch between
> > a write combining copy and a cache hot copy. Write combining is good
> > for blasting huge amounts of data quickly without killing your caches.
> > Cache hot is good for everything else.
> 
> I expect that caching userspace and not pagecache would be
> a reasonable choice.

Normally yes, but not always. e.g. for squid you don't really want to 
cache user space.

But I guess it would be a reasonable heuristic. Or at least worth a try :-)

> 
> > But it'll need hints from the higher level code. e.g. read and write
> > could turn on write combining for bigger writes (let's say >8K)
> > I discovered that just unconditionally turning it on for all copies
> > is not good because it forces data out of cache. But I still have hope
> > that it helps for selected copies.
> 
> Well if it's a really big read then bypassing the CPU cache on
> the userspace-side buffer would make sense.
> 
> Can you control the cachability of the memory reads as well?

SSE2 has hints for that (prefetchnti and even prefetcht0,1 etc. for different
cache hierarchies), but it's not completely clear on how much
the CPUs follow these. 

For writing it's much more obvious and usually documented even.

> 
> What restrictions are there on these instructions?  Would
> they force us to bear the cost of the aligment problem?

They should be aligned, otherwise it makes no sense. When you assume it's
more likely that one target or destination are unaligned then you can easily
align either target or destination. Trick is to chose the right one,
it varies on the call site.
(these are for big copies so a small alignment function is lost in the noise)

x86-64 copy_*_user currently aligns the destination, but hardcoding that
is a bit dumb and I'm not completely happy with it.


-Andi


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
