From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] [PATCH 2/7] SUNRPC: Fix TCP rebinding logic
Date: Wed, 07 Nov 2007 18:28:18 -0500
Message-ID: <47324A12.9080201@oracle.com>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>	
	<20071107003945.13713.61995.stgit@heimdal.trondhjem.org>	
	<473240BE.7000709@oracle.com>
	<1194476901.7504.66.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060306000402010900060808"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1194476901.7504.66.camel@heimdal.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

This is a multi-part message in MIME format.
--------------060306000402010900060808
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Wed, 2007-11-07 at 17:48 -0500, Chuck Lever wrote:
>> Trond Myklebust wrote:
>>>  static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
>>>  {
>>>  	struct sockaddr_in myaddr = {
>>>  		.sin_family = AF_INET,
>>>  	};
>>>  	struct sockaddr_in *sa;
>>> -	int err;
>>> -	unsigned short port = transport->port;
>>> +	int err, nloop = 0;
>>> +	unsigned short port = xs_get_srcport(transport, sock);
>>> +	unsigned short last;
>>>  
>>> -	if (!transport->xprt.resvport)
>>> -		port = 0;
>>>  	sa = (struct sockaddr_in *)&transport->addr;
>>>  	myaddr.sin_addr = sa->sin_addr;
>>>  	do {
>>>  		myaddr.sin_port = htons(port);
>>>  		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
>>>  						sizeof(myaddr));
>>> -		if (!transport->xprt.resvport)
>>> +		if (port == 0)
>>>  			break;
>>>  		if (err == 0) {
>>>  			transport->port = port;
>>>  			break;
>>>  		}
>>> -		if (port <= xprt_min_resvport)
>>> -			port = xprt_max_resvport;
>>> -		else
>>> -			port--;
>>> -	} while (err == -EADDRINUSE && port != transport->port);
>>> +		last = port;
>>> +		port = xs_next_srcport(transport, sock, port);
>>> +		if (port > last)
>>> +			nloop++;
>> It seems like there are cases where a user can adjust the port range and 
>> it would defeat this check.  For example, if the port range is 30 to 40, 
>> and the user changes it to 10 to 20, we keep looping.
> 
> Yes, but once we hit 10, then the nloop gets bumped. It is guaranteed to
> get bumped if we hit 0, or if the administrator increases the minimum
> port number past the current one.
> 
>> Doesn't breaking out of the loop break "Hard" NFS requests?
> 
> We've always had to deal with breaking out of the loops. If we don't, we
> will deadlock the computer.

In that case it might make sense to allow some scheduling between each 
socket bind attempt, and do only a single pass over the port range 
before breaking out.  Then you could forget about whether the range 
changes -- you will use the new range the next time a connection is 
attempted.

> If this is a hard mount, then the only result should normally be that we
> abort the connection,  time out, and then try again. This has been the
> behaviour for quite some while.

--------------060306000402010900060808
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


--------------060306000402010900060808
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--------------060306000402010900060808--
