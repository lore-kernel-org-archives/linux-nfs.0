From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: RH 7.3 kernels and NFS performance
Date: Wed, 7 Aug 2002 15:04:05 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020807150405.B25584@ti19>
References: <15697.18944.451371.303514@charged.uio.no> <Pine.LNX.4.44.0208071142060.1462-100000@duran.unl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 209-166-240-202.cust.walrus.com.240.166.209.in-addr.arpa ([209.166.240.202] helo=ti3.telemetry-investments.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cW6T-0002SQ-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 12:04:17 -0700
To: Rex Dieter <rdieter@math.unl.edu>
In-Reply-To: <Pine.LNX.4.44.0208071142060.1462-100000@duran.unl.edu>; from rdieter@math.unl.edu on Wed, Aug 07, 2002 at 11:43:24AM -0500
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

On Wed, Aug 07, 2002 at 11:43:24AM -0500, Rex Dieter wrote:
> I just tested things with a test kernel (2.4.18-7) from redhat, and it 
> sync write speeds were again way up there.  Problem fixed, as far as I'm 
> concerned... hopefully, they'll release an errata soon.

BTW, Arjan has included many of Trond's RPC patches in the latest
Rawhide kernels:

$ rpm -qp --changelog kernel-2.4.18-7.93.src.rpm | head -4
* Fri Aug 02 2002 Arjan van de Ven <arjanv@redhat.com>

- added most of the NFS patchkit

Based on the patch file names, these look like Trond's 2.4.19-rc3 patches:

linux-2.4.19-00-fix_clnt.patch
linux-2.4.19-01-fix_kmap1.patch
linux-2.4.19-02-fix_kmap2.patch
linux-2.4.19-03-fix_kmap3.patch
linux-2.4.19-04-rpc_rep.patch
linux-2.4.19-05-rpc_rtt1.patch
linux-2.4.19-06-rpc_rtt2.patch
linux-2.4.19-07-rpc_rtt3.patch
linux-2.4.19-08-xprt_write.patch
linux-2.4.19-09-rpc_cong1.patch
linux-2.4.19-10-rpc_cong2.patch
linux-2.4.19-11-rpc_cong3.patch
linux-2.4.19-12-rpc_wspace.patch
linux-2.4.19-13-rpc_cleanup.patch
linux-2.4.19-16-rpcbuf.patch

This should be nearly current, though Trond's 2.4.19 patches are broken
down somewhat differently.

I hope that Trond is planning to submit most of this to Marcelo for
2.4.20, as Neil is submitting his NFS server patches, and it would be
very nice to have a 2.4.20 that is fully up-to-date w.r.t current NFS
patches for both client and server.  [Those of us on this list for a
long time will remember a similar exercise with Alan for 2.2.19 --
gosh, that seems like ancient history. :-P]

In any case, Trond's work should receive some more widespread "end-user"
testing from the Limbo Beta and Rawhide crowd in the near future.

I've long pined [since RH 5.x] for a Red Hat kernel with working
NFS that played nice with the NetApp and Solaris.  It has since become
a ritual to patch NFS into the Red Hat tree.

Many thanks to Trond and Neil for their tireless efforts!

It is difficult to underestimate how important working NFS is in deployments
like ours ...

Regards

   Bill Rugolsky


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
