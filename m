From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: How to unlock a file if an NFSv3 client dies forever?
Date: Wed, 26 May 2004 17:23:22 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085606601.3834.5.camel@lade.trondhjem.org>
References: <4F28105F70F4324A8723F0C949088941BCB773@pa-exch5.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT5rw-0000Tw-L1
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 14:23:24 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BT5rw-0002GW-Av
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 14:23:24 -0700
To: Howie Xu <howie@vmware.com>
In-Reply-To: <4F28105F70F4324A8723F0C949088941BCB773@pa-exch5.vmware.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

P=E5 on , 26/05/2004 klokka 16:06, skreiv Howie Xu:

> Btw, anyone knows that NFSv4 is immune to this "dead lock" scenario?

Yes, NFSv4 is immune. See pages 13,15, and 77 of RFC3530 if you want
details on the "lease" mechanism that is used to avoid the problem...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
