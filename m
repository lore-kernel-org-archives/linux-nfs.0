Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:58537 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761372Ab3JPSqO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 14:46:14 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        William Dauchy <wdauchy@gmail.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Fix NULL dereference in recovery path
Date: Wed, 16 Oct 2013 18:46:11 +0000
Message-ID: <9E03C1BB-7194-4359-87E9-10C6EFDB5EC0@netapp.com>
References: <1381188833-3728-1-git-send-email-dros@netapp.com>
 <55848506-CAF1-47C5-9442-0E3AB3D2A398@netapp.com>
 <CAJ75kXZT5HPqh8oMw8LTzNMxVYQm8o01+m8_ghufaTfiD60Pew@mail.gmail.com>
 <300B01EF-CEB0-41EE-BAF4-655728DF90EE@netapp.com>
In-Reply-To: <300B01EF-CEB0-41EE-BAF4-655728DF90EE@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok, I figured this out.

Bisecting took me to 5f65753033d8c5a53e65810bff3832e8282c68d1, which seems unrelated, but blocks open (and open recover) code paths from being run, so the real culprit is two commits back e23008ec81ef37b7b271669ce5d2de2643b2dc75. I changed the order of these patches and verified that e23008ec81ef37b7b271669ce5d2de2643b2dc75 introduces the NULL dereference.

e23008ec81ef37b7b271669ce5d2de2643b2dc75 is in all tags since v3.7.

Trond:

Please CC stable with a note that this is for v3.7+. I'll add the CC if I need to repost upon review.

-dros

On Oct 15, 2013, at 1:43 PM, Weston Andros Adamson <dros@netapp.com> wrote:

> I plan on bisecting this next time I get a few spare cycles.
> 
> -dros
> 
> On Oct 14, 2013, at 11:51 AM, William Dauchy <wdauchy@gmail.com> wrote:
> 
>> On Tue, Oct 8, 2013 at 1:40 AM, Weston Andros Adamson <dros@netapp.com> wrote:
>>> This is the bug I found at the bakeathon. I can finally reproduce it quickly! And in a shockingly easy way!
>>> Tomorrow I'll figure out how long this regression has been present and if we need to CC stable.
>> 
>> Any news on that? Does it apply on older version?
>> 
>> Thanks,
>> 
>> -- 
>> William
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

