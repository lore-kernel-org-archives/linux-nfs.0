From: Bryan O'Sullivan <bos@serpentine.com>
Subject: NFS/TCP patches against 2.4.18 have problems
Date: 03 Jul 2002 16:13:13 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1025737993.1835.10.camel@plokta.s8.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from server.s8.com ([66.77.12.139])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17PtJL-00070q-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Jul 2002 16:13:23 -0700
To: trond.myklebust@fys.uio.no
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

Hi, Trond -

I've been taking a look at the following patches from your web site:

  linux-2.4.18-svc_tcp.dif.bz2
  linux-2.4.18-rpc_tweaks.dif.bz2

In the accompanying commentary, you mention that the rpc_tweaks patch
applies on top of the svc_tcp patch, but this is not the case.  I get
two very substantial rejects, in net/sunrpc/xprt.c and
include/linux/sunrpc/xprt.h.

It looks like the rpc_tweaks patch includes some fixes that were
developed in parallel, but in a different way, during 2.4.18
development.  Before I leap into figuring out how to munge the patch so
that it applies, I wanted to check if you've taken a look at the rejects
yourself.

Thanks,

	<b


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
No, I will not fix your computer.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
