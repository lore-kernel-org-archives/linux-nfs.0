From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Bugme-new] [Bug 14546] New: Off-by-two stack buffer overflow in function rpc_uaddr2sockaddr() of net/sunrpc/addr.c
Date: Tue, 10 Nov 2009 18:38:05 -0500
Message-ID: <967DC2CE-588D-4207-BF2D-59727454DC2E@oracle.com>
References: <bug-14546-10286@http.bugzilla.kernel.org/> <20091110152908.7558a471.akpm@linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Linux Network Developers <netdev@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Neil Brown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: argp@census-labs.com
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20091110152908.7558a471.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 10, 2009, at 6:29 PM, Andrew Morton wrote:
>
> (switched to email.  Please respond via emailed reply-to-all, not  
> via the
> bugzilla web interface).
>
> On Thu, 5 Nov 2009 10:31:03 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> http://bugzilla.kernel.org/show_bug.cgi?id=14546
>>
>>           Summary: Off-by-two stack buffer overflow in function
>>                    rpc_uaddr2sockaddr() of net/sunrpc/addr.c
>>           Product: Networking
>>           Version: 2.5
>>    Kernel Version: 2.6.32-rc6
>>          Platform: All
>>        OS/Version: Linux
>>              Tree: Mainline
>>            Status: NEW
>>          Severity: normal
>>          Priority: P1
>>         Component: Other
>>        AssignedTo: acme@ghostprotocols.net
>>        ReportedBy: argp@census-labs.com
>>                CC: argp@census-labs.com
>>        Regression: No
>>
>>
>> There is an off-by-two stack buffer overflow in function  
>> rpc_uaddr2sockaddr()
>> of file net/sunrpc/addr.c in the Linux kernel SUNRPC implementation.
>>
>> The function rpc_uaddr2sockaddr() that is used to convert a  
>> universal address
>> to a socket address takes as an argument the size_t variable  
>> uaddr_len (the
>> length of the universal address string). The stack buffer buf is  
>> declared in
>> line 315 to be of size RPCBIND_MAXUADDRLEN. If the passed argument  
>> uaddr_len is
>> equal to RPCBIND_MAXUADDRLEN then the check at line 319 passes and  
>> then at
>> lines 324 and 325 there are two out-of-bounds assignments:
>>
>>    319         if (uaddr_len > sizeof(buf))
>>    320                 return 0;
>> ...
>>    324         buf[uaddr_len] = '\n';
>>    325         buf[uaddr_len + 1] = '\0';
>>
>> To fix it please see the attached patch.
>>
>
> Please don't submit patches via bugzilla.
>
> Please prepare this patch as per Documentation/SubmittingPatches and
> email it to all the recipients of this email, thanks.
>
> --- ./net/sunrpc/addr.c.orig	2009-11-05 11:55:45.000000000 +0200
> +++ ./net/sunrpc/addr.c	2009-11-05 12:09:34.000000000 +0200
> @@ -316,7 +316,7 @@
> 	unsigned long portlo, porthi;
> 	unsigned short port;
>
> -	if (uaddr_len > sizeof(buf))
> +	if (uaddr_len > sizeof(buf) - 2)
> 		return 0;

Why wouldn't you bump the size of the buffer by two as well?   
Otherwise valid universal addresses that are RPCBIND_MAXUADDRLEN bytes  
long will fail here.

> 	memcpy(buf, uaddr, uaddr_len);

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



