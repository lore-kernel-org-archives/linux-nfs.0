From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/7] SUNRPC: Make rpcb_decode_getaddr more picky
 about universal addresses
Date: Mon, 27 Aug 2007 15:15:17 -0400
Message-ID: <46D322C5.4010506@oracle.com>
References: <20070827173018.23426.14005.stgit@monet.1015granger.net>
	<1188238184.6701.102.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080308030506080400080104"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPk4W-000657-8K
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 12:16:25 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPk4Y-0007ys-9y
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 12:16:28 -0700
In-Reply-To: <1188238184.6701.102.camel@heimdal.trondhjem.org>
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
--------------080308030506080400080104
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Mon, 2007-08-27 at 13:30 -0400, Chuck Lever wrote:
>> Make the XDR decoder for GETVERSADDR more picky about server replies.  It
>> should detect a bogus reply and return an error.  In this case, make
>> rpcbind recovery retry with an older protocol version.  The older versions
>> are more likely to work correctly.
>>
>> Also of note: while the RPC client is retrying a bind, it becomes
>> uninterruptible; this is not user-friendly.  This patch does not address
>> this issue.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>>  net/sunrpc/clnt.c      |    4 ++++
>>  net/sunrpc/rpcb_clnt.c |   32 +++++++++++++++++++++++++++-----
>>  2 files changed, 31 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 0ad3042..215bafa 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -963,6 +963,10 @@ call_bind_status(struct rpc_task *task)
>>  		task->tk_status = 0;
>>  		task->tk_action = call_bind;
>>  		return;
>> +	case -EINVAL:
>> +		dprintk("RPC: %5u remote rpcbind returned garbage\n",
>> +				task->tk_pid);
>> +		break;
>>  	default:
>>  		dprintk("RPC: %5u unrecognized rpcbind error (%d)\n",
>>  				task->tk_pid, -task->tk_status);
>> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
>> index 0bb6709..7f25907 100644
>> --- a/net/sunrpc/rpcb_clnt.c
>> +++ b/net/sunrpc/rpcb_clnt.c
>> @@ -446,6 +446,10 @@ static void rpcb_getport_done(struct rpc_task *child, void *data)
>>  	struct rpc_xprt *xprt = map->r_xprt;
>>  	int status = child->tk_status;
>>  
>> +	/* Garbage reply: retry with a lesser rpcbind version */
>> +	if (status == -EINVAL)
>> +		status = -EPROTONOSUPPORT;
>> +
>>  	/* rpcbind server doesn't support this rpcbind protocol version */
>>  	if (status == -EPROTONOSUPPORT)
>>  		xprt->bind_index++;
>> @@ -528,12 +532,19 @@ static int rpcb_decode_getaddr(struct rpc_rqst *req, __be32 *p,
>>  
>>  	*portp = 0;
>>  	addr_len = ntohl(*p++);
>> -	if (addr_len > RPCB_MAXADDRLEN)			/* sanity */
>> -		return -EINVAL;
>> -
>> -	dprintk("RPC:       rpcb_decode_getaddr returned string: '%s'\n",
>> -			(char *) p);
>>  
>> +	/*
>> +	 * Simple sanity check.  The smallest possible universal
>> +	 * address is an IPv4 address string containing 11 bytes.
>> +	 */
>> +	if (addr_len < 11 || addr_len > RPCB_MAXADDRLEN)
>> +		goto out_err;
>> +
>> +	/*
>> +	 * Start at the end and walk backwards until the first dot
>> +	 * is encountered.  When the second dot is found, we have
>> +	 * both parts of the port number.
>> +	 */
>>  	addr = (char *)p;
>>  	val = 0;
>>  	first = 1;
>> @@ -555,8 +566,19 @@ static int rpcb_decode_getaddr(struct rpc_rqst *req, __be32 *p,
>>  		}
>>  	}
>>  
>> +	/*
>> +	 * Simple sanity check.  If we never saw a dot in the reply,
>> +	 * then this was probably just garbage.
>> +	 */
>> +	if (first)
>> +		goto out_err;
>> +
>>  	dprintk("RPC:       rpcb_decode_getaddr port=%u\n", *portp);
>>  	return 0;
>> +
>> +out_err:
>> +	printk(KERN_WARNING "RPC: rpcbind server returned malformed reply\n");
> 
> NACK! This should be a dprintk().

Noted and fixed.

>> +	return -EINVAL;
>>  }
>>  
>>  #define RPCB_program_sz		(1u)
>>
> 
> Can't we pick something better than EINVAL? EINVAL is usually reserved
> for 'the user chose an invalid value'.

Note that the recently added NFS ACL XDR routines use EINVAL for this 
purpose.  How about -EPROTO?

--------------080308030506080400080104
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


--------------080308030506080400080104
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------080308030506080400080104
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080308030506080400080104--
