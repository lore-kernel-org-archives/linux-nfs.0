Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cit-hm8-mail01.bmw-carit.de ([212.118.206.84]:25866 "EHLO
        cit-hm8-gw01.bmw-carit.de" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755037AbcIZFjB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2016 01:39:01 -0400
Subject: Re: [PATCH 0/2] NFS: Use complete() instead complete_all()
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Daniel Wagner <wagi@monom.org>, <linux-nfs@vger.kernel.org>
References: <1474545269-8694-1-git-send-email-wagi@monom.org>
 <ca2d158b-ebdd-a709-a63a-421a11d8ca0a@Netapp.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        <linux-kernel@vger.kernel.org>
From: Daniel Wagner <daniel.wagner@bmw-carit.de>
Message-ID: <74468e19-772d-41b8-b7df-c0aa845e52ab@bmw-carit.de>
Date: Mon, 26 Sep 2016 07:33:44 +0200
MIME-Version: 1.0
In-Reply-To: <ca2d158b-ebdd-a709-a63a-421a11d8ca0a@Netapp.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna,

On 09/23/2016 03:48 PM, Anna Schumaker wrote:
>> Besides trying to analys all the code paths to the wait_for_completion()
>> call and convince myself that there is only one waiter, I also run
>> a few tests:
>>
>>  - some fio benchmarks
>>  - pynfs
>>   -cthon04
>
> Thanks for the patches, and for the extensive testing!  I haven't
> tried them with xfstests yet, but They look okay to me otherwise.
> Assuming I don't see any new failures there I'll plan on adding them
> for v4.9.

I tried a few tests from xfstests but I was not sure which make sense to 
run, that's why I went for the more NFS specific tests.

I'll see what happens when I run the generic tests from xfstests. Should 
all of them pass?

cheers,
daniel
