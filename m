From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS/TCP mount problem
Date: 12 Jul 2002 14:11:45 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shshej5w3ge.fsf@charged.uio.no>
References: <200207121157.g6CBvBg03130@bebop.France.Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SzH8-00008R-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Jul 2002 05:11:54 -0700
To: Tengxiao Wu - Sun Microsystems <Tengxiao.Wu@Sun.COM>
In-Reply-To: <200207121157.g6CBvBg03130@bebop.France.Sun.COM>
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

>>>>> " " == Tengxiao Wu <- Sun Microsystems <Tengxiao.Wu@Sun.COM>> writes:

     > Hi, all I am trying nfs on tcp under linux 2.4.18 side server:

The server-side TCP code has not yet made it into the standard kernel,
as you could see from your rpcinfo output:

    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp   1028  nlockmgr
    100021    3   udp   1028  nlockmgr
    100021    4   udp   1028  nlockmgr


Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Gadgets, caffeine, t-shirts, fun stuff.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
