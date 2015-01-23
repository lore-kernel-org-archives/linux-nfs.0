Return-Path: linux-nfs-owner@vger.kernel.org
Received: from sandeen.net ([63.231.237.45]:51755 "EHLO sandeen.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755381AbbAWUZU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jan 2015 15:25:20 -0500
Message-ID: <54C2AE2E.2040906@sandeen.net>
Date: Fri, 23 Jan 2015 14:25:18 -0600
From: Eric Sandeen <sandeen@sandeen.net>
MIME-Version: 1.0
To: Steve French <smfrench@gmail.com>
CC: fstests@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: xfstest generic/299
References: <CAH2r5mvSUc0-Z1Kn3NfowUzH1Jw4x_8UF46+uXKBPshuFkb1dw@mail.gmail.com> <54C1DDA8.5040103@sandeen.net> <CAH2r5mtL52=MYu225w5G-D8X9kAb1w0Zi-GhvOfyBzm-WVT0pQ@mail.gmail.com>
In-Reply-To: <CAH2r5mtL52=MYu225w5G-D8X9kAb1w0Zi-GhvOfyBzm-WVT0pQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/23/15 2:09 PM, Steve French wrote:
> On Thu, Jan 22, 2015 at 11:35 PM, Eric Sandeen <sandeen@sandeen.net> wrote:
>> On 1/22/15 11:23 PM, Steve French wrote:
>>> Noticed test generic/299 failing over NFS (v4.1 dialect) with the error
>>>
>>> "[not run] /usr/bin/fio too old"
>>>
>>> fio-2.1.11 version (which is what is installed on current Ubuntu) is
>>> presumably not too old
>>
>> Well, 2.1.11 was released 16-Jul-2014
>>
>> fio is up to 2.2.5 now, so it sure could be.
> 
> I updated to 2.2.5-3 (cloning and building from the repository on
> git.kernel.org) which did not seem to change the results.
> 
>> The test sets up a config file, and tries to run fio against it;
>> if it fails, it's deemed "too old"
>>
>> And _require_fio dumps to $seqres.full,
>>
>>         $FIO_PROG --warnings-fatal --showcmd $job >> $seqres.full 2>&1
>>         [ $? -eq 0 ] || _notrun "$FIO_PROG too old, see $seqres.full"
>>
>> so what does 299.full look like?

so it's telling you:

> min value out of range: 0 (1 min)
> fio: failed parsing filesize=0
                      ^^^^^^^^^^

and if we read the test:

BLK_DEV_SIZE=`blockdev --getsz $SCRATCH_DEV`
FILE_SIZE=$((BLK_DEV_SIZE * 512))

cat >$fio_config <<EOF
###########
# $seq test fio activity
# Filenames derived from jobsname and jobid like follows:
# ${JOB_NAME}.${JOB_ID}.${ITERATION_ID}
[global]
ioengine=libaio
bs=128k
directory=${SCRATCH_MNT}
filesize=${FILE_SIZE}
^^^^^^^^^^^^^^^^^^^^^
...

since you have no block device for NFS, blockdev will fail,
and you won't get a block dev size, so you won't get a file size,
and the fio test won't work.

The script not catching this looks like a bug.

fio saying "too old" looks inaccurate.

You could fix it to DTRT on NFS somehow, or catch the fact that
the blockdev command fails (probably because $SCRATCH_DEV isn't
set?) and _notrun the test.

I imagine it could be fixed, though; df total space available on
$SCRATCH_MNT might do as well as blockdev --getsz, though I'm not
100% sure.

-Eric
