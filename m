From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: Millions of files and directory caching.
Date: Mon, 21 Oct 2002 14:34:50 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021021143450.E1944@vestdata.no>
References: <086801c278c7$fd7e19c0$6801a8c0@c1886657a>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from stine.vestdata.no ([195.204.68.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 183blu-0000lp-00
	for <nfs@lists.sourceforge.net>; Mon, 21 Oct 2002 05:35:02 -0700
To: Matt Heaton <admin@0catch.com>
In-Reply-To: <086801c278c7$fd7e19c0$6801a8c0@c1886657a>; from admin@0catch.com on Mon, Oct 21, 2002 at 12:06:26AM -0600
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, Oct 21, 2002 at 12:06:26AM -0600, Matt Heaton wrote:
> 1) Can I increase the cache on the client side to hold the entire=20
> directory structure of both NFS servers?

If your files don't change to often you can extend the NFS cache timers.
See the manpage for mount-options.

> 2) How can I tell if I am just maxing the seek time out on my NFS serve=
r?
iostat?

> 3) Each NFS server serves about 60-100 files per second.  Is this too m=
any per second?  Could I possibly be maxing
> out seek time on the NFS servers?  My IDE Raid card is the 3ware 750 wi=
th 8 individual IDE ports on it.

All the metadata should be cached on the server; how much RAM does your
nfs-servers have?

> 4) Is there anything like cachefs being developed for linux??  Any othe=
r=20
> suggestions for persistent client caching for NFS?
> Free or commercial is fine.

I have only bad experiences with (solaris) cachefs, so I'm not sure
that's it's a goal to develop something exactly like it :)
Anyway; there are lots of alternatives for client-side cache. NFSv4 will
allow better caching - not sure if the current patch-set implements this
though. Inter-mezzo and coda are other attractive alternatives.
Feel free to contact me off the list for more info.


Of course the obvious solution is to have a set of web-proxies in front
of your web-servers, but I guess there is a reason why you're not doing
that...



--=20
Ragnar Kj=F8rstad
Big Storage



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
