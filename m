Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51716 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753610AbcD0Rud (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2016 13:50:33 -0400
Subject: Re: [PATCH v3 1/3] gssd: use pthreads to handle upcalls
To: "Kornievskaia, Olga" <Olga.Kornievskaia@netapp.com>
References: <1461603513-67523-1-git-send-email-kolga@netapp.com>
 <1461603513-67523-2-git-send-email-kolga@netapp.com>
 <5720D2BA.5010400@RedHat.com>
 <59AF3631-819C-42E5-AB0D-3483590E279D@netapp.com> <5720D977.10008@RedHat.com>
 <57DB10EC-2538-4191-B5D7-03D53FD1F9C9@netapp.com>
 <FDB72BF5-75F1-4A03-84B5-F4E1A06263C8@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <5720FBE7.2000300@RedHat.com>
Date: Wed, 27 Apr 2016 13:50:31 -0400
MIME-Version: 1.0
In-Reply-To: <FDB72BF5-75F1-4A03-84B5-F4E1A06263C8@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/27/2016 12:33 PM, Kornievskaia, Olga wrote:
>>>> I think the biggest saving would be to take the next step 
>>>> and do the pool of threads that are pre-created (and thus 
>>>> not taking time to be allocated for each upcall). Then we 
>>>> need a way to make sure we cleanup any threads that might 
>>>> be hanging for whatever reason.
>>> This will be an excellent next step! 
>>
>> This patch series is suppose to show ‘proof-of-concept’ and 
>> functionally equivalent but better to what we have now. 
>> Old: upcall -> new process. New: upcall -> new thread. 
>> Old: process hangs -> resources not cleaned and no new upcalls. 
>> New: thread hangs -> resources not cleaned and new upcalls can proceed.
Well I think you proved it... Nice work!

>>
>> I will submit the new version with:
>> — make function inline
>> — change setresuid/setresgid to set all three uids: real, effective, saved. git blame tells me Jeff you wrote the comment about attacks from ptrace().
> 
> Sorry I unintentionally hit send. I wanted to say that then I’ll work on 
> getting the pool of thread but working on top of these patches. 
> Or do you want me to keep working and then submit that version 
> as if this one wasn’t written? 
Let's get these in now so they will get some real world 
testing... So lets build on these... 

steved.
