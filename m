From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NLM: add network test when host expire but hold lock at nlm_gc_hosts
Date: Thu, 3 Dec 2009 10:28:53 -0500
Message-ID: <22D2BD38-1243-417A-A8DD-A686983E4A02@oracle.com>
References: <4B163798.7010309@cn.fujitsu.com> <20091202072644.31c5d17e@tlielax.poochiereds.net> <1259764143.2663.10.camel@localhost> <20091202170931.GD13406@fieldses.org> <CF8A534F-BC6A-457A-89CF-2C2D34765B67@oracle.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Jeff Layton <jlayton@redhat.com>,
	Mi Jinlong <mijinlong@cn.fujitsu.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:34040 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756284AbZLCPal (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2009 10:30:41 -0500
In-Reply-To: <CF8A534F-BC6A-457A-89CF-2C2D34765B67@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 2, 2009, at 12:20 PM, Chuck Lever wrote:

> On Dec 2, 2009, at 12:09 PM, J. Bruce Fields wrote:
>> On Wed, Dec 02, 2009 at 09:29:03AM -0500, Trond Myklebust wrote:
>>> On Wed, 2009-12-02 at 07:26 -0500, Jeff Layton wrote:
>>>> On Wed, 02 Dec 2009 17:47:04 +0800
>>>> Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:
>>>>
>>>>> After a client get lock, it's network partition for some reasons.
>>>>> other client cannot get lock success forever.
>>>>>
>>>>> This patch can avoid this problem using rpc_ping to test client's
>>>>> network when host expired but hold lock.
>>>>>
>>>>> If the client's network is partition, server will release client's
>>>>> lock, other client will get lock success.
>>>>>
>>>>> Signed-off-by: mijinlong@cn.fujitsu.com
>>>>
>>>> Yikes! That sounds like it'll make locking subject to the  
>>>> reliability
>>>> of the network. I don't think that's a good idea.
>>>>
>>>> What might be more reasonable is to consider implementing something
>>>> like the clear_locks command in Solaris. That is, a way for an  
>>>> admin to
>>>> remove server-side locks held by a client that he knows is never  
>>>> going
>>>> to come back. With that, this sort of thing at least becomes a  
>>>> willful
>>>> act...
>>>
>>> Agreed on both counts.
>>>
>>> We should not be changing the semantics of either NFSv3 or NLM at  
>>> this
>>> time. That will break existing setups that are treating NFSv3 as  
>>> being a
>>> stable platform.
>>> As I've said in previous correspondence: NFSv4 already offers lease
>>> based locking. If people are worried about network partitions and/or
>>> locks being held by clients that are dead, then they can switch to  
>>> that.
>>>
>>> On the other hand, a clear_locks command could be useful in order to
>>> tell a server that a given client is dead. It should be fairly  
>>> easy to
>>> leverage the existing NSM/statd protocol to implement this.
>>
>> Oh, so all clear_locks does is send an nsm notification?  Yeah, that
>> sounds like a completely reasonable project for someone.
>
> If you send an SM_NOTIFY to statd, it will ignore it if it doesn't  
> recognize the mon_name.  statd also checks the sender's IP address,  
> which would be different in this case than that actual peer's IP  
> address.
>
> The SM_NOTIFY RPC does not have a return value, so there's no way to  
> know whether your command was effective (other than seeing that the  
> locks are still held).
>
> clear_locks would have to read /var/lib/nfs/statd/sm/foo to get the  
> RPC proc/vers/proc and priv arguments if it were to send an NLM  
> downcall.

Taking the downcall approach....

If we can live with operating "in the dark" (with regard to what the  
kernel is actually doing) and live with the "appropriation" of data  
in /var/lib/nfs/statd, this would be simple and get us 70-80%.

Basically this tool would make use of the features of the new  
libnsm.a.  Copy sm-notify.c, strip out the unnecessary parts, and use  
the libnsm.a NLM downcall functions instead of its SM_NOTIFY functions.

A synopsis might be:

    clear-locks [-a] [-p state-directory] [--list] [hostname]  
[hostname] [hostname] ...

-a      Clear NLM locks for all monitored peers

-p      Specify an alternate state directory (default: /var/lib/nfs/ 
statd)

--list  List all monitored peers

Each hostname would have to match a monitor record.

The tool could report only on the contents of /var/lib/nfs/statd; it  
could not report on kernel state, so it could not report whether the  
peer actually had any locks, or whether existing locks were actually  
cleared successfully. The kernel would poke statd to unmonitor the  
peer as needed, in order to keep the kernel's monitor list in sync  
with statd's.

For discussion, I could mock up a prototype and insert it in my statd  
patch series (which introduces libnsm.a).

> So, using NSM might be a simple approach, but not a robust one, IMO.
>
> I've always wanted to have the kernel's NSM hosts cache exported  
> via /sys (or similar).  That would make it somewhat easier to see  
> what's going on, and provide a convenient sysctl-like interface for  
> local commands to make adjustments such as this (or for statd to  
> gather more information than is available from an SM_MON request).

If this is ever implemented, clear-locks could use it when it was  
available.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




