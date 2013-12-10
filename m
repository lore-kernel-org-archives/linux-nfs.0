Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:29325 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814Ab3LJA4Z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Dec 2013 19:56:25 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: NFS file size anomaly?
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <9FBE3B61-C265-460A-A92E-A4DFE8D27114@oracle.com>
Date: Mon, 9 Dec 2013 19:56:16 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <4233F512-B1BB-4DEA-91B9-6B2566A02AC8@oracle.com>
References: <3a1854bb-6a06-4924-810a-aa8ba69f642b@default> <9FBE3B61-C265-460A-A92E-A4DFE8D27114@oracle.com>
To: Jan Kara <jack@suse.cz>, Dan Duval <dan.duval@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 9, 2013, at 4:05 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> Copying Trond's new work address.
> 
> 
> Begin forwarded message:
> 
>> From: Dan Duval <dan.duval@oracle.com>
>> Subject: NFS file size anomaly?
>> Date: December 9, 2013 3:04:27 PM EST
>> To: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Cc: <linux-nfs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
>> 
>> [NOTE: cross-posted to linux-nfs and linux-fsdevel]
>> 
>> I'm seeing some unexpected behavior with NFS and file sizes.
>> 
>> The test cases are from the LTP (Linux Test Project), tests
>> ftest01, ftest05, and ftest07.  I'll concentrate on ftest01
>> to explain what I've found.
>> 
>> ftest01 fires off 5 subprocesses, each of which opens an empty
>> file and does the following, repeatedly:
>> 
>>       . lseek to some point in the file
>>       . read 2048 bytes
>>       . lseek back to the same point
>>       . write 2048 bytes
>> 
>> The "point in the file" is determined by a pseudo-random
>> sequence.  All such points are on 2048-byte boundaries.
>> 
>> Occasionally, also driven pseudo-randomly, ftest01 will throw
>> in a call to ftruncate(), truncate(), sync(), or fstat().
>> 
>> With the fstat() calls, the returned .st_size is compared
>> with the test's expected size for the file, and an error is
>> declared if they don't match.
>> 
>> What's happening is that, some way into the test, this fstat()
>> check is failing.  Specifically, the .st_size reported by
>> fstat() is greater than the computed size.
>> 
>> The sequence of operations leading up to this is:
>> 
>>       lseek 1034240 0
>>       read 2048
>>       lseek 0 1
>>       write 2048
>> 
>>       lseek 638976 0
>>       (read, lseek, write)
>> 
>>       lseek 708608 0
>>       (read, lseek, write)
>> 
>>       lseek 708608 0
>>       (read, lseek, write)
>> 
>>       lseek 679584 0
>>       (read, lseek, write)
>> 
>>       truncate 266240
>> 
>>       lseek 960512 0
>>       (read, lseek, write)
>> 
>>       (a bunch of lseek/read/lseek/write ops that do not
>>        extend the file)
>> 
>>       fstat
>> 
>> So the expected size of the file is 960512 + 2048 == 960560.
>> But the fstat reports a size of 1036288.
>> 
>> A look at what's happening on the wire, distilled from the
>> output of tethereal, is instructive.
>> 
>>       READ Call 638976 4096 (byte offset and size to read)
>>       READ Reply 4096 995382 (bytes read and current file size)
>> 
>>       SETATTR Call 266240 (this corresponds to the truncate() call)
>> 
>>       WRITE Call 638976 4096 (byte offset and size to write)
>>       WRITE Call 708608 4096
>>       WRITE Call 1032192 4096
>> 
>>       SETATTR Reply 266240 (current size of file)
>> 
>>       WRITE Reply 643072 (current size of file after write)
>>       WRITE Reply 1036288
>>       WRITE Reply 1036288
>> 
>>       GETATTR (initiated internally by NFS code?)
>> 
>>       READ Call 958464 4096 READ Reply 4096 1036288
>> 
>>       ... (a bunch of READ and WRITE ops that do not extend the file)
>> 
>>       GETATTR Call (this corresponds to the fstat() call)
>>       GETATTR Reply 1036288
>> 
>> So what appears to have happened here is that three of the
>> WRITE operations that the program issued before the truncate()
>> call have "bled past" the SETATTR, extending the file further
>> than the SETATTR did.  Since none of the operations issued
>> after SETATTR extends the file further, by the time we get to
>> the GETATTR, the file is larger than the test expects.
>> 
>> There are two strange things going on here.  The first,
>> identified above, is that write()s that were initiated before
>> the truncate() call are being processed after the resulting
>> SETATTR call.  The second is that WRITE operations are being
>> initiated while the SETATTR is outstanding.
>> 
>> It seems to me that a size-changing SETATTR operation should
>> act essentially as an I/O barrier. It should wait for all outstanding
>> read/write requests to complete, then issue the SETATTR,
>> wait for the reply, and only then re-enable read/write requests.
>> 
>> In other words, SETATTR should be atomic with respect to other
>> I/O operations.

nfs_setattr() relies on writeback_single_inode() [ via nfs_setattr() -> nfs_wb_all() -> sync_inode() -> writeback_single_inode() ] to serialize itself with other pending I/O operations.  The NFS client already treats SETATTR as an I/O barrier. 

>> A git bisect indicates that this problem first appeared (or
>> was first uncovered) with this commit:
>> 
>>   4f8ad65 writeback: Refactor writeback_single_inode()
>> 
>> It continues to the most recent mainline kernels.
>> 
>> NFS v3 vs. v4 doesn't seem to matter.
>> 
>> Has anyone else seen this?  Any pointers you can provide?

After commit 4f8ad65, writeback_single_inode() occasionally returns immediately instead of waiting for writeback to finish.  The behavior would be difficult or impossible to spot with a local filesystem, but with NFS, a race is clearly exposed.

Jan, as author of commit 4f8ad65, can you comment on this?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




