From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: portmap -> map db entirely in filesystem
Date: Mon, 19 May 2008 10:43:15 -0400
Message-ID: <20080519144315.GA7622@fieldses.org>
References: <20080513195831.GA18915@nibiru.local> <DCFA5A55-22F0-4C03-9877-E8DC80F57CB5@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weigelt-EU+a56NjgY8@public.gmane.org, linux-nfs <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48277 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758139AbYESOn0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 10:43:26 -0400
In-Reply-To: <DCFA5A55-22F0-4C03-9877-E8DC80F57CB5@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 13, 2008 at 03:30:42PM -0700, Chuck Lever wrote:
> On May 13, 2008, at 12:58 PM, Enrico Weigelt wrote:
>> Hi folks,
>>
>> while working on portmap, I was thinking about moving the
>> entire mapping table to the filesystem: one file per record.
>
> Well, first of all we are moving away from portmap these days since we  
> need to support IPv6.  We currently have an rpcbind implementation that 
> is ported from Solaris.
>
> But it would make sense to keep the rpcbind service completely in the  
> kernel.  That way the kernel RPC services could register with the  
> rpcbind database directly, and we wouldn't have to worry about re- 
> registering running RPC services because of a daemon restart.

Sounds sensible to me....--b.

>
> There's no need to involve permanent storage for rpcbind.  Once the  
> system reboots the database is empty and must be repopulated as RPC  
> services are restarted.
>
> Local user-space RPC services might then register via an ioctl() (or  
> other special interface) instead of an actual RPC.  That way we could  
> gate RPC service registration with actual security capabilities.
>
>> Benefits:
>>
>> * allows much simpler code: no internal maptable and load/store
>>  logic - just simple file IO (even limited to REST)
>> * external programs can directly manipulate the map db, w/o
>>  goint through portmap itself
>> * several portmap's (eg. for serving on separate sockets or
>>  different security domains) can easily share the same map.
>> * less process memory consumption of portmap (on larger maps)
>>
>> Drawbacks:
>>
>> * a bit slower, more IO traffic
>> * we have to rethink chroot'ing
>>
>>
>> What do you think about this ?
>>
>>
>> cu
>> -- 
>> ---------------------------------------------------------------------
>> Enrico Weigelt    ==   metux IT service - http://www.metux.de/
>> ---------------------------------------------------------------------
>> Please visit the OpenSource QM Taskforce:
>> 	http://wiki.metux.de/public/OpenSource_QM_Taskforce
>> Patches / Fixes for a lot dozens of packages in dozens of versions:
>> 	http://patches.metux.de/
>> ---------------------------------------------------------------------
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
