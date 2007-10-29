From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 19/27] NFS: Ensure that NFS version 4 mounts use
 NFS_PORT if	nfsport wasn't set
Date: Mon, 29 Oct 2007 12:08:21 -0400
Message-ID: <47260575.2030903@oracle.com>
References: <20071026173219.31475.68965.stgit@manray.1015granger.net>
	<EXNANE01S0qPzg9uV5400000825@exnane01.hq.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080100030702010608010006"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImXAA-000111-PN
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 09:08:26 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ImXAG-0004JS-0N
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 09:08:32 -0700
In-Reply-To: <EXNANE01S0qPzg9uV5400000825@exnane01.hq.netapp.com>
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
--------------080100030702010608010006
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Talpey, Thomas wrote:
> But... 2049 is only valid for TCP. Ther eis no such guarantee for RDMA,
> SCTP, etc etc. Wouldn't it be safer/better to fail the mount if no port
> is specified? This is what rpcbind would do if it fails to resolve the port,
> for example.

I'm copying logic already used in the legacy mount ABI.  See "case 1:" 
in the same switch statement.  The behavior there, unless I'm mistaken, 
is that if no port is specified via a mount option, that's the same as 
saying "port=2049".

RFC 3530 states

3.1.  Ports and Transports

    Historically, NFS version 2 and version 3 servers have resided on
    port 2049.  The registered port 2049 [RFC3232] for the NFS protocol
    should be the default configuration.  Using the registered port for
    NFS services means the NFS client will not need to use the RPC
    binding protocols as described in [RFC1833]; this will allow NFS to
    transit firewalls.

The last sentence fragment is pertinent here.  Without the logic I add 
in this patch, text-based NFSv4 mounts won't transit firewalls that 
block the rpcbind protocol, but legacy NFSv4 mounts will work as expected.

I'm not familiar with the v4.1 spec, but I assume (perhaps at my own 
risk) that the firewall transit requirement has not been changed.

In any event, I understand that RDMA uses port 2050, but I thought that 
was just a place holder in the rpcbind protocol; the actual value of the 
port number is never used by the underlying RDMA transport.  In other 
words, is this patch really going to affect RDMA mounts?

> At 01:32 PM 10/26/2007, Chuck Lever wrote:
>> Text-based mount option parsing introduced a minor regression in the
>> behavior of NFS version 4 mounts.  NFS version 4 is not supposed to require
>> a running rpcbind service on the server in order for a mount to succeed.
>>
>> In other words, if the mount options don't specify a port number, the port
>> number is supposed to default to 2049.  For earlier versions of NFS, the
>> default port number was zero in order to cause the RPC client to autobind
>> to the server's NFS service.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/nfs/super.c |    2 ++
>> 1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index fa517ae..1b2fac8 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -1612,6 +1612,8 @@ static int nfs4_validate_mount_data(void *options,
>> 		if (nfs_parse_mount_options((char *)options, args) == 0)
>> 			return -EINVAL;
>>
>> +		if (args->nfs_server.address.sin_port == 0)
>> +			args->nfs_server.address.sin_port = htons(NFS_PORT);
>> 		if (!nfs_verify_server_address((struct sockaddr *)
>> 						&args->nfs_server.address))
>> 			return -EINVAL;
>>
>>
>> -------------------------------------------------------------------------
>> This SF.net email is sponsored by: Splunk Inc.
>> Still grepping through log files to find problems?  Stop.
>> Now Search log events and configuration files using AJAX and a browser.
>> Download your FREE copy of Splunk now >> http://get.splunk.com/
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs

--------------080100030702010608010006
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
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------080100030702010608010006
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------080100030702010608010006
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080100030702010608010006--
