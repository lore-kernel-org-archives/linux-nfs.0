Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:20774 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932222AbbBYWdE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 17:33:04 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: File Read Returns Non-existent Null Bytes
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
Date: Wed, 25 Feb 2015 17:32:49 -0500
Cc: Chris Perl <cperl@janestreet.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Message-Id: <E6147A6E-E0B4-4DB1-A35F-2EB4BC6910B0@oracle.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com> <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com> <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com> <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com> <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com> <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 25, 2015, at 4:47 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Wed, Feb 25, 2015 at 4:02 PM, Chris Perl <cperl@janestreet.com> wrote:
>>> So imagine 2 WRITE calls that are being sent to an initially empty
>>> file. One WRITE call is for offset 0, and length 4096 bytes. The
>>> second call is for offset 4096 and length 4096 bytes.
>>> Imagine now that the first WRITE gets delayed (either because the page
>>> cache isn't flushing that part of the file yet or because it gets
>>> re-ordered in the RPC layer or on the server), and the second WRITE is
>>> received and processed by the server first.
>>> Once the delayed WRITE is processed there will be data at offset 0,
>>> but until that happens, anyone reading the file on the server will see
>>> a hole of length 4096 bytes.
>>> 
>>> This kind of issue is why close-to-open cache consistency relies on
>>> only one client accessing the file on the server when it is open for
>>> writing.
>> 
>> Fair enough.  I am taking note of the fact that you said "This kind of
>> issue" implying there are probably other subtle cases I'm not thinking
>> about or that your example does not illustrate.
>> 
>> That said, in your example, there exists some moment in time when the
>> file on the server actually does have a hole in it full of 0's.  In my
>> case, the file never contains 0's.
>> 
>> To be fair, when testing with an Isilon, I can't actually inspect the
>> state of the file on the server in any meaningful way, so I can't be
>> certain that's true.  But, from the view point of the reading client
>> at the NFS layer there are never 0's read back across the wire.  I've
>> confirmed this by matching up wireshark traces while reproducing and
>> the READ reply's never contain 0's.  The 0's manifest due to reading
>> too far past where there is valid data in the page cache.
> 
> Then that could be a GETATTR or something similar extending the file
> size outside the READ rpc call. Since the pagecache data is copied to
> userspace without any locks being held, we cannot prevent that race.

FWIW it’s easy to reproduce a similar race with fsx, and I encounter
it frequently while running xfstests on fast NFS servers.

fsx invokes ftruncate following a set of asynchronous reads
(generated possibly due to readahead). The reads are started first,
then the SETATTR, but they complete out of order.

The SETATTR changes the test file’s size, and the completion
updates the file size in the client’s inode. Then the read requests
complete on the client and set the file’s size back to its old value.

All it takes is one late read completion, and the cached file size
is corrupted. fsx detects the file size mismatch and terminates the
test. The file size is corrected by a subsequent GETATTR (say, an
“ls -l” to check it after fsx has terminated).

While SETATTR blocks concurrent writes, there’s no serialization
on either the client or server to help guarantee the ordering of
SETATTR with read operations.

I’ve found a successful workaround by forcing the client to ignore
post-op attrs in read replies. A stronger solution might simply set
the “file attributes need update” flag in the inode if any file
attribute mutation is noticed during a read completion.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



