Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:64604 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935875AbcIZNb7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Sep 2016 09:31:59 -0400
Subject: Re: [PATCH 0/2] NFS: Use complete() instead complete_all()
To: Daniel Wagner <daniel.wagner@bmw-carit.de>,
        Daniel Wagner <wagi@monom.org>, <linux-nfs@vger.kernel.org>
References: <1474545269-8694-1-git-send-email-wagi@monom.org>
 <ca2d158b-ebdd-a709-a63a-421a11d8ca0a@Netapp.com>
 <74468e19-772d-41b8-b7df-c0aa845e52ab@bmw-carit.de>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        <linux-kernel@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <ded5c166-aa7e-ce61-8190-ffc15c7d1b12@Netapp.com>
Date: Mon, 26 Sep 2016 09:31:54 -0400
MIME-Version: 1.0
In-Reply-To: <74468e19-772d-41b8-b7df-c0aa845e52ab@bmw-carit.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/26/2016 01:33 AM, Daniel Wagner wrote:
> Hi Anna,
> 
> On 09/23/2016 03:48 PM, Anna Schumaker wrote:
>>> Besides trying to analys all the code paths to the wait_for_completion()
>>> call and convince myself that there is only one waiter, I also run
>>> a few tests:
>>>
>>>  - some fio benchmarks
>>>  - pynfs
>>>   -cthon04
>>
>> Thanks for the patches, and for the extensive testing!  I haven't
>> tried them with xfstests yet, but They look okay to me otherwise.
>> Assuming I don't see any new failures there I'll plan on adding them
>> for v4.9.
> 
> I tried a few tests from xfstests but I was not sure which make sense to run, that's why I went for the more NFS specific tests.
> 
> I'll see what happens when I run the generic tests from xfstests. Should all of them pass?

No, there are a handful that we know don't pass.  When I run on NFS v4.1, I get:

        Failures: generic/035 generic/071 generic/128 generic/294 generic/306 generic/309 generic/310 generic/313 generic/314 generic/315 generic/316 generic/319 generic/337 generic/360 generic/375
        Failed 15 of 92 tests

Thanks,
Anna

> 
> cheers,
> daniel

