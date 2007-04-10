From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: cel's patches under development
Date: Tue, 10 Apr 2007 17:22:12 +0200
Message-ID: <200704101722.13798.olaf.kirch@oracle.com>
References: <460852BB.4080503@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbICX-0000tF-E1
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 08:24:09 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbICY-0000oG-EX
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 08:24:11 -0700
Received: from rgmgw3.us.oracle.com (rgmgw3.us.oracle.com [138.1.186.112])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l3AFN2pk027953
	for <nfs@lists.sourceforge.net>; Tue, 10 Apr 2007 10:23:03 -0500
Received: from acsmt351.oracle.com (acsmt351.oracle.com [141.146.40.151])
	by rgmgw3.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l3AEsFFM002065
	for <nfs@lists.sourceforge.net>; Tue, 10 Apr 2007 09:23:01 -0600
In-Reply-To: <460852BB.4080503@oracle.com>
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

Hi,

I've been working a bit on some changes to clean up the xdr_buf
handling. Patches can be found here:
http://oss.oracle.com/~okir/xdr-buf-rewrite/

The patch set aims to

 -	factor out common send/recv code in the client/server side, and
	put it into socklib.c
 -	get rid of some of the messy and duplicated code in xdr.c
 -	move the data copies out of the data_ready callbacks in xprtsock.c.
	(In the long run, one may want to think about per-CPU rpciod threads,
	so that data remains inside the cache of the CPU that processes it,
	rather than bouncing around)

The current code tries to guess the correct alignment of the returned data in
READ, READLINK and READDIR replies, and inlines a vector of pages "just so"
into the XDR so that the data ends up in the right place. If it doesn't, we jump
through 15 hoops to realign it.

The approach I'm trying is to leave the data in skb's for as long as it's
practical, and copy data to the page cache in the XDR decode routines.
In order to hide the skb mechanics, there's an rpc_data object that
encapsulates this. It looks a little awkward, but Chuck complained
about layering violations so I tried this instead.

The patch set is based on Chuck's tree (drop-20070409). It's
far from complete; in particular, I want to get rid of any code that
uses xdr_inline_pages, and I want to fully convert svcsock.c to use
the new generic recv functions as well.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
