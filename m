From: Jim Eshleman <jce0@Lehigh.EDU>
Subject: Re: 2.4.18 rpciod oops [xdr_encode_netobj]
Date: Mon, 18 Mar 2002 11:28:21 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C9615A5.6080807@Lehigh.EDU>
References: <3C922BF6.8050405@Lehigh.EDU> <shs663vrq6t.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, linux-xfs@oss.sgi.com
Received: from rain.cc.lehigh.edu ([128.180.39.20])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16mzzn-00027p-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Mar 2002 08:28:27 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

Trond Myklebust wrote:
>>>>>>" " == Jim Eshleman <jce0@Lehigh.EDU> writes:
>>>>>
> 
>      >    FYI.  There was no apparent effect on the running system, an
>      > 8-way 8.5G (64G HIGHMEM) P3 Xeon, running 2.4.18 + XFS, NIS,
>      > NFS, sendmail, etc.  Let me know if more info is needed.
> 
> Is it repeatable on a non-XFS patched kernel?
> 
> Cheers,
>   Trond

   Unfortunately I'm not able to try a non-XFS kernel on this machine.

Jim



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
