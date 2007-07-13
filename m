From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC Patch 08/09] NFS/RDMA client - rpcrdma protocol
 handling
Date: Fri, 13 Jul 2007 12:50:29 -0400
Message-ID: <EXNANE01D8z9tTx7e4V00000c83@exnane01.hq.netapp.com>
References: <EXNANE01jOuF1Qp4hZD00000c67@exnane01.hq.netapp.com>
	<4697A9DE.50703@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9OLl-0003Lg-NQ
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 09:50:37 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I9OLo-0000Fs-2v
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 09:50:41 -0700
In-Reply-To: <4697A9DE.50703@oracle.com>
References: <EXNANE01jOuF1Qp4hZD00000c67@exnane01.hq.netapp.com>
	<4697A9DE.50703@oracle.com>
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

At 12:35 PM 7/13/2007, Chuck Lever wrote:
>Talpey, Thomas wrote:
>> RPCRDMA: rpc rdma protocol implementation
>> +#include <linux/nfs2.h>
>> +#include <linux/nfs3.h>
>> +#include <linux/nfs4.h>
>
>I haven't looked closely at this yet, but is there really a dependency 
>in here on NFS?  I don't see NFS dependencies in other parts of the RPC 
>client or server, save the legacy debugging interface 
>(/proc/sys/sunrpc/nfs_debug and friends).
>

It's right here:

>> +/*
>> + * Totally imperfect, temporary attempt to detect nfs reads...
>> + * e.g. establish a hint via xdr_inline_pages, etc.
>> + */
>> +static int
>> +is_nfs_read(struct rpc_rqst *rqst)
>> +{

In which the code peeks into the rpc request to divine its origin.
NFS reads prefer a slightly different RDMA handling, because they
(ideally) transfer directly into the buffer cache, or other pagelist
buffers such as passed by directio. Ops such as readdir however
prefer a contiguous transfer.

It's actually fairly clean in the case of NFSv3 and NFSv2, the nfs
#includes are simply there to define the procedure numbers. However
for NFSv4, there is a bit of ... uncleanliness.

The alternative is mentioned, and would involve marking pagelists
built in xdr_inline_pages(), this of course would also require changes to
the NFS-layer callers. I am prepared to do that, pending the outcome
of these comments.

The other integration concern is how to pass any RDMA parameters
at mount time, which of course you're well aware of. :-) I see Trond
has submitted some of your queued changes for 2.6.23, so I expect
to make use of them for the next patch revision, post .23-rc1.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
