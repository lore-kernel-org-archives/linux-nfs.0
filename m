Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:11244 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269Ab3KYU6A convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Nov 2013 15:58:00 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 fix a kswap nfs4_state_manger race
Date: Mon, 25 Nov 2013 20:57:58 +0000
Message-ID: <A3F7EC45-D493-4A09-A90B-FA5D3E44AFEF@netapp.com>
References: <1385402270-14284-1-git-send-email-andros@netapp.com>
 <1385402270-14284-2-git-send-email-andros@netapp.com>
 <5B8C7A9D-CD9E-487A-AC62-B1292649835D@netapp.com>
 <496E7DBC-183B-43A2-91D4-837FC092E88A@netapp.com>
 <676D25D8-B845-42BC-BB1E-6441B6B8E5E3@netapp.com>
 <5BE68579-3F17-4786-89B9-21CEC1A94E8E@netapp.com>
 <48468258-591E-49A8-9EAA-2DD8E3993100@netapp.com>
 <A18682DD-86C4-47C0-89F4-B8298F918AC9@netapp.com>
 <3A65AD2F-797E-4292-BA9C-4CF20BD075CB@netapp.com>
 <79AE6267-FF17-4299-B127-EB10E0B243D1@netapp.com>
In-Reply-To: <79AE6267-FF17-4299-B127-EB10E0B243D1@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 25, 2013, at 15:51, Adamson, Andy <William.Adamson@netapp.com> wrote:

> 
> On Nov 25, 2013, at 3:29 PM, "Adamson, Andy" <William.Adamson@netapp.com>
> wrote:
> 
>> 
>> On Nov 25, 2013, at 3:20 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
>> wrote:
>> 
>>> 
>>> On Nov 25, 2013, at 15:10, Adamson, Andy <William.Adamson@netapp.com> wrote:
>>> 
>>>> 
>>>> On Nov 25, 2013, at 2:53 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
>>>> wrote:
>>>> 
>>>>> 
>>>>> On Nov 25, 2013, at 14:27, Adamson, Andy <William.Adamson@netapp.com> wrote:
>>>>> 
>>>>>> 
>>>>>> On Nov 25, 2013, at 1:33 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
>>>>>> wrote:
>>>>>> 
>>>>>>> 
>>>>>>> On Nov 25, 2013, at 13:13, Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:
>>>>>>> 
>>>>>>>> 
>>>>>>>> On Nov 25, 2013, at 12:57, <andros@netapp.com> <andros@netapp.com> wrote:
>>>>>>>> 
>>>>>>>>> From: Andy Adamson <andros@netapp.com>
>>>>>>>>> 
>>>>>>>>> The state manager is recovering expired state and recovery OPENs are being
>>>>>>>>> processed. If kswapd is pruning inodes at the same time, a deadlock can occur
>>>>>>>>> when kswapd calls evict_inode on an NFSv4.1 inode with a layout, and the
>>>>>>>>> resultant layoutreturn gets an error that the state mangager is to handle,
>>>>>>>>> causing the layoutreturn to wait on the (NFS client) cl_rpcwaitq.
>>>>>>>>> 
>>>>>>>>> At the same time an open is waiting for the inode deletion to complete in
>>>>>>>>> __wait_on_freeing_inode.
>>>>>>>>> 
>>>>>>>>> If the open is either the open called by the state manager, or an open from
>>>>>>>>> the same open owner that is holding the NFSv4.0 sequence id which causes the
>>>>>>>>> OPEN from the state manager to wait for the sequence id on the Seqid_waitqueue,
>>>>>>>>> then the state is deadlocked with kswapd.
>>>>>>>>> 
>>>>>>>>> Do not handle LAYOUTRETURN errors when called from nfs4_evict_inode.
>>>>>>>> 
>>>>>>>> Why are we waiting for recovery in LAYOUTRETURN at all? Layouts are automatically lost when the server reboots or when the lease is otherwise lost.
>>>>>>>> 
>>>>>>>> IOW: Is there any reason why we need to special-case nfs4_evict_inode? Shouldn’t we just bail out on error in _all_ cases?
>>>>>>> 
>>>>>>> BTW: Is it possible that we might have a similar problem with delegreturn? That too can be called from nfs4_evict_inode…
>>>>>> 
>>>>>> Yes, good point.  kswapd could be waiting for a delegation to return which has an error along with the same scenario with sys_open and the state manager running.
>>>>>> 
>>>>>> With delegreturn, we most definately want to limit 'no error handling' to the evict inode case.
>>>>> 
>>>>> Ah… I forgot that the delegreturn in nfs4_evict_inode is asynchronous and doesn’t wait for completion, so it shouldn’t be a problem here.
>>>> 
>>>> Except we just changed that to fix a different state manager hang:
>>>> 
>>>> commit 4a82fd7c4e78a1b7a224f9ae8bb7e1fd95f670e0
>>>> Author: Andy Adamson <andros@netapp.com>
>>>> Date:   Fri Nov 15 16:36:16 2013 -0500
>>>> 
>>>> NFSv4 wait on recovery for async session errors
>>> 
>>> Right, but that won’t prevent nfs4_evict_inode from completing,
>> 
>> Ah - I was thinking of the synchronous handlers call to nfs4_wait_clnt_recover - so yes, no problem
> 
> In fact, this issue is NOT an upstream issue!  RHEL6.5-pre has nfs4_proc_layoutreturn as as SYNC rpc call, and _that_ is the bug that is fixed upstream.
> 
> Really sorry for the confusion. I'll back port a solution for RHEL6.5

Are you sure? As far as I can tell, the upstream nfs4_proc_layoutreturn is also synchronous. I therefore suspect that we still have the same problem.

--
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

