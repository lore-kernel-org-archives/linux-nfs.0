From: Fred Isaman <iisaman@umich.edu>
Subject: Re: [PATCH 0/7] LAYOUTGET invocation cleanup patches
Date: Fri, 11 Jun 2010 09:44:32 -0400
Message-ID: <AANLkTinJ8-lSQ-vKUUEsvFecrinaEglQ-5hK6mKfopPP@mail.gmail.com>
References: <1276242039-18649-1-git-send-email-iisaman@netapp.com>
	<4C11EEAD.8060803@panasas.com>
	<AANLkTinwz5TNku2DCC1wszhBngklvOMTJhP7Oho_INJP@mail.gmail.com>
	<4C11FAD1.10207@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
To: Boaz Harrosh <bharrosh@panasas.com>,
	Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:42472 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760292Ab0FKNod convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jun 2010 09:44:33 -0400
Received: by yxl31 with SMTP id 31so241739yxl.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 06:44:33 -0700 (PDT)
In-Reply-To: <4C11FAD1.10207@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 11, 2010 at 4:58 AM, Boaz Harrosh <bharrosh@panasas.com> wr=
ote:
> On 06/11/2010 11:47 AM, Fred Isaman wrote:
>> On Fri, Jun 11, 2010 at 4:07 AM, Boaz Harrosh <bharrosh@panasas.com>=
 wrote:
>>> On 06/11/2010 10:40 AM, Fred Isaman wrote:
>>>> These patches, applied to the head of pnfs-all-latest after rebase=
, bring
>>>> the blocklayout back in synch with the generic code changed by my =
previous
>>>> patches and the rebase. =A0The final tree containing the fully reb=
ased tree
>>>> with these patches applied is at
>>>> git://linux-nfs.org/~isaman/pnfs-block.git in the branch for-benny=
-20100611.
>>>>
>>>
>>> Grate Fred with a git tree it is actually usable.
>>>
>>> I will clone your tree. And'll inspect it carefully on the flight.
>>> I want to do even more. I'd like to rebase them over an Alexandros-=
less
>>> patchset and actually test them. How hard will that be? Perhaps you
>>> might have a branch based on 2.6.34 without Alexandros patches that
>>> are up to date? Could you push it for me?
>>>
>>
>> I switched the order of the two patchsets at one point, and it wasn'=
t too hard.
>> The original patchset I submitted was based directly on the then
>> pnfs-submit tree.
>>
>> Right now something is wrong with my connection between here and lin=
ux-nfs.org.
>> At the current rate, the push of the tree I mentioned above will be
>> done in about 10 hours :(
>>
>> I don't think I'll be pushing any other tree soon.
>>
>> Fred
>>
>>>> Fred
>>>>
>
> Fred I get:
> $ git ls-remote git://linux-nfs.org/~isaman/pnfs-block.git
> fatal: The remote end hung up unexpectedly
>
> Maybe it's that you are pushing, or there might be a problem.
> Perhaps check the permission, or maybe it needs added to git-daemon
> (and service restart)
>
> Benny's tree access is fine.
>
> I'll try to connect from home on Saturday and clone it. See if you
> can fix the access problem when you are done.
>
> BTW: it should not take so long. You should first clone a tree from
> =A0 =A0 Benny, locally. Do you have a ssh access? then pusshing just =
your
> =A0 =A0 changes should be very fast. Perhaps you are pushing the full
> =A0 =A0 tree by dialup, that's not smart.
>
> Boaz
>
>
>

OK, it has finished, and seems to be working now.

=46red

>
>
>
