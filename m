From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/3] SUNRPC client: add interface for binding to
 a	local address
Date: Fri, 06 Jul 2007 11:40:25 -0400
Message-ID: <468E6269.8080004@oracle.com>
References: <20070705152634.GC6603@janus>
	<1183729576.6463.29.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040705040102080404050800"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6pwi-0003Xq-Gy
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 08:42:12 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I6pwk-0005jH-Re
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 08:42:16 -0700
In-Reply-To: <1183729576.6463.29.camel@heimdal.trondhjem.org>
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
--------------040705040102080404050800
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Thu, 2007-07-05 at 17:26 +0200, Frank van Maarseveen wrote:
>> @@ -1146,31 +1147,33 @@ static void xs_set_port(struct rpc_xprt 
>>  	sap->sin_port = htons(port);
>>  }
>>  
>> -static int xs_bindresvport(struct sock_xprt *transport, struct socket *sock)
>> +static int xs_bind(struct sock_xprt *transport, struct socket *sock)
>>  {
>>  	struct sockaddr_in myaddr = {
>>  		.sin_family = AF_INET,
>>  	};
>> +	struct sockaddr_in *sa;
>>  	int err;
>>  	unsigned short port = transport->port;
> 
> Instead of forcing two tests of transport->xprt.resvport per loop, why
> not just set port to 0 in the case of !transport->xprt.resvport?

This logic seems unnecessarily complicated to me, too.  I'm not so 
concerned about the loop optimization, but it certainly isn't immediate 
from looking at these changes exactly what is going on here in the two 
important cases ("yes we want a reserved port" and "no, any old port 
will do, thanks").  Anything that clarifies this would be welcome, but 
I'd encourage code clarity over just adding a comment or two.

>>  
>> +	sa = (struct sockaddr_in *)&transport->saddr;
>> +	myaddr.sin_addr = sa->sin_addr;
>>  	do {
>> -		myaddr.sin_port = htons(port);
>> +		if (transport->xprt.resvport)
>> +			myaddr.sin_port = htons(port);
>>  		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
>>  						sizeof(myaddr));
>> -		if (err == 0) {
>> +		if (err == 0 || !transport->xprt.resvport) {
>>  			transport->port = port;
>> -			dprintk("RPC:       xs_bindresvport bound to port %u\n",
>> -					port);
>> -			return 0;
>> +			break;
>>  		}
>>  		if (port <= xprt_min_resvport)
>>  			port = xprt_max_resvport;
>>  		else
>>  			port--;
>>  	} while (err == -EADDRINUSE && port != transport->port);
>> -
>> -	dprintk("RPC:       can't bind to reserved port (%d).\n", -err);
>> +	dprintk("RPC:       xs_bind "NIPQUAD_FMT":%u: %d\n",
>> +		NIPQUAD(myaddr.sin_addr), port, err);
> 
> Hmm... I thought you said this was IPv6 clean :-)

Well, IPv6 uses a separate xs_bindresvport routine, so IPv4-specific 
stuff can be added in here with aplomb.  We just have to remember to 
make Frank's changes to the xs_bindresvport6 when it is integrated.

Frank, can you make this debugging message a little more friendly?

--------------040705040102080404050800
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


--------------040705040102080404050800
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------040705040102080404050800
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040705040102080404050800--
