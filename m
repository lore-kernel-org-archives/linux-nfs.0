From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.18 rpciod oops [xdr_encode_netobj]
Date: 17 Mar 2002 19:42:50 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs663vrq6t.fsf@charged.uio.no>
References: <3C922BF6.8050405@Lehigh.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,  linux-xfs@oss.sgi.com
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16mfcW-0001K0-00
	for <nfs@lists.sourceforge.net>; Sun, 17 Mar 2002 10:43:04 -0800
To: Jim Eshleman <jce0@Lehigh.EDU>
In-Reply-To: <3C922BF6.8050405@Lehigh.EDU>
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

>>>>> " " == Jim Eshleman <jce0@Lehigh.EDU> writes:

     >    FYI.  There was no apparent effect on the running system, an
     > 8-way 8.5G (64G HIGHMEM) P3 Xeon, running 2.4.18 + XFS, NIS,
     > NFS, sendmail, etc.  Let me know if more info is needed.

Is it repeatable on a non-XFS patched kernel?

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
