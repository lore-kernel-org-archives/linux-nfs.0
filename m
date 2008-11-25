From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/4] Support for IPv6 in the showmount command
Date: Tue, 25 Nov 2008 13:36:54 -0500
Message-ID: <53AEB619-3E79-4E18-AF25-B5AFE821FCBE@oracle.com>
References: <20081118192711.22516.2801.stgit@ingres.1015granger.net> <492C0B6C.7070104@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:54631 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbYKYShP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2008 13:37:15 -0500
In-Reply-To: <492C0B6C.7070104-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 25, 2008, at Nov 25, 2008, 9:27 AM, Steve Dickson wrote:
> Chuck Lever wrote:
>> Hi Steve-
>>
>> These patches implement support for rpcbind v3/v4 queries and IPv6  
>> NFS
>> servers in the showmount command.  Please consider these for the next
>> release of nfs-utils.
>>
>> Thanks!
>>
>> ---
>>
>> Chuck Lever (4):
>>      showmount command: support querying IPv6 servers
>>      showmount command: move logic to acquire RPC client handle out  
>> of main()
>>      showmount command: Remove unused local getport() implementation
>>      showmount command: call nfs_getport instead of local getport
>>
>>
>> utils/showmount/showmount.c |  237 ++++++++++++++++ 
>> +--------------------------
>> 1 files changed, 91 insertions(+), 146 deletions(-)
> All four patch have been committed and regression tested...

Thanks.

Neil posted a patch around start_statd earlier this week.  My next set  
of patches touches this part of mount.nfs. Are you planning to apply  
his patch?  I can wait for that and rework my patches when you're ready.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
