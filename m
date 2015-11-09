Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41073 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797AbbKIULb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2015 15:11:31 -0500
Subject: Re: [RFC PATCH] Using pthreads to handle upcalls.
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <1447074308-15823-1-git-send-email-steved@redhat.com>
 <20151109183938.GD8738@fieldses.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <5640FDF2.9040802@RedHat.com>
Date: Mon, 9 Nov 2015 15:11:30 -0500
MIME-Version: 1.0
In-Reply-To: <20151109183938.GD8738@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey,

On 11/09/2015 01:39 PM, J. Bruce Fields wrote:
> On Mon, Nov 09, 2015 at 08:05:07AM -0500, Steve Dickson wrote:
>> Recently a bug was found that was causing a
>> TGT fetch for every mount upcall. The bug was
>> caused when forking for every mount was introduce.
>> The global memory for the TGT cache was being
>> freed when the forked process existed. 
>>
>> The fix we came up with was to only fork on non-root
>> upcalls, basically mount upcalls would no longer fork.
>> In debugging the patch it became apparent that if the
>> process hung, all NFS mounts on that client would be blocked.
>> So at this point rpc.gssd is a single point of failure.
>>
>> This patch replaces the forking/non-forking with creating
>> pthreads for every upcall which I think is a better 
>> solution to the original problem since pthreads can share
>> global data. 
> 
> I seem to recall the reason for the fork is to allow dropping some
> privileges while processing the upcall, is that right? 
I don't see this where privileges are being dropped. 

> But looking at pthreads(7), it looks like those are probably 
> shared (e.g., it says user and group IDs are process-wide).
I think they are and that's also why thread can access the
same global data. 

> 
>> I was also hoping using pthread would bring more asynchronous
>> to rpc.gssd. I was thinking rpc.gssd could take an upcall,
>> fire off a thread to handle it, the go back and listen
>> for more upcalls. 
>>
>> Unfortunately this is not the case. It seems, maybe due to
>> my lack of my pthreads understanding, that after each 
>> pthread_create() call, a pthread_join() call, which waits for 
>> the created to stop, is needed. Similar to fork/wait..
> 
> Actually making gssd thread-safe would be a significant effort.
Is it because the MIT libs are not thread-safe? Isn't the 
gssd_k5_kt_princ_list the only global list?

Something to do with the upcalls? 

> 
>> This means if an upcall pthread gets hung the daemon
>> is also hung... The same single point of failure... 
>>
>> I do believe using threads is a better solution than
>> the non-fork solution, but rpc.gssd is still a single 
>> point of failure. Plus I'm hoping moving to pthread will 
>> allow us to solve that problem.
> 
> So this doesn't actually fix anything right now?
No.. it does not... :-)  But I do think its a clearer way 
handling global lists via multiple threads/process. It also makes 
the top of process_krb5_upcall easier to read, IMHO... 

Plus it does introduce pthread to nfs-utils.. So maybe some
day we can pull some these daemons into the 21th century 
by multi-threading them.. or kill them! I'm good either way. 8-)

Thanks for the cycles!!! 

steved.
