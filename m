From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Fixed segfault in rpc.mountd
Date: Wed, 26 Jan 2011 11:34:15 -0500
Message-ID: <4D404D07.9040200@RedHat.com>
References: <1296046655-20246-1-git-send-email-steved@redhat.com> <C6DF5374-6E97-459B-BED1-B044B456AAFE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43443 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428Ab1AZQeS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jan 2011 11:34:18 -0500
In-Reply-To: <C6DF5374-6E97-459B-BED1-B044B456AAFE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/26/2011 10:35 AM, Chuck Lever wrote:
> 
> On Jan 26, 2011, at 7:57 AM, Steve Dickson wrote:
> 
>> A unallocated piece of memory, instead of a NULL point, was being
>> used to initialize a ->next point in the mount link list which
>> caused a segfault after a few remote accesses via the showmount
>> command.
> 
> I thought there was a patch on the list just like this last week... in any event:
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Thanks! 

steved.
> 
> 
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>> utils/mountd/rmtab.c |    1 +
>> 1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
>> index d339296..527377f 100644
>> --- a/utils/mountd/rmtab.c
>> +++ b/utils/mountd/rmtab.c
>> @@ -205,6 +205,7 @@ mountlist_list(void)
>> 	}
>> 	if (stb.st_mtime != last_mtime) {
>> 		mountlist_freeall(mlist);
>> +		mlist = NULL;
>> 		last_mtime = stb.st_mtime;
>>
>> 		setrmtabent("r");
> 
