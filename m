Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:60218 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932240Ab0FKI67 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jun 2010 04:58:59 -0400
Message-ID: <4C11FAD1.10207@panasas.com>
Date: Fri, 11 Jun 2010 11:58:57 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Fred Isaman <iisaman@umich.edu>
CC: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] LAYOUTGET invocation cleanup patches
References: <1276242039-18649-1-git-send-email-iisaman@netapp.com>	<4C11EEAD.8060803@panasas.com> <AANLkTinwz5TNku2DCC1wszhBngklvOMTJhP7Oho_INJP@mail.gmail.com>
In-Reply-To: <AANLkTinwz5TNku2DCC1wszhBngklvOMTJhP7Oho_INJP@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/11/2010 11:47 AM, Fred Isaman wrote:
> On Fri, Jun 11, 2010 at 4:07 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>> On 06/11/2010 10:40 AM, Fred Isaman wrote:
>>> These patches, applied to the head of pnfs-all-latest after rebase, bring
>>> the blocklayout back in synch with the generic code changed by my previous
>>> patches and the rebase.  The final tree containing the fully rebased tree
>>> with these patches applied is at
>>> git://linux-nfs.org/~isaman/pnfs-block.git in the branch for-benny-20100611.
>>>
>>
>> Grate Fred with a git tree it is actually usable.
>>
>> I will clone your tree. And'll inspect it carefully on the flight.
>> I want to do even more. I'd like to rebase them over an Alexandros-less
>> patchset and actually test them. How hard will that be? Perhaps you
>> might have a branch based on 2.6.34 without Alexandros patches that
>> are up to date? Could you push it for me?
>>
> 
> I switched the order of the two patchsets at one point, and it wasn't too hard.
> The original patchset I submitted was based directly on the then
> pnfs-submit tree.
> 
> Right now something is wrong with my connection between here and linux-nfs.org.
> At the current rate, the push of the tree I mentioned above will be
> done in about 10 hours :(
> 
> I don't think I'll be pushing any other tree soon.
> 
> Fred
> 
>>> Fred
>>>

Fred I get:
$ git ls-remote git://linux-nfs.org/~isaman/pnfs-block.git
fatal: The remote end hung up unexpectedly

Maybe it's that you are pushing, or there might be a problem.
Perhaps check the permission, or maybe it needs added to git-daemon
(and service restart)

Benny's tree access is fine.

I'll try to connect from home on Saturday and clone it. See if you
can fix the access problem when you are done.

BTW: it should not take so long. You should first clone a tree from
     Benny, locally. Do you have a ssh access? then pusshing just your
     changes should be very fast. Perhaps you are pushing the full
     tree by dialup, that's not smart.

Boaz






