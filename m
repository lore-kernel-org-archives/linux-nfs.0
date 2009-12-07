From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NLM: add network test when host expire but hold lock
	at nlm_gc_hosts
Date: Mon, 7 Dec 2009 11:36:52 -0500
Message-ID: <20091207163652.GE29416@fieldses.org>
References: <4B163798.7010309@cn.fujitsu.com> <20091202072644.31c5d17e@tlielax.poochiereds.net> <1259764143.2663.10.camel@localhost> <20091202170931.GD13406@fieldses.org> <CF8A534F-BC6A-457A-89CF-2C2D34765B67@oracle.com> <22D2BD38-1243-417A-A8DD-A686983E4A02@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Jeff Layton <jlayton@redhat.com>,
	Mi Jinlong <mijinlong@cn.fujitsu.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35631 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755737AbZLGQgw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 11:36:52 -0500
In-Reply-To: <22D2BD38-1243-417A-A8DD-A686983E4A02@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 03, 2009 at 10:28:53AM -0500, Chuck Lever wrote:
> On Dec 2, 2009, at 12:20 PM, Chuck Lever wrote:
>> If you send an SM_NOTIFY to statd, it will ignore it if it doesn't  
>> recognize the mon_name.  statd also checks the sender's IP address,  
>> which would be different in this case than that actual peer's IP  
>> address.
>>
>> The SM_NOTIFY RPC does not have a return value, so there's no way to  
>> know whether your command was effective (other than seeing that the  
>> locks are still held).
>>
>> clear_locks would have to read /var/lib/nfs/statd/sm/foo to get the  
>> RPC proc/vers/proc and priv arguments if it were to send an NLM  
>> downcall.
>
> Taking the downcall approach....
>
> If we can live with operating "in the dark" (with regard to what the  
> kernel is actually doing) and live with the "appropriation" of data in 
> /var/lib/nfs/statd, this would be simple and get us 70-80%.
>
> Basically this tool would make use of the features of the new libnsm.a.  
> Copy sm-notify.c, strip out the unnecessary parts, and use the libnsm.a 
> NLM downcall functions instead of its SM_NOTIFY functions.

Forgive me for being behind here: what's the practical difference
between the two?  I guess the NLM rpc's are authenticated just by being
from localhost.  Does it give any better error reporting?  What's the
remaining 20-30%?

--b.

>
> A synopsis might be:
>
>    clear-locks [-a] [-p state-directory] [--list] [hostname] [hostname] 
> [hostname] ...
>
> -a      Clear NLM locks for all monitored peers
>
> -p      Specify an alternate state directory (default: /var/lib/nfs/ 
> statd)
>
> --list  List all monitored peers
>
> Each hostname would have to match a monitor record.
>
> The tool could report only on the contents of /var/lib/nfs/statd; it  
> could not report on kernel state, so it could not report whether the  
> peer actually had any locks, or whether existing locks were actually  
> cleared successfully. The kernel would poke statd to unmonitor the peer 
> as needed, in order to keep the kernel's monitor list in sync with 
> statd's.
>
> For discussion, I could mock up a prototype and insert it in my statd  
> patch series (which introduces libnsm.a).
>
>> So, using NSM might be a simple approach, but not a robust one, IMO.
>>
>> I've always wanted to have the kernel's NSM hosts cache exported via 
>> /sys (or similar).  That would make it somewhat easier to see what's 
>> going on, and provide a convenient sysctl-like interface for local 
>> commands to make adjustments such as this (or for statd to gather more 
>> information than is available from an SM_MON request).
>
> If this is ever implemented, clear-locks could use it when it was  
> available.
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
