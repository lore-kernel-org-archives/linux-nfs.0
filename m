From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: Re: [PATCH] direct-IO API change
Date: Fri, 4 Oct 2002 16:56:45 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200210042356.g94NujG24693@eng2.beaverton.ibm.com>
References: <Pine.LNX.4.44.0210041644050.2526-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@digeo.com (Andrew Morton), pbadari@us.ibm.com (Badari Pulavarty),
   janetmor@us.ibm.com (Janet Morgan), cel@citi.umich.edu (Chuck Lever),
   linux-kernel@vger.kernel.org (Linux Kernel Mailing List),
   nfs@lists.sourceforge.net (Linux NFS List)
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e2.ny.us.ibm.com ([32.97.182.102])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17xcJd-0007j8-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Oct 2002 16:57:05 -0700
To: torvalds@transmeta.com (Linus Torvalds)
In-Reply-To: <Pine.LNX.4.44.0210041644050.2526-100000@home.transmeta.com> from "Linus Torvalds" at Oct 04, 2002 03:44:46 PM PST
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

> 
> 
> On Fri, 4 Oct 2002, Andrew Morton wrote:
> > 
> > > Especially since I thought that O_DIRECT on the regular file (or block
> > > device) performed about as well as raw does anyway these days? Or is that
> > > just one of my LSD-induced flashbacks?
> > > 
> > 
> > Now we're not holding i_sem for O_DIRECT writes to blockdevs,
> > I don't think the raw driver offers any advantages at all.  It's
> > a compatibility thing to save people from having to add "|O_DIRECT" to
> > their source and then typing `ln -s /dev/hda1 /dev/raw/raw0'.
> 
> Maybe the raw driver could become a shell that just adds the O_DIRECT? 
> Unless it can do something more, of course..
> 
> 		Linus
> 
> 

Only issue would be the alignment restriction on blockdev versus raw device.

raw allows 512 byte alignment on userbuff, offset and length.

blockdevice might need  1024/2048 byte alignment.


If we get the alignment patch for DIO, this is not an issue.
(alignment patch - in case of defualt alignment problem,
go down to blkdev_hardsect_size() alignment.)

- Badari


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
