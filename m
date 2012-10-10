Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f46.google.com ([209.85.215.46]:65072 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755657Ab2JJKON (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Oct 2012 06:14:13 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so241106lag.19
        for <linux-nfs@vger.kernel.org>; Wed, 10 Oct 2012 03:14:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <507474F5.8050307@panasas.com>
References: <CA+a=Yy5+i+z++XHkKkyFav1nE9pdccwUpz2=GW2J1GDRseR8jA@mail.gmail.com>
 <507470AB.8030900@panasas.com> <507474F5.8050307@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Wed, 10 Oct 2012 18:13:50 +0800
Message-ID: <CA+a=Yy4jw744eDR56o9JdVwzRBOakXZJpoY2mfkMrQ+LLkT0MA@mail.gmail.com>
Subject: Re: [PATCH-Resend] NFS41: layoutget optimize and pnfsblock cleanup
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        linuxnfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 10, 2012 at 3:03 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 10/09/2012 11:44 AM, Boaz Harrosh wrote:
>> On 10/07/2012 02:59 PM, Peng Tao wrote:
>>> Hi Trond,
>>>
>>> Following first three patches were sent before and optimize layoutget size.
>>> Last patch is cleanup and is also sent before.
>>>
>>> Sorry that I have to send patches as attachments. I am having problem
>>> with my smtp setup.
>>>
>>> Thanks,
>>> Tao
>>>
>>
>> Tao hi.
>>
>> What are these patches based on? they do not apply to Linus tree as of today
>> (v3.6-9228-g547b1e8) and they do not apply to v3.6 nor v3.5 tags.
>>
>> I get a conflict on the first patch:
>>       NFS: track direct IO left bytes
>>
>
> Actually the second patch does not apply either. minor on pnfs.c but
> a real fallout on blocklayout.c (3 and 4 are fine)
>
Sorry I forgot to mention... They apply to Trond's nfs-for-next
branch, commit (5f65753033d8c5a53e65810bff3832e8282c68d1).

Thanks,
Tao
