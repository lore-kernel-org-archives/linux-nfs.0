Return-Path: linux-nfs-owner@vger.kernel.org
Received: from sandeen.net ([63.231.237.45]:51809 "EHLO sandeen.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753244AbbAWU2R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jan 2015 15:28:17 -0500
Message-ID: <54C2AEE0.3090503@sandeen.net>
Date: Fri, 23 Jan 2015 14:28:16 -0600
From: Eric Sandeen <sandeen@sandeen.net>
MIME-Version: 1.0
To: Steve French <smfrench@gmail.com>
CC: fstests@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: xfstest generic/299
References: <CAH2r5mvSUc0-Z1Kn3NfowUzH1Jw4x_8UF46+uXKBPshuFkb1dw@mail.gmail.com> <54C1DDA8.5040103@sandeen.net> <CAH2r5mtL52=MYu225w5G-D8X9kAb1w0Zi-GhvOfyBzm-WVT0pQ@mail.gmail.com> <CAH2r5mvhO=7NiTLZWOqyaMfzgt2vCgVo+iuhbBbcC_P30hkbZA@mail.gmail.com>
In-Reply-To: <CAH2r5mvhO=7NiTLZWOqyaMfzgt2vCgVo+iuhbBbcC_P30hkbZA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1/23/15 2:17 PM, Steve French wrote:
> On Fri, Jan 23, 2015 at 2:09 PM, Steve French <smfrench@gmail.com> wrote:
>> On Thu, Jan 22, 2015 at 11:35 PM, Eric Sandeen <sandeen@sandeen.net> wrote:
>>> On 1/22/15 11:23 PM, Steve French wrote:
>>>> Noticed test generic/299 failing over NFS (v4.1 dialect) with the error
>>>>
>>>> "[not run] /usr/bin/fio too old"
>>>>
>>>> fio-2.1.11 version (which is what is installed on current Ubuntu) is
>>>> presumably not too old
>>>
>>> Well, 2.1.11 was released 16-Jul-2014
>>>
>>> fio is up to 2.2.5 now, so it sure could be.
>>
>> I updated to 2.2.5-3 (cloning and building from the repository on
>> git.kernel.org) which did not seem to change the results.
>>
>>> The test sets up a config file, and tries to run fio against it;
>>> if it fails, it's deemed "too old"
>>>
>>> And _require_fio dumps to $seqres.full,
>>>
>>>         $FIO_PROG --warnings-fatal --showcmd $job >> $seqres.full 2>&1
>>>         [ $? -eq 0 ] || _notrun "$FIO_PROG too old, see $seqres.full"
>>>
>>> so what does 299.full look like?
>>
>> min value out of range: 0 (1 min)
>> fio: failed parsing filesize=0
>> fio: job global dropped
>> fio --ioengine=libaio --bs=128k --directory=/mnt1/scratch --size=999G
>> --iodepth=128*1 --continue_on_error=write --ignore_error=,ENOSPC
>> --error_dump=0 --create_on_open=1 --fallocate=none --exitall=1
>>
> 
> Manually setting FILE_SIZE=262144  in tests/generic/299 got it
> past that point (I wonder if BLOCK_SIZE is not set - where
> does it get set?).
> 
> But since it then call xfs_io falloc it is not going to work over NFSv4.1

ok, then it should have a requirement on falloc...
which it does ...

_require_fio $fio_config
_require_xfs_io_command "falloc"

so it'll gracefully _notrun due to either of those, as it should, apparently.
I'd swap the two _requires, the falloc _notrun message will make more sense
than the _require_fio notrun message, and save future NFS users the
head-scratching you've suffered through.  :)


-Eric

