Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:32973 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751883AbdFOTLO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jun 2017 15:11:14 -0400
MIME-Version: 1.0
In-Reply-To: <D4ACE39C-B98F-4076-B9D1-9767CE76EFED@dilger.ca>
References: <20170614170653.58083-1-kolga@netapp.com> <20170615081502.GA10599@infradead.org>
 <CAN-5tyEbqtP-=XmHRSKQbRrdPJgw3tmXzW-DmXwTvMLp7xR49w@mail.gmail.com> <D4ACE39C-B98F-4076-B9D1-9767CE76EFED@dilger.ca>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 15 Jun 2017 15:11:12 -0400
Message-ID: <CAN-5tyGvHQPccnps0JGsAfRxeD4cM2OiBAjJsozUgswy07k=XA@mail.gmail.com>
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
To: Andreas Dilger <adilger@dilger.ca>
Cc: Christoph Hellwig <hch@infradead.org>,
        Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 15, 2017 at 2:35 PM, Andreas Dilger <adilger@dilger.ca> wrote:
>
>> On Jun 15, 2017, at 7:07 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Thu, Jun 15, 2017 at 4:15 AM, Christoph Hellwig <hch@infradead.org> wrote:
>>> On Wed, Jun 14, 2017 at 01:06:53PM -0400, Olga Kornievskaia wrote:
>>>> This is a proposal to allow 64bit count to copy and return as
>>>> a result of a copy_file_range. No attempt was made to share code
>>>> with the 32bit function because 32bit interface should probably
>>>> get depreciated.
>>>>
>>>> Why use 64bit? Current uses of 32bit are by clone_file_range()
>>>> which could use 64bit count and NFS copy_file_range also supports
>>>> 64bit count value.
>>>
>>> Please provide a very good use case that actually matters to a large
>>> portion of the Linux users.
>>
>> Reason: it will not hurt any user but it will help for
>> server-to-server NFS copy because for each invocation of of
>> copy_file_range() it requires that the client sends COPY_NOTIFY, then
>> COPY and then a copy triggers a establishment of clientid/session
>> before the reading of the source file can happen. All that could be
>> saved by have a 64bit value.
>
> What is the overhead of sending a couple of RPCs vs. copying 4GB of
> data on the server?

We get about 11% improvement having an interface that removes the need
for multiple calls. That's testing 8gb copy that normally would have
needed 2 copies.

>> Current copy_file_range would work for any file size, it would just
>> need to be called in a loop by the application. With the given
>> proposal, there wouldn't be a need for the application to loop due to
>> the API size limitation. It might still loop if a partial copy was
>> done.
>
>
> Given that there always needs to be a loop to handle partial completion,
> adding the 64-bit syscall doesn't really simplify the application at
> all, but adds duplicate code to the kernel for little benefit.

If 32bit version would be deprecated then there won't be duplicate code.
