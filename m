From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/5] nfs-utils: query for remote port using rpcbind
	instead of getaddrinfo
Date: Thu, 9 Apr 2009 13:34:14 -0400
Message-ID: <07C74B52-9FEC-468B-9C71-05F3EC84F9B2@oracle.com>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
	<1239117946-7535-4-git-send-email-jlayton@redhat.com>
	<41F98279-F000-4C1C-8E44-3568C89FC2BD@oracle.com>
	<49db7f0d.85c2f10a.5025.ffffb257@mx.google.com>
	<20090407131151.69203e5e@tleilax.poochiereds.net>
	<49dbacf3.14025a0a.5898.ffffbaa2@mx.google.com>
	<20090407231406.GC28733@fieldses.org>
	<DDF2F477-FC1E-45D0-A9F6-A4D690F2256B@oracle.com>
	<20090409161947.GG32589@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090409161947.GG32589@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

On Apr 9, 2009, at 12:19 PM, J. Bruce Fields wrote:
> On Wed, Apr 08, 2009 at 03:32:43PM -0400, Chuck Lever wrote:
>> On Apr 7, 2009, at 7:14 PM, J. Bruce Fields wrote:
>>> On Tue, Apr 07, 2009 at 03:43:39PM -0400, Tom Talpey wrote:
>>>> At 01:11 PM 4/7/2009, Jeff Layton wrote:
>>>>> On Tue, 07 Apr 2009 12:27:49 -0400
>>>>> Tom Talpey <tmtalpey@gmail.com> wrote:
>>>>>
>>>>>> At 12:02 PM 4/7/2009, Chuck Lever wrote:
>>>>>>>
>>>>>>> On Apr 7, 2009, at 11:25 AM, Jeff Layton wrote:
>>>>>>>> +	/* Use standard NFS port for NFSv4 */
>>>>>>>> +	if (program == 100003 && version == 4) {
>>>>>>>> +		port = 2049;
>>>>>>>> +		goto set_port;
>>>>>>>> +	}
>>>>>>>
>>>>>>> I think this patch set looks pretty reasonable.  Here's my one
>>>>>>> remaining quibble.
>>>>>>>
>>>>>>> You can specify "port=" for nfs4 mounts, in which case we want
>>>>>>> to use
>>>>>>> that value here, too, I think.  It would be simpler overall if  
>>>>>>> the
>>>>>>
>>>>>> *Must* use a port= specification. The 2049 definition is only
>>>>>> true for
>>>>>> NFSv4/TCP, as a counterexample the NFSv4/RDMA IANA binding is
>>>>>> port 20049. So slamming the port to 2049 would break NFSv4/RDMA.
>>>>>>
>>>>>
>>>>> rpc.gssd doesn't seem to be rdma-enabled at this point. It only
>>>>> seems
>>>>> to handle "tcp" and "udp" in the existing code.
>>>>
>>>> Fair enough. But hardwiring 2049 for all transports is going to  
>>>> very
>>>> problematic. What's the motivation for bypassing the rpcbind query
>>>> altogether (that "goto set_port" skips over it)? Why not at least
>>>> try the query first?
>>>
>>> We're just doing the rpcsec_gss context initiation.  Normally that
>>> would
>>> be done over an already-established connection--the only reason we
>>> don't
>>> is because our implementation is split between the client and the
>>> server, so it's more convenient for us to set up a new connection in
>>> rpc.gssd.  But we really shouldn't be doing an entirely new rpcbind
>>> call--somebody else already did that for us and is telling us the
>>> results through the rpc_pipefs info file.
>>
>> This is an entirely separate RPC transport being set up for gssd, and
>> there seem to be a lot of cases where the kernel (rightfully)  
>> passes a
>> zero for the port number.  In fact, even if the kernel did the  
>> rpcbind
>> for gssd at some point in the past, gss doesn't have any information
>> about how old that information is.
>>
>> So, yes, we do want an rpcbind here.
>
> As long as we don't do it in the NFSv4 case, I'm happy.

As far as I understand it, the kernel won't send up a zero for NFSv4  
unless the mount command line says "port=0" which forces an rpcbind  
for each transport we use to connect to that server.

For NFSv2/v3, however, not specifying port= on the mount command line  
means the kernel will send up zero in most common cases, I think.   
Using /etc/services on the client to discover the server's NFSD port  
means that if the server has registered the NFS service on some other  
port, specifying "port=" will be required on the mount command line  
for gssd to work, even though rpcbind on the server is advertising the  
correct port already.

> My only point is that the above argument is putting the cart before  
> the
> horse a bit: the fact that there's an entirely separate RPC transport
> being set up is entirely an artifact of our implementation, and if it
> became a problem at some point, then we'd need to consider modifying  
> the
> kernel/gssd interface to eliminate the need for that.


port=0 has a specific well-defined meaning for RPC, which is "do an  
rpcbind".  If you really think you need to distinguish between "use  
this port number," "do an rpcbind," "use the standard port for this  
transport," and "consult /etc/services" then I don't think port=0 is  
adequate.

Should we even bother to consult /etc/services for NFSv4, since that  
port value is required by standard?  nfs4mount.c doesn't look at /etc/ 
services, for example.  So today, gssd looks in /etc/services,  
nfs4mount.c and the kernel hard-code the port number.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
