From: I Lee Hetherington <ilh@sls.lcs.mit.edu>
Subject: Re: 2.4.18: NFS_ALL patch greatly hurting UDP speed
Date: Wed, 20 Mar 2002 10:39:55 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C98AD4B.8244EDC0@sls.lcs.mit.edu>
References: <3C88F8EE.86058BD5@sls.lcs.mit.edu> <shs7kollatu.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sls.lcs.mit.edu ([18.27.0.167])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16niC2-0006nq-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 07:40:02 -0800
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

Did you ever get a chance to look at the tcpdumps I sent you?

Given that UDP is now *100* times slower with NFS_ALL vs. without,
something is fishy.  We have always gotten good performance with UDP in
our network, even with the 1Gb/s to 100Mb/s switching.  Maybe our
switches have big enough buffers to deal with the peaks.

--Lee Hetherington



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
