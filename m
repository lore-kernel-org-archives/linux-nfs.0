Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:25804 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383Ab3KAQix convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Nov 2013 12:38:53 -0400
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: clientid is in use
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5272CA26.8010304@uw.edu>
Date: Fri, 1 Nov 2013 12:38:47 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <BE23E12D-D5F5-4E04-ACBA-E62C9EE558EA@oracle.com>
References: <51FBDB14.4040801@uw.edu> <BE9C4EAA-B835-4021-86C2-D91F66BFF7C8@oracle.com> <5272CA26.8010304@uw.edu>
To: Harry Edmon <harry@uw.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 31, 2013, at 5:22 PM, Harry Edmon <harry@uw.edu> wrote:

> On 08/04/13 12:20, Chuck Lever wrote:
>> On Aug 2, 2013, at 12:15 PM, Harry Edmon <harry@uw.edu> wrote:
>> 
>>> Occasionally I am seeing the following in our kernel log on a NFS client:
>>> 
>>> [2321389.137595] NFS: Server enkf reports our clientid is in use
>>> [2321389.137615] NFS: state manager: lease expired failed on NFSv4 server enkf with error 1
>>> 
>>> The result is that the read of the file in question fails.   This occurs for multiple kernel versions on multiple machines.  Anyone have an idea how I should start debugging this?  How is the clientid calculated/assigned?
>> It depends on the kernel version.  You can look in fs/nfs/nfs4proc.c for the nfs4_proc_setclientid function.
>> 
> I am still occasionally seeing this error.   The last time was with the NFS client and server both running kernel 3.11.6.   The message was on the client.   Here is the mount info from /proc/mounts:
> 
> margaret:/home/margaret/margaret /home/disk/margaret nfs4
> rw,relatime,vers=4.0,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=140.142.113.26,local_lock=none,addr=128.95.89.30
> 0 0
> 
> I am still looking for ideas on how to debug this.

The server is reporting that your clients are using the same client ID.  The client ID is based on the client's hostname.  Are your clients dynamically named?

The description of the nfs4_unique_id parameter in linux/Documentation/filesystems/nfs/nfs.txt might be helpful.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




