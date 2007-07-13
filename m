From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC Patch 08/09] NFS/RDMA client - rpcrdma protocol
 handling
Date: Fri, 13 Jul 2007 13:28:24 -0400
Message-ID: <EXNANE01iFEW6sStwNe00000c84@exnane01.hq.netapp.com>
References: <EXNANE01jOuF1Qp4hZD00000c67@exnane01.hq.netapp.com>
	<4697A9DE.50703@oracle.com>
	<EXNANE01D8z9tTx7e4V00000c83@exnane01.hq.netapp.com>
	<4697B233.8040205@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9Owo-0007bh-Md
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 10:28:54 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I9Owq-0007ig-4a
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 10:28:57 -0700
In-Reply-To: <4697B233.8040205@oracle.com>
References: <EXNANE01jOuF1Qp4hZD00000c67@exnane01.hq.netapp.com>
	<4697A9DE.50703@oracle.com>
	<EXNANE01D8z9tTx7e4V00000c83@exnane01.hq.netapp.com>
	<4697B233.8040205@oracle.com>
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

At 01:11 PM 7/13/2007, Chuck Lever wrote:
>Well, the other "read-like" operations (like readdir or readlink) use a 
>single page cache page, as far as i recall.  In fact there is some 
>desire to support multi-page readdir and readdirplus operations at some 
>point.

Doesn't help, as a hint, since read can also operate on just a page.

>I would humbly prefer the clean alternative: I think several other 
>operations can use this.  Seems like the distinction is the operations 
>that read data (like readdir, readlink, read) and those that read 
>metadata (getattr).

Me too. But the distinction is finer than that. Basically the one that
RPC/RDMA needs to know is whether the rpc result that is destined
for the pagelist is bulk data, or encoded. Readdir, readdirplus, and
readlink are all in the latter category.

The other wrinkle is NFSv4 COMPOUND, which can wrap any number
of these. At the moment, the XDR interface doesn't support a COMPOUND
that would pass down multiple pagelists (e.g. more than one OP_READ),
so that's not an issue. This is the reason for the "simplification" comments
you may see in the code (and it's a good thing IMO).

>The ULP should provide a hint on each of these.  Possibly you could hack 
>the nfs_procedures tables (which is an RPC client data structure) to 
>provide the hint.

That would be simpler than extending the xdr_buf, but it might make
things difficult for NFSv4, which only ever uses one procedure.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
