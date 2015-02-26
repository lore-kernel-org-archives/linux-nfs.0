Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:28891 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754058AbbBZTAe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2015 14:00:34 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: fsx size error (was: File Read Returns Non-existent Null Bytes)
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtRAYQu8yaXORseCquO9JyWfXhkYYVx4MhM-sZXDChWiGg@mail.gmail.com>
Date: Thu, 26 Feb 2015 14:00:24 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1DD59CAE-F2C8-45D3-9613-908064D8E476@oracle.com>
References: <1424914057.41161.8.camel@primarydata.com> <1DA1252F-8D1D-4A77-BF8B-51B8AD30975A@oracle.com> <CAHQdGtRAYQu8yaXORseCquO9JyWfXhkYYVx4MhM-sZXDChWiGg@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 26, 2015, at 12:27 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Thu, Feb 26, 2015 at 11:26 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> I’m breaking this into a separate thread, since you correctly
>> pointed out that this is not the same problem that Chris sees.
>> 
>> Begin forwarded message:
>> 
>>> From: Trond Myklebust <trond.myklebust@primarydata.com>
>>> Subject: Re: File Read Returns Non-existent Null Bytes
>>> Date: February 25, 2015 at 8:27:37 PM EST
>>> To: Chuck Lever <chuck.lever@oracle.com>
>>> Cc: Chris Perl <cperl@janestreet.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, Chris Perl <chris.perl@gmail.com>
>>> 
>>> On Wed, 2015-02-25 at 19:43 -0500, Trond Myklebust wrote:
>>>> On Wed, 2015-02-25 at 19:37 -0500, Trond Myklebust wrote:
>>>>> On Wed, 2015-02-25 at 17:32 -0500, Chuck Lever wrote:
>>>>>> FWIW it’s easy to reproduce a similar race with fsx, and I encounter
>>>>>> it frequently while running xfstests on fast NFS servers.
>>>>>> 
>>>>>> fsx invokes ftruncate following a set of asynchronous reads
>>>>>> (generated possibly due to readahead). The reads are started first,
>>>>>> then the SETATTR, but they complete out of order.
>>>>>> 
>>>>>> The SETATTR changes the test file’s size, and the completion
>>>>>> updates the file size in the client’s inode. Then the read requests
>>>>>> complete on the client and set the file’s size back to its old value.
>>>>>> 
>>>>>> All it takes is one late read completion, and the cached file size
>>>>>> is corrupted. fsx detects the file size mismatch and terminates the
>>>>>> test. The file size is corrected by a subsequent GETATTR (say, an
>>>>>> “ls -l” to check it after fsx has terminated).
>>>>>> 
>>>>>> While SETATTR blocks concurrent writes, there’s no serialization
>>>>>> on either the client or server to help guarantee the ordering of
>>>>>> SETATTR with read operations.
>>>>>> 
>>>>>> I’ve found a successful workaround by forcing the client to ignore
>>>>>> post-op attrs in read replies. A stronger solution might simply set
>>>>>> the “file attributes need update” flag in the inode if any file
>>>>>> attribute mutation is noticed during a read completion.
>>>>> 
>>>>> That's different. We definitely should aim to fix this kind of issue
>>>>> since you are talking about a single client being the only thing
>>>>> accessing the file on the server.
>>>>> How about the following patch?
>>>> 
>>>> Let me retry without the typos. The following will actually
>>>> compile... :-/
>>> 
>>> Third version: this contains a minor optimisation so that we don't force
>>> the re-read of the last page in the file. Also a little more detail in
>>> the changelog.
>> 
>> Test results:
>> 
>> generic/127 74s ... - output mismatch (see /home/cel/src/xfstests/results//generic/127.out.bad)
>>    --- tests/generic/127.out   2014-02-13 15:40:45.202103271 -0500
>>    +++ /home/cel/src/xfstests/results//generic/127.out.bad     2015-02-26 10:46:24.284735977 -0500
>>    @@ -4,7 +4,10011 @@
>>     === FSX Light Mode, Memory Mapping ===
>>     All operations completed A-OK!
>>     === FSX Standard Mode, No Memory Mapping ===
>>    -All operations completed A-OK!
>>    +ltp/fsx -q -l 262144 -o 65536 -S 191110531 -N 100000 -R -W fsx_std_nommap
>>    +Size error: expected 0x36f6f stat 0x3e67a seek 0x3e67a
>>    +LOG DUMP (83542 total operations):
>>    ...
>>    (Run 'diff -u tests/generic/127.out /home/cel/src/xfstests/results//generic/127.out.bad'  to see the entire diff)
>> 
>> This happens when the server exports a tmpfs, for example, which
>> mimics the performance characteristics of an NVM-based filesystem.
>> Otherwise, SETATTR will be slow and the race is typically avoided.
>> Well, that’s my theory, anyway.
>> 
>> 
>>> 8<--------------------------------------------------------------------
>>> From d2c822d64a68542665e4887b4d7bccd6e8e3a741 Mon Sep 17 00:00:00 2001
>>> From: Trond Myklebust <trond.myklebust@primarydata.com>
>>> Date: Wed, 25 Feb 2015 19:26:28 -0500
>>> Subject: [PATCH] NFS: Quiesce reads before updating the file size after
>>> truncating
>>> 
>>> Chuck Lever reports seeing readaheads racing with truncate operations
>>> and causing the file size to be reverted. Fix is to quiesce reads
>>> after truncating the file on the server, but before updating the
>>> size on the client.
>>> 
>>> Note:
>>> 
>>> 1) We believe that waiting for those reads that lie outside the new
>>> file boundaries is sufficient, since this means any attempt to read
>>> the data in those areas will trigger a new RPC call, which will be
>>> ordered w.r.t.  the size change on the server.
>> 
>> Certainly reads outside the new file size have _data_ that can
>> be discarded.
>> 
>> But in this case: The server processes the operations in the order
>> the client sent them. The READs first, then the SETATTR. That’s why
>> the READ replies still have the old file size.
>> 
>> But queuing on the server causes the replies to be returned to the
>> client out of order. The client applies the post-op attributes in
>> that order, and the old file size replaces the new size.
>> 
>> Therefore I think _any_ READ that is performed on the server before
>> the SETATTR, but completes on the client after the SETATTR, will
>> poison the file’s attribute cache on the client.
>> 
> 
> Why doesn't our usual trick of using the ctime to discriminate between
> older and newer file sizes work here? Is the problem that the
> resolution is insufficient?

I’m not sure. These operations can occur during the same
millisecond, so it is plausible there’s a timestamp resolution
issue.

Or the server doesn’t return pre-op attrs.

Timestamp is more likely, though: I have seen this issue occur
on NFSv4 as well.

> The alternative would be to add a "barrier" operation to allow the
> setattr code to wait for all RPC calls before ours to complete (it
> would have to wait not just for READ, but also GETATTR and all other
> operations to the file). We could do that too.

Yes. A barrier is usually heavyweight, though. And I thought there
was some exclusion between GETATTR and SETATTR, so forcing an
inode revalidation should work too? Or would that result in an
unneeded data cache invalidation?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



