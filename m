From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] direct-IO API change
Date: Fri, 04 Oct 2002 16:35:03 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D9E25A7.B3E13D8@digeo.com>
References: <3D9E1847.F6DDA3AE@digeo.com> <Pine.LNX.4.44.0210041621170.2526-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <cel@citi.umich.edu>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from packet.digeo.com ([12.110.80.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17xbyU-0005L7-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Oct 2002 16:35:14 -0700
Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id QAA15018
	for <nfs@lists.sourceforge.net>; Fri, 4 Oct 2002 16:35:08 -0700 (PDT)
To: Linus Torvalds <torvalds@transmeta.com>,
        Badari Pulavarty <pbadari@us.ibm.com>,
        Janet Morgan <janetmor@us.ibm.com>
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

Linus Torvalds wrote:
> 
> On Fri, 4 Oct 2002, Andrew Morton wrote:
> >
> > Because the file handle which we have is for /dev/raw/raw0,
> > not for /dev/hda1.
> >
> > The raw driver binds to major/minor, not a file*.  I considered
> > changing that (change userspace to pass the open fd).  But didn't.
> 
> Ok. I'd really rather have a cleaner internal API and break the raw driver
> for a while, than have a silly API just because the raw driver uses it.

OK - bust it.

> Especially since I thought that O_DIRECT on the regular file (or block
> device) performed about as well as raw does anyway these days? Or is that
> just one of my LSD-induced flashbacks?
> 

Now we're not holding i_sem for O_DIRECT writes to blockdevs,
I don't think the raw driver offers any advantages at all.  It's
a compatibility thing to save people from having to add "|O_DIRECT" to
their source and then typing `ln -s /dev/hda1 /dev/raw/raw0'.

I think we can probably delete the raw driver.  But I've Cc'ed Janet
and Badari to find out why that's wrong.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
