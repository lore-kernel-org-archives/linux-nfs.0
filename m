From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 'random' diskless clients hangs
Date: 05 Sep 2003 15:50:34 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsn0djm2ut.fsf@charged.uio.no>
References: <NEBBIHNAFKJAFOHBHGCOKEJGEFAA.nfsmailinglist@heessels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19vMbd-0005pp-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Sep 2003 12:50:53 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19vMbd-0004Om-22
	for nfs@lists.sourceforge.net; Fri, 05 Sep 2003 12:50:53 -0700
To: <nfsmailinglist@heessels.com>
In-Reply-To: <NEBBIHNAFKJAFOHBHGCOKEJGEFAA.nfsmailinglist@heessels.com>
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

>>>>> " " == nfsmailinglist  <nfsmailinglist@heessels.com> writes:

     > The clients still hang every few hours. There is nothing in the
     > logs.  When we change the rsize and wsize to 2048, the cleint
     > no longer crash but clients and server because extremely slow.

That is usually a sign of a networking problem. What kind of
NIC+driver are you using on the clients?

Also, what does that 'custom' mean on you client kernels? Have you
done anything other than to enable nfsroot?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
