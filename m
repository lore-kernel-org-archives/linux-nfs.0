From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RedHat Rawhide Kernels
Date: Thu, 8 Aug 2002 23:16:17 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15698.57249.605357.32060@charged.uio.no>
References: <Pine.LNX.4.44.0208082017590.23326-100000@xpc1.ast.cam.ac.uk>
	<20020808153331.F28223@redhat.com>
	<shs65ylm7hp.fsf@charged.uio.no>
	<20020808162326.G28223@redhat.com>
	<15698.54589.795037.127176@charged.uio.no>
	<20020808165712.H28223@redhat.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cudz-0001iR-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Aug 2002 14:16:31 -0700
To: Benjamin LaHaise <bcrl@redhat.com>
In-Reply-To: <20020808165712.H28223@redhat.com>
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

     > That is the list of patches applied to 2.4.18-5.  Sorry for not
     > being clear on that.

Duh... My mistake I didn't read your mail clearly enough...

I know of 1 possible hang in that patchset (a hang which also affects
the standard 2.4.19 kernel): The spinlock in xprt_write_space() needs
to be converted to a bh-safe spinlock. The race should be very rare,
but definitely exists (it's been fixed BTW in the newer patchset)...

Do you have any details on the hangs in question that might help?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
