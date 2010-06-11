Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:40378 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754563Ab0FKIrf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jun 2010 04:47:35 -0400
Received: by wwb18 with SMTP id 18so540371wwb.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 01:47:31 -0700 (PDT)
In-Reply-To: <4C11EEAD.8060803@panasas.com>
References: <1276242039-18649-1-git-send-email-iisaman@netapp.com>
	<4C11EEAD.8060803@panasas.com>
Date: Fri, 11 Jun 2010 04:47:31 -0400
Message-ID: <AANLkTinwz5TNku2DCC1wszhBngklvOMTJhP7Oho_INJP@mail.gmail.com>
Subject: Re: [PATCH 0/7] LAYOUTGET invocation cleanup patches
From: Fred Isaman <iisaman@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jun 11, 2010 at 4:07 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 06/11/2010 10:40 AM, Fred Isaman wrote:
>> These patches, applied to the head of pnfs-all-latest after rebase, bring
>> the blocklayout back in synch with the generic code changed by my previous
>> patches and the rebase.  The final tree containing the fully rebased tree
>> with these patches applied is at
>> git://linux-nfs.org/~isaman/pnfs-block.git in the branch for-benny-20100611.
>>
>
> Grate Fred with a git tree it is actually usable.
>
> I will clone your tree. And'll inspect it carefully on the flight.
> I want to do even more. I'd like to rebase them over an Alexandros-less
> patchset and actually test them. How hard will that be? Perhaps you
> might have a branch based on 2.6.34 without Alexandros patches that
> are up to date? Could you push it for me?
>

I switched the order of the two patchsets at one point, and it wasn't too hard.
The original patchset I submitted was based directly on the then
pnfs-submit tree.

Right now something is wrong with my connection between here and linux-nfs.org.
At the current rate, the push of the tree I mentioned above will be
done in about 10 hours :(

I don't think I'll be pushing any other tree soon.

Fred

>> Fred
>>
>
> Thanks
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
