From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] direct-IO API change
Date: Fri, 4 Oct 2002 16:44:46 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0210041644050.2526-100000@home.transmeta.com>
References: <3D9E25A7.B3E13D8@digeo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Janet Morgan <janetmor@us.ibm.com>,
        Chuck Lever <cel@citi.umich.edu>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from neon-gw-l3.transmeta.com ([63.209.4.196] helo=neon-gw.transmeta.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17xc5x-000601-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Oct 2002 16:42:57 -0700
To: Andrew Morton <akpm@digeo.com>
In-Reply-To: <3D9E25A7.B3E13D8@digeo.com>
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


On Fri, 4 Oct 2002, Andrew Morton wrote:
> 
> > Especially since I thought that O_DIRECT on the regular file (or block
> > device) performed about as well as raw does anyway these days? Or is that
> > just one of my LSD-induced flashbacks?
> > 
> 
> Now we're not holding i_sem for O_DIRECT writes to blockdevs,
> I don't think the raw driver offers any advantages at all.  It's
> a compatibility thing to save people from having to add "|O_DIRECT" to
> their source and then typing `ln -s /dev/hda1 /dev/raw/raw0'.

Maybe the raw driver could become a shell that just adds the O_DIRECT? 
Unless it can do something more, of course..

		Linus



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
