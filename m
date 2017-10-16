Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:27446 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751637AbdJPNNn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Oct 2017 09:13:43 -0400
Subject: Re: [PATCH v5 00/10] NFSD support for asynchronous COPY
To: Olga Kornievskaia <aglo@umich.edu>,
        "J. Bruce Fields" <bfields@redhat.com>
CC: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
References: <20171013205412.65532-1-kolga@netapp.com>
 <20171013212626.GB28854@parsley.fieldses.org>
 <CAN-5tyETeVgOWKeFSBxQBJi6wwXTcgQqaxxLn0BFXCTCv09h0g@mail.gmail.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <b4f0f30e-c19e-1b2f-7379-d859b4b5ff49@Netapp.com>
Date: Mon, 16 Oct 2017 09:13:20 -0400
MIME-Version: 1.0
In-Reply-To: <CAN-5tyETeVgOWKeFSBxQBJi6wwXTcgQqaxxLn0BFXCTCv09h0g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/13/2017 08:09 PM, Olga Kornievskaia wrote:
> On Fri, Oct 13, 2017 at 5:26 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>> On Fri, Oct 13, 2017 at 04:54:02PM -0400, Olga Kornievskaia wrote:
>>> To do asynchronous copies, NFSD creates a new kthread to handle the request.
>>> Upon receiving the COPY, it generates a unique copy stateid (stored in a
>>> global list for keeping track of state for OFFLOAD_STATUS to be queried by),
>>> starts the thread, and replies back to the client. nfsd4_copy arguments that
>>> are allocated on the stack are copies for the kthread.
>>>
>>> In the async copy handler, it calls into VFS copy_file_range() (for synch
>>> we keep the 4MB chunk and requested size for the async copy). If error is
>>> encountered it's saved but also we save the amount of data copied so far.
>>> Once done, the results are queued for the callback workqueue and sent via
>>> CB_OFFLOAD.
>>>
>>> When the server received an OFFLOAD_CANCEL, it will find the kthread running
>>> the copy and will send a SIGPENDING and kthread_stop() and it will interrupt
>>> the ongoing do_splice() and once vfs returns we are choosing not to send
>>> the CB_OFFLOAD back to the client.
>>>
>>> When the server receives an OFFLOAD_STATUS, it will find the kthread running
>>> the copy and will query the i_size_read() of the associated filehandle of
>>> the destination file and return the result.
>>
>> That assumes we're copying into a previously empty file?
> 
> Sigh. Alright, then it's back to my original solution where I broke
> everything into 4MB calls and kept track of bytes copies so far.

Do they have to be 4MB calls?  Assuming clients don't need a super-accurate results, you could probably use a larger copy size and still have decent copy performance.

> 
>>
>> --b.
>>
>>>
>>> v5:
>>> 1. reimplementing asynchronous copy to use kthreads instead of the workqueue
>>> 2. store asynchronous copies in the list of the nfs4_client structure
>>> 3. when copying nfsd4_copy datastructure for the async copy refcount the
>>> nfs4_client structure as well as struct file src/dst structure
>>> 4. add refcount to the nfsd4_copy structure to coordinate with offload_status
>>> and offload_cancel
>>> 5. offload_cancel/copy_shutdown sets the SIGPENDING in the copy's thread to
>>> interrupt do_splice and calls kthread_stop to wait for the copy to stop
>>> 6. offload_cancel adds MODIFIES_SOMETHING to flags
>>> 7. offload_status reports the size of the destination file form i_size_read()
>>> instead of before 4MB loop updated chunk size.
>>> 8. for async copy call vfs_copy_file_range() with the whole copy size. still
>>> keep the loop to do more the MAX_RW_COUNT that do_splice can do.
>>>
>>> Olga Kornievskaia (10):
>>>   NFSD CB_OFFLOAD xdr
>>>   NFSD OFFLOAD_STATUS xdr
>>>   NFSD OFFLOAD_CANCEL xdr
>>>   NFSD xdr callback stateid in async COPY reply
>>>   NFSD first draft of async copy
>>>   NFSD return nfs4_stid in nfs4_preprocess_stateid_op
>>>   NFSD create new stateid for async copy
>>>   NFSD handle OFFLOAD_CANCEL op
>>>   NFSD support OFFLOAD_STATUS
>>>   NFSD stop queued async copies on client shutdown
>>>
>>>  fs/nfsd/netns.h        |   8 ++
>>>  fs/nfsd/nfs4callback.c |  97 +++++++++++++++
>>>  fs/nfsd/nfs4proc.c     | 321 ++++++++++++++++++++++++++++++++++++++++++++-----
>>>  fs/nfsd/nfs4state.c    |  77 +++++++++++-
>>>  fs/nfsd/nfs4xdr.c      |  50 ++++++--
>>>  fs/nfsd/nfsctl.c       |   1 +
>>>  fs/nfsd/state.h        |  21 +++-
>>>  fs/nfsd/xdr4.h         |  28 +++++
>>>  fs/nfsd/xdr4cb.h       |  10 ++
>>>  9 files changed, 576 insertions(+), 37 deletions(-)
>>>
>>> --
>>> 1.8.3.1
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
