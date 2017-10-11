Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:38232 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751350AbdJKQIH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Oct 2017 12:08:07 -0400
Received: by mail-vk0-f65.google.com with SMTP id d12so639918vkf.5
        for <linux-nfs@vger.kernel.org>; Wed, 11 Oct 2017 09:08:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171011151956.GE25913@fieldses.org>
References: <20170928172945.50780-1-kolga@netapp.com> <20170928172945.50780-9-kolga@netapp.com>
 <20170928183846.GG10182@parsley.fieldses.org> <CAN-5tyFfTZ=CFsyM8CWWXkGt8jvLBV+qH60Yd-X4p5ohK5pK=g@mail.gmail.com>
 <20171009155804.GA1586@parsley.fieldses.org> <CAN-5tyGO384JprQoSmwc_6LaLLHhGbYEJm8heZqSe6ChrK3BKw@mail.gmail.com>
 <20171011140740.GD25913@fieldses.org> <CAN-5tyGgwuKHBCHZg2LOhwrYSzG5W=+h_Gsch6b_5cJVjsCbOQ@mail.gmail.com>
 <20171011151956.GE25913@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 11 Oct 2017 12:08:05 -0400
Message-ID: <CAN-5tyEfNFx-=JDY9rLGOVxFqwVps754grB6RQd3=c_CrqynPw@mail.gmail.com>
Subject: Re: [PATCH v4 08/10] NFSD handle OFFLOAD_CANCEL op
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 11, 2017 at 11:19 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Oct 11, 2017 at 11:02:56AM -0400, Olga Kornievskaia wrote:
>> On Wed, Oct 11, 2017 at 10:07 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> > On Tue, Oct 10, 2017 at 05:14:29PM -0400, Olga Kornievskaia wrote:
>> >> On Mon, Oct 9, 2017 at 11:58 AM, J. Bruce Fields <bfields@redhat.com> wrote:
>> >> > On Mon, Oct 09, 2017 at 10:53:13AM -0400, Olga Kornievskaia wrote:
>> >> >> On Thu, Sep 28, 2017 at 2:38 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>> >> >> > On Thu, Sep 28, 2017 at 01:29:43PM -0400, Olga Kornievskaia wrote:
>> >> >> >> Upon receiving OFFLOAD_CANCEL search the list of copy stateids,
>> >> >> >> if found mark it cancelled. If copy has more interations to
>> >> >> >> call vfs_copy_file_range, it'll stop it. Server won't be sending
>> >> >> >> CB_OFFLOAD to the client since it received a cancel.
>> >> >> >>
>> >> >> >> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> >> >> >> ---
>> >> >> >>  fs/nfsd/nfs4proc.c  | 26 ++++++++++++++++++++++++--
>> >> >> >>  fs/nfsd/nfs4state.c | 16 ++++++++++++++++
>> >> >> >>  fs/nfsd/state.h     |  4 ++++
>> >> >> >>  3 files changed, 44 insertions(+), 2 deletions(-)
>> >> >> >>
>> >> >> >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> >> >> >> index 3cddebb..f4f3d93 100644
>> >> >> >> --- a/fs/nfsd/nfs4proc.c
>> >> >> >> +++ b/fs/nfsd/nfs4proc.c
>> >> >> >> @@ -1139,6 +1139,7 @@ static int _nfsd_copy_file_range(struct nfsd4_copy *copy)
>> >> >> >>       size_t bytes_to_copy;
>> >> >> >>       u64 src_pos = copy->cp_src_pos;
>> >> >> >>       u64 dst_pos = copy->cp_dst_pos;
>> >> >> >> +     bool cancelled = false;
>> >> >> >>
>> >> >> >>       do {
>> >> >> >>               bytes_to_copy = min_t(u64, bytes_total, MAX_RW_COUNT);
>> >> >> >> @@ -1150,7 +1151,12 @@ static int _nfsd_copy_file_range(struct nfsd4_copy *copy)
>> >> >> >>               copy->cp_res.wr_bytes_written += bytes_copied;
>> >> >> >>               src_pos += bytes_copied;
>> >> >> >>               dst_pos += bytes_copied;
>> >> >> >> -     } while (bytes_total > 0 && !copy->cp_synchronous);
>> >> >> >> +             if (!copy->cp_synchronous) {
>> >> >> >> +                     spin_lock(&copy->cps->cp_lock);
>> >> >> >> +                     cancelled = copy->cps->cp_cancelled;
>> >> >> >> +                     spin_unlock(&copy->cps->cp_lock);
>> >> >> >> +             }
>> >> >> >> +     } while (bytes_total > 0 && !copy->cp_synchronous && !cancelled);
>> >> >> >>       return bytes_copied;
>> >> >> >
>> >> >> > I'd rather we sent a signal, and then we won't need this
>> >> >> > logic--vfs_copy_range() will just return EINTR or something.
>> >> >>
>> >> >> Hi Bruce,
>> >> >>
>> >> >> Now that I've implemented using the kthread instead of the workqueue,
>> >> >> I don't see that it can provide any better  guarantee than the work
>> >> >> queue. vfs_copy_range() is not interrupted in the middle and returning
>> >> >> the EINTR. The function that runs the kthread, it has to at some point
>> >> >> call signalled()/kthread_should_stop() function to see if it was
>> >> >> signaled and use it to 'stop working instead of continuing on'.
>> >> >>
>> >> >> If I were to remove the loop and check (if signaled() ||
>> >> >> kthread_should_stop()) before and after calling the
>> >> >> vfs_copy_file_range(), the copy will either not start if the
>> >> >> OFFLOAD_CANCEL was received before copy started or the whole copy
>> >> >> would happen.
>> >> >>
>> >> >> Even with the loop, I'd be checking after every call for
>> >> >> vfs_copy_file_range() just like it was in the current version with the
>> >> >> workqueue.
>> >> >>
>> >> >> Please advise if you still want the kthread-based implementation or
>> >> >> keep the workqueue.
>> >> >
>> >> > That's interesting.
>> >> >
>> >> > To me that sounds like a bug somewhere under vfs_copy_file_range().
>> >> > splice_direct_to_actor() can do long-running copies, so it should be
>> >> > interruptible, shouldn't it?
>> >>
>> >> So I found it. Yes do_splice_direct() will react to somebody sending a
>> >> ctrl-c and will stop. It calls signal_pendning(). However, in our
>> >> case, I'm calling kthread_stop() and that sets a different flag and
>> >> one needs to also check for kthread_should_stop() as a stopping
>> >> condition. splice.c lacks that.
>> >>
>> >> I hope they can agree that it's a bug. I don't have any luck with VFS...
>> >
>> > Argh.  No, it's probably not their bug, I guess kthreads just ignore
>> > signals.  OK, I can't immediately see what the right thing to do is
>> > here....
>> >
>> > I do think we need to do something as we want to be able to interrupt
>> > and clean up copy threads when we can.
>>
>> A bug is not the right word. It would be asking them to accommodate
>> stopping to include kthread_stop condition. Why do you say kthreads
>> ignore signals? You can say that kthread_stop doesn't send a signal.
>
> I think both are true.
>
> I doubt it's reasonable to add kthread_should_stop everywhere that
> there are currently checks for signals.
>
>> Also another note, I still can't remove the loop around the call to
>> the vfs_copy_file_range() because it's not guaranteed to copy all the
>> bytes that the call asks for. The implementation of
>> vfs_copy_file_range will do_splice_direct only MAX_RW_COUNT at a time.
>> So the upper layer needs to loop to make sure it copies all the bytes.
>
> MAX_RW_COUNT is about 4 gigs.  I'm not sure if it's really a problem to
> copy only 4 gigs at a time?  But, yes, maybe the loop is still worth it.
>
>> If VFS will decide to reject the request to add kthread_should_stop to
>> their conditions, then the loop could be a way to stop every 4MB.
>> Copying 4MB would be the equivalent of what the current synchronous
>> copy does now anyway?
>
> I'm still a little worried about copy threads hanging indefinitely if
> the peer goes away mid-copy.  The ability to signal the copy thread
> would help.

So I don't know if this is ok or not but I can directly set the
SIGPENDING bit in the copy task structure from the OFFLOAD_CANCEL
thread and that stops the splice copy too.

>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
