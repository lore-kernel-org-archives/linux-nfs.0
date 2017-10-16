Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f178.google.com ([209.85.217.178]:56655 "EHLO
        mail-ua0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755795AbdJPTZU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Oct 2017 15:25:20 -0400
Received: by mail-ua0-f178.google.com with SMTP id n22so10449000uaj.13
        for <linux-nfs@vger.kernel.org>; Mon, 16 Oct 2017 12:25:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171016164935.GD19720@parsley.fieldses.org>
References: <20171013205412.65532-1-kolga@netapp.com> <20171013212626.GB28854@parsley.fieldses.org>
 <CAN-5tyETeVgOWKeFSBxQBJi6wwXTcgQqaxxLn0BFXCTCv09h0g@mail.gmail.com>
 <b4f0f30e-c19e-1b2f-7379-d859b4b5ff49@Netapp.com> <20171016164935.GD19720@parsley.fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 16 Oct 2017 15:25:19 -0400
Message-ID: <CAN-5tyG74LpQytszp0k_+gCZN-1D_fCUeS=KHD9ggcCOrKfCxQ@mail.gmail.com>
Subject: Re: [PATCH v5 00/10] NFSD support for asynchronous COPY
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 16, 2017 at 12:49 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> On Mon, Oct 16, 2017 at 09:13:20AM -0400, Anna Schumaker wrote:
>>
>>
>> On 10/13/2017 08:09 PM, Olga Kornievskaia wrote:
>> > On Fri, Oct 13, 2017 at 5:26 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>> >> On Fri, Oct 13, 2017 at 04:54:02PM -0400, Olga Kornievskaia wrote:
>> >>> To do asynchronous copies, NFSD creates a new kthread to handle the request.
>> >>> Upon receiving the COPY, it generates a unique copy stateid (stored in a
>> >>> global list for keeping track of state for OFFLOAD_STATUS to be queried by),
>> >>> starts the thread, and replies back to the client. nfsd4_copy arguments that
>> >>> are allocated on the stack are copies for the kthread.
>> >>>
>> >>> In the async copy handler, it calls into VFS copy_file_range() (for synch
>> >>> we keep the 4MB chunk and requested size for the async copy). If error is
>> >>> encountered it's saved but also we save the amount of data copied so far.
>> >>> Once done, the results are queued for the callback workqueue and sent via
>> >>> CB_OFFLOAD.
>> >>>
>> >>> When the server received an OFFLOAD_CANCEL, it will find the kthread running
>> >>> the copy and will send a SIGPENDING and kthread_stop() and it will interrupt
>> >>> the ongoing do_splice() and once vfs returns we are choosing not to send
>> >>> the CB_OFFLOAD back to the client.
>> >>>
>> >>> When the server receives an OFFLOAD_STATUS, it will find the kthread running
>> >>> the copy and will query the i_size_read() of the associated filehandle of
>> >>> the destination file and return the result.
>> >>
>> >> That assumes we're copying into a previously empty file?
>> >
>> > Sigh. Alright, then it's back to my original solution where I broke
>> > everything into 4MB calls and kept track of bytes copies so far.
>>
>> Do they have to be 4MB calls?  Assuming clients don't need a super-accurate results, you could probably use a larger copy size and still have decent copy performance.
>
> Sure, we could.  Do we have reason to believe there's an advantage to
> larger sizes?

I wouldn't think there'd be a large enough performance advantage with
a larger size and there'd be worse OFFLOAD_STATUS information. I'm
sure there is a setup cost for calling into do_splice() and the cost
of doing a function call but I'd like they would be small.
