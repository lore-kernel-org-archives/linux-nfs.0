Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37466 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751838AbeBYUlt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 25 Feb 2018 15:41:49 -0500
Subject: Re: [PATCH] Add LICENSE for Connectathon test suite
To: Trond Myklebust <trondmy@primarydata.com>,
        "sumitgt@google.com" <sumitgt@google.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <20180224010702.235739-1-sumitgt@google.com>
 <1519441996.24645.5.camel@primarydata.com>
 <CAKVgptYWbvrf6+PUm55id8vBGAkHYaxHRQ8Rx8wURK6cTRSkEg@mail.gmail.com>
 <1519443337.24645.17.camel@primarydata.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <86922e14-8764-6582-047c-e5c39746c21c@RedHat.com>
Date: Sun, 25 Feb 2018 15:41:48 -0500
MIME-Version: 1.0
In-Reply-To: <1519443337.24645.17.camel@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/23/2018 10:35 PM, Trond Myklebust wrote:
> On Sat, 2018-02-24 at 03:17 +0000, Sumit Gouthaman wrote:
>> Sorry, should have clarified in the description.
>>
>> This was after checking with the maintainer Steve Dickson (steved@red
>> hat.com),
>> who suggested we should send in a patch adding the license file.
This is true... 

> 
> In order to do so, you would have to get the consent of the main
> copyright holders. The problem is that the Connectathon event rules
> themselves never contained a copyright assignment or license for the
> test suite contributions, and neither did anyone keep a clear record of
> who contributed what code.The people you talk of... no longer exist... The tests were built
at Lachman Associates back in the late 80's or early 90's
then they were used as the go to tests suite for all those
years at the Sun sponsored Connectations... 

So thee bottom line... there are no "copyright holders".

> 
> I therefore suspect that if you were to talk to your employer's legal
> department, they would strongly advise to let these particular sleeping
> dogs lie.
If the google lawyers are good with this... Why should we be??

steved.

> 
>> On Fri, Feb 23, 2018 at 7:13 PM Trond Myklebust <trondmy@primarydata.
>> com> wrote:
>>> On Fri, 2018-02-23 at 17:07 -0800, Sumit Gouthaman wrote:
>>>> Adding a new LICENSE file with Apache 2.0 License.
>>>>
>>>> Signed-off-by: Sumit Gouthaman <sumitgt@google.com>
>>>> ---
>>>>  LICENSE | 14 ++++++++++++++
>>>>  1 file changed, 14 insertions(+)
>>>>  create mode 100644 LICENSE
>>>>
>>>> diff --git a/LICENSE b/LICENSE
>>>> new file mode 100644
>>>> index 0000000..5e54891
>>>> --- /dev/null
>>>> +++ b/LICENSE
>>>> @@ -0,0 +1,14 @@
>>>> +Copyright 2018, Connectathon NFS Testsuites Authors.
>>>> +
>>>> +Licensed under the Apache License, Version 2.0 (the "License");
>>>> +you may not use this file except in compliance with the License.
>>>> +You may obtain a copy of the License at
>>>> +
>>>> +    http://www.apache.org/licenses/LICENSE-2.0
>>>> +
>>>> +Unless required by applicable law or agreed to in writing,
>>> software
>>>> +distributed under the License is distributed on an "AS IS"
>>> BASIS,
>>>> +WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
>>>> implied.
>>>> +See the License for the specific language governing permissions
>>> and
>>>> +limitations under the License.
>>>> +
>>>
>>> Exactly what claim are you asserting that might give you the right
>>> to
>>> slap a license on it? Unless you are claiming to be the main
>>> author,
>>> then you I can't see that have any right whatsoever to submit this
>>> patch.
>>>
>>> --
>>> Trond Myklebust
>>> Linux NFS client maintainer, PrimaryData
>>> trond.myklebust@primarydata.com
>>
>>
