From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: RedHat Rawhide Kernels
Date: Thu, 8 Aug 2002 17:27:29 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020808172729.J28223@redhat.com>
References: <Pine.LNX.4.44.0208082017590.23326-100000@xpc1.ast.cam.ac.uk> <20020808153331.F28223@redhat.com> <shs65ylm7hp.fsf@charged.uio.no> <20020808162326.G28223@redhat.com> <15698.54589.795037.127176@charged.uio.no> <20020808165712.H28223@redhat.com> <15698.57249.605357.32060@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cuof-0005wv-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Aug 2002 14:27:34 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15698.57249.605357.32060@charged.uio.no>; from trond.myklebust@fys.uio.no on Thu, Aug 08, 2002 at 11:16:17PM +0200
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

On Thu, Aug 08, 2002 at 11:16:17PM +0200, Trond Myklebust wrote:
> Duh... My mistake I didn't read your mail clearly enough...
> 
> I know of 1 possible hang in that patchset (a hang which also affects
> the standard 2.4.19 kernel): The spinlock in xprt_write_space() needs
> to be converted to a bh-safe spinlock. The race should be very rare,
> but definitely exists (it's been fixed BTW in the newer patchset)...

Ah, interesting.  I'll put that into a test rpm for the people 
experiencing the problem to see if it helps.

> Do you have any details on the hangs in question that might help?

Basically, under heavy load several processes end up stuck in 
lock_page being called from generic_file_read.  The problem is 
very hard to reproduce (at least I can't on my local machines).

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
