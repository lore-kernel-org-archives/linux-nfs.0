From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/7] SUNRPC: RPC bind failures should be permanent
 for NULL requests
Date: Mon, 27 Aug 2007 15:15:09 -0400
Message-ID: <46D322BD.2070305@oracle.com>
References: <20070827173023.23426.58465.stgit@monet.1015granger.net>
	<1188238365.6701.105.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040205080302030309060507"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPk4W-000656-7H
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 12:16:25 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPk4Y-0007xc-A1
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 12:16:28 -0700
In-Reply-To: <1188238365.6701.105.camel@heimdal.trondhjem.org>
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
--------------040205080302030309060507
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Mon, 2007-08-27 at 13:30 -0400, Chuck Lever wrote:
>> The purpose of an RPC ping (a NULL request) is to determine whether the
>> remote end is operating and supports the program and version of the
>> request.
>>
>> If we do an RPC bind and the remote's rpcbind service says "this program or
>> service isn't supported" then we have our answer already, and we should
>> give up immediately.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>>  net/sunrpc/clnt.c |    5 +++++
>>  1 files changed, 5 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 215bafa..4ebdfb8 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -947,6 +947,11 @@ call_bind_status(struct rpc_task *task)
>>  	case -EACCES:
>>  		dprintk("RPC: %5u remote rpcbind: RPC program/version "
>>  				"unavailable\n", task->tk_pid);
>> +		/* fail immediately if this is an RPC ping */
>> +		if (task->tk_msg.rpc_proc->p_proc == 0) {
>> +			task->tk_status = -ENOPROTOOPT;
>> +			break;
>> +		}
>>  		rpc_delay(task, 3*HZ);
>>  		goto retry_timeout;
>>  	case -ETIMEDOUT:
>>
> 
> The rpcbind client currently also returns EACCES if it simply wants us
> to retry the request. If you want to do something like the above,
> shouldn't you be distinguishing between the two cases?

The rpcb_getport_done() callback reports -EPROTONOSUPPORT if it wants to 
retry with another rpcbind version.  But I see the forward path 
(rpcb_getport_async) does use -EACCES for a retry -- I think that's an 
error and should be changed.

--------------040205080302030309060507
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
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------040205080302030309060507
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------040205080302030309060507
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040205080302030309060507--
