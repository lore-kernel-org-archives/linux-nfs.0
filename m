From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: question on sk_sem within svc_sendto
Date: Wed, 30 Apr 2003 20:02:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16048.4035.771425.199589@charged.uio.no>
References: <E199G1Z-0004eg-00@sc8-sf-list2.sourceforge.net>
	<BAY2-DAV28rRZ1UbDBR000085f3@hotmail.com>
	<shsllxsngts.fsf@charged.uio.no>
	<BAY2-DAV68RvTxjoay000008a4a@hotmail.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
    <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Avus-0000AZ-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Apr 2003 11:02:50 -0700
To: "Wendy Cheng" <s_wendy_cheng@hotmail.com>
In-Reply-To: <BAY2-DAV68RvTxjoay000008a4a@hotmail.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Wendy Cheng <s_wendy_cheng@hotmail.com> writes:

     > This makes sense (for me) in TCP case but how about UDP ? Does
     > the 2.5.x kernel send multiple NFS UDP packets within one reply
     > (for one single request) ?

When using MSG_MORE in order to aggregate the data, you need to ensure
that only your thread is accessing that socket. If not, another nfsd
thread may corrupt your request by injecting its payload.

So yes, in 2.5.x the semaphore is also needed for UDP.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
