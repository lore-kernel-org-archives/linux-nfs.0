From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Utils package testing
Date: 12 Jun 2002 14:21:39 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsy9dkwuuk.fsf@charged.uio.no>
References: <3D062664.C93B7399@attbi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17I78M-0001ZJ-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Jun 2002 05:21:54 -0700
To: Tom McNeal <trmcneal@attbi.com>
In-Reply-To: <3D062664.C93B7399@attbi.com>
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

>>>>> " " == Tom McNeal <trmcneal@attbi.com> writes:

     >  - Does locking take a much longer time in ext3 file systems,
     >    or in the patched environment?  In the patched kernel,
     >    exporting ext3, the connectathon lock tests seemed to take
     >    up to 10x as long, but that was over many hours, with a big
     >    load.  When run just once with the other connectathon tests,
     >    it didn't seem so different.

Flushing to disk would be slower with ext3. As this is done every time
somebody takes or releases a lock...

     >  - The client net statistics in /proc/net/rpc/nfs seems to remain
     >    at 0 regardless of the activity and regardless of the
     >    kernel.  I'm going to start browsing through the kernel code
     >    to see if there is something obvious, but maybe someone
     >    knows about this already.  I didn't see anything in the
     >    mailing list.

I've never touched the 'net statistics' field, and I've no idea what
it purports to measure. As far as I'm concerned it can be removed
entirely...

Cheers,
  Trond

_______________________________________________________________

Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
