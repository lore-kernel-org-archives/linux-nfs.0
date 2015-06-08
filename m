Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28098 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938AbbFHQKE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 12:10:04 -0400
Message-ID: <5575BE58.3050301@oracle.com>
Date: Mon, 08 Jun 2015 09:10:00 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH V3 0/7] nfsd/sunrpc: prepare nfsd to add workqueue
 support
References: <557525DD.6070300@oracle.com>	<CAHQdGtSrgLaTRDBxtUCKrt+90WrJq2YR_VfSi9RC4_7m0k--3w@mail.gmail.com>	<20150608093437.3bb9b028@synchrony.poochiereds.net>	<20150608145730.GE24159@fieldses.org> <20150608115113.349061b5@tlielax.poochiereds.net>
In-Reply-To: <20150608115113.349061b5@tlielax.poochiereds.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/08/2015 08:51 AM, Jeff Layton wrote:
> On Mon, 8 Jun 2015 10:57:30 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
>> On Mon, Jun 08, 2015 at 09:34:37AM -0400, Jeff Layton wrote:
>>> On Mon, 8 Jun 2015 09:15:28 -0400
>>> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>>
>>>> On Mon, Jun 8, 2015 at 1:19 AM, Shirley Ma <shirley.ma@oracle.com> wrote:
>>>>> This patchset was originally written by Jeff Layton from adding support for a workqueue-based nfsd. I am helping on stability test and performance analysis. There are some workloads benefit from global threading mode, some workloads benefit from workqueue mode. I am still investigating on how to make workqueue mode better to bid global theading mode. I am splitting the patchset into two parts: one is preparing nfsd to add workqueue mode, one is adding workqueue mode. The test results show that the first part doesn't cause much performance change, the results are within the variation from each run.
>>>>
>>>> As stated in the original emails, Primary Data's internal testing of
>>>> these patches showed that there is a significant difference. We had 48
>>>> virtual clients running on 7 ESX hypervisors with 10GigE NICs against
>>>> a hardware NFSv3 server with a 40GigE NIC. The clients were doing 4k
>>>> aio/dio reads+writes in a 70/30 mix.
>>>> At the time, we saw a roughly 50% decrease with measured standard
>>>> deviations being of the order a few % when comparing the performance
>>>> as measured in IOPs between the existing code and the workqueue code.
>>>>
>>>> Testing showed the workqueue performance was relatively improved when
>>>> we upped the block size to 256k (with lower IOPs counts). That would
>>>> indicate that the workqueues are failing to scale correctly for the
>>>> high IOPs (i.e. high thread count) case.
I am still investing the workqueue patchset performance gain and cost. I did see in some random write/read workloads workqueue made a big difference. If we can have both modes support, then the customer can switch modes based up their workloads preferences.

>>>> Trond
>>>
>>> Yes.
>>>
>>> Also, I did some work with tracepoints to see if I could figure out
>>> where the extra latency was coming from. At the time, the data I
>>> collected showed that the workqueue server was processing incoming
>>> frames _faster_ than the thread based one.
>>>
>>> So, my theory (untested) is that somehow the workqueue server is
>>> causing extra latency in processing interrupts for the network card or
>>> disk. The test I was using at the time was to just dd a bunch of
>>> sequential reads and writes to a file. I figured that was as simple a
>>> testcase as you could get...
>>>
>>> In any case though, the patches that Shirley is proposing here don't
>>> actually add any of the workqueue based server code. It's all just
>>> preparatory patches to add an ops structure to the svc_serv and move a
>>> bunch of disparate function pointers into it. I think that's a reasonable
>>> set to take, even if we don't take the workqueue code itself as it
>>> cleans up the rpc server API considerably (IMNSHO).
>>
>> OK.  And just out of paranoia--you didn't notice any significant
>> difference with the new patches running in the old thread-based mode,
>> right?
>>
>> --b.
> No, we didn't notice any substantive difference. I'd be quite surprised
> if there were. There might be (e.g.) slightly more pointer-chasing with
> this set (since you have to look in the ops structure), but it doesn't
> make much in the way of substantive changes to how the code works.
 
Right, not much difference from my test results.

Shirley
