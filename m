From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] direct-IO API change
Date: Fri, 4 Oct 2002 17:11:27 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0210041704110.2993-100000@home.transmeta.com>
References: <200210042356.g94NujG24693@eng2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@digeo.com>, Janet Morgan <janetmor@us.ibm.com>,
        Chuck Lever <cel@citi.umich.edu>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS List <nfs@lists.sourceforge.net>,
        Alexander Viro <viro@math.psu.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from neon-gw-l3.transmeta.com ([63.209.4.196] helo=neon-gw.transmeta.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17xcW0-0002sB-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Oct 2002 17:09:52 -0700
To: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <200210042356.g94NujG24693@eng2.beaverton.ibm.com>
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


On Fri, 4 Oct 2002, Badari Pulavarty wrote:
> 
> Only issue would be the alignment restriction on blockdev versus raw device.

Hmm.. We might want to revert the stuff that made the default block device 
alignment be the maximal possible, and instead make the default be the 
minimum possible.

The offending code is the "while"-loop in bd_set_size(). Just removing 
that should make the default size be the minimal one (ie hardsect_size).

It _used_ to make sense to try to maximize the block-size, since it had a
noticeable impact on performance whether we did 8 512-byte requests or
just 1 4kB request. However, all the bio changes have likely made that a
non-issue, since Andrew's code ends up doing things directly one page at a
time _anyway_.

Of course, mounting a filesystem on the device will override the default 
anyway, so this by no means will guarantee that direct access will always 
have the minimal alignment restrictions, but once you've mounted a 4kB 
blocksize filesystem on that device I think you might as well do 4kB 
chunks even if you open it through the device interface, no?

			Linus



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
