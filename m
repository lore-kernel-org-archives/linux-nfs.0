From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC Patch 08/09] NFS/RDMA client - rpcrdma protocol
	handling
Date: Fri, 13 Jul 2007 13:11:15 -0400
Message-ID: <4697B233.8040205@oracle.com>
References: <EXNANE01jOuF1Qp4hZD00000c67@exnane01.hq.netapp.com>
	<4697A9DE.50703@oracle.com>
	<EXNANE01D8z9tTx7e4V00000c83@exnane01.hq.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040406060900030405050403"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9Ohk-0005uP-6f
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 10:13:20 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9Ohm-0001YF-Jz
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 10:13:23 -0700
In-Reply-To: <EXNANE01D8z9tTx7e4V00000c83@exnane01.hq.netapp.com>
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

This is a multi-part message in MIME format.
--------------040406060900030405050403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Talpey, Thomas wrote:
> At 12:35 PM 7/13/2007, Chuck Lever wrote:
>> Talpey, Thomas wrote:
>>> RPCRDMA: rpc rdma protocol implementation
>>> +#include <linux/nfs2.h>
>>> +#include <linux/nfs3.h>
>>> +#include <linux/nfs4.h>
>> I haven't looked closely at this yet, but is there really a dependency 
>> in here on NFS?  I don't see NFS dependencies in other parts of the RPC 
>> client or server, save the legacy debugging interface 
>> (/proc/sys/sunrpc/nfs_debug and friends).
>>
> 
> It's right here:
> 
>>> +/*
>>> + * Totally imperfect, temporary attempt to detect nfs reads...
>>> + * e.g. establish a hint via xdr_inline_pages, etc.
>>> + */
>>> +static int
>>> +is_nfs_read(struct rpc_rqst *rqst)
>>> +{
> 
> In which the code peeks into the rpc request to divine its origin.
> NFS reads prefer a slightly different RDMA handling, because they
> (ideally) transfer directly into the buffer cache, or other pagelist
> buffers such as passed by directio. Ops such as readdir however
> prefer a contiguous transfer.

Well, the other "read-like" operations (like readdir or readlink) use a 
single page cache page, as far as i recall.  In fact there is some 
desire to support multi-page readdir and readdirplus operations at some 
point.

> The alternative is mentioned, and would involve marking pagelists
> built in xdr_inline_pages(), this of course would also require changes to
> the NFS-layer callers. I am prepared to do that, pending the outcome
> of these comments.

I would humbly prefer the clean alternative: I think several other 
operations can use this.  Seems like the distinction is the operations 
that read data (like readdir, readlink, read) and those that read 
metadata (getattr).

The ULP should provide a hint on each of these.  Possibly you could hack 
the nfs_procedures tables (which is an RPC client data structure) to 
provide the hint.

--------------040406060900030405050403
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------040406060900030405050403
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------040406060900030405050403
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040406060900030405050403--
