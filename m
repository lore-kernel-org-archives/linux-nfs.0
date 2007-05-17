From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC,PATCH 4/14] knfsd: has_wspace per transport
Date: Thu, 17 May 2007 08:39:25 -0400
Message-ID: <EXNANE01SlSt7IZfSp100000a27@exnane01.hq.netapp.com>
References: <20070516192211.GJ9626@sgi.com>
	<20070516211053.GE18927@fieldses.org>
	<20070517071202.GE27247@sgi.com>
	<17996.11983.278205.708747@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HofGd-0008Q3-IU
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 05:39:39 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HofGf-0004P8-Ba
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 05:39:42 -0700
In-Reply-To: <17996.11983.278205.708747@notabene.brown>
References: <20070516192211.GJ9626@sgi.com>
	<20070516211053.GE18927@fieldses.org>
	<20070517071202.GE27247@sgi.com>
	<17996.11983.278205.708747@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

At 06:30 AM 5/17/2007, Neil Brown wrote:
>And I gather by the fact that you test "->sko_has_wspace" that RDMA
>doesn't have such a function?  Do that mean that RDMA will never
>reject a write due to lack of space?  That seems unlikely.

RDMA uses credits, which are preallocated per-connection resources in
the hardware. RDMA transports don't generally support flow control, that
is left to the upper layer. As such, if the client is obeying the protocol, the
send will succeed. And if it's not, then the client only loses since the failure
will cause the connection to be lost.

Someday we might want to support this kind of test. There are shared
resource schemes in RDMA, more for the receive side, but it's not out of the
question for sends. As a default though, a NULL has_wspace makes sense. 

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
