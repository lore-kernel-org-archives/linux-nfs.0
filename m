From: Grzegorz Tylenda <beh@freya.dsv.agh.edu.pl>
Subject: Re: nfs client performance - 2.4 vs 2.6
Date: Mon, 12 Jun 2006 11:01:47 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0606121045440.22123@freya.dsv.agh.edu.pl>
References: <Pine.LNX.4.64.0606071256140.17804@freya.dsv.agh.edu.pl>
	<1149693044.26188.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FpiJ3-0007G1-V0
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 02:01:57 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FpiJ3-0006bd-QK
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 02:01:57 -0700
Received: from freya.dsv.agh.edu.pl ([149.156.124.22] ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FpiJ1-0004tZ-9X
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 02:01:57 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1149693044.26188.3.camel@localhost>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net



On Wed, 7 Jun 2006, Trond Myklebust wrote:

>
> 2.4 kernels did not use 'access' to check for permissions except in the
> case of root access, but relied (wrongly!) on the mode bits.
>
> 2.6 kernels do use access, but are supposed to cache the results. What
> kind of a workload are you running on these clients?


These clients are webservers. All content are read from filer, where files 
do not change often.


--
best regards,
Grzesiek Tylenda



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
