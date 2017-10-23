Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:56814 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751271AbdJWWj4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Oct 2017 18:39:56 -0400
Received: by mail-ua0-f195.google.com with SMTP id n22so14116880uaj.13
        for <linux-nfs@vger.kernel.org>; Mon, 23 Oct 2017 15:39:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyEtGgk=_iR60Zr6objNA--9FNQjKYkqRTDydRcAwsxOQw@mail.gmail.com>
References: <20171013205412.65532-1-kolga@netapp.com> <20171013212626.GB28854@parsley.fieldses.org>
 <CAN-5tyETeVgOWKeFSBxQBJi6wwXTcgQqaxxLn0BFXCTCv09h0g@mail.gmail.com>
 <b4f0f30e-c19e-1b2f-7379-d859b4b5ff49@Netapp.com> <20171016164935.GD19720@parsley.fieldses.org>
 <CAN-5tyG74LpQytszp0k_+gCZN-1D_fCUeS=KHD9ggcCOrKfCxQ@mail.gmail.com> <CAN-5tyEtGgk=_iR60Zr6objNA--9FNQjKYkqRTDydRcAwsxOQw@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 23 Oct 2017 18:39:54 -0400
Message-ID: <CAN-5tyGsO-i3nNwwUArFB2D+howw+CJonGGjjCyW_yigGes0xA@mail.gmail.com>
Subject: Re: [PATCH v5 00/10] NFSD support for asynchronous COPY
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

Do you have any more comments on the current async patches or should I
post a new version? I plan to do the original OFFLOAD_STATUS looping
and I'm planning to change server to not send the EINVAL error to the
client and instead send a partial copy and 0 when reading past the end
of the file.

Thanks.

On Mon, Oct 23, 2017 at 5:48 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> Hi Bruce,
>
> You were asking for performance numbers for asynchronous vs
> synchronous intra copy. Here's what Jorge reports:
>
> This is using RHEL 7.4 on both the client and server with COMMIT on
> the same compound as the COPY for the synchronous case.
> In this case, improvement is achieved for copies larger than 16MB.
>
>
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 1KB file: 0.218760585785 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 1KB file: 0.636984395981 seconds
>                                                          65.66%
> performance degradation by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 2KB file: 0.22707760334 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 2KB file: 0.583548688889 seconds
>                                                          61.09%
> performance degradation by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 4KB file: 0.234200882912 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 4KB file: 0.782712388039 seconds
>                                                          70.08%
> performance degradation by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 8KB file: 0.214556503296 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 8KB file: 0.692702102661 seconds
>                                                          69.03%
> performance degradation by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 16KB file: 0.215230226517 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 16KB file: 0.56289691925 seconds
>                                                          61.76%
> performance degradation by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 32KB file: 0.186200523376 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 32KB file: 0.65691485405 seconds
>                                                          71.66%
> performance degradation by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 64KB file: 0.233846497536 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 64KB file: 0.525265741348 seconds
>                                                          55.48%
> performance degradation by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 128KB file: 0.198684954643 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 128KB file: 0.69602959156 seconds
>                                                          71.45%
> performance degradation by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 256KB file: 0.211255192757 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 256KB file: 0.556627941132 seconds
>                                                          62.05%
> performance degradation by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 512KB file: 0.218777489662 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 512KB file: 0.496951031685 seconds
>                                                          55.98%
> performance degradation by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 1MB file: 0.179558849335 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 1MB file: 0.50447602272 seconds
>                                                          64.41%
> performance degradation by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 2MB file: 0.252070856094 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 2MB file: 0.570275163651 seconds
>                                                          55.80%
> performance degradation by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 4MB file: 0.289573478699 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 4MB file: 0.656079149246 seconds
>                                                          55.86%
> performance degradation by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 8MB file: 0.50943710804 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 8MB file: 0.696055078506 seconds
>                                                          26.81%
> performance degradation by async
>
> Performance Improvement:
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 16MB file: 0.920844507217 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 16MB file: 0.817601919174 seconds
>                                                          11.21%
> performance improvement by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 32MB file: 1.46817543507 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 32MB file: 1.24578406811 seconds
>                                                          15.15%
> performance improvement by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 64MB file: 2.42379112244 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 64MB file: 1.58639280796 seconds
>                                                          34.55%
> performance improvement by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 128MB file: 4.16012530327 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 128MB file: 2.58433949947 seconds
>                                                          37.88%
> performance improvement by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 256MB file: 7.56400749683 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 256MB file: 4.43859291077 seconds
>                                                          41.32%
> performance improvement by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 512MB file: 14.5191983461 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 512MB file: 8.18448216915 seconds
>                                                          43.63%
> performance improvement by async
>
> /home/mora/logs/nfstest_ssc_20171022201303.log:    PASS: SSC copy of
> 1GB file: 28.7398069143 seconds
> /home/mora/logs/nfstest_ssc_20171015171323.log:    PASS: SSC copy of
> 1GB file: 16.1399238825 seconds
>                                                          43.84%
> performance improvement by async
>
> On Mon, Oct 16, 2017 at 3:25 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> On Mon, Oct 16, 2017 at 12:49 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>>> On Mon, Oct 16, 2017 at 09:13:20AM -0400, Anna Schumaker wrote:
>>>>
>>>>
>>>> On 10/13/2017 08:09 PM, Olga Kornievskaia wrote:
>>>> > On Fri, Oct 13, 2017 at 5:26 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>>>> >> On Fri, Oct 13, 2017 at 04:54:02PM -0400, Olga Kornievskaia wrote:
>>>> >>> To do asynchronous copies, NFSD creates a new kthread to handle the request.
>>>> >>> Upon receiving the COPY, it generates a unique copy stateid (stored in a
>>>> >>> global list for keeping track of state for OFFLOAD_STATUS to be queried by),
>>>> >>> starts the thread, and replies back to the client. nfsd4_copy arguments that
>>>> >>> are allocated on the stack are copies for the kthread.
>>>> >>>
>>>> >>> In the async copy handler, it calls into VFS copy_file_range() (for synch
>>>> >>> we keep the 4MB chunk and requested size for the async copy). If error is
>>>> >>> encountered it's saved but also we save the amount of data copied so far.
>>>> >>> Once done, the results are queued for the callback workqueue and sent via
>>>> >>> CB_OFFLOAD.
>>>> >>>
>>>> >>> When the server received an OFFLOAD_CANCEL, it will find the kthread running
>>>> >>> the copy and will send a SIGPENDING and kthread_stop() and it will interrupt
>>>> >>> the ongoing do_splice() and once vfs returns we are choosing not to send
>>>> >>> the CB_OFFLOAD back to the client.
>>>> >>>
>>>> >>> When the server receives an OFFLOAD_STATUS, it will find the kthread running
>>>> >>> the copy and will query the i_size_read() of the associated filehandle of
>>>> >>> the destination file and return the result.
>>>> >>
>>>> >> That assumes we're copying into a previously empty file?
>>>> >
>>>> > Sigh. Alright, then it's back to my original solution where I broke
>>>> > everything into 4MB calls and kept track of bytes copies so far.
>>>>
>>>> Do they have to be 4MB calls?  Assuming clients don't need a super-accurate results, you could probably use a larger copy size and still have decent copy performance.
>>>
>>> Sure, we could.  Do we have reason to believe there's an advantage to
>>> larger sizes?
>>
>> I wouldn't think there'd be a large enough performance advantage with
>> a larger size and there'd be worse OFFLOAD_STATUS information. I'm
>> sure there is a setup cost for calling into do_splice() and the cost
>> of doing a function call but I'd like they would be small.
