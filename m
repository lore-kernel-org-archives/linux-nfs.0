Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36022 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751689AbdI1QTL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Sep 2017 12:19:11 -0400
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [RFC PATCH manpages] write.2, fsync.2, close.2: update
 description of error codes
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
References: <20170720194227.7830-1-jlayton@kernel.org>
 <1503683981.22608.0.camel@redhat.com>
 <87h8wsiog4.fsf@notabene.neil.brown.name>
 <1503920855.4563.12.camel@redhat.com>
 <87pobfgo9q.fsf@notabene.neil.brown.name>
 <1504004058.4679.7.camel@redhat.com>
 <87efrjb2mn.fsf@notabene.neil.brown.name>
 <1504784132.4954.12.camel@redhat.com>
 <1504796087.3561.7.camel@primarydata.com>
 <874ls9diij.fsf@notabene.neil.brown.name>
 <1505126785.4916.7.camel@redhat.com>
 <87poawc390.fsf@notabene.neil.brown.name>
 <1505229616.28831.26.camel@redhat.com>
 <87efrbbne1.fsf@notabene.neil.brown.name>
 <1505305391.4822.13.camel@redhat.com>
 <87ingm9n04.fsf@notabene.neil.brown.name>
 <1505386139.4870.10.camel@redhat.com>
 <87fub75xxr.fsf@notabene.neil.brown.name>
From: "Michael Kerrisk (man-opages)" <mtk.manpages@gmail.com>
Message-ID: <97a7dd08-d736-cf83-052e-af4fb6596a02@gmail.com>
Date: Thu, 28 Sep 2017 18:19:06 +0200
MIME-Version: 1.0
In-Reply-To: <87fub75xxr.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

On 09/28/2017 05:01 AM, NeilBrown wrote:
> On Thu, Sep 14 2017, Jeff Layton wrote:
> 
>>>   .TP
>>>   .B EIO
>>> -An error occurred during synchronization.
>>> +An error occurred during synchronization.  This error may relate
>>> +to data written to some other file descriptor on the same file.
>>> +.\" commit 088737f44bbf6378745f5b57b035e57ee3dc4750
>>> +Since Linux 4.13 errors from write-back will be reported to
>>> +all file descriptors that might have written the data which triggered
>>> +the error, and which are still open.
>>
>> This is a little awkward. How could we report to a fd that was no longer
>> open? How about:
>>
>> "Since Linux 4.13, errors from write-back will be reported to all file
>> descriptors that were open at the time that the error was recorded."
> 
> That might be simpler, but it is less correct.  As I go on to say, NFS
> *doesn't* report on all file descriptors that were open at that time.
> 
> I've changed it to
> 
> -------------------
> Since Linux 4.13, errors from write-back will be reported to
> all file descriptors that might have written the data which triggered
> the error.  Some filesystems (e.g. NFS) keep close track of which data
> came through which file descriptor, and give precise reporting.
> Other filesystems (e.g. most local filesystems) will report errors to
> all file descriptors that where open on the file when the error was recorded.
> ------------------
> 
> which includes some of your text, and removes the "that are still open"
> which probably doesn't help.
> 
>>>   .TP
>>>   .B EIO
>>>   A low-level I/O error occurred while modifying the inode.
>>> +This error may relate to data written by an earlier
>>> +.BR write (2),
>>> +which may have been issued to a different file descriptor on
>>> +the same file.  Since Linux 4.13 errors from write-back will
>>> +be reported to all file descriptors that might have
>>> +written the data which triggered the error, and which are still
>>> +open.
>>
>>
>> This is where things get a little more vague.
>>
>> Some filesystems will return errors on a subsequent write(2) when
>> previous writeback has failed -- some don't. In either case though,
>> write(2) should never advance your errseq_t cursor, so only an fsync
>> will "clear" an earlier error.
>>
>> I'm not sure how best to convey that in the manpages though.
> 
> How about:
> 
> -------------
> This error may relate to the write-back of data written by an
> earlier
> .BR write (2),
> which may have been issued to a different file descriptor on
> the same file.  Since Linux 4.13, errors from write-back come
> with a promise that they
> .I may
> be reported by subsequent.
> .BR write (2)
> requests, and
> .I will
> be reported by a subsequent
> .BR fsync (2)
> (whether or not they were also reported by
> .BR write (2)).
> ------------
> ??
> 
> Those changes are included in the following.
> 
> Thanks,
> NeilBrown
> 
> From: NeilBrown <neilb@suse.com>
> Date: Thu, 14 Sep 2017 09:44:43 +1000
> Subject: [PATCH] write.2, fsync.2, close.2: update description of error codes
> 
> Since 4.13, errors from writeback are more reliably reported
> to all file descriptors that might be relevant.
> 
> Add notes to this effect, and also add detail about ENOSPC and EDQUOT
> which can be delayed in a similar many to EIO - for NFS in particular.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Thanks! I've applied, and added Jeff's Reviewed-by.

