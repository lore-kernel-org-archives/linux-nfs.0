Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:51946 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbaJOOwF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Oct 2014 10:52:05 -0400
Received: by mail-qg0-f53.google.com with SMTP id q107so1013397qgd.12
        for <linux-nfs@vger.kernel.org>; Wed, 15 Oct 2014 07:52:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141015132620.GB10652@infradead.org>
References: <20140917181619.GA31483@infradead.org> <CAH2r5mutD=JzAf0whP2OLgZVzBR_H81-rzmq_Qku2fEBofR9mA@mail.gmail.com>
 <20141015132620.GB10652@infradead.org>
From: Steve French <smfrench@gmail.com>
Date: Wed, 15 Oct 2014 09:51:42 -0500
Message-ID: <CAH2r5mvhubJm3Yaab4roBo36pFcwtW6Y7uP-rU3z_oE4SCJUnQ@mail.gmail.com>
Subject: Re: NFSv4.1 xfstests results
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna.Schumaker@netapp.com,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 15, 2014 at 8:26 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Oct 14, 2014 at 07:49:10PM -0500, Steve French wrote:
>> Is the test 35 failure (overwriting rename syscall test) expected (it
>> wasn't in Christoph's original list)? and the test 11 failure expected
>> (which failed on NFSv4 only)?
>>
>> Test 35 output:
>>     --- tests/generic/035.out 2014-10-14 16:59:22.237529380 -0500
>>     +++ /home/sfrench/xfstests/results//NFSv41/generic/035.out.bad
>> 2014-10-14 18:52:51.523146653 -0500
>>     @@ -1,3 +1,6 @@
>>      QA output created by 035
>>      overwriting regular file:
>>     +./tests/generic/035: line 57: src/t_rename_overwrite: No such
>> file or directory
>
> Looks like you didn't run a make to build that new testcase.

You are right, despite it being a low numbered test, it is new.  After
rebuilding it still fails on v3/v4/v4.1

SECTION       -- NFSv3
FSTYP         -- nfs
PLATFORM      -- Linux/x86_64 ubuntu 3.17.0+

generic/035 - output mismatch (see
/home/sfrench/xfstests/results//NFSv3/generic/035.out.bad)
    --- tests/generic/035.out 2014-10-14 16:59:22.237529380 -0500
    +++ /home/sfrench/xfstests/results//NFSv3/generic/035.out.bad
2014-10-15 06:50:41.149755964 -0500
    @@ -1,3 +1,5 @@
     QA output created by 035
     overwriting regular file:
    +nlink is 1, should be 0
     overwriting directory:
    +t_rename_overwrite: fstat(3): Stale file handle
    ...
    (Run 'diff -u tests/generic/035.out
/home/sfrench/xfstests/results//NFSv3/generic/035.out.bad'  to see the
entire diff)
Ran: generic/035
Failures: generic/035
Failed 1 of 1 tests





-- 
Thanks,

Steve
