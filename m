Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:37554 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726351AbeGLTWI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jul 2018 15:22:08 -0400
Received: by mail-ua0-f195.google.com with SMTP id u8-v6so19116779uao.4
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jul 2018 12:11:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180712185611.GB10033@parsley.fieldses.org>
References: <20180709192638.44799-1-kolga@netapp.com> <20180712185611.GB10033@parsley.fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 12 Jul 2018 15:11:14 -0400
Message-ID: <CAN-5tyFeuDxTFTpM_-ZJp27sc87A1TU0ToDJxb2Kw4jTGFA+-A@mail.gmail.com>
Subject: Re: [PATCH v9 0/9] NFSD support for async COPY
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 12, 2018 at 2:56 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> On Mon, Jul 09, 2018 at 03:26:29PM -0400, Olga Kornievskaia wrote:
>> From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
>>
>> To do asynchronous copies, NFSD creates a new kthread to handle the request.
>> Upon receiving the COPY, it generates a unique copy stateid (stored in a
>> global list for keeping track of state for OFFLOAD_STATUS to be queried by),
>> starts the thread, and replies back to the client. nfsd4_copy arguments that
>> are allocated on the stack are copies for the kthread.
>>
>> For the async copy handler, copy is done in the loop for the requested
>> number of bytes. If an error is encountered and partial copy has happened,
>> a successful partial copy is returned in the CB_OFFLOAD. vfs_copy_file_range
>> is called with 4MB chunks for both async and sync, allowing for 4MB
>> granularity of OFFLOAD_STATUS queiry. Once copy is done, the results are
>> queued for the callback workqueue and sent via CB_OFFLOAD.
>>
>> When the server received an OFFLOAD_CANCEL, it will find the kthread running
>> the copy and will send a SIGPENDING and kthread_stop() and it will interrupt
>> the ongoing do_splice() and once vfs returns we are choosing not to send
>> the CB_OFFLOAD back to the client.
>>
>> When the server receives an OFFLOAD_STATUS, it will find the kthread running
>> the copy and will locate within the copy state the current number of bytes
>> copied so far.
>>
>> v9:
>> -- added module parameter (async_copy_offload_enable) to turns on async
>> copy processing on the server
>
> I think we got confused in the previous discussion of this.
>
> The reason I wanted the module parameter was that server-to-server copy
> would allow a rogue client to direct the server to copy from any server
> it wishes, and I thought this was potentially risky, and want people to
> opt into it rather than having it the default.
>
> That doesn't apply to asynchronous copy on its own.
>
> So this module parameter could wait for the next patchset.

To clarify, you want "inter" copy offload to be configuration, but it
already was (when it was first posted) under config option. Now
instead of a compile option you prefer this to be a module parameter?

Do you have any other comments? I'd rather not re-post another version
if you have more comments.

>
> --b.
>
>> -- fixes some kbuild errors from the previous submission
>>
>>
>> Olga Kornievskaia (9):
>>   NFSD CB_OFFLOAD xdr
>>   NFSD OFFLOAD_STATUS xdr
>>   NFSD OFFLOAD_CANCEL xdr
>>   NFSD xdr callback stateid in async COPY reply
>>   NFSD introduce async copy feature
>>   NFSD create new stateid for async copy
>>   NFSD handle OFFLOAD_CANCEL op
>>   NFSD support OFFLOAD_STATUS
>>   NFSD stop ongoing async copies on client shutdown
>>
>>  fs/nfsd/netns.h        |   8 ++
>>  fs/nfsd/nfs4callback.c |  98 +++++++++++++++++
>>  fs/nfsd/nfs4proc.c     | 291 ++++++++++++++++++++++++++++++++++++++++++++++---
>>  fs/nfsd/nfs4state.c    |  38 ++++++-
>>  fs/nfsd/nfs4xdr.c      |  50 +++++++--
>>  fs/nfsd/nfsctl.c       |   1 +
>>  fs/nfsd/nfssvc.c       |   6 +
>>  fs/nfsd/state.h        |  10 ++
>>  fs/nfsd/xdr4.h         |  29 +++++
>>  fs/nfsd/xdr4cb.h       |  10 ++
>>  10 files changed, 517 insertions(+), 24 deletions(-)
>>
>> --
>> 1.8.3.1
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