Cheers,

Michael


> ---
>   man2/close.2 |  9 +++++++++
>   man2/fsync.2 | 18 +++++++++++++++++-
>   man2/write.2 | 28 +++++++++++++++++++++++++---
>   3 files changed, 51 insertions(+), 4 deletions(-)
> 
> diff --git a/man2/close.2 b/man2/close.2
> index 55d89ed3dbc7..136bd0be3f67 100644
> --- a/man2/close.2
> +++ b/man2/close.2
> @@ -82,6 +82,15 @@ call was interrupted by a signal; see
>   .TP
>   .B EIO
>   An I/O error occurred.
> +.TP
> +.BR ENOSPC ", " EDQUOT
> +On NFS, these errors are not normally reported against the first write
> +which exceeds the available storage space, but instead against a
> +subsequent
> +.BR write (2),
> +.BR fsync (2),
> +or
> +.BR close (2).
>   .PP
>   See NOTES for a discussion of why
>   .BR close ()
> diff --git a/man2/fsync.2 b/man2/fsync.2
> index eed3c460bea9..c7878bf3496f 100644
> --- a/man2/fsync.2
> +++ b/man2/fsync.2
> @@ -121,7 +121,15 @@ is set appropriately.
>   is not a valid open file descriptor.
>   .TP
>   .B EIO
> -An error occurred during synchronization.
> +An error occurred during synchronization.  This error may relate
> +to data written to some other file descriptor on the same file.
> +.\" commit 088737f44bbf6378745f5b57b035e57ee3dc4750
> +Since Linux 4.13, errors from write-back will be reported to
> +all file descriptors that might have written the data which triggered
> +the error.  Some filesystems (e.g. NFS) keep close track of which data
> +came through which file descriptor, and give more precise reporting.
> +Other filesystems (e.g. most local filesystems) will report errors to
> +all file descriptors that where open on the file when the error was recorded.
>   .TP
>   .B ENOSPC
>   Disk space was exhausted while synchronizing.
> @@ -130,6 +138,14 @@ Disk space was exhausted while synchronizing.
>   .I fd
>   is bound to a special file (e.g., a pipe, FIFO, or socket)
>   which does not support synchronization.
> +.TP
> +.BR ENOSPC ", " EDQUOT
> +.I fd
> +is bound to a file on NFS or another filesystem which does not allocate
> +space at the time of a
> +.BR write (2)
> +system call, and some previous write failed due to insufficient
> +storage space.
>   .SH CONFORMING TO
>   POSIX.1-2001, POSIX.1-2008, 4.3BSD.
>   .SH AVAILABILITY
> diff --git a/man2/write.2 b/man2/write.2
> index 061aa70cf590..b1cc3a2cfb17 100644
> --- a/man2/write.2
> +++ b/man2/write.2
> @@ -47,7 +47,7 @@ write \- write to a file descriptor
>   .BR write ()
>   writes up to
>   .I count
> -bytes from the buffer pointed
> +bytes from the buffer starting at
>   .I buf
>   to the file referred to by the file descriptor
>   .IR fd .
> @@ -181,6 +181,22 @@ or the file offset is not suitably aligned.
>   .TP
>   .B EIO
>   A low-level I/O error occurred while modifying the inode.
> +This error may relate to the write-back of data written by an
> +earlier
> +.BR write (2),
> +which may have been issued to a different file descriptor on
> +the same file.  Since Linux 4.13, errors from write-back come
> +with a promise that they
> +.I may
> +be reported by subsequent.
> +.BR write (2)
> +requests, and
> +.I will
> +be reported by a subsequent
> +.BR fsync (2)
> +(whether or not they were also reported by
> +.BR write (2)).
> +.\" commit 088737f44bbf6378745f5b57b035e57ee3dc4750
>   .TP
>   .B ENOSPC
>   The device containing the file referred to by
> @@ -222,8 +238,14 @@ unsigned and signed integer data types specified by POSIX.1.
>   A successful return from
>   .BR write ()
>   does not make any guarantee that data has been committed to disk.
> -In fact, on some buggy implementations, it does not even guarantee
> -that space has successfully been reserved for the data.
> +On some filesystems, including NFS, it does not even guarantee
> +that space has successfully been reserved for the data.  In the case,
> +some errors might be delayed to a future
> +.BR write (2)
> +or to
> +.BR fsync (2)
> +or even
> +.BR close (2).
>   The only way to be sure is to call
>   .BR fsync (2)
>   after you are done writing all your data.
> 
