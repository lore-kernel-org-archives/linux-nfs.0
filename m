From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RedHat Rawhide Kernels
Date: 08 Aug 2002 23:35:01 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shshei511bu.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0208082017590.23326-100000@xpc1.ast.cam.ac.uk>
	<20020808153331.F28223@redhat.com> <shs65ylm7hp.fsf@charged.uio.no>
	<20020808162326.G28223@redhat.com>
	<15698.54589.795037.127176@charged.uio.no>
	<20020808165712.H28223@redhat.com>
	<15698.57249.605357.32060@charged.uio.no>
	<20020808172729.J28223@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	  NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cuw9-0007A9-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Aug 2002 14:35:17 -0700
To: Benjamin LaHaise <bcrl@redhat.com>
In-Reply-To: <20020808172729.J28223@redhat.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == Benjamin LaHaise <bcrl@redhat.com> writes:

    >> Do you have any details on the hangs in question that might
    >> help?

     > Basically, under heavy load several processes end up stuck in
     > lock_page being called from generic_file_read.  The problem is
     > very hard to reproduce (at least I can't on my local machines).

The only other hang I can think of concerns only HIGHMEM machines,
where you can deadlock while exhausting all free kmap() resources.

Also fixed (well - at least chances are *very* heavily reduced) in the
new 'kmap' patchsets.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
