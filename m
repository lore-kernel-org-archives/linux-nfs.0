From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: RPC service registration timeout
Date: Fri, 4 Apr 2008 14:41:12 -0400
Message-ID: <0FE09339-FB7A-4E9E-B56F-61648EFD121A@oracle.com>
References: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com> <EXNANE01XvpFVjCRGry00000233@exnane01.hq.netapp.com> <1207330103.11655.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:12315 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbYDDSmY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Apr 2008 14:42:24 -0400
In-Reply-To: <1207330103.11655.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 4, 2008, at 1:28 PM, Trond Myklebust wrote:
> On Fri, 2008-04-04 at 12:49 -0400, Talpey, Thomas wrote:
>> I think a second or two is way too short, but I do wonder if it can't
>> issue the unregisters asynchronously, and in parallel. Then it can
>> wait for them all, with a timeout maybe on the order of 10 to 15
>> seconds. A couple of retries while waiting sounds reasonable.
>>
>> Making the wait interruptible seems dicey. Once the deregistration
>> is started, it seems like it should always make a best attempt to
>> complete it. Also, nfsd is usually started as a service, so there's
>> not likely to be a user.
>
> I'd say that making the RPC call asynchronous, but doing an
> interruptible wait on completion is probably the best solution.
>
> Making the process entirely asynchronous can be problematic if you
> decide to restart the service due to the potential for reordering
> between the unregister/register RPC calls.

Another approach that doesn't address interruptibility, but does  
prevent waiting for a timeout if rpcbind isn't listening:

Use TCP instead of UDP to contact the local rpcbind daemon.  If  
rpcbind isn't listening, the connection is refused immediately, and  
the RPC client can tell without waiting for a timeout.

We would have to create a new RPC_CLNT_CREATE_FOO flag that tells the  
client to fail an RPC immediately if the connection is refused (kind  
of like the old "one shot" flag).  This shouldn't be the default  
behavior.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
